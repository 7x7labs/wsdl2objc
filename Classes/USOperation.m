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

#import "USOperation.h"

#import "USOperationInterface.h"
#import "USPortType.h"
#import "USMessage.h"
#import "USElement.h"
#import "USType.h"
#import "NSString+USAdditions.h"
#import "NSXMLElement+Children.h"

@implementation USOperation
+ (USOperation *)operationWithElement:(NSXMLElement *)el schema:(USSchema *)schema portType:(USPortType *)portType
{
    USOperation *operation = [USOperation new];
    operation.name = [[el attributeForName:@"name"] stringValue];

    USPortTypeOperation *pto = portType.operations[operation.name];
    if (!pto) {
        NSLog(@"Skipping operation %@: Not present in PortType", operation.name);
        return nil;
    }

    for (NSXMLElement *child in [el childElements]) {
        NSString *localName = [child localName];

        if ([localName isEqualToString:@"operation"] && [child isSoapNS])
            operation.soapAction = [[child attributeForName:@"soapAction"] stringValue];
        else if ([localName isEqualToString:@"input"])
            operation.input = [USOperationInterface interfaceWithElement:child schema:schema message:pto.input];
        else if ([localName isEqualToString:@"output"])
            operation.output = [USOperationInterface interfaceWithElement:child schema:schema message:pto.output];
    }
    assert(operation.soapAction);
    return operation;
}

- (NSString *)className {
    return [self.name stringByRemovingIllegalCharacters];
}

- (NSString *)invokeStringWithAsync:(BOOL)async {
    if (![self.input.bodyParts count] && !async)
        return self.className;

    if (![self.input.bodyParts count])
        return [self.className stringByAppendingString:@"Async"];

    NSMutableString *invokeString;
    BOOL first = YES;
    for (USElement *element in self.input.bodyParts) {
        if (first) {
            if ([element.uname isEqualToString:self.className])
                invokeString = [NSMutableString stringWithFormat:@"%@%@:",
                                self.className, async ? @"Async" : @""];
            else
                invokeString = [NSMutableString stringWithFormat:@"%@%@Using%@:",
                                self.className, async ? @"Async" : @"", element.uname];
            first = NO;
        }
        else {
            [invokeString appendFormat:@" %@:", element.name];
        }

        [invokeString appendFormat:@"(%@)a%@", element.type.variableTypeName, element.uname];
    }

    return invokeString;
}

- (NSString *)invokeString {
    return [self invokeStringWithAsync:NO];
}

- (NSString *)asyncInvokeString {
    return [self invokeStringWithAsync:YES];
}

@end
