//
//	STSStringOps.h
//	STS Additions to NSString ver 1.00
//
//	Provides additional methods for NSString.
//
//	Created by benjk on 6/28/05.
//
//	This software is released as open source under the terms of the new BSD
//	License obtained from http://www.opensource.org/licenses/bsd-license.php
//	on Tuesday, July 19, 2005.  The full license text follows below.
//
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
//

#import "STSStringOps.h"

// ---------------------------------------------------------------------------
//	Averages used to calculate the initial capacity of mutable arrays
// ---------------------------------------------------------------------------

#define AVG_WORD_LENGTH 8
#define AVG_LINE_LENGTH 80

// ---------------------------------------------------------------------------
//	Macro for use in if-clauses when testing NSRange variables
// ---------------------------------------------------------------------------

#define found(x) (x.location != NSNotFound)

// ---------------------------------------------------------------------------
//	Literals for whitespace, tab and empty string
// ---------------------------------------------------------------------------

// string literals
#define kWhitespace @" "
#define kTabulator @"\t"
#define kEmptyString @""
#define kEOLmarkers @"\r\n"

// unichar literals
#define kUnicharCR (unichar)'\r'
#define kUnicharLF (unichar)'\n'


@implementation NSString (STSAdditionsToNSString)

// ---------------------------------------------------------------------------
//	Instance Method:  isEmpty
// ---------------------------------------------------------------------------
//
// convenience method to test if the receiver's length is zero.

- (BOOL)isEmpty
{
	return ([self length] == 0);
} // end method

// ---------------------------------------------------------------------------
//	Instance Method:  representsTrue
// ---------------------------------------------------------------------------
//
// returns YES if the receiver represents logical true, otherwise returns NO.
// the receiver represents logical true if its all lowercase representation
// is equal to "1", "yes" or "true". returns NO if the receiver is nil.

- (BOOL)representsTrue
{
	NSString *lowercaseSelf;
	
	if (self == nil) {
		return NO;
	} // end if
	lowercaseSelf = [self lowercaseString];
	return (([lowercaseSelf isEqualToString:@"1"]) ||
			([lowercaseSelf isEqualToString:@"yes"]) ||
			([lowercaseSelf isEqualToString:@"true"]));
} // end method

// ---------------------------------------------------------------------------
//	Instance Method:  rangeOfWhitespace
// ---------------------------------------------------------------------------
//
// convenience method invoking characterSetWithCharactersInString: using only
// the whitespace character in the character set.

- (NSRange)rangeOfWhitespace
{
	return [self rangeOfCharacterFromSet:
		[NSCharacterSet characterSetWithCharactersInString:kWhitespace]];
} // end method

// ---------------------------------------------------------------------------
//	Instance Method:  stringByTrimmingWhitespace
// ---------------------------------------------------------------------------
//
// pre-conditions:
//  the receiver is an NSString, it may be an empty string.
//
// post-conditions:
//  a modified copy of the receiver is returned, trimmed as follows ...
//  any leading whitespace and tab characters in the receiver are removed.
//  any trailing whitespcae and tab characters in the receiver are removed.
//  if the receiver is empty, an empty string is returned
//
// error-condtions:
//  if the receiver is nil, nil is returned

- (NSString *)stringByTrimmingWhitespace
{
	if (self == nil) {
		return nil;
	} // end if
	
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
} // end method

// ---------------------------------------------------------------------------
//	Instance Method:  stringByCollapsingWhitespace
// ---------------------------------------------------------------------------
//
// pre-conditions:
//  the receiver is an NSString, it may be an empty string.
//
// post-conditions:
//  a modified copy of the receiver is returned, collapsed as follows ...
//  any group of multiple whitespace characters is replaced by a single
//  whitespace; any group of multiple tab characters is replaced by a single
//  tab; any mixed group of whitespace and tab characters is replaced by a
//  single tab; if the receiver is empty, an empty string is returned
//
// error-condtions:
//  if the receiver is nil, nil is returned

- (NSString *)stringByCollapsingWhitespace
{
	NSMutableString *remainder_ = [NSMutableString stringWithCapacity:[self length]];
	NSMutableString *result = [NSMutableString stringWithCapacity:[self length]];
	NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
	NSCharacterSet *invertedWhitespaceSet = [whitespaceSet invertedSet];
	NSCharacterSet *tabulatorSet = [NSCharacterSet characterSetWithCharactersInString:kTabulator];
	NSRange token, range;
	
	// first check pre-conditions
	if (self == nil) {
		return nil;
	} // end if
	if ([self length] == 0) {
		return self;
	} // end if
	
	// initialise the source string
	[remainder_ setString:self];
	// set the start value of the search range which always stays 0
	range.location = 0;
	// if the source string is empty or contains only one character ...
	if ([remainder_ length] < 2) {
		// return it as it is and we're done
		return remainder_;
	}
	// if the source string contains more than one character ...
	else {
		// for as long as we have characters in the remaining source string ...
		while ([remainder_ length] > 0) {
			// find the first whitespace or tab in the remainder_
			token = [remainder_ rangeOfCharacterFromSet:whitespaceSet];
			// if we find a whitespace or tab ...
			if found(token) {
				// append substring preceeding whitespace/tab to the result string
				[result appendString:[remainder_ substringToIndex:token.location]];
				// remove substring preceeding whitespace/tab from the remainder_
				range.length = token.location;
				[remainder_ deleteCharactersInRange:range];
				// find first non-whitespace and non-tab in the remainder_
				range.length = [remainder_ length];
				token = [remainder_ rangeOfCharacterFromSet:invertedWhitespaceSet options:0 range:range];
				// if we find any non-whitespace or non-tab ...
				if found(token) {
					// define search range as the area containing the preceeding characters
					range.length = token.location;
				} // end if
				  // if we don't find any non-whitespace/non-tab in the search range ...
				  // ... then the search range remains the same as for the previous search
				  // find tab in this search range
				token = [remainder_ rangeOfCharacterFromSet:tabulatorSet options:0 range:range];
				// if we find a tab ...
				if found(token) {
					// append a tab to the result string
					[result appendString:kTabulator];
				}
				// if we don't find a tab ...
				else {
					// append a whitespace to the result string
					[result appendString:kWhitespace];
				} // end if
				// remove substring preceeding whitespace/tab from the remainder_
				[remainder_ deleteCharactersInRange:range];
			}
			// if we don't find any whitespace nor tab ...
			else {
				// append the entire remainder_ to the result string
				[result appendString:remainder_];
				// remove remaining characters in remainder_
				[remainder_ setString:kEmptyString];
			} // end if
		} // end while
		// return the result string and we're done
		return result;
	} // end if
} // end method

// ---------------------------------------------------------------------------
//	Private Instance Method:  substringWithStringBetweenDelimiters:
// ---------------------------------------------------------------------------
//
// pre-conditions:
//  the receiver is an NSString, it may be an empty string.
//
// post-conditions:
//  a new string is returned containing the characters of the receiver between
//  the first and second ocurrence of the delimiter character delimChar.
//  the returned string does not include the delimiters. returns nil
//  if no matching pair of delimiters is found in the receiver.
//
// error-condtions:
//  if the receiver is nil, nil is returned

- (NSString *)substringWithStringBetweenDelimiters:(unichar)delimChar
{
	NSString *delimStr = [NSString stringWithFormat:@"%C", delimChar];
	NSRange range, delimiter;
	
	// first check pre-conditions
	if (self == nil) {
		return nil;
	} // end if
	
	// find the first delimiter character
	delimiter = [self rangeOfString:delimStr];
	// if there is a delimiter character ...
	if found(delimiter) {
		// set the search range starting with the character after the delimiter
		range.location = delimiter.location + 1;
		range.length = [self length] - range.location;
		// find the matching closing delimiter character
		delimiter = [self rangeOfString:delimStr options:0 range:range];
		// if there is a matching closing delimiter character ...
		if found(delimiter) {
			// set the range's length to the character before the delimiter
			range.length = range.location + delimiter.location - 1;
			// return the characters within the range
			return [self substringWithRange:range];
		} // end if
	} // end if

	// if we got here then there was no matching pair - return nil
	return nil;
} // end method

// ---------------------------------------------------------------------------
//	Instance Method:  substringWithStringInSingleQuotes
// ---------------------------------------------------------------------------
//
// pre-conditions:
//  the receiver is an NSString, it may be an empty string.
//
// post-conditions:
//  a new string is returned containing the characters of the receiver between
//	the first and the second ocurrence of the apostrophe character (U+0027).
//  the returned string does not include the apostrophes. returns nil
//	if no matching pair of apostrophes is found in the receiver.
//
// error-condtions:
//  if the receiver is nil, nil is returned

- (NSString *)substringWithStringInSingleQuotes
{
	return [self substringWithStringBetweenDelimiters:'\''];
} // end method

// ---------------------------------------------------------------------------
//	Instance Method:  substringWithStringInDoubleQuotes
// ---------------------------------------------------------------------------
//
// pre-conditions:
//  the receiver is an NSString, it may be an empty string.
//
// post-conditions:
//  a new string is returned containing the characters of the receiver between
//  the first and second ocurrence of the quotation mark character (U+0022).
//  the returned string does not include the quotation marks. returns nil
//  if no matching pair of quotation marks is found in the receiver.
//
// error-condtions:
//  if the receiver is nil, nil is returned

- (NSString *)substringWithStringInDoubleQuotes
{
	return [self substringWithStringBetweenDelimiters:'"'];
} // end method

// ---------------------------------------------------------------------------
//	Instance Method:  numberOfWords
// ---------------------------------------------------------------------------
//
// Invokes numberOfWordsUsingDelimitersFromSet: with a union of character sets
// punctuationCharacterSet and whitespaceAndNewlineCharacterSet.

- (int)numberOfWords
{
	NSMutableCharacterSet *delimiterSet = [[NSCharacterSet punctuationCharacterSet] mutableCopy];
	
	// set default delimiter character set to punctuation, whitespace, tab and newline chars
	[delimiterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	// return first word using default delimiter character set
	return [self numberOfWordsUsingDelimitersFromSet:delimiterSet];
} // end method

// ---------------------------------------------------------------------------
//	Instance Method:  numberOfWordsUsingDelimitersFromString:
// ---------------------------------------------------------------------------
//
// Invokes numberOfWordsUsingDelimitersFromSet: with a character set made from
// characters in string delimiters.

- (int)numberOfWordsUsingDelimitersFromString:(NSString *)delimiters
{
	NSCharacterSet *delimiterSet = [NSCharacterSet characterSetWithCharactersInString:delimiters];
	// return first word using given delimiters
	return [self numberOfWordsUsingDelimitersFromSet:delimiterSet];
} // end method

// ---------------------------------------------------------------------------
//	Instance Method:  numberOfWordsUsingDelimitersFromSet:
// ---------------------------------------------------------------------------
//
// pre-conditions:
//  the receiver is an NSString, it may be an empty string.
//
// post-conditions:
//  the number of words in the receiver is returned, using character set
//  delimiterSet as word delimiters. leading and trailing delimiters are
//  ignored. if the receiver is an empty string, zero is returned.
//  if delimiterSet is nil and the receiver is not an empty string, one
//  will be returned.
//
// error-condtions:
//  if the receiver is nil, nil is returned

- (int)numberOfWordsUsingDelimitersFromSet:(NSCharacterSet *)delimiterSet;
{
	NSRange delimiter, range;
	unsigned len, wordCount = 0;

	// first check pre-conditions
	if (self == nil) {
		return 0;
	} // end if
	if ([self length] == 0) {
		return 0;
	} // end if
	if (delimiterSet == nil) {
		return 1;
	} // end if
	
	// remember the length of the receiver
	len = [self length];
	// initialise the search range
	range.location = 0; range.length = len;

	// move search range to the first non-delimiter character in the receiver
	delimiter = [self rangeOfCharacterFromSet:[delimiterSet invertedSet] options:0 range:range];
	// if we find a non-delimiter character ...
	if found(delimiter) {
		// move the start of the search range to the non-delimiter character
		range.location = delimiter.location;
	}
	// if we don't find any non-delimiter characters
	else {
		// then the receiver is composed entirely of delimiters
		// which means the word count in the receiver is zero and we're done
		return 0;
	} // end if
		
	// at this point
	// our search range starts at the first non-delimiter
	// and our word count is still zero
	
	// for as long as there are characters in the search range ...
	while (range.length > 0) {
		// find the first delimiter
		delimiter = [self rangeOfCharacterFromSet:delimiterSet options:0 range:range];
		// if we find a delimiter ...
		if found(delimiter) {
			// then we have just found a word
			// increment the word count
			wordCount++;
			// move search range to the next non-delimiter character in the receiver
			delimiter = [self rangeOfCharacterFromSet:[delimiterSet invertedSet] options:0 range:range];
			// if we find a non-delimiter character ...
			if found(delimiter) {
				// move the start of the search range to the non-delimiter character
				range.location = delimiter.location;
				range.length = len - delimiter.location;
			}
			else {
				// then the remaining receiver is composed entirely of delimiters
				// set the search range to the end of the receiver
				range.location = len+1;
				range.length = 0;
			} // end if
		}
		// if we did not find a delimiter
		else {
			// then the next word fills the entire remaining search range
			// increment the word count
			wordCount++;
			// set the search range to the end of the receiver
			range.location = len+1;
			range.length = 0;
		} // end if
	} // end while
	return wordCount;
} // end method

// ---------------------------------------------------------------------------
//	Instance Method:  firstWord
// ---------------------------------------------------------------------------
//
// Invokes firstWordUsingDelimitersFromSet: with a union of character sets
// punctuationCharacterSet and whitespaceAndNewlineCharacterSet.

- (NSString *)firstWord
{
	NSMutableCharacterSet *delimiterSet = [[NSCharacterSet punctuationCharacterSet] mutableCopy];
	
	// set default delimiter character set to punctuation, whitespace, tab and newline chars
	[delimiterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	// return first word using default delimiter character set
	return [self firstWordUsingDelimitersFromSet:delimiterSet];
} // end method

// ---------------------------------------------------------------------------
//	Instance Method:  firstWordUsingDelimitersFromString:
// ---------------------------------------------------------------------------
//
// Invokes firstWordUsingDelimitersFromSet: with a character set made from
// characters in string delimiters.

- (NSString *)firstWordUsingDelimitersFromString:(NSString *)delimiters
{
	NSCharacterSet *delimiterSet = [NSCharacterSet characterSetWithCharactersInString:delimiters];
	// return first word using given delimiters
	return [self firstWordUsingDelimitersFromSet:delimiterSet];
} // end method

// ---------------------------------------------------------------------------
//	Instance Method:  firstWordUsingDelimitersFromSet:
// ---------------------------------------------------------------------------
//
// pre-conditions:
//  the receiver is an NSString, it may be an empty string.
//
// post-conditions:
//  the first word of the receiver is returned. character set delimiterSet
//  is used as word delimiters. leading delimiters are ignored.
//  if the receiver is empty, an empty string is returned
//
// error-condtions:
//  if the receiver is nil, nil is returned

- (NSString *)firstWordUsingDelimitersFromSet:(NSCharacterSet *)delimiterSet
{
	NSMutableString *remainder_ = [NSMutableString stringWithCapacity:[self length]];
	NSRange delimiter;

	// first check pre-conditions
	if (self == nil) {
		return nil;
	} // end if
	if ([self length] == 0) {
		return self;
	} // end if
	if (delimiterSet == nil) {
		return self;
	} // end if
	
	// trim any leading and trailing delimiters from the source string
	[remainder_ setString:[self stringByTrimmingCharactersInSet:delimiterSet]];
	// find first delimiter in the trimmed source string
	delimiter = [remainder_ rangeOfCharacterFromSet:delimiterSet];
	// if there is a delimiter in the trimmed source string ...
	if found(delimiter) {
		// return the characters preceeding the delimiter
		return [remainder_ substringToIndex:delimiter.location];
	}
	// if there is no delimiter in the trimmed source string ...
	else {
		// return the trimmed source string as is
		return remainder_;
	} // end if
} // end method

// ---------------------------------------------------------------------------
//	Instance Method:  restOfWords
// ---------------------------------------------------------------------------
//
// Invokes restOfWordsUsingDelimitersFromSet: with a union of character sets
// punctuationCharacterSet and whitespaceAndNewlineCharacterSet.

- (NSString *)restOfWords
{
	NSMutableCharacterSet *delimiterSet = [[NSCharacterSet punctuationCharacterSet] mutableCopy];
	
	// set default delimiter character set to punctuation, whitespace, tab and newline chars
	[delimiterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	// return remaining words after first word using default delimiter character set
	return [self restOfWordsUsingDelimitersFromSet:delimiterSet];
} // end method

// ---------------------------------------------------------------------------
//	Instance Method:  restOfWordsUsingDelimitersFromString:
// ---------------------------------------------------------------------------
//
// Invokes restOfWordsUsingDelimitersFromSet: with a character set made from
// characters in string delimiters.

- (NSString *)restOfWordsUsingDelimitersFromString:(NSString *)delimiters
{
	NSCharacterSet *delimiterSet = [NSCharacterSet characterSetWithCharactersInString:delimiters];
	// return remaining words after first word using given delimiters
	return [self restOfWordsUsingDelimitersFromSet:delimiterSet];
} // end method

// ---------------------------------------------------------------------------
//	Instance Method:  restOfWordsUsingDelimitersFromSet:
// ---------------------------------------------------------------------------
//
// pre-conditions:
//  the receiver is an NSString, it may be an empty string.
//
// post-conditions:
//  a copy of the receiver with the first word and its following delimiters
//  is returned. character set delimiterSet is used as word delimiters.
//  if the receiver is empty, an empty string is returned
//
// error-condtions:
//  if the receiver is nil, nil is returned

- (NSString *)restOfWordsUsingDelimitersFromSet:(NSCharacterSet *)delimiterSet
{
	NSMutableString *remainder_ = [NSMutableString stringWithCapacity:[self length]];
	NSRange delimiter;

	// first check pre-conditions
	if (self == nil) {
		return nil;
	} // end if
	if ([self length] == 0) {
		return self;
	} // end if
	if (delimiterSet == nil) {
		return self;
	} // end if
	
	// trim any leading and trailing delimiters from the source string
	[remainder_ setString:[self stringByTrimmingCharactersInSet:delimiterSet]];
	// find first delimiter in the trimmed source string
	delimiter = [remainder_ rangeOfCharacterFromSet:delimiterSet];
	// if there is a delimiter in the trimmed source string ...
	if found(delimiter) {
		// return the remaining characters following the delimiter 
		// with leading and trailing spaces and tabs removed
		return [[remainder_ substringFromIndex:delimiter.location]
					stringByTrimmingCharactersInSet:delimiterSet];
	}
	// if there is no delimiter in the trimmed source string ...
	else {
		// return empty string
		return kEmptyString;
	} // end if
} // end method

// ---------------------------------------------------------------------------
//	Instance Method:  wordAtIndex:
// ---------------------------------------------------------------------------
//
// Invokes wordAtIndex:usingDelimitersFromSet: with a union of character sets
// punctuationCharacterSet and whitespaceAndNewlineCharacterSet.

- (NSString *)wordAtIndex:(int)anIndex
{
	NSMutableCharacterSet *delimiterSet = [[NSCharacterSet punctuationCharacterSet] mutableCopy];
	
	// set default delimiter character set to punctuation, whitespace, tab and newline chars
	[delimiterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	// return nth word using default delimiter character set
	return [self wordAtIndex:anIndex usingDelimitersFromSet:delimiterSet];
} // end method

// ---------------------------------------------------------------------------
//	Instance Method:  wordAtIndex:usingDelimitersFromString:
// ---------------------------------------------------------------------------
//
// Invokes wordAtIndex:usingDelimitersFromSet: with a character set made from
// characters in string delimiters.

- (NSString *)wordAtIndex:(int)anIndex usingDelimitersFromString:(NSString *)delimiters
{
	NSCharacterSet *delimiterSet = [NSCharacterSet characterSetWithCharactersInString:delimiters];
	// return remaining words after first word using given delimiters
	return [self wordAtIndex:anIndex usingDelimitersFromSet:delimiterSet];
} // end method

// ---------------------------------------------------------------------------
//	Instance Method:  wordAtIndex:usingDelimitersFromSet:
// ---------------------------------------------------------------------------
//
// pre-conditions:
//  the receiver is an NSString, it may be an empty string.
//  anIndex is greater or equal 1.
//
// post-conditions:
//  the Nth word of the receiver is returned where N is anIndex. character set
//  delimiterSet is used as word delimiters. leading delimiters are ignored.
//  if the receiver is empty, an empty string is returned. if delmiterSet is
//  nil, a copy of the receiver is returned.
//
// error-condtions:
//  if the receiver is nil, nil is returned
//  if anIndex is smaller than 1, an empty string is returned

- (NSString *)wordAtIndex:(int)anIndex usingDelimitersFromSet:(NSCharacterSet *)delimiterSet
{
	NSMutableString *remainder_ = [NSMutableString stringWithCapacity:[self length]];
	NSRange delimiter;
	unsigned nextWord = 1;
	
	// first check pre-conditions
	if (self == nil) {
		return nil;
	} // end if
	if ([self length] == 0) {
		return self;
	} // end if
	if (anIndex < 1) {
		return kEmptyString;
	} // end if
	if (delimiterSet == nil) {
		return self;
	} // end if
	
	// trim any leading and trailing delimiters from the source string
	[remainder_ setString:[self stringByTrimmingCharactersInSet:delimiterSet]];
	// for as long as there are characters in the remainder_
	// and the word counter is lower than the given index
	while ((nextWord < anIndex) && ([remainder_ length] > 0)) {
		// find first delimiter in the remainder_
		delimiter = [remainder_ rangeOfCharacterFromSet:delimiterSet];
		// if there is a delimiter in the remainder_ ...
		if found(delimiter) {
			// remove the characters preceeding the delimiter from the remainder_
			[remainder_ setString:[remainder_ substringFromIndex:delimiter.location]];
			// trim any leading and trailing delimiters from the remainder_
			[remainder_ setString:[remainder_ stringByTrimmingCharactersInSet:delimiterSet]];
		}
		// if there is no delimiter in the remainder_ ...
		else {
			// then we've already reached the end -- set the remainder_ to empty string
			[remainder_ setString:kEmptyString];
		} // end if
		// increase the word counter
		nextWord++;
	} // end while
	// if the word counter is equal to the given index ...
	if (nextWord == anIndex) {
		// then first word of the remainder_ is the word we're looking for
		// find first delimiter in the remainder_
		delimiter = [remainder_ rangeOfCharacterFromSet:delimiterSet];
		// if there is a delimiter in the remainder_ ...
		if found(delimiter) {
			// return the characters preceeding the delimiter
			return [remainder_ substringToIndex:delimiter.location];
		}
		// if there is no delimiter in the remainder_ ...
		else {
			// then the remainder_ is equal to the word we're looking for
			// return the remainder_ as is
			return remainder_;
		} // end if
	}
	// if the word counter is not equal to the given index ...
	else {
		// then there is no nth word in the source string
		// return an empty string
		return kEmptyString;
	} // end if
} // end method

// ---------------------------------------------------------------------------
//	Instance Method:  arrayBySeparatingWords
// ---------------------------------------------------------------------------
//
// Invokes arrayBySeparatingWordsUsingDelimitersFromSet: with a union of
// character sets punctuationCharacterSet and whitespaceAndNewlineCharacterSet.

- (NSArray *)arrayBySeparatingWords
{
	NSMutableCharacterSet *delimiterSet = [[NSCharacterSet punctuationCharacterSet] mutableCopy];
	
	// set default delimiter character set to punctuation, whitespace, tab and newline chars
	[delimiterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	// return nth word using default delimiter character set
	return [self arrayBySeparatingWordsUsingDelimitersFromSet:delimiterSet];
} // end method

// ---------------------------------------------------------------------------
//	Instance Method:  arrayBySeparatingWordsUsingDelimitersFromString:
// ---------------------------------------------------------------------------
//
// Invokes arrayBySeparatingWordsUsingDelimitersFromSet: with a character set
// made from characters in string delimiters.

- (NSArray *)arrayBySeparatingWordsUsingDelimitersFromString:(NSString *)delimiters;
{
	NSCharacterSet *delimiterSet = [NSCharacterSet characterSetWithCharactersInString:delimiters];
	// return remaining words after first word using given delimiters
	return [self arrayBySeparatingWordsUsingDelimitersFromSet:delimiterSet];
} // end method

// ---------------------------------------------------------------------------
//	Instance Method:  arrayBySeparatingWordsUsingDelimitersFromSet:
// ---------------------------------------------------------------------------
//
// pre-conditions:
//  the receiver is an NSString, it may be an empty string.
//  delimiterSet is an NSCharacterSet, it may be nil.
//
// post-conditions:
//  if the receiver is an empty string, an empty array will be returned.
//  if the delimiterSet is nil, an array with a single object containing a
//  copy of the receiver will be returned. otherwise, an array with the
//  number of member objects equal to the number of words in the receiver
//  is returned with each object containing one word in the same order as
//  they appear in the receiver. character set delimiterSet is used as
//  word delimiters. leading and trailing delimiters are ignored.
//
// error-conditions:
//  if the receiver is nil, nil is returned.

- (NSArray *)arrayBySeparatingWordsUsingDelimitersFromSet:(NSCharacterSet *)delimiterSet;
{
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:([self length] / AVG_WORD_LENGTH)];
	NSRange delimiter, word, range;
	unsigned len;
	
	// first check pre-conditions
	if (self == nil) {
		return nil;
	} // end if
	if ([self length] == 0) {
		return [NSArray array];
	} // end if
	if (delimiterSet == nil) {
		return [NSArray arrayWithObject:self];
	} // end if
	
	// remember the length of the receiver
	len = [self length];
	// initialise the search range
	range.location = 0; range.length = len;
	
	// move search range to the first non-delimiter character in the receiver
	delimiter = [self rangeOfCharacterFromSet:[delimiterSet invertedSet] options:0 range:range];
	// if we find a non-delimiter character ...
	if found(delimiter) {
		// move the start of the search range to the non-delimiter character
		range.location = delimiter.location;
	}
	// if we don't find any non-delimiter characters
	else {
		// then the receiver is composed entirely of delimiters
		// which means there are no words in the receiver
		// return an empty array and we're done
		return [NSArray array];
	} // end if
	
	// at this point
	// our search range starts at the first non-delimiter
	
	// for as long as there are characters in the search range ...
	while (range.length > 0) {
		// find the first delimiter
		delimiter = [self rangeOfCharacterFromSet:delimiterSet options:0 range:range];
		// if we find a delimiter ...
		if found(delimiter) {
			// then we have just found the start of a word
			word.location = delimiter.location;
			// move search range to the next non-delimiter character in the receiver
			delimiter = [self rangeOfCharacterFromSet:[delimiterSet invertedSet] options:0 range:range];
			// if we find a non-delimiter character ...
			if found(delimiter) {
				// then we have just found the end of a word
				word.length = delimiter.location - word.location;
				// add the word to the result
				[result addObject:[self substringWithRange:word]];
				// move the start of the search range to the non-delimiter character
				range.location = delimiter.location;
				range.length = len - delimiter.location;
			}
			else {
				// then the remaining receiver is composed entirely of delimiters
				// set the search range to the end of the receiver
				range.location = len+1;
				range.length = 0;
			} // end if
		}
		// if we did not find a delimiter
		else {
			// then the next word fills the entire remaining search range
			word = range;
			// add the word to the result
			[result addObject:[self substringWithRange:word]];
			// set the search range to the end of the receiver
			range.location = len+1;
			range.length = 0;
		} // end if
	} // end while
	return result;
} // end method

// ---------------------------------------------------------------------------
//	Instance Method:  arrayBySeparatingLinesUsingEOLmarkers
// ---------------------------------------------------------------------------
//
// pre-conditions:
//  the receiver is an NSString, it may be an empty string.
//
// post-conditions:
//  if the receiver is an empty string, an empty array will be returned.
//  if there are no EOL markers present in the receiver, an array with a
//  single object containing a copy of the receiver will be returned.
//  otherwise, an array with the number of member objects equal to the number
//  of lines in the receiver is returned with each object containing one line
//  in the same order as they appear in the receiver. the EOL markers used to
//  determine the end of a line are Line Feed (U+000A) and Carriage Return
//  (U+000D). The EOL marker sequence CRLF (U+000D followed by U+000A) is
//  treated as a single EOL marker.
//
// error-conditions:
//  if the receiver is nil, nil is returned.

- (NSArray *)arrayBySeparatingLinesUsingEOLmarkers;
{
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:([self length] / AVG_LINE_LENGTH)];
	NSCharacterSet *EOLmarkerSet = [NSCharacterSet characterSetWithCharactersInString:kEOLmarkers];
	NSRange EOLmarker, line, range;
	int previousMarkerWasCR;
	unsigned len;
	
	// first check pre-conditions
	if (self == nil) {
		return nil;
	} // end if
	if ([self length] == 0) {
		return [NSArray array];
	} // end if
	
	// remember the length of the receiver
	len = [self length];
	// initialise previous marker flag
	previousMarkerWasCR = 0;
	// initialise the search range
	range.location = 0; range.length = len;
	
	// for as long as there are characters in the search range ...
	while (range.length > 0) {
		// find the first EOL marker
		EOLmarker = [self rangeOfCharacterFromSet:EOLmarkerSet options:0 range:range];
		// if we find an EOL marker ...
		if found(EOLmarker) {
			// check if this is part of a CRLF marker
			if ((previousMarkerWasCR) && (EOLmarker.location == range.location) &&
				([self characterAtIndex:EOLmarker.location] == kUnicharLF)) {
				// this marker is the LF of a CRLF marker -- ignore it
				range.location++; range.length--;
			}
			// otherwise, if this is a new EOL marker ...
			else {
				// then we have just found the end of a line
				line.location = range.location;
				line.length = EOLmarker.location - line.location;
				// add the line to the result
				[result addObject:[self substringWithRange:line]];
				// move the start of the search range past the EOL marker
				range.location = EOLmarker.location + 1;
				range.length = len - range.location;
			} // end if
			// remember if this marker is a CR -- for it may be the first part of a CRLF
			previousMarkerWasCR = ([self characterAtIndex:EOLmarker.location] == kUnicharCR);
		}
		// if we did not find any EOL marker ...
		else {
			// then the next line fills the entire remaining search range
			line = range;
			// add the line to the result
			[result addObject:[self substringWithRange:line]];
			// set the search range to the end of the receiver
			range.location = len+1;
			range.length = 0;
		} // end if
	} // end while
	return result;
} // end method

@end // STSAdditionsToNSString
