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

#import "USBinding.h"

#import "USPortType.h"
#import "USObjCKeywords.h"
#import "NSBundle+USAdditions.h"

@implementation USBinding

@synthesize name;
@synthesize portType;
@synthesize soapVersion;
@synthesize schema;
@dynamic className;

- (id)init
{
	if((self = [super init])) {
		self.name = nil;
		self.portType = [[USPortType new] autorelease];
        self.soapVersion = @"1.1";
		self.schema = nil;
	}
	
	return self;
}

- (void) dealloc
{
    [name release];
    [portType release];
    [soapVersion release];
    [super dealloc];
}

- (NSString *)className
{
	NSString *result = [[self.name componentsSeparatedByCharactersInSet:kIllegalClassCharactersSet] componentsJoinedByString:@""];
	if(![result.lowercaseString hasSuffix:@"binding"])
		result = [result stringByAppendingString:@"Binding"];
	return result;
}

- (NSMutableArray *)operations
{
	return self.portType.operations;
}

- (NSString *)templateFileHPath
{
	return [[NSBundle mainBundle] pathForTemplateNamed:@"Binding_H"];
}

- (NSString *)templateFileMPath
{
	return [[NSBundle mainBundle] pathForTemplateNamed:@"Binding_M"];
}

- (NSDictionary *)templateKeyDictionary
{
	NSMutableDictionary *returning = [NSMutableDictionary dictionary];
	
	[returning setObject:self.name forKey:@"name"];
	[returning setObject:self.className forKey:@"className"];
	[returning setObject:self.portType forKey:@"portType"];
	[returning setObject:self.soapVersion forKey:@"soapVersion"];
	[returning setObject:[self operations] forKey:@"operations"];
	[returning setObject:self.schema forKey:@"schema"];
	
	return returning;
}

@end
