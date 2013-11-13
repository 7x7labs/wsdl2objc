//	Copyright 2005 Sunrise Telephone Systems Ltd. All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modi-
//	fication, are permitted provided that the following conditions are met:
//
//	Redistributions of source code must retain the above copyright notice,
//	this list of conditions and the following disclaimer.  Redistributions in
//	binary form must reproduce the above copyright notice, this list of
//	conditions and the following disclaimer in the documentation and/or other
//	materials provided with the distribution.  Neither the name of Sunrise
//	Telephone Systems Ltd. nor the names of its contributors may be used to
//	endorse or promote products derived from this software without specific
//	prior written permission.
//
//	THIS  SOFTWARE  IS  PROVIDED  BY  THE  COPYRIGHT HOLDERS  AND CONTRIBUTORS
//	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,  INCLUDING, BUT NOT LIMITED
//	TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//	PURPOSE  ARE  DISCLAIMED.  IN  NO  EVENT  SHALL  THE  COPYRIGHT  OWNER  OR
//	CONTRIBUTORS  BE  LIABLE  FOR  ANY  DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//	EXEMPLARY,  OR  CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT LIMITED  TO,
//	PROCUREMENT  OF SUBSTITUTE  GOODS  OR  SERVICES;  LOSS  OF  USE,  DATA, OR
//	PROFITS;  OR  BUSINESS  INTERRUPTION)  HOWEVER CAUSED AND ON ANY THEORY OF
//	LIABILITY,  WHETHER  IN  CONTRACT,  STRICT LIABILITY,  OR TORT  (INCLUDING
//	NEGLIGENCE OR OTHERWISE)  ARISING  IN  ANY  WAY  OUT  OF  THE  USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "STSStringOps.h"

#define AVG_WORD_LENGTH 8
#define AVG_LINE_LENGTH 80

#define found(x) (x.location != NSNotFound)

#define kWhitespace @" "
#define kTabulator @"\t"
#define kEmptyString @""
#define kEOLmarkers @"\r\n"

#define kUnicharCR (unichar)'\r'
#define kUnicharLF (unichar)'\n'

@implementation NSString (STSAdditionsToNSString)

- (BOOL)isEmpty
{
	return ([self length] == 0);
}

- (int)numberOfWords
{
	NSMutableCharacterSet *delimiterSet = [[NSCharacterSet punctuationCharacterSet] mutableCopy];

	[delimiterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return [self numberOfWordsUsingDelimitersFromSet:delimiterSet];
}

- (int)numberOfWordsUsingDelimitersFromSet:(NSCharacterSet *)delimiterSet;
{
	NSRange delimiter, range;
	unsigned len, wordCount = 0;

	if ([self length] == 0) {
		return 0;
	}
	if (delimiterSet == nil) {
		return 1;
	}

	len = [self length];
	range.location = 0; range.length = len;

	delimiter = [self rangeOfCharacterFromSet:[delimiterSet invertedSet] options:0 range:range];
	if found(delimiter) {
		range.location = delimiter.location;
	}
	else {
		return 0;
	}

	while (range.length > 0) {
		delimiter = [self rangeOfCharacterFromSet:delimiterSet options:0 range:range];
		if found(delimiter) {
			wordCount++;
			delimiter = [self rangeOfCharacterFromSet:[delimiterSet invertedSet] options:0 range:range];
			if found(delimiter) {
				range.location = delimiter.location;
				range.length = len - delimiter.location;
			}
			else {
				range.location = len+1;
				range.length = 0;
			}
		}
		else {
			wordCount++;
			range.location = len+1;
			range.length = 0;
		}
	}
	return wordCount;
}

- (NSString *)firstWord
{
	NSMutableCharacterSet *delimiterSet = [[NSCharacterSet punctuationCharacterSet] mutableCopy];

	[delimiterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return [self firstWordUsingDelimitersFromSet:delimiterSet];
}

- (NSString *)firstWordUsingDelimitersFromSet:(NSCharacterSet *)delimiterSet
{
	NSMutableString *remainder_ = [NSMutableString stringWithCapacity:[self length]];
	NSRange delimiter;

	if ([self length] == 0) {
		return self;
	}
	if (delimiterSet == nil) {
		return self;
	}

	[remainder_ setString:[self stringByTrimmingCharactersInSet:delimiterSet]];
	delimiter = [remainder_ rangeOfCharacterFromSet:delimiterSet];
	if found(delimiter) {
		return [remainder_ substringToIndex:delimiter.location];
	}
	else {
		return remainder_;
	}
}

- (NSString *)restOfWords
{
	NSMutableCharacterSet *delimiterSet = [[NSCharacterSet punctuationCharacterSet] mutableCopy];

	[delimiterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return [self restOfWordsUsingDelimitersFromSet:delimiterSet];
}

- (NSString *)restOfWordsUsingDelimitersFromSet:(NSCharacterSet *)delimiterSet
{
	NSMutableString *remainder_ = [NSMutableString stringWithCapacity:[self length]];
	NSRange delimiter;

	if ([self length] == 0) {
		return self;
	}
	if (delimiterSet == nil) {
		return self;
	}

	[remainder_ setString:[self stringByTrimmingCharactersInSet:delimiterSet]];
	delimiter = [remainder_ rangeOfCharacterFromSet:delimiterSet];
	if found(delimiter) {
		return [[remainder_ substringFromIndex:delimiter.location]
					stringByTrimmingCharactersInSet:delimiterSet];
	}
	else {
		return kEmptyString;
	}
}

- (NSString *)wordAtIndex:(int)anIndex
{
	NSMutableCharacterSet *delimiterSet = [[NSCharacterSet punctuationCharacterSet] mutableCopy];

	[delimiterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return [self wordAtIndex:anIndex usingDelimitersFromSet:delimiterSet];
}

- (NSString *)wordAtIndex:(int)anIndex usingDelimitersFromString:(NSString *)delimiters
{
	NSCharacterSet *delimiterSet = [NSCharacterSet characterSetWithCharactersInString:delimiters];
	return [self wordAtIndex:anIndex usingDelimitersFromSet:delimiterSet];
}

- (NSString *)wordAtIndex:(int)anIndex usingDelimitersFromSet:(NSCharacterSet *)delimiterSet
{
	NSMutableString *remainder_ = [NSMutableString stringWithCapacity:[self length]];
	NSRange delimiter;
	unsigned nextWord = 1;

	if ([self length] == 0) {
		return self;
	}
	if (anIndex < 1) {
		return kEmptyString;
	}
	if (delimiterSet == nil) {
		return self;
	}

	[remainder_ setString:[self stringByTrimmingCharactersInSet:delimiterSet]];
	while ((nextWord < anIndex) && ([remainder_ length] > 0)) {
		delimiter = [remainder_ rangeOfCharacterFromSet:delimiterSet];
		if found(delimiter) {
			[remainder_ setString:[remainder_ substringFromIndex:delimiter.location]];
			[remainder_ setString:[remainder_ stringByTrimmingCharactersInSet:delimiterSet]];
		}
		else {
			[remainder_ setString:kEmptyString];
		}
		nextWord++;
	}
	if (nextWord == anIndex) {
		delimiter = [remainder_ rangeOfCharacterFromSet:delimiterSet];
		if found(delimiter) {
			return [remainder_ substringToIndex:delimiter.location];
		}
		else {
			return remainder_;
		}
	}
	else {
		return kEmptyString;
	}
}

- (NSArray *)arrayBySeparatingWords
{
	NSMutableCharacterSet *delimiterSet = [[NSCharacterSet punctuationCharacterSet] mutableCopy];

	[delimiterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return [self arrayBySeparatingWordsUsingDelimitersFromSet:delimiterSet];
}

- (NSArray *)arrayBySeparatingWordsUsingDelimitersFromSet:(NSCharacterSet *)delimiterSet;
{
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:([self length] / AVG_WORD_LENGTH)];
	NSRange delimiter, word, range;
	unsigned len;

	if ([self length] == 0) {
		return @[];
	}
	if (delimiterSet == nil) {
		return @[self];
	}

	len = [self length];
	range.location = 0; range.length = len;

	delimiter = [self rangeOfCharacterFromSet:[delimiterSet invertedSet] options:0 range:range];
	if found(delimiter) {
		range.location = delimiter.location;
	}
	else {
		return @[];
	}

	while (range.length > 0) {
		delimiter = [self rangeOfCharacterFromSet:delimiterSet options:0 range:range];
		if found(delimiter) {
			word.location = delimiter.location;
			delimiter = [self rangeOfCharacterFromSet:[delimiterSet invertedSet] options:0 range:range];
			if found(delimiter) {
				word.length = delimiter.location - word.location;
				[result addObject:[self substringWithRange:word]];
				range.location = delimiter.location;
				range.length = len - delimiter.location;
			}
			else {
				range.location = len+1;
				range.length = 0;
			}
		}
		else {
			word = range;
			[result addObject:[self substringWithRange:word]];
			range.location = len+1;
			range.length = 0;
		}
	}
	return result;
}

- (NSArray *)arrayBySeparatingLinesUsingEOLmarkers;
{
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:([self length] / AVG_LINE_LENGTH)];
	NSCharacterSet *EOLmarkerSet = [NSCharacterSet characterSetWithCharactersInString:kEOLmarkers];
	NSRange EOLmarker, line, range;

	if ([self length] == 0) {
		return @[];
	}

	unsigned len = [self length];
	int previousMarkerWasCR = 0;
	range.location = 0; range.length = len;

	while (range.length > 0) {
		EOLmarker = [self rangeOfCharacterFromSet:EOLmarkerSet options:0 range:range];
		if found(EOLmarker) {
			if ((previousMarkerWasCR) && (EOLmarker.location == range.location) &&
				([self characterAtIndex:EOLmarker.location] == kUnicharLF)) {
				range.location++; range.length--;
			}
			else {
				line.location = range.location;
				line.length = EOLmarker.location - line.location;
				[result addObject:[self substringWithRange:line]];
				range.location = EOLmarker.location + 1;
				range.length = len - range.location;
			}
			previousMarkerWasCR = ([self characterAtIndex:EOLmarker.location] == kUnicharCR);
		}
		else {
			line = range;
			[result addObject:[self substringWithRange:line]];
			range.location = len+1;
			range.length = 0;
		}
	}
	return result;
}

@end

@implementation NSNumber (STSAdditionsToNSNumber)
- (BOOL)representsTrue
{
    return [self boolValue];
}
@end
