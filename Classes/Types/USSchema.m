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

#import "USSchema.h"

#import "NSArray+USAdditions.h"
#import "NSBundle+USAdditions.h"
#import "USAttribute.h"
#import "USBinding.h"
#import "USElement.h"
#import "USMessage.h"
#import "USObjCKeywords.h"
#import "USPortType.h"
#import "USService.h"
#import "USType.h"
#import "USWSDL.h"

@interface USSchema ()
@property (nonatomic, strong) NSMutableDictionary *attributeWaits;
@property (nonatomic, strong) NSMutableDictionary *attributeGroupWaits;
@property (nonatomic, strong) NSMutableDictionary *elementWaits;
@property (nonatomic, strong) NSMutableDictionary *typeWaits;
@property (nonatomic, strong) NSMutableDictionary *messageWaits;
@property (nonatomic, strong) NSMutableDictionary *portTypeWaits;
@property (nonatomic, strong) NSMutableDictionary *bindingWaits;
@end

@implementation USSchema
- (id)initWithWSDL:(USWSDL *)aWsdl {
    if ((self = [super init])) {
        self.fullName = @"";
        self.types = [NSMutableDictionary new];
        self.elements = [NSMutableDictionary new];
        self.attributes = [NSMutableDictionary new];
        self.attributeGroups = [NSMutableDictionary new];
        self.imports = [NSMutableArray new];
        self.messages = [NSMutableDictionary new];
        self.portTypes = [NSMutableDictionary new];
        self.bindings = [NSMutableDictionary new];
        self.services = [NSMutableDictionary new];
        self.wsdl = aWsdl;

        self.attributeWaits = [NSMutableDictionary new];
        self.attributeGroupWaits = [NSMutableDictionary new];
        self.elementWaits = [NSMutableDictionary new];
        self.typeWaits = [NSMutableDictionary new];
        self.messageWaits = [NSMutableDictionary new];
        self.portTypeWaits = [NSMutableDictionary new];
        self.bindingWaits = [NSMutableDictionary new];
    }
    return self;
}

- (USSchema *)schemaFromNode:(NSXMLNode *)node element:(NSXMLElement *)el {
    if (!node) return nil;
    NSString *qName = [node stringValue];
    NSString *namespaceURI = [[el resolveNamespaceForName:qName] stringValue];
    return self.wsdl.schemas[namespaceURI];
}

- (BOOL)call:(void (^)(id))block
withValueForKey:(NSXMLNode *)node
     ifKeyIn:(NSMutableDictionary *)items
otherwiseEnqueueIn:(NSMutableDictionary *)waits
{
    if (!node) return NO;

    NSString *localName = [NSXMLNode localNameForName:[node stringValue]];
    id value = items[localName];
    if (value)
        block(value);
    else {
        if (!waits[localName])
            waits[localName] = [NSMutableArray new];
        [waits[localName] addObject:block];
    }

    return YES;
}

- (void)checkWaits:(NSMutableDictionary *)dictionary key:(NSString *)key value:(id)value {
    if (dictionary[key]) {
        for (void (^block)(id) in dictionary[key])
            block(value);
        [dictionary removeObjectForKey:key];
    }
}

- (BOOL)withTypeFromElement:(NSXMLElement *)el attrName:(NSString *)attrName call:(void (^)(USType *))block {
    NSXMLNode *node = [el attributeForName:attrName];
    USSchema *targetSchema = [self schemaFromNode:node element:el];
    return [targetSchema call:block
              withValueForKey:node
                      ifKeyIn:targetSchema.types
           otherwiseEnqueueIn:targetSchema.typeWaits];
}

- (void)registerType:(USType *)type {
    self.types[type.typeName] = type;
    [self checkWaits:self.typeWaits key:type.typeName value:type];
}

- (BOOL)withElementFromElement:(NSXMLElement *)el attrName:(NSString *)attrName call:(void (^)(USElement *))block {
    NSXMLNode *node = [el attributeForName:attrName];
    USSchema *targetSchema = [self schemaFromNode:node element:el];
    return [targetSchema call:block
              withValueForKey:node
                      ifKeyIn:targetSchema.elements
           otherwiseEnqueueIn:targetSchema.elementWaits];
}

- (void)registerElement:(USElement *)element {
    self.elements[element.wsdlName] = element;
    [self checkWaits:self.elementWaits key:element.wsdlName value:element];
}

- (BOOL)withAttributeFromElement:(NSXMLElement *)el attrName:(NSString *)attrName call:(void (^)(USAttribute *))block
{
    NSXMLNode *node = [el attributeForName:attrName];
    USSchema *targetSchema = [self schemaFromNode:node element:el];
    return [targetSchema call:block
              withValueForKey:node
                      ifKeyIn:targetSchema.attributes
           otherwiseEnqueueIn:targetSchema.attributeWaits];
}

- (void)registerAttribute:(USAttribute *)attribute {
    self.attributes[attribute.name] = attribute;
    [self checkWaits:self.attributeWaits key:attribute.name value:attribute];
}

- (BOOL)withAttributeGroupFromElement:(NSXMLElement *)el attrName:(NSString *)attrName call:(void (^)(NSArray *))block
{
    NSXMLNode *node = [el attributeForName:attrName];
    USSchema *targetSchema = [self schemaFromNode:node element:el];
    return [targetSchema call:block
              withValueForKey:node
                      ifKeyIn:targetSchema.attributeGroups
           otherwiseEnqueueIn:targetSchema.attributeGroupWaits];
}

- (void)registerAttributeGroup:(NSArray *)group named:(NSString *)name {
    self.attributeGroups[name] = group;
    [self checkWaits:self.attributeGroupWaits key:name value:group];
}

- (BOOL)withMessageFromElement:(NSXMLElement *)el attrName:(NSString *)attrName call:(void (^)(USMessage *))block {
    NSXMLNode *node = [el attributeForName:attrName];
    USSchema *targetSchema = [self schemaFromNode:node element:el];
    return [targetSchema call:block
              withValueForKey:node
                      ifKeyIn:targetSchema.messages
           otherwiseEnqueueIn:targetSchema.messageWaits];
}

- (void)registerMessage:(USMessage *)message {
    self.messages[message.name] = message;
    [self checkWaits:self.messageWaits key:message.name value:message];
}

- (BOOL)withPortTypeFromElement:(NSXMLElement *)el attrName:(NSString *)attrName call:(void (^)(USPortType *))block {
    NSXMLNode *node = [el attributeForName:attrName];
    USSchema *targetSchema = [self schemaFromNode:node element:el];
    return [targetSchema call:block
              withValueForKey:node
                      ifKeyIn:targetSchema.portTypes
           otherwiseEnqueueIn:targetSchema.portTypeWaits];
}

- (void)registerPortType:(USPortType *)portType {
    self.portTypes[portType.name] = portType;
    [self checkWaits:self.portTypeWaits key:portType.name value:portType];
}

- (BOOL)withBindingFromElement:(NSXMLElement *)el attrName:(NSString *)attrName call:(void (^)(USBinding *))block {
    NSXMLNode *node = [el attributeForName:attrName];
    USSchema *targetSchema = [self schemaFromNode:node element:el];
    return [targetSchema call:block
              withValueForKey:node
                      ifKeyIn:targetSchema.bindings
           otherwiseEnqueueIn:targetSchema.bindingWaits];
}

- (void)registerBinding:(USBinding *)binding {
    self.bindings[binding.name] = binding;
    [self checkWaits:self.bindingWaits key:binding.name value:binding];
}

- (void)registerService:(USService *)service {
    self.services[service.name] = service;
}

- (void)addSimpleClassWithName:(NSString *)name representationClass:(NSString *)repClass {
    self.types[name] = [USType primitiveTypeWithName:name prefix:self.prefix type:repClass];
}

- (BOOL)shouldWrite {
    return [self.elements count]
        || [self.imports count]
        || [self.bindings count]
        || [self.services count]
        || [self.types count];
}

- (NSString *)templateFileHPath {
    return [[NSBundle mainBundle] pathForTemplateNamed:@"Schema_H"];
}

- (NSString *)templateFileMPath {
    return [[NSBundle mainBundle] pathForTemplateNamed:@"Schema_M"];
}

- (NSDictionary *)templateKeyDictionary {
    NSArray *types = [self.types allValues];
    return @{@"fullName": self.fullName,
             @"prefix": self.prefix,
             @"imports": self.imports,
             @"uniqueTypes": [[[NSSet setWithArray:types] allObjects] sortedArrayUsingKey:@"typeName" ascending:YES],
             @"types": [types sortedArrayUsingKey:@"typeName" ascending:YES],
             @"wsdl": self.wsdl};
}

@end
