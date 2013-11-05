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

#import "USParser+PortTypes.h"

#import "NSXMLElement+Children.h"

#import "USSchema.h"
#import "USPortType.h"
#import "USOperation.h"
#import "USOperationInterface.h"
#import "USWSDL.h"
#import "USOperationFault.h"

@implementation USParser (PortTypes)

- (void)processPortTypeElement:(NSXMLElement *)el schema:(USSchema *)schema
{
	NSString *name = [[el attributeForName:@"name"] stringValue];
	USPortType *portType = [schema portTypeForName:name];

	for (NSXMLElement *child in [el childElementsWithName:@"operation"])
		[self processPortTypeOperationElement:child portType:portType];
}

- (void)processPortTypeOperationElement:(NSXMLElement *)el portType:(USPortType *)portType
{
	NSString *name = [[el attributeForName:@"name"] stringValue];

	USOperation *operation = [portType operationForName:name];
	operation.name = name;

	for (NSXMLElement *child in [el childElements])
        [self processPortTypeOperationChildElement:child operation:operation];
}

- (void)processPortTypeOperationChildElement:(NSXMLElement *)el operation:(USOperation *)operation
{
	NSString *localName = [el localName];
	if ([localName isEqualToString:@"input"]) {
        [self processPortTypeOperationInterfaceElement:el operationInterface:operation.input];
	} else if ([localName isEqualToString:@"output"]) {
        [self processPortTypeOperationInterfaceElement:el operationInterface:operation.output];
	} else if ([localName isEqualToString:@"fault"]) {
		[self processPortTypeFaultElement:el operation:operation];
	}
}

- (void)processPortTypeOperationInterfaceElement:(NSXMLElement *)el operationInterface:(USOperationInterface *)interface
{
	NSString *name = [[el attributeForName:@"name"] stringValue];
	interface.name = name;

	NSString *messageQName = [[el attributeForName:@"message"] stringValue];

	NSString *uri = [[el resolveNamespaceForName:messageQName] stringValue];
	USSchema *schema = [interface.operation.portType.schema.wsdl schemaForNamespace:uri];

	NSString *localName = [NSXMLNode localNameForName:messageQName];
	USMessage *bodyMessage = [schema messageForName:localName];

	interface.body = bodyMessage;
}

- (void)processPortTypeFaultElement:(NSXMLElement *)el operation:(USOperation *)operation
{
	NSString *name = [[el attributeForName:@"name"] stringValue];
	USOperationFault *fault = [operation faultForName:name];

	NSString *messageQName = [[el attributeForName:@"message"] stringValue];

	NSString *uri = [[el resolveNamespaceForName:messageQName] stringValue];
	USSchema *schema = [operation.portType.schema.wsdl schemaForNamespace:uri];

	NSString *localName = [NSXMLNode localNameForName:messageQName];
	USMessage *bodyMessage = [schema messageForName:localName];

	fault.message = bodyMessage;
}

@end
