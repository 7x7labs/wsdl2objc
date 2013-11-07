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

#import "USPortType.h"

#import "NSXMLElement+Children.h"
#import "USSchema.h"

@implementation USPortTypeOperation
+ (USPortTypeOperation *)operationWithElement:(NSXMLElement *)el schema:(USSchema *)schema {
    USPortTypeOperation *operation = [USPortTypeOperation new];
    operation.name = [[el attributeForName:@"name"] stringValue];

    for (NSXMLElement *child in [el childElements]) {
        NSString *localName = [child localName];
        if ([localName isEqualToString:@"input"]) {
            [schema withMessageFromElement:child attrName:@"message" call:^(USMessage *message) {
                operation.input = message;
            }];
        }
        else if ([localName isEqualToString:@"output"]) {
            [schema withMessageFromElement:child attrName:@"message" call:^(USMessage *message) {
                operation.output = message;
            }];
        }
    }
    return operation;
}
@end

@implementation USPortType
+ (USPortType *)portTypeWithElement:(NSXMLElement *)el schema:(USSchema *)schema {
    USPortType *portType = [USPortType new];
    portType.name = [[el attributeForName:@"name"] stringValue];

    NSMutableDictionary *operations = [NSMutableDictionary new];
    for (NSXMLElement *child in [el childElementsWithName:@"operation"]) {
        USPortTypeOperation *operation = [USPortTypeOperation operationWithElement:child schema:schema];
        operations[operation.name] = operation;
    }
    portType.operations = operations;
    return portType;
}
@end
