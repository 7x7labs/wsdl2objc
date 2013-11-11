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

#import "USBinding.h"

#import "NSArray+USAdditions.h"
#import "NSBundle+USAdditions.h"
#import "NSString+USAdditions.h"
#import "NSXMLElement+Children.h"
#import "USElement.h"
#import "USOperation.h"
#import "USOperationInterface.h"
#import "USPortType.h"
#import "USSchema.h"

@implementation USBinding
+ (instancetype)bindingWithElement:(NSXMLElement *)el schema:(USSchema *)schema {
    USBinding *binding = [USBinding new];
    binding.name = [[el attributeForName:@"name"] stringValue];
    binding.prefix = schema.prefix;
    binding.soapVersion = @"1.1";

    __block USPortType *portType;
    [schema withPortTypeFromElement:el attrName:@"type" call:^(USPortType *pt) {
        portType = pt;
    }];

    NSMutableDictionary *operations = [NSMutableDictionary new];
    for (NSXMLElement *child in [el childElementsWithName:@"operation"]) {
        USOperation *operation = [USOperation operationWithElement:child schema:schema portType:portType];
        if (operation)
            operations[operation.name] = operation;
    }

    for (NSXMLElement *child in [el childElementsWithName:@"binding"]) {
        NSString *namespace = [[child resolveNamespaceForName:[child name]] stringValue];
        if ([namespace isEqualToString:@"http://schemas.xmlsoap.org/wsdl/soap12/"])
            binding.soapVersion = @"1.2";
    }

    binding.operations = operations;
    return binding;
}

- (NSString *)cleanName {
	NSString *result = [self.name stringByRemovingIllegalCharacters];
	if (![result.lowercaseString hasSuffix:@"binding"])
		result = [result stringByAppendingString:@"Binding"];
	return result;
}

- (NSString *)className {
    return [NSString stringWithFormat:@"%@_%@", self.prefix, self.cleanName];
}

- (NSString *)templateFileHPath {
	return [[NSBundle mainBundle] pathForTemplateNamed:@"Binding_H"];
}

- (NSString *)templateFileMPath {
	return [[NSBundle mainBundle] pathForTemplateNamed:@"Binding_M"];
}

- (NSDictionary *)templateKeyDictionary {
    NSMutableDictionary *inputHeaders = [NSMutableDictionary new];
    for (NSString *key in self.operations) {
        for (USElement *header in [self.operations[key] input].headers) {
            if (inputHeaders[header.name]) {
                assert([(USElement *)inputHeaders[header.name] type] == header.type);
            }
            inputHeaders[header.name] = header;
        }
    }

    return @{@"name": self.name,
             @"className": self.className,
             @"soapVersion": self.soapVersion,
             @"operations": [[self.operations allValues] sortedArrayUsingKey:@"name" ascending:YES],
             @"inputHeaders": [inputHeaders allValues]};
}

@end
