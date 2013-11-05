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

#import "USParser+Bindings.h"

#import "NSXMLElement+Children.h"

#import "USSchema.h"
#import "USBinding.h"
#import "USOperation.h"
#import "USOperationInterface.h"
#import "USOperationFault.h"
#import "USWSDL.h"
#import "USPortType.h"
#import "USPart.h"
#import "USMessage.h"

@implementation USParser (Bindings)

- (void)processBindingElement:(NSXMLElement *)el schema:(USSchema *)schema
{
    NSString *name = [[el attributeForName:@"name"] stringValue];
    USBinding *binding = [schema bindingForName:name];

    NSString *type = [[el attributeForName:@"type"] stringValue];

    NSString *uri = [[el resolveNamespaceForName:type] stringValue];
    USSchema *typeSchema = [schema.wsdl schemaForNamespace:uri];

    NSString *typeLocalName = [NSXMLNode localNameForName:type];
    USPortType *portType = [typeSchema portTypeForName:typeLocalName];
    binding.portType = portType;

    for (NSXMLElement *child in [el childElements])
        [self processBindingChildElement:child binding:binding];
}

- (void)processBindingChildElement:(NSXMLElement *)el binding:(USBinding *)binding
{
    NSString *localName = [el localName];

    if ([localName isEqualToString:@"binding"]) {
        NSString *namespace = [[el resolveNamespaceForName:[el name]] stringValue];
        if ([namespace isEqualToString:@"http://schemas.xmlsoap.org/wsdl/soap/"] ||
           [namespace isEqualToString:@"http://schemas.xmlsoap.org/wsdl/soap12/"]) {
            [self processSoapBindingElement:el binding:binding];
        }
    } else if ([localName isEqualToString:@"operation"]) {
        [self processBindingOperationElement:el binding:binding];
    }
}

- (void)processSoapBindingElement:(NSXMLElement *)el binding:(USBinding *)binding
{
    //This space intentionally left blank
    //I don't know yet how this element might affect the generated code so I don't bother to parse it
}

- (void)processBindingOperationElement:(NSXMLElement *)el binding:(USBinding *)binding
{
    NSString *name = [[el attributeForName:@"name"] stringValue];
    USOperation *operation = [binding.portType operationForName:name];

    for (NSXMLElement *child in [el childElements])
        [self processBindingOperationChildElement:child operation:operation];
}

- (void)processBindingOperationChildElement:(NSXMLElement *)el operation:(USOperation *)operation
{
    NSString *localName = [el localName];

    if ([localName isEqualToString:@"operation"]) {
        NSString *namespace = [[el resolveNamespaceForName:[el name]] stringValue];
        if ([namespace isEqualToString:@"http://schemas.xmlsoap.org/wsdl/soap/"] ||
           [namespace isEqualToString:@"http://schemas.xmlsoap.org/wsdl/soap12/"]) {
            [self processSoapOperationElement:el operation:operation];
        }
    } else if ([localName isEqualToString:@"input"]) {
        [self processBindingOperationInterfaceElement:el operationInterface:operation.input];
    } else if ([localName isEqualToString:@"output"]) {
        [self processBindingOperationInterfaceElement:el operationInterface:operation.output];
    } else if ([localName isEqualToString:@"fault"]) {
        [self processBindingOperationFaultElement:el operation:operation];
    }
}

- (void)processSoapOperationElement:(NSXMLElement *)el operation:(USOperation *)operation
{
    operation.soapAction = [[el attributeForName:@"soapAction"] stringValue];
}

- (void)processBindingOperationInterfaceElement:(NSXMLElement *)el operationInterface:(USOperationInterface *)interface
{
    for (NSXMLElement *child in [el childElements])
        [self processBindingOperationInterfaceChildElement:child operationInterface:interface];
}

- (void)processBindingOperationInterfaceChildElement:(NSXMLElement *)el operationInterface:(USOperationInterface *)interface
{
    NSString *localName = [el localName];

    if ([localName isEqualToString:@"header"]) {
        NSString *namespace = [[el resolveNamespaceForName:[el name]] stringValue];
        if ([namespace isEqualToString:@"http://schemas.xmlsoap.org/wsdl/soap/"] ||
           [namespace isEqualToString:@"http://schemas.xmlsoap.org/wsdl/soap12/"]) {
            [self processSoapHeaderElement:el operationInterface:interface];
        }
    } else if ([localName isEqualToString:@"body"]) {
        NSString *namespace = [[el resolveNamespaceForName:[el name]] stringValue];
        if ([namespace isEqualToString:@"http://schemas.xmlsoap.org/wsdl/soap/"] ||
           [namespace isEqualToString:@"http://schemas.xmlsoap.org/wsdl/soap12/"]) {
            [self processSoapBodyElement:el operationInterface:interface];
        }
    }
}

- (void)processSoapHeaderElement:(NSXMLElement *)el operationInterface:(USOperationInterface *)interface
{
    NSString *messageQName = [[el attributeForName:@"message"] stringValue];
    NSString *uri = [[el resolveNamespaceForName:messageQName] stringValue];
    USSchema *messageSchema = [interface.operation.portType.schema.wsdl schemaForNamespace:uri];
    NSString *messageLocalName = [NSXMLNode localNameForName:messageQName];
    USMessage *message = [messageSchema messageForName:messageLocalName];

    NSString *partName = [[el attributeForName:@"part"] stringValue];
    USPart *part = [message partForName:partName];

    if (part.element) {
        [interface.headers addObject:part.element];
    } else {
        NSLog(@"WARNING: No part '%@' in message '%@', referenced in element:\n%@", partName, messageQName, el);
    }
}

- (void)processSoapBodyElement:(NSXMLElement *)el operationInterface:(USOperationInterface *)interface
{
    //This space intentionally left blank
    //I don't know yet how this element might affect the generated code so I don't bother to parse it
}

- (void)processBindingOperationFaultElement:(NSXMLElement *)el operation:(USOperation *)operation
{
    NSString *faultName = [[el attributeForName:@"name"] stringValue];
    USOperationFault *fault = [operation faultForName:faultName];

    for (NSXMLElement *child in [el childElementsWithName:@"fault"])
        [self processBindingOperationFaultChildElement:child fault:fault];
}

- (void)processBindingOperationFaultChildElement:(NSXMLElement *)el fault:(USOperationFault *)fault
{
    NSString *namespace = [[el resolveNamespaceForName:[el name]] stringValue];
    if ([namespace isEqualToString:@"http://schemas.xmlsoap.org/wsdl/soap/"] ||
        [namespace isEqualToString:@"http://schemas.xmlsoap.org/wsdl/soap12/"]) {
        [self processSoapFaultElement:el fault:fault];
    }
}

- (void)processSoapFaultElement:(NSXMLElement *)el fault:(USOperationFault *)fault
{
    //This space intentionally left blank
    //I don't know yet how this element might affect the generated code so I don't bother to parse it
}

@end
