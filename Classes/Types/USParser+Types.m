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
#import "USSequenceElement.h"
#import "USType.h"
#import "USWSDL.h"

static void readMinMax(NSXMLElement *el, int *min, int *max) {
    NSXMLNode *minOccursNode = [el attributeForName:@"minOccurs"];
    *min = minOccursNode ? [[minOccursNode stringValue] intValue] : 1;

    NSXMLNode *maxOccursNode = [el attributeForName:@"maxOccurs"];
    if (maxOccursNode) {
        NSString *maxOccursValue = [maxOccursNode stringValue];
        if ([maxOccursValue isEqualToString:@"unbounded"])
            *max = -1;
        else
            *max = [maxOccursValue intValue];
    }
    else
        *max = 1;
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
    USType *type = [USType simpleTypeWithName:typename prefix:schema.prefix];

    for (NSXMLElement *child in [el childElements]) {
        NSString *localName = [child localName];
        if ([localName isEqualToString:@"restriction"]) {
            return [self parseRestriction:child type:type schema:schema];
        }
        else if ([localName isEqualToString:@"union"]) {
            NSLog(@"Not handling union type %@ %@", type.typeName, el);
            type.representationClass = @"NSString *";
        }
        else if ([localName isEqualToString:@"list"]) {
            NSLog(@"Not handling list type %@ %@", type.typeName, el);
            type.representationClass = @"NSString *";
        }
    }

    return type;
}

- (USType *)parseRestriction:(NSXMLElement *)el type:(USType *)type schema:(USSchema *)schema {
    NSMutableOrderedSet *enumerationValues = [NSMutableOrderedSet new];
    for (NSXMLElement *child in [el childElementsWithName:@"enumeration"])
        [enumerationValues addObject:[[child attributeForName:@"value"] stringValue]];
    type.enumerationValues = [enumerationValues array];

    [schema withTypeFromElement:el attrName:@"base" call:^(USType *baseType) {
        if (type.isSimpleType)
            type.representationClass = baseType.representationClass;
        else // Restriction on complex types is used to remove things from the base, which this doesn't handle
            type.superClass = baseType;
    }];

    return type;
}

#pragma mark - Complex
- (USType *)parseComplexType:(NSXMLElement *)el schema:(USSchema *)schema name:(NSString *)name
{
    NSString *typename = [[el attributeForName:@"name"] stringValue] ?: [self uniqueName:name schema:schema];
    USType *type = [USType complexTypeWithName:typename prefix:schema.prefix];
    return [self processComplexTypeBody:el schema:schema type:type];
}

- (USType *)processComplexTypeBody:(NSXMLElement *)el schema:(USSchema *)schema type:(USType *)type
{
    for (NSXMLElement *child in [el childElementsWithName:@"attribute"])
         [type.attributes addObject:[USAttribute attributeWithElement:child schema:schema]];
    NSArray *attributeGroups = [el childElementsWithName:@"attributeGroup"];
    if ([attributeGroups count])
        NSLog(@"Not handling attribute groups for %@", type.typeName);

    NSXMLElement *content = [el childElementWithNames:@[@"simpleContent", @"complexContent", @"group",
                                                        @"sequence", @"choice", @"all",
                                                        @"restriction", @"extension"]
                                           parentName:@"complexType"];
    if (!content)
        return type;

    NSString *localName = [content localName];
    if ([localName isEqualToString:@"simpleContent"] || [localName isEqualToString:@"complexContent"]) {
        NSXMLElement *child = [content childElementWithNames:@[@"restriction", @"extension"] parentName:localName];
        localName = [child localName];
        if ([localName isEqualToString:@"restriction"])
            return [self parseRestriction:child type:type schema:schema];
        return [self processExtensionElement:child type:type schema:schema];
    }

    // Sequence, Group, Choice or Any
    for (NSXMLElement *child in [content childElementsWithName:@"element"])
        [type.sequenceElements addObject:[self processSequenceElementElement:child schema:schema]];

    int minOccurs, maxOccurs;
    readMinMax(content, &minOccurs, &maxOccurs);
    if (maxOccurs != 1) {
        if (type.sequenceElements.count == 1)
            [[type.sequenceElements firstObject] setMaxOccurs:maxOccurs];
        else
            type.isArray = YES;
    }

    return type;
}

- (USSequenceElement *)processSequenceElementElement:(NSXMLElement *)el schema:(USSchema *)schema {
    USSequenceElement *seqElement = [USSequenceElement new];

    int minOccurs, maxOccurs;
    readMinMax(el, &minOccurs, &maxOccurs);
    seqElement.minOccurs = minOccurs;
    seqElement.maxOccurs = maxOccurs;

    BOOL isRef = [schema withElementFromElement:el attrName:@"ref" call:^(USElement *element) {
        seqElement.name = element.name;
        seqElement.type = element.type;
    }];
    if (isRef) return seqElement;

    seqElement.name = [[[el attributeForName:@"name"] stringValue] stringByRemovingIllegalCharacters];

    BOOL hasTypeRef = [schema withTypeFromElement:el attrName:@"type" call:^(USType *t) {
        seqElement.type = t;
    }];
    if (hasTypeRef) return seqElement;

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

- (USType *)processExtensionElement:(NSXMLElement *)el type:(USType *)type schema:(USSchema *)schema
{
    [schema withTypeFromElement:el attrName:@"base" call:^(USType *base) {
        type.superClass = base;
    }];

    return [self processComplexTypeBody:el schema:schema type:type];
}
@end
