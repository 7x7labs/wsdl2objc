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

#import "USObjCKeywords.h"

static USObjCKeywords *sharedInstance = nil;

@implementation USObjCKeywords

+ (USObjCKeywords *)sharedInstance
{
	if(sharedInstance == nil) {
		sharedInstance = [USObjCKeywords new];
	}
	
	return sharedInstance;
}

- (id)init
{
	// Also included here are standard Mac/iPhone typedefs that might
	// be likely names of attributes as these cause the compiler to
	// complain as well.

	if((self = [super init])) {
		keywords = [NSArray arrayWithObjects:
					@"id",
					@"for",
					@"self",
					@"super",
					@"return",
					@"const",
					@"volatile",
					@"in",
					@"out",
					@"inout",
					@"bycopy",
					@"byref",
					@"oneway",
					@"void",
					@"char",
					@"short",
					@"int",
					@"long",
					@"float",
					@"double",
					@"signed",
					@"unsigned",
					@"class",
					@"break",
					@"switch",
					@"default",
					@"case",
					@"inline",
								
					// Standard Mac/iPhone types that might be chosen as attribute names
					@"fixed",
					@"ptr",
					@"handle",
					@"size",
					@"bytecount",
					@"byteoffset",
					@"duration",
					@"absolutetime",
					@"itemcount",
					@"langcode",
					@"regioncode",
					@"oserr",
					@"ostype",
					@"osstatus",
					@"point",
					@"style",
					
					// Variable names used during serialization
					@"doc",
					@"root",
					@"ns",
					@"xsi",
					@"node",
					@"buf",
					
					// more:
					@"method",
					@"category",
					nil];
	}
	
	return self;
}

- (BOOL)isAKeyword:(NSString *)testString
{
  // Compiler objects to things with the same name as keywords even if the
  // case differs, so convert to lower case for the test.
  
	if([keywords containsObject:[testString lowercaseString]]) {
		return YES;
	}
	
	return NO;
}

@end
