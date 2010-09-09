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

#import "USParser.h"
#import "USParser+Types.h"
#import "USParser+Messages.h"
#import "USParser+PortTypes.h"
#import "USParser+Bindings.h"
#import "USParser+Services.h"

#import "USWSDL.h"
#import "USSchema.h"
#import "USType.h"
#import "USSequenceElement.h"

@implementation USParser
- (id)initWithURL:(NSURL *)anURL
{
	if((self = [super init]))
	{
		baseURL = [anURL retain];
	}
	
	return self;
}

- (void)dealloc
{
	if(baseURL != nil) [baseURL release];
	[super dealloc];
}

- (USWSDL*)parse
{
	NSError *error = nil;
	
	NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:baseURL options:NSXMLNodeOptionsNone error:&error];
	
	if(error) {
		NSLog(@"Unable to parse XML document from %@: %@", baseURL, error);
        [document release];
		return nil;
	}
	
	NSXMLElement *definitions = [document rootElement];
	
	if([[definitions localName] isNotEqualTo:@"definitions"]) {
		NSLog(@"Expected element named definitions, found %@", [definitions name]);
        [document release];
		return nil;
	}
	
	USWSDL *wsdl = [[USWSDL new] autorelease];
	[wsdl addXSDSchema];
	
	[self processDefinitionsElement:definitions wsdl:wsdl];
    [document release];
	
	return wsdl;
}

- (void)processDefinitionsElement:(NSXMLElement *)el wsdl:(USWSDL *)wsdl
{
	NSString *targetNamespace = [[el attributeForName:@"targetNamespace"] stringValue];
	USSchema *tns = [wsdl schemaForNamespace:targetNamespace];
	wsdl.targetNamespace = tns;
	tns.prefix = @"tns";
	
	for(NSXMLNode *child in [el children]) {
		if([child kind] == NSXMLElementKind) {
			[self processDefinitionsChildElement:(NSXMLElement*)child wsdl:wsdl];
		}
	}
}

- (void)processDefinitionsChildElement:(NSXMLElement *)el wsdl:(USWSDL *)wsdl
{
	NSString *localName = [el localName];
	if([localName isEqualToString:@"types"]) {
		[self processTypesElement:el wsdl:wsdl];
	} else if([localName isEqualToString:@"import"]) {
		[self processDefinitionsImportElement:el wsdl:wsdl];
	} else if([localName isEqualToString:@"message"]) {
		[self processMessageElement:el schema:wsdl.targetNamespace];
	} else if([localName isEqualToString:@"portType"]) {
		[self processPortTypeElement:el schema:wsdl.targetNamespace];
	} else if([localName isEqualToString:@"binding"]) {
		[self processBindingElement:el schema:wsdl.targetNamespace];
	} else if([localName isEqualToString:@"service"]) {
		[self processServiceElement:el schema:wsdl.targetNamespace];
	}
}

- (void)processDefinitionsImportElement:(NSXMLElement *)el wsdl:(USWSDL *)wsdl
{
	[self processImportElement:el wsdl:wsdl];
	
	NSString *namespace = [[el attributeForName:@"namespace"] stringValue];
	USSchema *importedSchema = [wsdl schemaForNamespace:namespace];
	[wsdl.targetNamespace.imports addObject:importedSchema];
}

- (void)processImportElement:(NSXMLElement *)el wsdl:(USWSDL *)wsdl
{
	NSString *schemaLocation = [[el attributeForName:@"schemaLocation"] stringValue];
	
	if (schemaLocation != nil) {
		// it's a schema import
	
		NSURL *location = [NSURL URLWithString:schemaLocation relativeToURL:baseURL];
		
		NSLog(@"Processing schema import at location: %@", location);
		
		NSError *error = nil;
		NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:location options:NSXMLNodeOptionsNone error:&error];
		
		if(error) {
            NSLog(@"Unable to parse XML document from %@ (ignored): %@", location, error);
            [document release];
			return;
		}
		
		NSXMLElement *schemaElement = [document rootElement];
		
		if([[schemaElement localName] isNotEqualTo:@"schema"]) {
			NSLog(@"During schema import, expected element named schema, found %@", [schemaElement name]);
            [document release];
			return;
		}
		
		[self processSchemaElement:schemaElement wsdl:wsdl];
        [document release];

	} else {
		// not a schema import, let's see if it's a definitions import
		NSString *definitionsLocation = [[el attributeForName:@"location"] stringValue];
		if (definitionsLocation == nil) return;
		
		NSURL *location = [NSURL URLWithString:definitionsLocation relativeToURL:baseURL];
		
		NSLog(@"Processing definitions import at location: %@", location);
		
		NSError *error = nil;
		NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:location options:NSXMLNodeOptionsNone error:&error];
		
		if(error) {
            NSLog(@"Unable to parse XML document from %@ (ignored): %@", location, error);
            [document release];
			return;
		}
		
		NSXMLElement *definitionsElement = [document rootElement];
		
		if([[definitionsElement localName] isNotEqualTo:@"definitions"]) {
			NSLog(@"During definitions import, expected element named definitions, found %@", [definitionsElement name]);
            [document release];
			return;
		}
		
		// store the original targetNamespace
		// and reset it after the processing of the new DefinitionsElement
		
		NSString *targetNamespace = [[definitionsElement attributeForName:@"targetNamespace"] stringValue];
		USSchema *tns = [wsdl schemaForNamespace:targetNamespace];
		
		USSchema *oldTargetNamespace = wsdl.targetNamespace;
		wsdl.targetNamespace = tns;
		tns.prefix = @"tns";
		
		[self processDefinitionsElement:definitionsElement wsdl:wsdl];
		wsdl.targetNamespace = oldTargetNamespace;
        [document release];
	}
}

- (void)processSchemaElement:(NSXMLElement *)el wsdl:(USWSDL *)wsdl
{
	NSString *schemaNamespace = [[el attributeForName:@"targetNamespace"] stringValue];
	
	USSchema *schema = [wsdl schemaForNamespace:schemaNamespace];
	schema.localPrefix = [el resolvePrefixForNamespaceURI:schemaNamespace];
	NSString *prefix = schema.localPrefix;
	BOOL prefixCreated = NO;
	NSUInteger i = 1;
	while (!prefixCreated) {
		if(prefix == nil) {
			schema.prefix = nil;
			prefixCreated = YES;
		} else {
			USSchema *dupeSchema = [wsdl existingSchemaForPrefix:prefix];
			if ((dupeSchema != nil) && (![dupeSchema.fullName isEqualToString:schema.fullName])) {
				// there already exists another schema for this prefix
				// let another prefix be autogenerated later for this schema
				prefix = [schema.localPrefix stringByAppendingFormat:@"%d", i++];
			} else {
				schema.prefix = prefix;
				prefixCreated = YES;
			}
		}
	}
	
	if(!schema.hasBeenParsed) {
		for(NSXMLNode *child in [el children]) {
			if([child kind] == NSXMLElementKind) {
				[self processSchemaChildElement:(NSXMLElement*)child schema:schema];
			}
		}
		for(NSXMLNode *ns in [el namespaces]) {
			[self processNamespace:ns wsdl:wsdl];
		}
		
		schema.hasBeenParsed = YES;
	}
	
	// Uncomment the below to verify that all types and attributes have been correctly parsed
	/*
#warning Debug output on
	NSLog(@"Dumping schema: %@", schema.fullName);
	NSLog(@"TYPES:");
	for (USType *aT in [schema types]) {
		NSLog(@"	+ %@ (%@, %d, %d, %@", aT.typeName, aT, aT.hasBeenParsed, [aT.enumerationValues count], [aT assignOrRetain]);
		NSLog(@"		Attributes:");
		for (USAttribute *aTA in [aT attributes]) {
			NSLog(@"		- %@ (%@)", [aTA name], [[aTA type] typeName]);
		}
		NSLog(@"		Sequence Elements:");
		for (USSequenceElement *aSE in [aT sequenceElements]) {
			NSLog(@"		- %@ (%@)", aSE.name, [[aSE type] typeName]);
		}
	}	
	NSLog(@"ELEMENTS:");
	for (USElement *aE in [schema elements]) {
		NSLog(@"	+ %@ (%@, %d)", [aE name], [[aE type] typeName], [[aE type] hasBeenParsed]);
	}
	NSLog(@"ATTRIBUTES:");
	for (USAttribute *aA in [schema attributes]) {
		NSLog(@"	+ %@ (%@, %d)", [aA name], [[aA type] typeName], [[aA type] hasBeenParsed]);
	}
	NSLog(@"Finished Dumping schema: %@", schema.fullName);*/
}

- (void)processNamespace:(NSXMLNode *)ns wsdl:(USWSDL *)wsdl
{
	NSString *uri = [ns stringValue];
	NSString *prefix = [ns localName];
	
	if(prefix != nil && [prefix isNotEqualTo:@"xmlns"]) {
		if([wsdl existingSchemaForPrefix:prefix] == nil) {
			USSchema *schema = [wsdl schemaForNamespace:uri];
			schema.prefix = [[prefix stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0 ? nil : prefix;
		}
	}
}

- (void)processSchemaChildElement:(NSXMLElement *)el schema:(USSchema *)schema
{
	NSString *localName = [el localName];
	
	if([localName isEqualToString:@"import"]) {
		[self processSchemaImportElement:el schema:schema];
	} else if([localName isEqualToString:@"simpleType"]) {
		[self processSimpleTypeElement:el schema:schema];
	} else if([localName isEqualToString:@"complexType"]) {
		[self processComplexTypeElement:el schema:schema];
	} else if([localName isEqualToString:@"element"]) {
		[self processElementElement:el schema:schema];
	} else if([localName isEqualToString:@"attribute"]) {
		[self processAttributeElement:el schema:schema type:nil];
	}
}

- (void)processSchemaImportElement:(NSXMLElement *)el schema:(USSchema *)schema
{
	[self processImportElement:el wsdl:schema.wsdl];
	
	NSString *uri = [[el attributeForName:@"namespace"] stringValue];
	USSchema *importedSchema = [schema.wsdl schemaForNamespace:uri];
	
	[schema.imports addObject:importedSchema];
}

@end
