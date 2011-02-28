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
#import "USOperationFault.h"
#import "USPart.h"
#import "USMessage.h"
#import "USElement.h"
#import "USType.h"
#import "USObjCKeywords.h"

@implementation USOperation

@synthesize name;
@synthesize soapAction;
@synthesize input;
@synthesize output;
@synthesize faults;
@synthesize portType;
@dynamic className;

- (id)init
{
	if((self = [super init])) {
		self.name = nil;
		self.soapAction = nil;
		self.input = [USOperationInterface operationInterfaceForOperation:self];
		self.output = [USOperationInterface operationInterfaceForOperation:self];
		self.faults = [NSMutableArray array];
		self.portType = nil;
	}
	
	return self;
}

- (void) dealloc
{
    [name release];
    [soapAction release];
    [input release];
    [output release];
    [faults release];
    [super dealloc];
}

- (USOperationFault *)faultForName:(NSString *)aName
{
	for(USOperationFault *fault in self.faults) {
		if([fault.name isEqualToString:aName]) {
			return fault;
		}
	}
	
	USOperationFault *newFault = [USOperationFault new];
	newFault.operation = self;
	newFault.name = aName;
	[self.faults addObject:newFault];
    [newFault release];
	
	return newFault;
}

- (NSString *)className
{
	return [[self.name componentsSeparatedByCharactersInSet:kIllegalClassCharactersSet] componentsJoinedByString:@""];
}

- (NSString *)invokeStringWithAsync:(BOOL)async
{
	if(self.input.body == nil && self.input.headers == nil && !async) {
		return self.className;
	}
	
	NSMutableString *invokeString = [NSMutableString string];
	
	[invokeString appendFormat:@"%@%@Using", self.className, ((async)?@"Async":@"")];
	
	BOOL firstArgument = YES;
	for(USPart *part in self.input.body.parts) {
		[invokeString appendFormat:@"%@:(%@)a%@ ", (firstArgument ? [part uname] : part.name), [part.element.type classNameWithPtr], [part uname]];
		firstArgument = NO;
	}
	
	for(USElement *element in self.input.headers) {
		[invokeString appendFormat:@"%@:(%@)a%@ ", (firstArgument ? [element uname] : element.name), [element.type classNameWithPtr], [element uname]];
		firstArgument = NO;
	}
	
	return invokeString;
}

- (NSString *)invokeString
{
	return [self invokeStringWithAsync:NO];
}

- (NSString *)asyncInvokeString
{
	return [self invokeStringWithAsync:YES];
}

@end
