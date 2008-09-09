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

@interface NSString (STSAdditionsToNSString)

// ---------------------------------------------------------------------------
//	I n s t a n c e   M e t h o d s   a d d e d   t o   N S S t r i n g
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
//	Instance Method:  isEmpty
// ---------------------------------------------------------------------------
//
// Returns YES if the receiver is emply, returns NO otherwise.

- (BOOL)isEmpty;

// ---------------------------------------------------------------------------
//	Instance Method:  representsTrue
// ---------------------------------------------------------------------------
//
// Returns YES if the receiver represents logical true, otherwise returns NO.
// The receiver represents logical true if its all-lowercase representation
// is equal to "1", "yes" or "true". Returns NO if the receiver is nil.

- (BOOL)representsTrue;

// ---------------------------------------------------------------------------
//	Instance Method:  rangeOfWhitespace
// ---------------------------------------------------------------------------
//
// Returns an NSRange giving the location and length of the first occurrence
// of the whitespace character (U+0020). If a whitespace character is found,
// then length will be 1. If no whitespace character is found, a range of
// {NSNotFound, 0} is returned.

- (NSRange)rangeOfWhitespace;

// ---------------------------------------------------------------------------
//	Instance Method:  stringByTrimmingWhitespace
// ---------------------------------------------------------------------------
//
// Returns a new string made by removing leading and trailing whitespace
// (U+0020) and tab (U+0009) characters from the receiver.

- (NSString *)stringByTrimmingWhitespace;

// ---------------------------------------------------------------------------
//	Instance Method:  stringByCollapsingWhitespace
// ---------------------------------------------------------------------------
//
// Returns a new string made by substitution of a group of multiple whitespace
// (U+0020) characters with a single whitespace, a group of multiple tab
// (U+0009) characters with a single tab and a mixed group of whitespace and
// tab characters with a single tab in the receiver.

- (NSString *)stringByCollapsingWhitespace;

// ---------------------------------------------------------------------------
//	Instance Method:  substringWithStringInSingleQuotes
// ---------------------------------------------------------------------------
//
//  Returns a new string containing the characters of the receiver between the
//	first and the second ocurrence of the apostrophe character (U+0027).
//  The returned string does not include the apostrophes. Returns nil
//	if no matching pair of apostrophes is found in the receiver.

- (NSString *)substringWithStringInSingleQuotes;

// ---------------------------------------------------------------------------
//	Instance Method:  substringWithStringInDoubleQuotes
// ---------------------------------------------------------------------------
//
//  Returns a new string containing the characters of the receiver between the
//	first and the second ocurrence of the quotation mark character (U+0022).
//  The returned string does not include the quotation marks. Returns nil
//	if no matching pair of quotation marks is found in the receiver.

- (NSString *)substringWithStringInDoubleQuotes;

// ---------------------------------------------------------------------------
//	Instance Method:  numberOfWords
// ---------------------------------------------------------------------------
//
// Returns the number of words in the receiver, using the character sets
// punctuationCharacterSet and whitespaceCharacterSet as word delimiters.

- (int)numberOfWords;

// ---------------------------------------------------------------------------
//	Instance Method:  numberOfWordsUsingDelimitersFromString:
// ---------------------------------------------------------------------------
//
// Returns the number of words in the receiver, using a character set made
// from the characters in delimiters as word delimiters.

- (int)numberOfWordsUsingDelimitersFromString:(NSString *)delimiters;

// ---------------------------------------------------------------------------
//	Instance Method:  numberOfWordsUsingDelimitersFromSet:
// ---------------------------------------------------------------------------
//
// Returns the number of words in the receiver, using the character set
// delimiterSet as word delimiters.

- (int)numberOfWordsUsingDelimitersFromSet:(NSCharacterSet *)delimiterSet;

// ---------------------------------------------------------------------------
//	Instance Method:  firstWord
// ---------------------------------------------------------------------------
//
// Returns the first word in the receiver, using the character sets
// punctuationCharacterSet and whitespaceCharacterSet as word delimiters.

- (NSString *)firstWord;

// ---------------------------------------------------------------------------
//	Instance Method:  firstWordUsingDelimitersFromString:
// ---------------------------------------------------------------------------
//
// Returns the first word in the receiver, using a character set made from
// the characters in delimiters as word delimiters.

- (NSString *)firstWordUsingDelimitersFromString:(NSString *)delimiters;

// ---------------------------------------------------------------------------
//	Instance Method:  firstWordUsingDelimitersFromSet:
// ---------------------------------------------------------------------------
//
// Returns the first word in the receiver, using the character set
// delimiterSet as word delimiters.

- (NSString *)firstWordUsingDelimitersFromSet:(NSCharacterSet *)delimiterSet;

// ---------------------------------------------------------------------------
//	Instance Method:  restOfWords
// ---------------------------------------------------------------------------
//
// Returns a new string made from removing the first word and the delimiters
// following the first word from the receiver, using the character sets
// punctuationCharacterSet and whitespaceCharacterSet as word delimiters.

- (NSString *)restOfWords;

// ---------------------------------------------------------------------------
//	Instance Method:  restOfWordsUsingDelimitersFromString:
// ---------------------------------------------------------------------------
//
// Returns a new string made from removing the first word and the delimiters
// following the first word from the receiver, using a character set made
// from the characters in delimiters as word delimiters.

- (NSString *)restOfWordsUsingDelimitersFromString:(NSString *)delimiters;

// ---------------------------------------------------------------------------
//	Instance Method:  restOfWordsUsingDelimitersFromSet:
// ---------------------------------------------------------------------------
//
// Returns a new string made from removing the first word and the delimiters
// following the first word from the receiver, using the character set
// delimiterSet as word delimiters.

- (NSString *)restOfWordsUsingDelimitersFromSet:(NSCharacterSet *)delimiterSet;

// ---------------------------------------------------------------------------
//	Instance Method:  wordAtIndex:
// ---------------------------------------------------------------------------
//
// Returns the Nth word of the receiver, using the character sets
// punctuationCharacterSet and whitespaceCharacterSet as word delimiters,
// where N is anIndex. If anIndex is greater than the number of words in the
// receiver, an empty string is returned. If no delimiters are present in the
// receiver, a copy of the receiver is returned.

- (NSString *)wordAtIndex:(int)anIndex;

// ---------------------------------------------------------------------------
//	Instance Method:  wordAtIndex:usingDelimitersFromString:
// ---------------------------------------------------------------------------
//
// Returns the Nth word of the receiver, using a character set made
// from the characters in delimiters as word delimiters, where N is anIndex.
// If anIndex is greater than the number of words in the receiver, an empty
// string is returned. If no delimiters are present in the receiver, a copy of
// the receiver is returned.

- (NSString *)wordAtIndex:(int)anIndex usingDelimitersFromString:(NSString *)delimiters;

// ---------------------------------------------------------------------------
//	Instance Method:  wordAtIndex:usingDelimitersFromSet:
// ---------------------------------------------------------------------------
//
// Returns the Nth word of the receiver, using the character set delimiterSet
// as word delimiters, where N is anIndex. If anIndex is greater than the
// number of words in the receiver, an empty string is returned. If no
// delimiters are present in the receiver, a copy of the receiver is returned.

- (NSString *)wordAtIndex:(int)anIndex usingDelimitersFromSet:(NSCharacterSet *)delimiterSet;

// ---------------------------------------------------------------------------
//	Instance Method:  arrayBySeparatingWords
// ---------------------------------------------------------------------------
//
// Returns an NSArray containing words from the receiver, using the character
// sets punctuationCharacterSet and whitespaceCharacterSet as word delimiters.
// The words in the array appear in the order they did in the receiver. Any
// leading or trailing delimiters are ignored. If the receiver is an empty
// string, an empty array is returned. If no delimiters are present in the
// receiver, an array with a single element containing a copy of the receiver
// is returned.

- (NSArray *)arrayBySeparatingWords;

// ---------------------------------------------------------------------------
//	Instance Method:  arrayBySeparatingWordsUsingDelimitersFromString:
// ---------------------------------------------------------------------------
//
// Returns an NSArray containing words from the receiver, using a character
// set made from the characters in delimiters as word delimiters. The words
// in the array appear in the order they did in the receiver. Any leading
// or trailing delimiters are ignored. If the receiver is an empty string,
// an empty array is returned. If no delimiters are present in the receiver,
// an array with a single element containing a copy of the receiver is
// returned.

- (NSArray *)arrayBySeparatingWordsUsingDelimitersFromString:(NSString *)delimiters;

// ---------------------------------------------------------------------------
//	Instance Method:  arrayBySeparatingWordsUsingDelimitersFromSet:
// ---------------------------------------------------------------------------
//
// Returns an NSArray containing words from the receiver, using the character
// set delimiterSet as word delimiters. The words in the array appear in the
// order they did in the receiver. Any leading or trailing delimiters are
// ignored. If the receiver is an empty string, an empty array is returned.
// If no delimiters are present in the receiver, an array with a single
// element containing a copy of the receiver is returned.

- (NSArray *)arrayBySeparatingWordsUsingDelimitersFromSet:(NSCharacterSet *)delimiterSet;

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

@end // STSAdditionsToNSString
