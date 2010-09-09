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

#import "USParser+Services.h"

#import "USSchema.h"
#import "USService.h"
#import "USPort.h"
#import "USBinding.h"
#import "USWSDL.h"

@implementation USParser (Services)

- (void)processServiceElement:(NSXMLElement *)el schema:(USSchema *)schema
{
	NSString *name = [[el attributeForName:@"name"] stringValue];
	
	if([[[NSUserDefaults standardUserDefaults] objectForKey:@"addTagToServiceName"] boolValue]) {
		name = [name stringByAppendingString:@"Svc"];
	}
	
	USService *service = [schema serviceForName:name];
	
	schema.wsdl.targetNamespace.prefix = name;
	
	for(NSXMLNode *child in [el children]) {
		if([child kind] == NSXMLElementKind) {
			[self processServiceChildElement:(NSXMLElement*)child service:service];
		}
	}
}

- (void)processServiceChildElement:(NSXMLElement *)el service:(USService *)service
{
	NSString *localName = [el localName];
	
	if([localName isEqualToString:@"port"]) {
		[self processPortElement:el service:service];
	}
}

- (void)processPortElement:(NSXMLElement *)el service:(USService *)service
{
	NSString *name = [[el attributeForName:@"name"] stringValue];
	USPort *port = [service portForName:name];
	
	NSString *bindingQName = [[el attributeForName:@"binding"] stringValue];
	NSString *uri = [[el resolveNamespaceForName:bindingQName] stringValue];
	USSchema *bindingSchema = [service.schema.wsdl schemaForNamespace:uri];
	NSString *bindingLocalName = [NSXMLNode localNameForName:bindingQName];
	USBinding *binding = [bindingSchema bindingForName:bindingLocalName];
	
	port.binding = binding;
	
	for(NSXMLNode *child in [el children]) {
		if([child kind] == NSXMLElementKind) {
			[self processPortChildElement:(NSXMLElement*)child port:port];
		}
	}
}

- (void)processPortChildElement:(NSXMLElement *)el port:(USPort *)port
{
	NSString *localName = [el localName];
	
	if([localName isEqualToString:@"address"]) {
		NSString *namespace = [[el resolveNamespaceForName:[el name]] stringValue];
		if([namespace isEqualToString:@"http://schemas.xmlsoap.org/wsdl/soap/"] ||
		   [namespace isEqualToString:@"http://schemas.xmlsoap.org/wsdl/soap12/"]) {
			[self processSoapAddressElement:el port:port];
		} else {
			[port.service.ports removeObject:port];
		}
	}
}

- (void)processSoapAddressElement:(NSXMLElement *)el port:(USPort *)port
{
	NSString *location = [[el attributeForName:@"location"] stringValue];
    NSString *namespace = [[el resolveNamespaceForName:[el name]] stringValue];
	port.address = location;
    if ([namespace isEqualToString:@"http://schemas.xmlsoap.org/wsdl/soap/"]) {
        port.binding.soapVersion = @"1.1";
    } else if ([namespace isEqualToString:@"http://schemas.xmlsoap.org/wsdl/soap12/"]) {
        port.binding.soapVersion = @"1.2";
    }
}


@end
