/*
 Copyright (c) 2008 LightSPEED Technologies, Inc.
 
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

#import "USWSDL.h"
#import "USSchema.h"
#import "USType.h"
#import "USMessage.h"
#import "USPortType.h"

@implementation USWSDL

@synthesize schemas;
@synthesize targetNamespace;

-(id)init
{
	if((self = [super init]))
	{
		self.schemas = [NSMutableArray array];
		self.targetNamespace = nil;
	}
	return self;
}

-(void)dealloc
{
	[schemas release];
	[super dealloc];
}

- (USSchema *)schemaForNamespace:(NSString *)aNamespace
{
	for(USSchema *schema in self.schemas) {
		if([schema.fullName isEqualToString:aNamespace]) {
			return schema;
		}
	}
	
	USSchema *newSchema = [[[USSchema alloc] initWithWSDL:self] autorelease];
	newSchema.fullName = aNamespace;
	[self.schemas addObject:newSchema];
	
	return newSchema;
}

- (USSchema *)existingSchemaForPrefix:(NSString *)aPrefix
{
	if(aPrefix == nil) return nil;
	
	for(USSchema *schema in self.schemas) {
		if([schema.prefix isEqualToString:aPrefix]) {
			return schema;
		}
	}
	
	return nil;
}

- (USType *)typeForNamespace:(NSString *)aNamespace name:(NSString *)aName
{
	USSchema *schema = [self schemaForNamespace:aNamespace];
	
	if(schema) {
		USType *type = [schema typeForName:aName];
		return type;
	}
	
	return nil;
}

- (void)addXSDSchema
{
	USSchema *xsd = [self schemaForNamespace:@"http://www.w3.org/2001/XMLSchema"];
	xsd.prefix = @"xsd";
	
	[xsd addSimpleClassWithName:@"boolean" representationClass:@"USBoolean *"];
	[xsd addSimpleClassWithName:@"int" representationClass:@"NSNumber *"];
	[xsd addSimpleClassWithName:@"double" representationClass:@"NSNumber *"];
	[xsd addSimpleClassWithName:@"long" representationClass:@"NSNumber *"];
	[xsd addSimpleClassWithName:@"short" representationClass:@"NSNumber *"];
	[xsd addSimpleClassWithName:@"float" representationClass:@"NSNumber *"];
	[xsd addSimpleClassWithName:@"string" representationClass:@"NSString *"];
	[xsd addSimpleClassWithName:@"dateTime" representationClass:@"NSCalendarDate *"];
	[xsd addSimpleClassWithName:@"base64Binary" representationClass:@"NSData *"];
}

@end
