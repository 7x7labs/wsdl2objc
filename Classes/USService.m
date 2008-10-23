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

#import "USPort.h"
#import "USObjCKeywords.h"

@implementation USService

@synthesize name;
@synthesize ports;
@synthesize schema;
@dynamic className;

- (id)init
{
	if((self = [super init])) {
		self.name = nil;
		self.ports = [NSMutableArray array];
		self.schema = nil;
	}
	
	return self;
}

- (USPort *)portForName:(NSString *)aName
{
	for(USPort *port in self.ports) {
		if([port.name isEqualToString:aName]) {
			return port;
		}
	}
	
	USPort *newPort = [[USPort new] autorelease];
	newPort.service = self;
	newPort.name = aName;
	[self.ports addObject:newPort];
	
	return newPort;
}

- (NSString *)className
{
	return [self.name stringByReplacingOccurrencesOfString:kIllegalClassCharactersString withString:@""];
}

- (NSString *)templateFileHPath
{
	return [[NSBundle mainBundle] pathForResource:@"Service_H" ofType:@"template"];
}

- (NSString *)templateFileMPath
{
	return [[NSBundle mainBundle] pathForResource:@"Service_M" ofType:@"template"];
}

- (NSDictionary *)templateKeyDictionary
{
	NSMutableDictionary *returning = [NSMutableDictionary dictionary];
	
	[returning setObject:self.name forKey:@"name"];
	[returning setObject:self.className forKey:@"className"];
	[returning setObject:self.ports forKey:@"ports"];
	[returning setObject:self.schema forKey:@"schema"];
	
	return returning;
}

@end
