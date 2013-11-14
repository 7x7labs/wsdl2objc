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

#import "USElement.h"

#import "NSString+USAdditions.h"
#import "NSXMLElement+Children.h"
#import "USObjCKeywords.h"
#import "USParser+Types.h"
#import "USSchema.h"
#import "USType.h"

@implementation USElement
+ (USElement *)elementWithElement:(NSXMLElement *)el schema:(USSchema *)schema {
    USElement *element = [USElement new];
    element.wsdlName = [[el attributeForName:@"name"] stringValue];
    element.name = [USObjCKeywords mangleName:element.wsdlName];

    NSXMLNode *maxOccursNode = [el attributeForName:@"maxOccurs"];
    if (maxOccursNode) {
        NSString *maxOccursValue = [maxOccursNode stringValue];
        if ([maxOccursValue isEqualToString:@"unbounded"] || [maxOccursValue intValue] > 1)
            element.isArray = YES;
    }

    BOOL hasType = [schema withTypeFromElement:el attrName:@"type" call:^(USType *type) {
        element.type = type;
    }];

    if (!hasType) {
        USParser *parser = [USParser new];
        NSString *typeName = [@"Element" stringByAppendingString:element.name];
        for (NSXMLElement *child in [el childElements]) {
            element.type = [parser parseTypeElement:child schema:schema name:typeName];
            if (element.type) break;
        }
        [schema registerType:element.type];
    }

    [schema withElementFromElement:el attrName:@"substitutionGroup" call:^(USElement *ele) {
        [ele.substitutions addObject:element];
    }];

    return element;
}

- (NSString *)uname {
	return [self.name stringWithCapitalizedFirstCharacter];
}

- (NSMutableArray *)substitutions {
    if (!_substitutions) _substitutions = [NSMutableArray new];
    return _substitutions;
}
@end
