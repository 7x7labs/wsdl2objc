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

#import "USParser+Messages.h"

#import "USMessage.h"
#import "USSchema.h"
#import "USPart.h"
#import "USWSDL.h"
#import "USElement.h"

@implementation USParser (Messages)

- (void)processMessageElement:(NSXMLElement *)el schema:(USSchema *)schema
{
	USMessage *message = [schema messageForName:[[el attributeForName:@"name"] stringValue]];
    if (message.hasBeenParsed) return;

    for (NSXMLNode *child in [el children]) {
        if ([child kind] != NSXMLElementKind) continue;

        if ([[el localName] isEqualToString:@"part"]) {
            [self processPartElement:el message:message];
        }
    }

    message.hasBeenParsed = YES;
}

- (void)processPartElement:(NSXMLElement *)el message:(USMessage *)message
{
	NSString *name = [[el attributeForName:@"name"] stringValue];
	USPart *part = [message partForName:name];

	NSString *elementQName = [[el attributeForName:@"element"] stringValue];
	if (elementQName) {
		NSString *uri = [[el resolveNamespaceForName:elementQName] stringValue];
		USSchema *elementSchema = [message.schema.wsdl schemaForNamespace:uri];
		NSString *elementLocalName = [NSXMLNode localNameForName:elementQName];
		part.element = [elementSchema elementForName:elementLocalName];
        return;
	}

    NSString *typeQName = [[el attributeForName:@"type"] stringValue];
    if (typeQName) {
        NSString *uri = [[el resolveNamespaceForName:typeQName] stringValue];
        USSchema *elementSchema = [message.schema.wsdl schemaForNamespace:uri];
        NSString *elementLocalName = [NSXMLNode localNameForName:typeQName];
        part.element = [USElement new];
        part.element.name = name;
        part.element.schema = elementSchema;
        part.element.type = [elementSchema typeForName:elementLocalName];
        part.element.hasBeenParsed = YES;
    }
}

@end
