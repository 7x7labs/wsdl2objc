/*
 Copyright (c) 2013 7x7 Labs Inc.

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

#import "NSXMLElement+Children.h"

@implementation NSXMLElement (Children)
- (NSArray *)childElements {
    NSMutableArray *ret = [NSMutableArray new];
    for (NSXMLNode *child in self.children) {
		if ([child kind] == NSXMLElementKind)
            [ret addObject:child];
    }
    return ret;
}

- (NSArray *)childElementsWithName:(NSString *)localName {
    NSMutableArray *ret = [NSMutableArray new];
    for (NSXMLNode *child in self.children) {
		if ([child kind] == NSXMLElementKind && [child.localName isEqualToString:localName])
            [ret addObject:child];
    }
    return ret;
}

- (NSXMLElement *)childElementWithNames:(NSArray *)localNames parentName:(NSString *)name {
    for (NSXMLElement *child in self.children) {
		if ([child kind] == NSXMLElementKind && [localNames containsObject:child.localName])
            return child;
    }
    return nil;
}

- (BOOL)isSoapNS {
    NSString *namespace = [[self resolveNamespaceForName:[self name]] stringValue];
    return [namespace isEqualToString:@"http://schemas.xmlsoap.org/wsdl/soap/"]
        || [namespace isEqualToString:@"http://schemas.xmlsoap.org/wsdl/soap12/"];
}

@end
