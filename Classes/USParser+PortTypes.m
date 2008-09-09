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

#import "USSchema.h"
#import "USPortType.h"
#import "USOperation.h"
#import "USOperationInterface.h"
#import "USWSDL.h"
#import "USOperationFault.h"

@interface USParser (PortTypes_Private)

- (void)processPortTypeOperationInterfaceElement:(NSXMLElement *)el operationInterface:(USOperationInterface *)interface;

@end

@implementation USParser (PortTypes)

- (void)processPortTypeElement:(NSXMLElement *)el schema:(USSchema *)schema
{
	NSString *name = [[el attributeForName:@"name"] stringValue];
	USPortType *portType = [schema portTypeForName:name];
	
	for(NSXMLNode *child in [el children]) {
		if([child kind] == NSXMLElementKind) {
			[self processPortTypeChildElement:(NSXMLElement*)child portType:portType];
		}
	}
}

- (void)processPortTypeChildElement:(NSXMLElement *)el portType:(USPortType *)portType
{
	NSString *localName = [el localName];
	
	if([localName isEqualToString:@"operation"]) {
		[self processPortTypeOperationElement:el portType:portType];
	}
}

- (void)processPortTypeOperationElement:(NSXMLElement *)el portType:(USPortType *)portType
{
	NSString *name = [[el attributeForName:@"name"] stringValue];
	
	USOperation *operation = [portType operationForName:name];
	operation.name = name;
	
	for(NSXMLNode *child in [el children]) {
		if([child kind] == NSXMLElementKind) {
			[self processPortTypeOperationChildElement:(NSXMLElement*)child operation:operation];
		}
	}
}

- (void)processPortTypeOperationChildElement:(NSXMLElement *)el operation:(USOperation *)operation
{
	NSString *localName = [el localName];
	
	if([localName isEqualToString:@"input"]) {
		[self processPortTypeInputElement:el operation:operation];
	} else if([localName isEqualToString:@"output"]) {
		[self processPortTypeOutputElement:el operation:operation];
	} else if([localName isEqualToString:@"fault"]) {
		[self processPortTypeFaultElement:el operation:operation];
	}
}

- (void)processPortTypeInputElement:(NSXMLElement *)el operation:(USOperation *)operation
{
	[self processPortTypeOperationInterfaceElement:el operationInterface:operation.input];
}

- (void)processPortTypeOutputElement:(NSXMLElement *)el operation:(USOperation *)operation
{
	[self processPortTypeOperationInterfaceElement:el operationInterface:operation.output];
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
