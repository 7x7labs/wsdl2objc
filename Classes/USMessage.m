/*
 Copyright (c) 2013 7x7 Labs, Inc.

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

#import "USMessage.h"

#import "NSXMLElement+Children.h"
#import "USElement.h"
#import "USSchema.h"

@implementation USMessage
+ (USMessage *)messageWithElement:(NSXMLElement *)el schema:(USSchema *)schema {
	USMessage *message = [USMessage new];
	message.name = [[el attributeForName:@"name"] stringValue];

    NSMutableDictionary *parts = [NSMutableDictionary new];
    for (NSXMLElement *child in [el childElementsWithName:@"part"]) {
        NSString *name = [[child attributeForName:@"name"] stringValue];
        BOOL hasElement = [schema withElementFromElement:child attrName:@"element" call:^(USElement *element) {
            parts[name] = element;
        }];

        if (!hasElement) {
            [schema withTypeFromElement:child attrName:@"type" call:^(USType *type) {
                USElement *element = [USElement new];
                element.name = name;
                element.type = type;
                parts[name] = element;
            }];
        }
    }
    message.parts = parts;
    return message;

}
@end
