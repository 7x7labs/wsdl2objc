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

#import "USSequenceElement.h"
#import "USObjCKeywords.h"
#import "NSString+USAdditions.h"

@implementation USSequenceElement
@synthesize minOccurs;
@synthesize maxOccurs;
@synthesize name;
@synthesize wsdlName;
@synthesize type;

- (void) dealloc
{
    [name release];
    [wsdlName release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	USSequenceElement *newSeqElement = [USSequenceElement new];
	
	newSeqElement.minOccurs = self.minOccurs;
	newSeqElement.maxOccurs = self.maxOccurs;
	newSeqElement.name = self.name;
	newSeqElement.wsdlName = self.wsdlName;
	newSeqElement.type = self.type;
	
	return newSeqElement;
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

- (NSString *)uname
{
	return [self.name stringWithCapitalizedFirstCharacter];
}

- (NSString *)useAnArray
{
	if(self.maxOccurs == 0 || self.maxOccurs == 1) {
		return @"false";
	}
	
	return @"true";
}

@end
