/*
 Copyright (c) 2013 7x7 Labs Inc.

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

#import "USParser+Types.h"

#import "NSString+USAdditions.h"
#import "NSXMLElement+Children.h"
#import "USAttribute.h"
#import "USElement.h"
#import "USSchema.h"
#import "USType.h"
#import "USWSDL.h"

static int readMax(NSXMLElement *el) {
    NSXMLNode *maxOccursNode = [el attributeForName:@"maxOccurs"];
    if (maxOccursNode) {
        NSString *maxOccursValue = [maxOccursNode stringValue];
        if ([maxOccursValue isEqualToString:@"unbounded"])
            return -1;
        return [maxOccursValue intValue];
    }
    return 1;
}

@implementation USParser (Types)
#pragma mark Types

- (USType *)parseTypeElement:(NSXMLElement *)el schema:(USSchema *)schema name:(NSString *)name {
    NSString *localName = [el localName];
    if ([localName isEqualToString:@"simpleType"])
        return [self parseSimpleType:el schema:schema name:name];
    if ([localName isEqualToString:@"complexType"])
        return [self parseComplexType:el schema:schema name:name];
    return nil;
}

- (NSString *)uniqueName:(NSString *)base schema:(USSchema *)schema {
    if (!schema.types[base])
        return base;
    for (int i = 2; ; ++i) {
        NSString *name = [NSString stringWithFormat:@"%@%d", base, i];
        if (!schema.types[name])
            return name;
    }
}

#pragma mark - Simple
- (USType *)parseSimpleType:(NSXMLElement *)el schema:(USSchema *)schema name:(NSString *)name {
    NSString *typename = [[el attributeForName:@"name"] stringValue] ?: [self uniqueName:name schema:schema];
    for (NSXMLElement *child in [el childElements]) {
        NSString *localName = [child localName];
        if ([localName isEqualToString:@"restriction"])
            return [self parseSimpleRestriction:child name:typename schema:schema];
        else if ([localName isEqualToString:@"union"]) {
            NSLog(@"Not handling union type %@ %@", typename, el);
            return [USType primitiveTypeWithName:typename prefix:schema.prefix type:@"NSString *"];
        }
        else if ([localName isEqualToString:@"list"]) {
            NSLog(@"Not handling list type %@ %@", typename, el);
            return [USType primitiveTypeWithName:typename prefix:schema.prefix type:@"NSString *"];
        }
    }

    return nil;
}

- (USType *)parseSimpleRestriction:(NSXMLElement *)el name:(NSString *)name schema:(USSchema *)schema {
    NSMutableSet *enumerationValues = [NSMutableSet new];
    for (NSXMLElement *child in [el childElementsWithName:@"enumeration"])
        [enumerationValues addObject:[[child attributeForName:@"value"] stringValue]];
    if ([enumerationValues count])
        return [USType enumTypeWithName:name prefix:schema.prefix
                                 values:[[enumerationValues allObjects] sortedArrayUsingSelector:@selector(compare:)]];

    // The base type may not exist yet, so in that case we need to return a proxy
    // that will forward to the base type once it does exist
    __block USProxyType *proxy = [[USProxyType alloc] initWithName:name];
    [schema withTypeFromElement:el attrName:@"base" call:^(USType *baseType) {
        proxy.type = [baseType deriveWithName:name prefix:schema.prefix];
    }];

    return proxy.type ?: (USType *)proxy;
}

#pragma mark - Complex
- (USType *)parseComplexType:(NSXMLElement *)el schema:(USSchema *)schema name:(NSString *)name
{
    NSString *typename = [[el attributeForName:@"name"] stringValue] ?: [self uniqueName:name schema:schema];
    return [self processComplexTypeBody:el schema:schema name:typename base:nil];
}

- (USType *)processComplexTypeBody:(NSXMLElement *)el schema:(USSchema *)schema
                              name:(NSString *)typeName base:(USType *)base
{
    NSMutableArray *attributes = [NSMutableArray new];
    for (NSXMLElement *child in [el childElementsWithName:@"attribute"])
         [attributes addObject:[USAttribute attributeWithElement:child schema:schema]];
    for (NSXMLElement *child in [el childElementsWithName:@"attributeGroup"]) {
        [schema withAttributeGroupFromElement:child attrName:@"ref" call:^(NSArray *group) {
            [attributes addObjectsFromArray:group];
        }];
    }

    NSXMLElement *content = [el childElementWithNames:@[@"simpleContent", @"complexContent", @"group",
                                                        @"sequence", @"choice", @"all",
                                                        @"restriction", @"extension"]
                                           parentName:@"complexType"];
    if (!content)
        return [USType complexTypeWithName:typeName prefix:schema.prefix
                                  elements:@[] attributes:attributes base:base];

    NSString *localName = [content localName];
    if ([localName isEqualToString:@"simpleContent"] || [localName isEqualToString:@"complexContent"]) {
        NSXMLElement *child = [content childElementWithNames:@[@"restriction", @"extension"] parentName:localName];
        localName = [child localName];
        if ([localName isEqualToString:@"restriction"]) {
            __block USProxyType *proxy = [[USProxyType alloc] initWithName:typeName];
            [schema withTypeFromElement:child attrName:@"base" call:^(USType *baseType) {
                proxy.type = [baseType deriveWithName:typeName prefix:schema.prefix];
            }];

            return proxy.type ?: (USType *)proxy;
        }
        return [self processExtensionElement:child name:typeName schema:schema];
    }

    if ([localName isEqualToString:@"any"]) {
        NSLog(@"xsd:any not handled: %@", typeName);
        return nil;
    }

    if ([localName isEqualToString:@"group"]) {
        NSLog(@"xsd:group not handled: %@", typeName);
        return nil;
    }

    BOOL isChoice = [localName isEqualToString:@"choice"];
    // May be a sequence containing just a choice, and we want to flatten that
    if ([localName isEqualToString:@"sequence"]) {
        for (NSXMLElement *child in [content childElements]) {
            NSString *childName = [child localName];
            if ([childName isEqualToString:@"choice"])
                isChoice = YES;
            else if ([childName isEqualToString:@"element"]) {
                isChoice = NO;
                break;
            }
        }
    }

    NSMutableArray *elements = [self parseSequenceBody:content schema:schema];
    BOOL needsToBeComplex = attributes.count || base;

    if (!needsToBeComplex && isChoice) {
        if (readMax(content) != 1)
            return [USType arrayTypeWithName:typeName prefix:schema.prefix choices:elements];
        for (USElement *element in elements) {
            if (!element.isArray)
                return [USType choiceTypeWithName:typeName prefix:schema.prefix choices:elements];
        }
        return [USType arrayTypeWithName:typeName prefix:schema.prefix choices:elements];
    }

    if (!needsToBeComplex && elements.count == 1) {
        USElement *element = [elements firstObject];
        if (readMax(content) != 1 || element.isArray)
            return [USType arrayTypeWithName:typeName prefix:schema.prefix choices:elements];
    }

    return [USType complexTypeWithName:typeName prefix:schema.prefix
                              elements:elements attributes:attributes base:base];
}

- (NSMutableArray *)parseSequenceBody:(NSXMLElement *)el schema:(USSchema *)schema {
    NSMutableArray *sequenceElements = [NSMutableArray new];
    for (NSXMLElement *child in [el childElements]) {
        NSString *localName = [child localName];
        if ([localName isEqualToString:@"choice"]) {
            NSMutableArray *subElements = [self parseSequenceBody:child schema:schema];
            if (readMax(child) != 1) {
                // Not quite equivalent, but we don't enforce the choice anyway
                for (USElement *element in subElements)
                    element.isArray = YES;
            }

            if ([sequenceElements count] == 0)
                sequenceElements = subElements;
            else
                [sequenceElements addObjectsFromArray:subElements];
        }
        else if ([localName isEqualToString:@"element"]) {
            [sequenceElements addObject:[self processSequenceElementElement:child schema:schema]];
        }
    }
    return sequenceElements;
}

- (USElement *)processSequenceElementElement:(NSXMLElement *)el schema:(USSchema *)schema {
    USElement *seqElement = [USElement new];
    seqElement.isArray = readMax(el) != 1;

    BOOL isRef = [schema withElementFromElement:el attrName:@"ref" call:^(USElement *element) {
        seqElement.wsdlName = element.wsdlName;
        seqElement.name = element.name;
        seqElement.type = element.type;
        seqElement.substitutions = element.substitutions;
    }];
    if (isRef) return seqElement;

    seqElement.wsdlName = [[el attributeForName:@"name"] stringValue];
    seqElement.name = [seqElement.wsdlName stringByRemovingIllegalCharacters];

    USProxyType *proxy = [USProxyType alloc];
    BOOL hasTypeRef = [schema withTypeFromElement:el attrName:@"type" call:^(USType *t) {
        proxy.typeName = t.typeName;
        proxy.type = t;
    }];
    if (hasTypeRef) {
        seqElement.type = proxy.type ?: (USType *)proxy;
        return seqElement;
    }

    // Anonymous type definition, so we need to convert it to a named type
    NSString *name = [@"SequenceElement_" stringByAppendingString:seqElement.name];
    for (NSXMLElement *child in el.childElements) {
        USType *type = [self parseTypeElement:child schema:schema name:name];
        if (type) {
            seqElement.type = type;
            [schema registerType:type];
            break;
        }
    }

    return seqElement;
}

- (USType *)processExtensionElement:(NSXMLElement *)el name:(NSString *)name schema:(USSchema *)schema
{
    USProxyType *proxy = [[USProxyType alloc] initWithName:name];
    [schema withTypeFromElement:el attrName:@"base" call:^(USType *baseType) {
        proxy.type = baseType;
    }];

    return [self processComplexTypeBody:el schema:schema name:name base:proxy.type ?: (USType *)proxy];
}
@end
