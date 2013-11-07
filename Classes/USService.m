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

#import "USService.h"

#import "NSBundle+USAdditions.h"
#import "NSString+USAdditions.h"
#import "NSXMLElement+Children.h"
#import "USPort.h"

@implementation USService
+ (instancetype)serviceWithElement:(NSXMLElement *)el schema:(USSchema *)schema {
    NSString *name = [[el attributeForName:@"name"] stringValue];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"addTagToServiceName"] boolValue])
        name = [name stringByAppendingString:@"Svc"];

    USService *service = [USService new];
    service.name = name;
    NSMutableArray *ports = [NSMutableArray new];
    for (NSXMLElement *child in [el childElementsWithName:@"port"]) {
        USPort *port = [USPort portWithElement:child schema:schema];
        if (port)
            [ports addObject:port];
    }
    service.ports = ports;
    return service;
}

- (NSString *)className {
	return [self.name stringByRemovingIllegalCharacters];
}

- (NSString *)templateFileHPath {
	return [[NSBundle mainBundle] pathForTemplateNamed:@"Service_H"];
}

- (NSString *)templateFileMPath {
	return [[NSBundle mainBundle] pathForTemplateNamed:@"Service_M"];
}

- (NSDictionary *)templateKeyDictionary {
    return @{@"name": self.name,
             @"className": self.className,
             @"ports": self.ports};
}
@end
