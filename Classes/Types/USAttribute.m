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

#import "USAttribute.h"

#import "NSXMLElement+Children.h"
#import "USParser+Types.h"
#import "USObjCKeywords.h"
#import "USSchema.h"
#import "USType.h"

@implementation USAttribute
+ (USAttribute *)attributeWithElement:(NSXMLElement *)el schema:(USSchema *)schema {
    USAttribute *attribute = [USAttribute new];

    BOOL isRef = [schema withAttributeFromElement:el attrName:@"ref" call:^(USAttribute *ref) {
        attribute.name = ref.name;
        attribute.wsdlName = ref.wsdlName;
        attribute.attributeDefault = ref.attributeDefault;
        attribute.type = ref.type;

    }];
    if (isRef) return attribute;

    attribute.wsdlName = [[el attributeForName:@"name"] stringValue];
    attribute.name = [USObjCKeywords mangleName:attribute.wsdlName];
    attribute.attributeDefault = [[el attributeForName:@"default"] stringValue] ?: @"";

    BOOL hasType = [schema withTypeFromElement:el attrName:@"type" call:^(USType *type) {
        attribute.type = type;
    }];

    if (!hasType) {
        // Anonymous type, so we need to convert it to a named type
        USParser *parser = [USParser new];
        NSString *typeName = [@"Attribute" stringByAppendingString:attribute.name];
        for (NSXMLElement *child in [el childElements]) {
            attribute.type = [parser parseTypeElement:child schema:schema name:typeName];
            if (attribute.type) break;
        }
        [schema registerType:attribute.type];
    }
    return attribute;
}

- (NSDictionary *)templateKeyDictionary {
    return @{@"name": self.name,
             @"typeName": self.type.typeName,
             @"default": self.attributeDefault};
}
@end
