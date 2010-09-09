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
	//#define DEBUG
#ifdef DEBUG
#define NVLOG(__NSSTRING, ...) \
NSLog(@"%s[%d] >> " __NSSTRING, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__ )
#else
#define NVLOG(__NSSTRING, ...) 
#endif

@class USWSDL;
@class USSchema;

@interface USParser : NSObject {
	NSURL *baseURL;
}

- (id)initWithURL:(NSURL *)anURL;
- (void)dealloc;
- (USWSDL*)parse;

- (void)processDefinitionsElement:(NSXMLElement *)el wsdl:(USWSDL *)wsdl;
- (void)processDefinitionsChildElement:(NSXMLElement *)el wsdl:(USWSDL *)wsdl;
- (void)processDefinitionsImportElement:(NSXMLElement *)el wsdl:(USWSDL *)wsdl;
- (void)processImportElement:(NSXMLElement *)el wsdl:(USWSDL *)wsdl;
- (void)processSchemaElement:(NSXMLElement *)el wsdl:(USWSDL *)wsdl;
- (void)processNamespace:(NSXMLNode *)ns wsdl:(USWSDL *)wsdl;
- (void)processSchemaChildElement:(NSXMLElement *)el schema:(USSchema *)schema;
- (void)processSchemaImportElement:(NSXMLElement *)el schema:(USSchema *)schema;

@end
