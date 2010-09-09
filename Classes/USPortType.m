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

#import "USPortType.h"

#import "USOperation.h"

@implementation USPortType

@synthesize name;
@synthesize operations;
@synthesize schema;

- (id)init
{
	if((self = [super init])) {
		self.name = nil;
		self.operations = [NSMutableArray array];
		self.schema = nil;
	}
	
	return self;
}

- (void) dealloc
{
    [name release];
    [operations release];
    [super dealloc];
}

- (USOperation *)operationForName:(NSString *)aName
{
	for(USOperation *operation in self.operations) {
		if([operation.name isEqualToString:aName]) {
			return operation;
		}
	}
	
	USOperation *newOperation = [USOperation new];
	newOperation.name = aName;
	newOperation.portType = self;
	[self.operations addObject:newOperation];
    [newOperation release];
	
	return newOperation;
}

@end
