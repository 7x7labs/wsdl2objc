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

#import <Foundation/Foundation.h>
#import "USParser.h"

@class USSchema;
@class USBinding;
@class USOperation;
@class USOperationInterface;
@class USOperationFault;

@interface USParser (Bindings)

- (void)processBindingElement:(NSXMLElement *)el schema:(USSchema *)schema;
- (void)processBindingChildElement:(NSXMLElement *)el binding:(USBinding *)binding;
- (void)processSoapBindingElement:(NSXMLElement *)el binding:(USBinding *)binding;
- (void)processBindingOperationElement:(NSXMLElement *)el binding:(USBinding *)binding;
- (void)processBindingOperationChildElement:(NSXMLElement *)el operation:(USOperation *)operation;
- (void)processSoapOperationElement:(NSXMLElement *)el operation:(USOperation *)operation;
- (void)processBindingOperationInputElement:(NSXMLElement *)el operation:(USOperation *)operation;
- (void)processBindingOperationOutputElement:(NSXMLElement *)el operation:(USOperation *)operation;
- (void)processBindingOperationInterfaceElement:(NSXMLElement *)el operationInterface:(USOperationInterface *)interface;
- (void)processBindingOperationInterfaceChildElement:(NSXMLElement *)el operationInterface:(USOperationInterface *)interface;
- (void)processSoapHeaderElement:(NSXMLElement *)el operationInterface:(USOperationInterface *)interface;
- (void)processSoapBodyElement:(NSXMLElement *)el operationInterface:(USOperationInterface *)interface;
- (void)processBindingOperationFaultElement:(NSXMLElement *)el operation:(USOperation *)operation;
- (void)processBindingOperationFaultChildElement:(NSXMLElement *)el fault:(USOperationFault *)fault;
- (void)processSoapFaultElement:(NSXMLElement *)el fault:(USOperationFault *)fault;

@end
