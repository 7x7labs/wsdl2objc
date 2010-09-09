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

#import "USAttribute.h"
#import "USObjCKeywords.h"

@implementation USAttribute
@dynamic name;
@synthesize wsdlName;
@synthesize attributeDefault;
@synthesize schema;
@synthesize type;

- (id)init
{
	if((self = [super init]))
	{
		self.name = @"";
		self.wsdlName = @"";
		self.schema = nil;
		self.attributeDefault = @"";
		type = nil;
	}
	return self;
}

- (void)dealloc
{
	[name release];
	[wsdlName release];
	[attributeDefault release];
	[super dealloc];
}

- (NSDictionary *)templateKeyDictionary
{
	NSMutableDictionary *returning = [NSMutableDictionary dictionary];
	
	[returning setObject:self.name forKey:@"name"];
	[returning setObject:self.type.typeName forKey:@"typeName"];
	[returning setObject:self.attributeDefault forKey:@"default"];
	
	return returning;
}

- (NSString *)name
{
	return name;
}

- (void)setName:(NSString *)aName
{
	USObjCKeywords *keywords = [USObjCKeywords sharedInstance];
	
	self.wsdlName = aName;
	if([keywords isAKeyword:aName]) {
		aName = [NSString stringWithFormat:@"%@_", aName];
	}
	
	if(name != nil) [name autorelease];
	name = [aName copy];
}

@end
