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

@implementation USParser
-(id)initWithURL:(NSURL *)anURL
{
	if((self = [super init]))
	{
		baseURL = [anURL retain];
	}
	
	return self;
}

-(void)dealloc
{
	if(baseURL != nil) [baseURL release];
	[super dealloc];
}

-(USWSDL*)parse
{
	NSError *error;
	
	NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:baseURL options:NSXMLNodeOptionsNone error:&error];
	
	if(error) {
		NSLog(@"%@", error);
		return nil;
	}
	
	NSXMLElement *definitions = [document rootElement];
	
	if([[definitions localName] isNotEqualTo:@"definitions"]) {
		NSLog(@"Expected element named definitions, found %@", [definitions name]);
		return nil;
	}
	
	USWSDL *wsdl = [[USWSDL new] autorelease];
	[wsdl addXSDSchema];
	
	[self processDefinitionsElement:definitions wsdl:wsdl];
	
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
	
	if(schemaLocation == nil) return;
	
	NSURL *location = [NSURL URLWithString:schemaLocation relativeToURL:baseURL];
	
	NSError *error;
	NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:location options:NSXMLNodeOptionsNone error:&error];
	
	if(error) {
		NSLog(@"%@", error);
		return;
	}
	
	NSXMLElement *schemaElement = [document rootElement];
	
	if([[schemaElement localName] isNotEqualTo:@"schema"]) {
		NSLog(@"During import, expected element named schema, found %@", [schemaElement name]);
		return;
	}
	
	[self processSchemaElement:schemaElement wsdl:wsdl];
}

- (void)processSchemaElement:(NSXMLElement *)el wsdl:(USWSDL *)wsdl
{
	NSString *schemaNamespace = [[el attributeForName:@"targetNamespace"] stringValue];
	
	USSchema *schema = [wsdl schemaForNamespace:schemaNamespace];
	NSString *prefix = [el resolvePrefixForNamespaceURI:schemaNamespace];
	if(prefix != nil) schema.prefix = prefix;
	
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
}

- (void)processNamespace:(NSXMLNode *)ns wsdl:(USWSDL *)wsdl
{
	NSString *uri = [ns stringValue];
	NSString *prefix = [ns localName];
	
	if(prefix != nil && [prefix isNotEqualTo:@"xmlns"]) {
		if([wsdl existingSchemaForPrefix:prefix] == nil) {
			USSchema *schema = [wsdl schemaForNamespace:uri];
			schema.prefix = prefix;
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
