/*
 Copyright (c) 2008 LightSPEED Technologies, Inc.
 Modified by Matthew Faupel on 2009-05-06 to use NSDate instead of NSCalendarDate (for iPhone compatibility).
 Modifications copyright (c) 2009 Micropraxis Ltd.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "USWriter.h"
#import "STSTemplateEngine.h"
#import "USSchema.h"
#import "USType.h"
#import "USSequenceElement.h"
#import "USAttribute.h"
#import "USService.h"
#import "USBinding.h"
#import "USPort.h"
#import "NSBundle+USAdditions.h"

@interface USWriter (PrivateMethods)

- (BOOL)writeSchemas;
- (void)generateSchemaPrefixes;
- (BOOL)generatePrefixForSchema:(USSchema *)schema nsNum:(int*)nsNum;
- (void)doWriteSchema:(USSchema *)schema;
- (void)appendType:(USType *)type toHString:(NSMutableString *)hString mString:(NSMutableString *)mString;
- (void)appendService:(USService *)service toHString:(NSMutableString *)hString mString:(NSMutableString *)mString;
- (void)appendBinding:(USBinding *)binding toHString:(NSMutableString *)hString mString:(NSMutableString *)mString;
- (void)copyStandardFilesToOutputDirectory;
- (void)writeResourceName:(NSString *)resourceName resourceType:(NSString *)resourceType toFilename:(NSString *)fileName;

@end


@implementation USWriter

@synthesize wsdl;
@synthesize outDir;

- (id)initWithWSDL:(USWSDL *)aWsdl outputDirectory:(NSURL *)anOutDir
{
	if((self = [super init])) {
		self.wsdl = aWsdl;
		self.outDir = anOutDir;
	}
	
	return self;
}

- (void) dealloc
{
    [wsdl release];
    [outDir release];
    [super dealloc];
}

- (BOOL)write;
{
	if(!wsdl) {
		NSLog(@"No WSDL");
		return NO;
	}
	
	if(![self writeSchemas]) {
		NSLog(@"Error writing schemas");
		return NO;
	}
	
	return YES;
}

- (BOOL)writeSchemas
{	
	[self generateSchemaPrefixes];
	
	for(USSchema *schema in wsdl.schemas) {
		[self doWriteSchema:schema];
	}
	
	[self copyStandardFilesToOutputDirectory];
	
	return YES;
}

- (void)generateSchemaPrefixes
{
	int nsNum = 1;
	NSMutableSet *schemasToSkip = [NSMutableSet set];
	
	for(USSchema *schema in wsdl.schemas) {
		if(schema.fullName == nil || [schema.fullName length] == 0) {
			[schemasToSkip addObject:schema];
			continue;
		}
		
		[self generatePrefixForSchema:schema nsNum:&nsNum];
	}
	
	for(USSchema *schema in schemasToSkip) {
		[wsdl.schemas removeObject:schema];
	}
}

- (BOOL)generatePrefixForSchema:(USSchema *)schema nsNum:(int*)nsNum
{
	if(schema.prefix == nil) {
		NSString *generatedPrefix = [NSString stringWithFormat:@"ns%d", (*nsNum)++];
		while([wsdl existingSchemaForPrefix:generatedPrefix] != nil) {
			generatedPrefix = [NSString stringWithFormat:@"ns%d", (*nsNum)++];
		}
		
		schema.prefix = generatedPrefix;
		return YES;
	}
	
	return NO;
}

- (void)doWriteSchema:(USSchema *)schema
{
	if(schema.hasBeenWritten == YES) return;
	if([schema shouldNotWrite]) return;
	
	schema.hasBeenWritten = YES;
	
	//Write out any imports first so they can have a prefix generated for them if needed
	for(USSchema *import in schema.imports) {
		[self doWriteSchema:import];
	}
	
	NSArray *errors;
	NSError *error;
	
	NSMutableString *hString = [NSMutableString string];
	NSMutableString *mString = [NSMutableString string];
	
	NSString *schemaHString = [[NSString stringByExpandingTemplateAtPath:[schema templateFileHPath]
														 usingDictionary:[schema templateKeyDictionary]
																encoding:NSUTF8StringEncoding
														  errorsReturned:&errors] retain];
	if(errors == nil) {
		[hString appendString:schemaHString];
	}
	
	[schemaHString release];
	
	NSString *schemaMString = [[NSString stringByExpandingTemplateAtPath:[schema templateFileMPath]
														 usingDictionary:[schema templateKeyDictionary]
																encoding:NSUTF8StringEncoding
														  errorsReturned:&errors] retain];
	
	if(errors == nil) {
		[mString appendString:schemaMString];
	}
	
	[schemaMString release];
	
	for(USType *type in schema.types) {
		[self appendType:type toHString:hString mString:mString];
	}
	
	for(USService *service in schema.services) {
		[self appendService:service toHString:hString mString:mString];
		
		for(USPort *port in service.ports) {
			[self appendBinding:port.binding toHString:hString mString:mString];
		}
	}
	
	if([hString length] > 0) {
		[hString writeToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.h", schema.prefix] relativeToURL:outDir]
				 atomically:NO
				   encoding:NSUTF8StringEncoding
					  error:&error];
		
		[mString writeToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.m", schema.prefix] relativeToURL:outDir]
				 atomically:NO
				   encoding:NSUTF8StringEncoding
					  error:&error];
	}
}

- (void)appendType:(USType *)type toHString:(NSMutableString *)hString mString:(NSMutableString *)mString
{
	if(!type || !type.hasBeenParsed) {
		NSLog(@"Type %@ was never parsed!", (type ? type.typeName : @"(null)"));
		return;
	}
	
	if(type.hasBeenWritten) return;
	type.hasBeenWritten = YES;
	if(type.behavior == TypeBehavior_simple && [type.className isEqualToString:type.representationClass]) return;
	
	if(type.superClass != nil) [self appendType:type.superClass toHString:hString mString:mString];
	
	for(USSequenceElement *seqElement in type.sequenceElements) {
		[self appendType:seqElement.type toHString:hString mString:mString];
	}
	
	for(USAttribute *attribute in type.attributes) {
		[self appendType:attribute.type toHString:hString mString:mString];
	}
	
	NSArray *errors;
	
	NSString *typeHString = [[NSString stringByExpandingTemplateAtPath:[type templateFileHPath]
													   usingDictionary:[type templateKeyDictionary]
															  encoding:NSUTF8StringEncoding
														errorsReturned:&errors] retain];
	
	if(errors == nil) {
		[hString appendString:typeHString];
	}
	
	[typeHString release];
	
	NSString *typeMString = [[NSString stringByExpandingTemplateAtPath:[type templateFileMPath]
													   usingDictionary:[type templateKeyDictionary]
															  encoding:NSUTF8StringEncoding
														errorsReturned:&errors] retain];
	
	if(errors == nil) {
		[mString appendString:typeMString];
	} else {
		NSLog(@"Errors encountered while generating implementation for type %@", type.typeName);
	}
	
	[typeMString release];	
}

- (void)appendBinding:(USBinding *)binding toHString:(NSMutableString *)hString mString:(NSMutableString *)mString
{
	NSArray *errors;
	
	NSString *bindingHString = [[NSString stringByExpandingTemplateAtPath:[binding templateFileHPath]
														  usingDictionary:[binding templateKeyDictionary]
																 encoding:NSUTF8StringEncoding
														   errorsReturned:&errors] retain];
	
	if(errors == nil) {
		[hString appendString:bindingHString];
	}
	
	[bindingHString release];
	
	NSString *bindingMString = [[NSString stringByExpandingTemplateAtPath:[binding templateFileMPath]
														  usingDictionary:[binding templateKeyDictionary]
																 encoding:NSUTF8StringEncoding
														   errorsReturned:&errors] retain];
	
	if(errors == nil) {
		[mString appendString:bindingMString];
	} else {
		NSLog(@"Errors encountered while generating implementation for binding %@", binding.name);
	}
	
	[bindingMString release];
}

- (void)appendService:(USService *)service toHString:(NSMutableString *)hString mString:(NSMutableString *)mString
{
	NSArray *errors;
	
	NSString *serviceHString = [[NSString stringByExpandingTemplateAtPath:[service templateFileHPath]
														  usingDictionary:[service templateKeyDictionary]
																 encoding:NSUTF8StringEncoding
														   errorsReturned:&errors] retain];
	
	if(errors == nil) {
		[hString appendString:serviceHString];
	}
	
	[serviceHString release];
	
	NSString *serviceMString = [[NSString stringByExpandingTemplateAtPath:[service templateFileMPath]
														  usingDictionary:[service templateKeyDictionary]
																 encoding:NSUTF8StringEncoding
														   errorsReturned:&errors] retain];
	
	if(errors == nil) {
		[mString appendString:serviceMString];
	} else {
		NSLog(@"Errors encountered while generating implementation for service %@", service.name);
	}
	
	[serviceMString release];
}

- (void)copyStandardFilesToOutputDirectory
{
	//Copy additions files
	[self writeResourceName:@"USAdditions_H" resourceType:@"template" toFilename:@"USAdditions.h"];
	[self writeResourceName:@"USAdditions_M" resourceType:@"template" toFilename:@"USAdditions.m"];
	
	//Copy additions dependencies
	[self writeResourceName:@"NSDate+ISO8601Parsing_H" resourceType:@"template" toFilename:@"NSDate+ISO8601Parsing.h"];
	[self writeResourceName:@"NSDate+ISO8601Parsing_M" resourceType:@"template" toFilename:@"NSDate+ISO8601Parsing.m"];
	[self writeResourceName:@"NSDate+ISO8601Unparsing_H" resourceType:@"template" toFilename:@"NSDate+ISO8601Unparsing.h"];
	[self writeResourceName:@"NSDate+ISO8601Unparsing_M" resourceType:@"template" toFilename:@"NSDate+ISO8601Unparsing.m"];
	
	//Copy globals
	[self writeResourceName:@"USGlobals_H" resourceType:@"template" toFilename:@"USGlobals.h"];
	[self writeResourceName:@"USGlobals_M" resourceType:@"template" toFilename:@"USGlobals.m"];
}

- (void)writeResourceName:(NSString *)resourceName resourceType:(NSString *)resourceType toFilename:(NSString *)fileName
{
	NSString *resourceContents;
    
    if([resourceType isEqualToString:@"template"]){
        resourceContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForTemplateNamed:resourceName] usedEncoding:nil error:nil];
    }
    else{
        resourceContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:resourceName ofType:resourceType] usedEncoding:nil error:nil];
    }
	
	[resourceContents writeToURL:[NSURL URLWithString:fileName relativeToURL:outDir]
					  atomically:NO
						encoding:NSUTF8StringEncoding
						   error:nil];
}

@end
