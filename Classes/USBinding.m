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
#import "USSchema.h"
#import "USWSDL.h"
#import "USObjCKeywords.h"
#import "NSBundle+USAdditions.h"

@implementation USBinding
- (id)init
{
	if ((self = [super init])) {
		self.portType = [USPortType new];
        self.soapVersion = @"1.1";
	}

	return self;
}

- (NSString *)cleanName
{
	NSString *result = [[self.name componentsSeparatedByCharactersInSet:kIllegalClassCharactersSet] componentsJoinedByString:@""];
	if (![result.lowercaseString hasSuffix:@"binding"])
		result = [result stringByAppendingString:@"Binding"];
	return result;
}

- (NSString *)className
{
    NSString *prefixedName = [NSString stringWithFormat:@"%@_%@", self.schema.wsdl.targetNamespace.prefix, self.name];
    ;
	NSString *result = [[prefixedName componentsSeparatedByCharactersInSet:kIllegalClassCharactersSet] componentsJoinedByString:@""];
	if (![result.lowercaseString hasSuffix:@"binding"])
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
    return @{@"name": self.name,
             @"className": self.className,
             @"portType": self.portType,
             @"soapVersion": self.soapVersion,
             @"operations": [self operations],
             @"schema": self.schema};
}

@end
