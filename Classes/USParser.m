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

#import "NSXMLElement+Children.h"
#import "USAttribute.h"
#import "USBinding.h"
#import "USElement.h"
#import "USMessage.h"
#import "USPortType.h"
#import "USSchema.h"
#import "USService.h"
#import "USType.h"
#import "USWSDL.h"

@interface USParser ()
@property (nonatomic, strong) NSURL *baseURL;
@end

@implementation USParser
- (id)initWithURL:(NSURL *)url {
    if ((self = [super init]))
        self.baseURL = url;
    return self;
}

- (USWSDL *)parse {
    NSError *error = nil;
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:self.baseURL
                                                                   options:NSXMLNodeOptionsNone error:&error];

    if (error) {
        NSLog(@"Unable to parse XML document from %@: %@", self.baseURL, error);
        return nil;
    }

    NSXMLElement *definitions = [document rootElement];

    if ([[definitions localName] isNotEqualTo:@"definitions"]) {
        NSLog(@"Expected element named definitions, found %@", [definitions name]);
        return nil;
    }

    USWSDL *wsdl = [USWSDL new];
    [self processDefinitionsElement:definitions wsdl:wsdl];
    return wsdl;
}

- (void)processDefinitionsElement:(NSXMLElement *)el wsdl:(USWSDL *)wsdl {
    NSString *targetNamespace = [[el attributeForName:@"targetNamespace"] stringValue];
    USSchema *schema = wsdl.schemas[targetNamespace];
    if (!schema) {
        NSString *prefix = [[[[el childElementsWithName:@"service"] firstObject] attributeForName:@"name"] stringValue];
        if (!prefix)
            prefix = [el resolvePrefixForNamespaceURI:targetNamespace];
        schema = [wsdl createSchemaForNamespace:targetNamespace prefix:prefix];
    }

    USSchema *oldTns = wsdl.targetNamespace;
    wsdl.targetNamespace = schema;

    for (NSXMLElement *child in [el childElements])
        [self processDefinitionsChildElement:child wsdl:wsdl];

    wsdl.targetNamespace = oldTns;
}

- (void)processDefinitionsChildElement:(NSXMLElement *)el wsdl:(USWSDL *)wsdl {
    USSchema *tns = wsdl.targetNamespace;
    NSString *localName = [el localName];
    if ([localName isEqualToString:@"types"]) {
        for (NSXMLElement *child in [el childElements])
            [self processTypesChildElement:child wsdl:wsdl];
    }
    else if ([localName isEqualToString:@"import"])
        [self processDefinitionsImportElement:el wsdl:wsdl];
    else if ([localName isEqualToString:@"message"])
        [tns registerMessage:[USMessage messageWithElement:el schema:tns]];
    else if ([localName isEqualToString:@"portType"])
        [tns registerPortType:[USPortType portTypeWithElement:el schema:tns]];
    else if ([localName isEqualToString:@"binding"])
        [tns registerBinding:[USBinding bindingWithElement:el schema:tns]];
    else if ([localName isEqualToString:@"service"])
        [tns registerService:[USService serviceWithElement:el schema:tns]];
}

- (void)processTypesChildElement:(NSXMLElement *)el wsdl:(USWSDL *)wsdl {
    NSString *localName = [el localName];
    if ([localName isEqualToString:@"schema"])
        [self processSchemaElement:el wsdl:wsdl];
    else if ([localName isEqualToString:@"import"])
        [self processImportElement:el wsdl:wsdl];
}

- (void)processSchemaElement:(NSXMLElement *)el wsdl:(USWSDL *)wsdl {
    NSString *targetNamespace = [[el attributeForName:@"targetNamespace"] stringValue];
    USSchema *schema = wsdl.schemas[targetNamespace];
    if (!schema) {
        if (targetNamespace) {
            NSString *prefix = [el resolvePrefixForNamespaceURI:targetNamespace] ?: @"tns";
            schema = [wsdl createSchemaForNamespace:targetNamespace prefix:prefix];
        }
        else
            schema = wsdl.targetNamespace;
    }

    for (NSXMLElement *child in [el childElements])
        [self processSchemaChildElement:child schema:schema];
    for (NSXMLNode *ns in [el namespaces]) {
        [self processNamespace:ns wsdl:wsdl];
    }

    // Uncomment the below to verify that all types and attributes have been correctly parsed
#if 0
#warning Debug output on
    NSLog(@"Dumping schema: %@", schema.fullName);
    NSLog(@"TYPES:");
    for (USType *aT in [schema types]) {
        NSLog(@"    + %@ (%@, %d, %d, %@", aT.typeName, aT.representationClass, aT.hasBeenParsed, [aT.enumerationValues count], [aT assignOrRetain]);
        NSLog(@"        Attributes:");
        for (USAttribute *aTA in [aT attributes]) {
            NSLog(@"        - %@ (%@)", [aTA name], [[aTA type] typeName]);
        }
        NSLog(@"        Sequence Elements:");
        for (USSequenceElement *aSE in [aT sequenceElements]) {
            NSLog(@"        - %@ (%@)", aSE.name, [[aSE type] typeName]);
        }
    }
    NSLog(@"ELEMENTS:");
    for (USElement *aE in [schema elements]) {
        NSLog(@"    + %@ (%@, %d)", [aE name], [[aE type] typeName], [[aE type] hasBeenParsed]);
    }
    NSLog(@"ATTRIBUTES:");
    for (USAttribute *aA in [schema attributes]) {
        NSLog(@"    + %@ (%@, %d)", [aA name], [[aA type] typeName], [[aA type] hasBeenParsed]);
    }
    NSLog(@"Finished Dumping schema: %@", schema.fullName);
#endif
}

- (void)processDefinitionsImportElement:(NSXMLElement *)el wsdl:(USWSDL *)wsdl {
    [self processImportElement:el wsdl:wsdl];

    NSString *namespace = [[el attributeForName:@"namespace"] stringValue];
    USSchema *importedSchema = wsdl.schemas[namespace];
    [wsdl.targetNamespace.imports addObject:importedSchema];
}

- (void)processImportElement:(NSXMLElement *)el wsdl:(USWSDL *)wsdl {
    NSString *schemaLocation = [[el attributeForName:@"schemaLocation"] stringValue];
    if (schemaLocation) {
        NSURL *location = [NSURL URLWithString:schemaLocation relativeToURL:self.baseURL];

        NSLog(@"Processing schema import at location: %@", location);

        NSError *error = nil;
        NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:location options:0 error:&error];
        if (error) {
            NSLog(@"Unable to parse XML document from %@ (ignored): %@", location, error);
            return;
        }

        NSXMLElement *schemaElement = [document rootElement];
        if ([[schemaElement localName] isNotEqualTo:@"schema"]) {
            NSLog(@"During schema import, expected element named schema, found %@", [schemaElement name]);
            return;
        }

        [self processSchemaElement:schemaElement wsdl:wsdl];
        return;
    }

    // not a schema import, let's see if it's a definitions import
    NSString *definitionsLocation = [[el attributeForName:@"location"] stringValue];
    if (!definitionsLocation) {
        NSLog(@"Skipping unknown import: %@", el);
        return;
    }

    NSURL *location = [NSURL URLWithString:definitionsLocation relativeToURL:self.baseURL];
    NSLog(@"Processing definitions import at location: %@", location);

    NSError *error = nil;
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:location options:0 error:&error];
    if (error) {
        NSLog(@"Unable to parse XML document from %@ (ignored): %@", location, error);
        return;
    }

    NSXMLElement *definitionsElement = [document rootElement];
    if ([[definitionsElement localName] isNotEqualTo:@"definitions"]) {
        NSLog(@"During definitions import, expected element named definitions, found %@",
              [definitionsElement name]);
        return;
    }

    [self processDefinitionsElement:definitionsElement wsdl:wsdl];
}


- (void)processNamespace:(NSXMLNode *)ns wsdl:(USWSDL *)wsdl {
    NSString *uri = [ns stringValue];
    NSString *prefix = [ns localName];

    if ([prefix isNotEqualTo:@"xmlns"] && !wsdl.schemas[uri])
        [wsdl createSchemaForNamespace:uri prefix:prefix];
}

- (void)processSchemaChildElement:(NSXMLElement *)el schema:(USSchema *)schema
{
    NSString *localName = [el localName];

    if ([localName isEqualToString:@"import"])
        [self processSchemaImportElement:el schema:schema];
    else if ([localName isEqualToString:@"simpleType"])
        [schema registerType:[self parseSimpleType:el schema:schema name:nil]];
    else if ([localName isEqualToString:@"complexType"])
        [schema registerType:[self parseComplexType:el schema:schema name:nil]];
    else if ([localName isEqualToString:@"element"])
        [schema registerElement:[USElement elementWithElement:el schema:schema]];
    else if ([localName isEqualToString:@"attribute"])
        [schema registerAttribute:[USAttribute attributeWithElement:el schema:schema]];
    else if ([localName isEqualToString:@"attributeGroup"]) {
        NSMutableArray *group = [NSMutableArray new];
        for (NSXMLElement *child in [el childElementsWithName:@"attribute"])
            [group addObject:[USAttribute attributeWithElement:child schema:schema]];
        [schema registerAttributeGroup:group named:[[el attributeForName:@"name"] stringValue]];
    }
}

- (void)processSchemaImportElement:(NSXMLElement *)el schema:(USSchema *)schema
{
    [self processImportElement:el wsdl:schema.wsdl];

    NSString *uri = [[el attributeForName:@"namespace"] stringValue];
    [schema.imports addObject:schema.wsdl.schemas[uri]];
}

@end
