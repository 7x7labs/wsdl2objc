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

#import "USOperationInterface.h"

#import "NSXMLElement+Children.h"
#import "USElement.h"
#import "USMessage.h"
#import "USSchema.h"
#import "USType.h"

@implementation USOperationInterface
+ (instancetype)interfaceWithElement:(NSXMLElement *)el schema:(USSchema *)schema message:(USMessage *)message
{
    USOperationInterface *interface = [USOperationInterface new];

    NSMutableOrderedSet *headers = [NSMutableOrderedSet new];

    for (NSXMLElement *child in [el childElements]) {
        if (![child isSoapNS]) continue;

        NSString *localName = [child localName];
        if ([localName isEqualToString:@"header"]) {
            NSString *partName = [[child attributeForName:@"part"] stringValue];
            [schema withMessageFromElement:child attrName:@"message" call:^(USMessage *m) {
                [headers addObject:m.parts[partName]];
            }];
        }
        else if ([localName isEqualToString:@"body"]) {
            NSString *partsStr = [[child attributeForName:@"parts"] stringValue];
            if ([partsStr length] == 0) {
                // Empty or non-exists parts == all parts from message
                interface.bodyParts = [message.parts allValues];
                continue;
            }

            NSMutableArray *bodyParts = [NSMutableArray new];
            for (NSString *partName in [partsStr componentsSeparatedByString:@" "])
                [bodyParts addObject:message.parts[partName]];
            interface.bodyParts = bodyParts;
        }
    }

    interface.headers = headers;

    return interface;

}

- (NSString *)className {
	if ([self.bodyParts count] == 1)
		return ((USElement *)[self.bodyParts firstObject]).type.variableTypeName;
	return @"NSArray *";
}

- (NSNumber *)hasHeaders {
	return @([self.headers count] > 0);
}

@end
