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

#import "USMessage.h"
#import "USOperation.h"
#import "USType.h"
#import "USElement.h"
#import "USPart.h"

@implementation USOperationInterface
+ (USOperationInterface *)operationInterfaceForOperation:(USOperation *)operation
{
	USOperationInterface *interface = [USOperationInterface new];
	interface.operation = operation;
	return interface;
}

- (id)init
{
	if ((self = [super init])) {
		self.headers = [NSMutableArray array];
	}

	return self;
}

- (NSString *)className
{
	NSMutableArray *parts = self.body.parts;
	if ([parts count] == 1) {
		USPart *bodyPart = [parts lastObject];
		NSString *className = bodyPart.element.type.classNameWithPtr;
		return className;
	}

	return @"NSArray *";
}

- (NSNumber *)hasHeaders
{
	return @([self.headers count] > 0);
}

@end
