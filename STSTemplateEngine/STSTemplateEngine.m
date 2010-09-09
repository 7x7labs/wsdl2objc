//
//	STSTemplateEngine.m
//	STS Template Engine ver 1.00
//
//	A universal template engine with conditional template expansion support.
//
//	Created by benjk on 6/28/05.
//	Copyright 2005 Sunrise Telephone Systems Ltd. All rights reserved.
//
//	This software is released as open source under the terms of the General
//	Public License (GPL) version 2.  A copy of the GPL license should have
//	been distributed along with this software.  If you have not received a
//	copy of the GPL license, you can obtain it from Free Software Foundation
//	Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
//
//	Permission is hereby granted to link this code against Apple's proprietary
//	Cocoa Framework, regardless of the limitations in the GPL license. The
//	Copyright notice and credits must be preserved at all times in every
//	redistributed copy and any derivative work of this software.
//
//	THIS SOFTWARE  IS PROVIDED "AS IS"  WITHOUT  ANY  WARRANTY  OF  ANY  KIND,
//	WHETHER  EXPRESSED OR IMPLIED,  INCLUDING  BUT NOT LIMITED TO  ANY IMPLIED
//	WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR ANY PARTICULAR PURPOSE.  THE
//	ENTIRE RISK  AS TO THE QUALITY AND PERFORMANCE OF THIS SOFTWARE  LIES WITH
//	THE LICENSEE.  FOR FURTHER INFORMATION PLEASE REFER TO THE GPL VERSION 2.
//
//	For projects and software products for which the terms of the GPL license
//	are not suitable, alternative licensing can be obtained directly from
//	Sunrise Telephone Systems Ltd. at http://www.sunrise-tel.com
//

#import "LIFO.h"
#import "STSStringOps.h"

#import "STSTemplateEngine.h"

BOOL classExists (NSString *className);

#define TODO {}; /* dummy statement for future sections */

// ---------------------------------------------------------------------------
//	String literals
// ---------------------------------------------------------------------------

#define kEmptyString @""
#define kLineFeed @"\n"

// ---------------------------------------------------------------------------
//	Macro for use in if-clauses when testing NSRange variables
// ---------------------------------------------------------------------------

#define found(x) (x.location != NSNotFound)

// ---------------------------------------------------------------------------
//	Macros for testing if a key is present in an NSDictionary
// ---------------------------------------------------------------------------

#define keyDefined(x,y) ([NSString valueForDictionary:x key:y] != nil)
#define keyNotDefined(x,y) ([NSString valueForDictionary:x key:y] == nil)


// ---------------------------------------------------------------------------
//  P r i v a t e   F u n c t i o n s
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Private Function:  classExists(className)
// ---------------------------------------------------------------------------
//
// Returns YES if class className exists, otherwise NO.

BOOL classExists (NSString *className) {
	Class classPtr = NSClassFromString(className);
	return (classPtr != nil);
} // end function


// ---------------------------------------------------------------------------
//  P r i v a t e   C a t e g o r i e s
// ---------------------------------------------------------------------------

@interface NSFileManager (STSTemplateEnginePrivateCategory1)

// ---------------------------------------------------------------------------
// Private Method:  isRegularFileAtPath:
// ---------------------------------------------------------------------------
//
// Returns YES if the file specified in path is a regular file, or NO if it is
// not. This method traverses symbolic links.

- (BOOL)isRegularFileAtPath:(NSString *)path;

@end

@implementation NSFileManager (STSTemplateEnginePrivateCategory1);

// ---------------------------------------------------------------------------
// Instance Method:  isRegularFileAtPath:
// ---------------------------------------------------------------------------
//
// description:
//  Returns YES if the file specified in path is a regular file, or NO if it
//  is not. If path specifies a symbolic link, this method traverses the link
//  and returns YES or NO based on the existence of the file at the link
//  destination. If path begins with a tilde, it must first be expanded with
//  stringByExpandingTildeInPath, or this method will return NO.
//
// pre-conditions:
//  receiver must be an object of class NSFileManager.
//  path must be a valid POSIX pathname.
//
// post-conditions:
//  return value is of type BOOL and contains YES if the file at path is a
//  regular file or if it is a symbolic link pointing to a regular file.
//  Otherwise, NO is returned.

- (BOOL)isRegularFileAtPath:(NSString *)path
{
	return ([[[self fileAttributesAtPath:path traverseLink:YES] fileType]
		isEqualToString:@"NSFileTypeRegular"]);
} // end method

@end // private category


@interface NSString (STSTemplateEnginePrivateCategory2)

// ===========================================================================
// NOTE regarding the use of string literals with non 7-bit ASCII characters
// ---------------------------------------------------------------------------
//		The Cocoa runtime system always interprets string literals as if they
// were encoded in the system's default string encoding which is dependent on
// the current locale, regardless of their true encoding. Thus, if a source
// file is saved in a different encoding, all its string literals will contain
// data encoded with a different encoding than the encoding for the current
// locale but the runtime system will nevertheless interpret the data as
// having been encoded in the encoding for the current locale. Xcode does not
// adjust for this and as a result, characters which are not 7-bit ASCII
// characters will be garbled.
//		The default start and end tags of the template engine are non 7-bit
// ASCII characters. If they are passed as string literals and the source code
// is not in the same encoding as the current locale at the time the source
// code is compiled, the template engine will not work properly. Therefore
// the tags have to be embedded in an encoding-safe manner. This is what the
// following methods defaultStartTag and defaultEndTag are for.
// ===========================================================================

// ---------------------------------------------------------------------------
// Private Method:  defaultStartTag
// ---------------------------------------------------------------------------
//
// Returns a new NSString initialised with the template engine's default start
// tag (the percent sign followed by the opening chevrons, "%«"). This method
// is source file encoding-safe.

+ (NSString *)defaultStartTag;

// ---------------------------------------------------------------------------
// Private Method:  defaultEndTag
// ---------------------------------------------------------------------------
//
// Returns a new NSString initialised with the template engine's default end
// tag (the closing chevrons, "»"). This method is source file encoding-safe.

+ (NSString *)defaultEndTag;

// ---------------------------------------------------------------------------
// Private Method:  stringByExpandingPlaceholdersWithStartTag:andEndTag:
//                  usingDictionary:errorsReturned:lineNumber:
// ---------------------------------------------------------------------------
//
// This method is invoked by the public methods below in order to expand
// individual lines in a template string or template file. It returns the
// receiver with tagged placeholders expanded. Placeholders are recognised by
// start and end tags passed and they are expanded by using key/value pairs in
// the dictionary passed. An errorLog is returned to indicate whether the
// expansion has been successful.
//		If a placeholder cannot be expanded, a partially expanded string is
// returned with one or more error messages inserted or appended and an
// error description of class TEError is added to an NSArray returned in
// errorLog. lineNumber is used to set the error description's line number.

- (NSString *)stringByExpandingPlaceholdersWithStartTag:(NSString *)startTag
											  andEndTag:(NSString *)endTag
										usingDictionary:(NSDictionary *)dictionary
										 errorsReturned:(NSArray **)errorLog
											 lineNumber:(unsigned)lineNumber;
@end

@implementation NSString (STSTemplateEnginePrivateCategory2);

// ---------------------------------------------------------------------------
// Class Method:  defaultStartTag
// ---------------------------------------------------------------------------
//
// Returns a new NSString initialised with the template engine's default start
// tag (the percent sign followed by the opening chevrons, "%«"). This method
// is source file encoding-safe.

+ (NSString *)defaultStartTag
{
	NSData *data;
	// avoid the use of string literals to be source file encoding-safe
	// use MacOS Roman hex codes for percent and opening chevrons "%«"
	char octets[2] = { 0x25, 0xc7 };
	data = [NSData dataWithBytes:&octets length:2];
	return [[[NSString alloc] initWithData:data encoding:NSMacOSRomanStringEncoding] autorelease];
} // end method

// ---------------------------------------------------------------------------
// Class Method:  defaultEndTag
// ---------------------------------------------------------------------------
//
// Returns a new NSString initialised with the template engine's default end
// tag (the closing chevrons, "»"). This method is source file encoding-safe.

+ (NSString *)defaultEndTag
{
	NSData *data;
	// avoid the use of string literals to be source file encoding-safe
	// use MacOS Roman hex code for closing chevrons "»"
	char octet = 0xc8;
	data = [NSData dataWithBytes:&octet length:1];
	return [[[NSString alloc] initWithData:data encoding:NSMacOSRomanStringEncoding] autorelease];
} // end method

// ---------------------------------------------------------------------------
// Instance Method:  stringByExpandingPlaceholdersWithStartTag:andEndTag:
//                   usingDictionary:errorsReturned:lineNumber:
// ---------------------------------------------------------------------------
//
// description:
//  Returns the receiver with tagged placeholders expanded. Placeholders are
//  recognised by start and end tags passed and they are expanded by using
//  key/value pairs in the dictionary passed. A status code passed by
//  reference is set to indicate whether the expansion has been successful.
//  If a placeholder cannot be expanded, a partially expanded string is
//  returned with one or more error messages inserted or appended and an
//  error description of class TEError is added to an NSArray returned in
//  errorLog. lineNumber is used to set the error description's line number.
//
// pre-conditions:
//  startTag and endTag must not be empty strings and must not be nil.
//  dictionary contains keys to be replaced by their respective values.
//
// post-conditions:
//  Return value contains the receiver with all placeholders expanded for
//  which the dictionary contains keys. If there are no placeholders in the
//  receiver, the receiver will be returned unchanged.
//  Any placeholders for which the dictionary does not contain keys will
//  remain in their tagged placeholder form and have an error message
//  appended to them in the returned string. If a placeholder without
//  a closing tag is found, the offending placeholder will remain in its
//  incomplete start tag only form and have an error message appended to it.
//  Any text following the offending start tag only placeholder will not be
//  processed. An NSArray with error descriptions of class TEError will be
//  passed in errorLog to the caller.
//
// error-conditions:
//  If start tag is empty or nil, an exception StartTagEmptyOrNil will be
//  raised. If end tag is empty or nil, an exception EndTagEmptyOrNil will be
//  raised. It is the responsibility of the caller to catch the exception.

- (NSString *)stringByExpandingPlaceholdersWithStartTag:(NSString *)startTag
											  andEndTag:(NSString *)endTag
										usingDictionary:(NSDictionary *)dictionary
										 errorsReturned:(NSArray **)errorLog
											 lineNumber:(unsigned)lineNumber
{	
	NSMutableString *remainder_ = [NSMutableString stringWithCapacity:[self length]];
	NSMutableString *result = [NSMutableString stringWithCapacity:[self length]];
	NSMutableString *placeholder = [NSMutableString stringWithCapacity:20];
	NSMutableString *value;
	NSMutableArray *_errorLog = [NSMutableArray arrayWithCapacity:5];
	#define errorsHaveOcurred ([_errorLog count] > 0)
	NSException* exception = nil;
	NSRange tag, range;
	TEError *error;

	// check if start tag is nil or empty
	if ((startTag == nil) || ([startTag length] == 0)) {
		// this is a fatal error -- bail out by raising an exception
		exception = [NSException exceptionWithName:@"TEStartTagEmptyOrNil"
											reason:@"startTag is empty or nil" userInfo:nil];
		[exception raise];
	} // end if
	  // check if end tag is nil or empty
	if ((endTag == nil) || ([endTag length] == 0)) {
		// this is a fatal error -- bail out by raising an exception
		[NSException exceptionWithName:@"TEEndTagEmptyOrNil"
								reason:@"endTag is empty or nil" userInfo:nil];
		[exception raise];
	} // end if
	
	// initialise the source string
	[remainder_ setString:self];
	// look for the initial start tag
	tag = [remainder_ rangeOfString:startTag];
	// if we find a start tag ...
	if found(tag) {
		// continue for as long as we find start tags
		while found(tag) {
			// append substring before start tag to the result string
			[result appendString:[remainder_ substringToIndex:tag.location]];
			// remove preceeding text and start tag from the remainder_
			range.location = 0; range.length = tag.location+tag.length;
			[remainder_ deleteCharactersInRange:range];
			// look for the end tag
			tag = [remainder_ rangeOfString:endTag];
			// if we did find the end tag ...
			if found(tag) {
				// extract the placeholder
				[placeholder setString:[remainder_ substringToIndex:tag.location]];
				value = [NSString valueForDictionary:dictionary key:placeholder];
				// if the lookup returned nil (key not found)
				if (value == nil) {
					// append the tagged placeholder and an error message to the result string
					[result appendFormat:@"%@%@%@ *** ERROR: undefined key *** ", startTag, placeholder, endTag];
					// this is an error - create a new error description
					error = [TEError error:TE_UNDEFINED_PLACEHOLDER_FOUND_ERROR
									inLine:lineNumber atToken:TE_PLACEHOLDER];
					[error setLiteral:placeholder];
					// and add this error to the error log
					[_errorLog addObject:error];
					// log this error to the console
					[error logErrorMessageForTemplate:kEmptyString];
				}
				// if the lookup returns a value for the key ...
				else {
					// append the key's value to the result string
					[result appendString:value];
				} // end if
				  // remove placeholder and end tag from the remainder_
				range.location = 0; range.length = tag.location+tag.length;
				[remainder_ deleteCharactersInRange:range];
			} // end if
			  // if we don't find any end tag ...
			else {
				// append the start tag and an error message to the result string
				[result appendFormat:@"%@ *** ERROR: end tag missing *** ", startTag];
				// remove all remaining text from the source string to force exit of while loop
				[remainder_ setString:kEmptyString];
				// this is an error - create a new error description
				error = [TEError error:TE_EXPECTED_ENDTAG_BUT_FOUND_TOKEN_ERROR
								inLine:lineNumber atToken:TE_EOL];
				// and add this error to the error log
				[_errorLog addObject:error];
				// log this error to the console
				[error logErrorMessageForTemplate:kEmptyString];
			} // end if
			  // look for follow-on start tag to prepare for another parsing cycle
			tag = [remainder_ rangeOfString:startTag];
		} // end while
		// if there are still characters in the remainder_ ...
		if ([remainder_ length] > 0) {
			// append the remaining characters to the result
			[result appendString:remainder_];
		} // end if
	}
	// if we don't find a start tag ...
	else {
		// then there is nothing to expand and we return the original as is
		result = remainder_;
	} // end if
	// if there were any errors ...
	if (errorsHaveOcurred) {
		// pass the error log back to the caller
		*errorLog = _errorLog;
		// get rid of the following line after testing
		NSLog(@"errors have ocurred while expanding placeholders in string");
	}
	// if there were no errors ...
	else {
		// pass nil in the errorLog back to the caller
		*errorLog = nil;
	} // end if
	// return the result string
	return result;
	#undef errorsHaveOcurred
} // end method

@end // private category


// ---------------------------------------------------------------------------
//  P r i v a t e   C l a s s e s
// ---------------------------------------------------------------------------

@interface TEFlags : NSObject {
	// instance variable declaration
	@public unsigned consumed, expand, condex, forBranch;
} // end var
//
// public method: return new flags, allocated, initialised and autoreleased.
// initial values: consumed is false, expand is true, condex is false.
+ (TEFlags *)flags;
@end

@implementation TEFlags
// private method: initialise instance
- (id)init {
	self = [super init];
	return self;
} // end method

// private method: deallocate instance
- (void)dealloc {
	[super dealloc];
} // end method

// public method: return new flags, allocated, initialised and autoreleased.
// initial values: consumed is false, expand is true, condex is false.
+ (TEFlags *)flags {
	TEFlags *thisInstance = [[[TEFlags alloc] init] autorelease];
	// initialise flags
	thisInstance->consumed = false;
	thisInstance->expand = true;
	thisInstance->condex = false;
	thisInstance->forBranch = false;
	return thisInstance;
} // end method

@end // private class


// ---------------------------------------------------------------------------
//  P u b l i c   C a t e g o r y   I m p l e m e n t a t i o n
// ---------------------------------------------------------------------------

@implementation NSString (STSTemplateEngine);

// ---------------------------------------------------------------------------
// Class Method:  stringByExpandingTemplate:usingDictionary:errorsReturned:
// ---------------------------------------------------------------------------
//
// description:
//  Invokes method stringByExpandingTemplate:withStartTag:andEndTag:
//  usingDictionary:errorsReturned: with the template engine's default tags:
//  startTag "%«" and endTag "»". This method is source file encoding-safe.

+ (id)stringByExpandingTemplate:(NSString *)templateString
				usingDictionary:(NSDictionary *)dictionary
				 errorsReturned:(NSArray **)errorLog
{
	return [NSString stringByExpandingTemplate:templateString
								  withStartTag:[NSString defaultStartTag]
									 andEndTag:[NSString defaultEndTag]
							   usingDictionary:dictionary
								errorsReturned:errorLog];
} // end method

// ---------------------------------------------------------------------------
// Class Method:  stringByExpandingTemplate:withStartTag:andEndTag:
//                usingDictionary:errorsReturned:
// ---------------------------------------------------------------------------
//
// description:
//  Returns a new NSString made by expanding templateString. Lines starting
//  with a % character are interpreted as comments or directives for the
//  template engine. Directives are %IF, %IFNOT, %IFEQ, %IFNEQ, %IFDEF,
//	%IFNDEF, %ELSIF, %ELSIFNOT, %ELSIFEQ, %ELSIFNEQ, %ELSIFDEF, %ELSIFNDEF,
//	%ELSE, %ENDIF, %DEFINE, %UNDEF, %LOG, %ECHO and %DEBUG.
//	Any line starting with a % character that is not part of a valid directive
//	nor part of a start tag is treated as a comment. Comment lines are not
//	copied to the result returned.
//		The %IF, %IFNOT, %IFEQ, %IFNEQ, %IFDEF, %IFNDEF, %ELSIF, %ELSEIFNOT,
//	%ELSIFEQ, %ELSIFNEQ, %ELSIFDEF, %ELSIFNDEF, %ELSE and %ENDIF directives
//	are for conditional template expansion. Any %IF, %IFNOT, %IFEQ, %IFNEQ,
//	%IFDEF or %IFNDEF directive opens a new if-block and a new if-branch
//	within the new if-block. Any %ELSIF, %ELSIFNOT, %ELSIFEQ, %ELSIFNEQ,
//	%ELSIFDEF or %ELSEIFNDEF directive opens a new else-if branch in the
//	current if-block. An %ELSE directive opens an else-branch in the current
//	if-block. An %ENDIF directive closes the current if-block.
//		An identifier following %IF is interpreted as a key which is looked
//	up in the dictionary. If the key's value represents logical true, the
//	subsequent lines are expanded until an elsif-, else- or endif-directive
//	is found or another if-block is opened.
//		An identifier following %IFNOT is interpreted as a key which is
//	looked up in the dictionary. If the key's value does not represent logical
//	true, the subsequent lines are expanded until an elsif-, else- or endif-
//	directive is found or another if-block is opened.
//		A key's value represents logical true if its all-lowercase
//	representation is "1", "yes" or "true".
//		An identifier following %IFEQ is interpreted as a key which is looked
//	up in the dictionary and its value is then compared to the operand that
//	follows the key. If the key's value and the operand match, the subsequent
//	lines are expanded until an  elsif-, else- or endif-directive is found or
//	another if block is opened.
//		An identifier following %IFNEQ is interpreted as a key which is
//	looked up in the dictionary and its value is then compared to the operand
//	that follows the key. If the key's value and the operand do not match,
//	the subsequent lines are expanded until an  elsif-, else- or endif-
//	directive is found or another if block is opened.
//		An identifier following %IFDEF is interpreted as a key which is
//	looked up in the dictionary. If the key is found in the dictionary, the
//	subsequent lines are expanded until an  elsif-, else- or endif-
//	directive is found or another if-block is opened.
//		An identifier following %IFNDEF is interpreted as a key which is
//	looked up in the dictionary. If the key is not found in the dictionary,
//	the subsequent lines are expanded until an  elsif-, else- or endif-
//	directive is found or another if-block is opened.
//		An %ELSEIF, %ELSIFNOT, %ELSIFEQ, %ELSIFNEQ, %ELSIFDEF or %ELSIFNDEF
//	directive opens an else-if branch in the current if block. An else-if
//	directive will only be evaluated if no prior if- or else-if branch was
//	expanded. The expression following such an else-if directive is evaluated
//	in the same way an expression following the corresponding if-directive is
//	evaluated.
//		An %ELSE directive opens an else branch in the current if-block. The
//	lines following an else branch will be expanded if no prior if- or else-if
//	branch was expanded. Lines are expanded until an %ENDIF directive is found
//	or another if-block is opened.
//		Any section outside any an if-block is expanded unconditionally,
//	excluding comment lines which are always ignored. If-blocks may be nested.
//		A %DEFINE directive followed by a key name causes that key to be added
//  to the dictionary. If any text follows the key name, that text is stored
//  as the key's value, otherwise the key's value will be an empty string. If
//  the key already exists in the dictionary then it's value will be replaced.
//		An %UNDEF directive followed by a key name causes that key to be
//	removed from the dictionary.
//		A %LOG directive followed by a key will cause that key and its value
//	to be logged to the console, which may be used for troubleshooting.
//		The %ECHO and %DEBUG directives are ignored as they have not been
//	implemented yet.
//		Any lines to be expanded which contain tagged placeholders are copied
//  to the result returned with the tagged placeholders expanded. Any lines
//  to be expanded which do not contain any placeholders are copied verbatim
//  to the result returned. Placeholders are recognised by start and end tags
//  passed in startTag and endTag and they are expanded by using key/value
//  pairs in dictionary. Placeholder names starting with an underscore "_"
//	character are reserved for automatic placeholder variables.
//		Automatic placeholder variables are automatically entered into the
//	dictionary by the template engine. Currently defined automatic placeholder
//	variables are: _timestamp, _uniqueID and _hostname.
//		The value of _timestamp is a datetime string with the system's current
//	date and time value formatted to follow the international string
//	representation format YYYY-MM-DD HH:MM:SS ±HHMM at the time the method is
//	invoked.
//		The value of _uniqueID is a globally unique ID string as generated by
//	method globallyUniqueString of class NSProcessInfo. For each invocation of
//	stringByExpandingTemplate: withStartTag:andEndTag:usingDictionary:
//	errorsReturned: a new value for _uniqueID is generated.
//		The value of _hostname is the system's host name at the time the
//	method is invoked.
//		On MacOS X 10.4 "Tiger" (and later) locale information is available
//	through automatic placeholder variables _userCountryCode, _userLanguage,
//	_systemCountryCode and _systemLanguage.
//		For every placeholder that cannot be expanded, a partially expanded
//	line is copied to the result returned with one or more error messages
//	inserted or appended.
//		An NSArray containing descriptions of any errors that may have ocurred
//  during expansion is passed back in errorLog to the caller. If expansion
//  completed withough any errors, then errorLog is set to nil.
//
// pre-conditions:
//  templateString is an NSString containing the template to be expanded.
//  startTag and endTag must not be empty strings and must not be nil.
//  dictionary contains keys to be replaced by their respective values.
//  errorLog is an NSArray passed by reference.
//
// post-conditions:
//  Return value contains a new NSString made by expanding templateString
//  with lines outside of %IF blocks expanded unconditionally and lines
//  inside of %IF blocks expanded conditionally. If any errors are
//  encountered during template expansion, errorLog will be set to an NSArray
//  containing error descriptions of class TEError for each error or warning.
//  If there were neither errors nor warnings during template expansion,
//  errorLog is set to nil.
//		Template expansion errors are treated gracefully. Various error
//  recovery strategies ensure that expansion can continue even in the event
//  of errors encountered in the template and error descriptions are added to
//  errorLog.
//		If an if-directive is not followed by an expression, the entire
//	if-block opened by that directive will be ignored, that is all lines will
//	be ignored until a matching endif-directive is found. An error description
//	is added to errorLog and an error message is written to the console log.
//		If an else-if directive is not followed by an expression, the else-if
//	branch opened by that directive will be ignored, that is all lines will be
//	ignored until an else-if-, else- or endif-directive is found or another
//	if-block is opened.
//		If any else-if-, else- or endif-directive appears without a prior
//  if-directive, then the line with that directive will be ignored and
//	expansion continues accordingly. An error description is added to
//	errorLog and an error message is written to the console log.
//		If the end of the template file is reached before an if-block was
//  closed by an endif-directive, the block is deemed to have been closed
//	implicitly. An error description is added to errorLog and an error
//	message is written to the console log.
//		Any placeholders for which the dictionary does not contain keys will
//  remain in their tagged placeholder form and have an error message
//  appended to them in the corresponding expanded line. Expansion continues
//  accordingly. An error description is added to errorLog and logged to the
//  console.
//		If a placeholder without a closing tag is found, the offending
//  placeholder will remain in its incomplete start tag only form, have an
//  error message appended to it and the remainder_ of the line is not
//  processed. Expansion then continues in the line that follows. An error
//  description is added to errorLog and logged to the console.
//		When template expansion is completed and any errors have occurred,
//  the NSArray returned in errorLog contains all error descriptions in the
//  order they ocurred.
//
// error-conditions:
//  If startTag is empty or nil, an exception TEStartTagEmptyOrNil will be
//  raised. If end tag is empty or nil, an exception TEEndTagEmptyOrNil will
//  be raised. It is the responsibility of the caller to catch the exception.

+ (id)stringByExpandingTemplate:(NSString *)templateString
				   withStartTag:(NSString *)startTag
					  andEndTag:(NSString *)endTag
				usingDictionary:(NSDictionary *)dictionary
				 errorsReturned:(NSArray **)errorLog
{
	NSArray *template = [templateString arrayBySeparatingLinesUsingEOLmarkers];
	NSEnumerator *list = [template objectEnumerator];
	NSMutableString *result = [NSMutableString stringWithCapacity:[templateString length]];
//	NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
	NSMutableCharacterSet *whitespaceSet = [NSMutableCharacterSet whitespaceCharacterSet];
	[whitespaceSet addCharactersInString:@"\""];
	NSMutableDictionary *_dictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
	NSProcessInfo *processInfo = [NSProcessInfo processInfo];
	
	// IF/IF-NOT groups:
	// Each if-directive is processed by the same code as the directive's
	// complement directive. For example, %IF and %IFNOT are processed by the
	// same code in the parser. In order to be able to determine whether the
	// directive was a complement or not, a complement flag is used. Upon entry
	// into the parser loop, the complement flag is set whenever an %IFNOT,
	// %IFNEQ, %IFNDEF, %ELSIFNEQ or %ELSIFNDEF directive is found, and it is
	// cleared whenever an %IF, %IFEQ, %IFDEF, %ELSIFEQ or %ELSIFDEF is found.
	// When evaluating the expression following an if- or else-if directive a
	// logical XOR of the complement flag is applied to the expression.
	unsigned complement = 0;
	
	// Nested %IF blocks:
	// When a new %IF block is opened by %IF, %IFEQ, %IFNEQ, %IFDEF or %IFNDEF,
	// the current state held in flags is saved to stack and a new set of flags
	// is initialised. When an open if-block is closed by %ENDIF, the state of
	// the previous if-block is restored from stack to flags.
	TEFlags *flags = [TEFlags flags];
	LIFO *stack = [LIFO stackWithCapacity:8];
	
	// Error log:
	NSMutableArray *_errorLog = [NSMutableArray arrayWithCapacity:5];
	#define errorsHaveOcurred ([_errorLog count] > 0)
	NSMutableArray *lineErrors = [NSMutableArray arrayWithCapacity:2];
	#define lineErrorsHaveOcurred ([lineErrors count] > 0)
	TEError *error;

	// Temporary string variables and line counter
	NSString *line = nil, *remainder_ = nil, *keyword = nil, *key = nil, *value = nil, *operand = nil, *varName = nil;
	NSMutableString *innerString = nil;
	unsigned len, lineNumber = 0, unexpandIf = 0, unexpandFor = 0;
	
	// -----------------------------------------------------------------------
	//  P r e c o n d i t i o n s   c h e c k
	// -----------------------------------------------------------------------

	NSException *exception = nil;
	// check if start tag is nil or empty
	if ((startTag == nil) || ([startTag length] == 0)) {
		// this is a fatal error -- bail out by raising an exception
		exception = [NSException exceptionWithName:@"TEStartTagEmptyOrNil"
											reason:@"startTag is empty or nil" userInfo:nil];
		[exception raise];
	} // end if
	  // check if end tag is nil or empty
	if ((endTag == nil) || ([endTag length] == 0)) {
		// this is a fatal error -- bail out by raising an exception
		[NSException exceptionWithName:@"TEEndTagEmptyOrNil"
								reason:@"endTag is empty or nil" userInfo:nil];
		[exception raise];
	} // end if	
	
	// -----------------------------------------------------------------------
	//  A u t o m a t i c   p l a c e h o l d e r   v a r i a b l e s
	// -----------------------------------------------------------------------
	
	// Entering automatic placeholder variables into the dictionary:
	[_dictionary setObject:[[NSDate date] description] forKey:@"_timestamp"];
	[_dictionary setObject:[processInfo globallyUniqueString] forKey:@"_uniqueID"];
	[_dictionary setObject:[processInfo hostName] forKey:@"_hostname"];
	
	// -----------------------------------------------------------------------
	//  L o c a l e   i n f o r m a t i o n
	// -----------------------------------------------------------------------
	// Sometimes Apple have got their priorities dead wrong. Without ugly
	// hacks this information is only available as of MacOS X 10.4 "Tiger".
	
	// Define locale specific variables if the NSLocale class is available ...
	if (classExists(@"NSLocale")) {
		NSLocale *locale;
		// user's locale settings
		locale = [NSLocale currentLocale];
		[_dictionary setObject:[locale objectForKey:NSLocaleCountryCode] forKey:@"_userCountryCode"];
		[_dictionary setObject:[locale objectForKey:NSLocaleLanguageCode] forKey:@"_userLanguage"];
		// system locale settings
		locale = [NSLocale systemLocale];
		key = [locale objectForKey:NSLocaleCountryCode];
		// if NSLocaleCountryCode is undefined for the system locale ...
		if (key == nil) {
			// set the variable to empty string
			[_dictionary setObject:kEmptyString forKey:@"_systemCountryCode"];
		}
		else {
			// set the variable to the value of NSLocaleCountryCode
			[_dictionary setObject:key forKey:@"_systemCountryCode"];
		} // end if
		key = [locale objectForKey:NSLocaleLanguageCode];
		// if NSLocaleLanguageCode is undefined for the system locale ...
		if (key == nil) {
			// set the variable to empty string
			[_dictionary setObject:kEmptyString forKey:@"_systemLanguage"];
		}
		else {
			// set the variable to the value of NSLocaleLanguageCode
			[_dictionary setObject:key forKey:@"_systemLanguage"];
		} // end if
	} // end if

	// -----------------------------------------------------------------------
	//  P a r s e r   l o o p
	// -----------------------------------------------------------------------
	
	while ((line = [list nextObject])) {
		lineNumber++;
		if([line length] == 0) {
			//[result appendString:kLineFeed];
			continue;
		}
		// if the line begins with a % character but not the start tag ...
		if (([line hasPrefix:startTag] == NO) && ([line characterAtIndex:0] == '%')) {
			// then the first word is likely to be a keyword
			keyword = [line firstWordUsingDelimitersFromSet:whitespaceSet];
			// if keyword starts with "%IFN" or "%ELSIFN" set complement to 1, otherwise 0
			complement = (([keyword hasPrefix:@"%IFN"]) || ([keyword hasPrefix:@"%ELSIFN"]));

			// ---------------------------------------------------------------
			//  % I F   a n d   % I F N O T   b r a n c h
			// ---------------------------------------------------------------

			if (!flags->forBranch && (([keyword isEqualToString:@"%IF"]) || ([keyword isEqualToString:@"%IFNOT"]))) {
				if (flags->expand) {
					// we are to evaluate if the key's value represents 'true'
					// evaluate expression following %IF/%IFNOT
					key = [line wordAtIndex:2 usingDelimitersFromSet:whitespaceSet];
					// if there is no identifier following %IF/%IFNOT ...
					if ([key isEmpty]) {
						// this is an error - create a new error description
						error = [TEError error:TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR
										inLine:lineNumber atToken:(TE_IF + complement)];
						// and add this error to the error log
						[_errorLog addObject:error];
						// log this error to the console
						[error logErrorMessageForTemplate:kEmptyString];
						// *** we are going to ignore this entire if-elsif-else-endif block ***
						// if this is a nested if-else block ...
						if (flags->condex) {
							// save flags to the stack
							[stack pushObject:flags];
							// and initialise a new set of flags
							flags = [TEFlags flags];
						} // end if
						// clear the expand flag to ignore this if-branch
						flags->expand = false;
						// set the consumed flag to ignore any elsif- and else- branches
						flags->consumed = true;
						// set condex flag to indicate we're inside an if-else block
						flags->condex = true;
					}
					// if there is an identifier following %IF/%IFNOT ...
					else {
						// look up the value of the key in the dictionary
						value = [self valueForDictionary:_dictionary key:key];
						// *** this is the surviving branch - others are error branches ***
						// if this is a nested if-else block ...
						if (flags->condex) {
							// save flags to the stack
							[stack pushObject:flags];
							// and initialise a new set of flags
							flags = [TEFlags flags];
						} // end if
						  // evaluate if the value of the key represents 'true'
						flags->expand = ([value representsTrue]) ^ complement;
						// remember evaluation
						flags->consumed = flags->expand;
						// remember that we're in an if-else block
						flags->condex = true;
					} // end if
				} else {
					++unexpandIf;
					flags->condex = false;
				} // end if
			}
			
			// ---------------------------------------------------------------
			//  % E L S I F   a n d   % E L S I F N O T   b r a n c h
			// ---------------------------------------------------------------
			
			else if (!flags->forBranch && (([keyword isEqualToString:@"%ELSIF"]) || ([keyword isEqualToString:@"%ELSIFNOT"]))) {
				if (flags->condex) {
					// if any branch in this if-else block was true ...
					if (flags->consumed) {
						// do not evaluate
						flags->expand = false;
					}
					else {
						// evaluate expression following %ELSIF/%ELSIFNOT
						key = [line wordAtIndex:2 usingDelimitersFromSet:whitespaceSet];
						// if there is no identifier following %ELSIF/%ELSIFNOT ...
						if ([key isEmpty]) {
							// this is an error - create a new error description
							error = [TEError error:TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR
											inLine:lineNumber atToken:(TE_ELSIF + complement)];
							// and add this error to the error log
							[_errorLog addObject:error];
							// log this error to the console
							[error logErrorMessageForTemplate:kEmptyString];
							// clear the expand flag to ignore this elsif-branch
							flags->expand = false;
						}
						else {
							value = [self valueForDictionary:dictionary key:key];
							// evaluate if the value of the key represents 'true'
							flags->expand = ([value representsTrue]) ^ complement;
						} // end if			
					} // end if
					  // remember evaluation
					flags->consumed = (flags->consumed || flags->expand);
				}
				else if(unexpandIf == 0) {
					// found %ELSIF/%ELSIFNOT without prior %IF block having been opened
					// this is an error - create a new error description
					error = [TEError error:TE_UNEXPECTED_TOKEN_ERROR
									inLine:lineNumber atToken:(TE_ELSIF + complement)];
					// and add this error to the error log
					[_errorLog addObject:error];
					// log this error to the console
					[error logErrorMessageForTemplate:kEmptyString];
					// clear the expand flag to ignore this elsif-branch
					flags->expand = false;
				} // end if
			}
			
			// ---------------------------------------------------------------
			//  % I F E Q   a n d   % I F N E Q   b r a n c h
			// ---------------------------------------------------------------
			
			else if (!flags->forBranch && (([keyword isEqualToString:@"%IFEQ"]) || ([keyword isEqualToString:@"%IFNEQ"]))) {
				if (flags->expand) {
					// we are to compare the key's value with an operand ...
					// evaluate expression following %IFEQ/%IFNEQ
					key = [line wordAtIndex:2 usingDelimitersFromSet:whitespaceSet];
					// if there is no identifier following %IFEQ/%IFNEQ ...
					if ([key isEmpty]) {
						// this is an error - create a new error description
						error = [TEError error:TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR
										inLine:lineNumber atToken:(TE_IFEQ + complement)];
						// and add this error to the error log
						[_errorLog addObject:error];
						// log this error to the console
						[error logErrorMessageForTemplate:kEmptyString];
						// *** we are going to ignore this entire if-elsif-else-endif block ***
						// if this is a nested if-else block ...
						if (flags->condex) {
							// save flags to the stack
							[stack pushObject:flags];
							// and initialise a new set of flags
							flags = [TEFlags flags];
						} // end if
						  // clear the expand flag to ignore this if-branch
						flags->expand = false;
						// set the consumed flag to ignore any elsif- and else- branches
						flags->consumed = true;
						// set condex flag to indicate we're inside an if-else block
						flags->condex = true;
					}
					// if there is an identifier following %IFEQ/%IFNEQ ...
					else {
						// look up the value of the key in the dictionary
						value = [NSString valueForDictionary:_dictionary key:key];
						// get the remaining characters following the key
						remainder_ = [[line restOfWordsUsingDelimitersFromSet:whitespaceSet]
									restOfWordsUsingDelimitersFromSet:whitespaceSet];
						// check if we have an operand
						len = [remainder_ length];
						if (len == 0) {
							// this is an error - no operand to compare
							error = [TEError error:TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR
											inLine:lineNumber atToken:TE_KEY];
							[error setLiteral:key];
							// and add this error to the error log
							[_errorLog addObject:error];
							// log this error to the console
							[error logErrorMessageForTemplate:kEmptyString];
							// *** we are going to ignore this entire if-elsif-else-endif block ***
							// if this is a nested if-else block ...
							if (flags->condex) {
								// save flags to the stack
								[stack pushObject:flags];
								// and initialise a new set of flags
								flags = [TEFlags flags];
							} // end if
							  // clear the expand flag to ignore this if-branch
							flags->expand = false;
							// set the consumed flag to ignore any elsif- and else- branches
							flags->consumed = true;
							// set condex flag to indicate we're inside an if-else block
							flags->condex = true;
						}
						else {
							if (len == 1) {
								// only one character - use it as it is
								operand = [remainder_ copy];
							}
							else {
								// multiple characters left on the line
								// check if we have a quoted string using single quotes
								if ([remainder_ characterAtIndex:0] == '\'') {
									// get the characters enclosed by the single quotes
									operand = [remainder_ substringWithStringInSingleQuotes];
									// if there are no closing quotes
									if (operand == nil) {
										// assume EOL terminates the quoted string
										operand = [remainder_ substringFromIndex:1];
									} // end if
								}
								// alternatively, a quoted string using double quotes
								else if ([remainder_ characterAtIndex:0] == '"') {
									// get the characters enclosed by the double quotes
									operand = [remainder_ substringWithStringInDoubleQuotes];
									// if there are no closing quotes
									if (operand == nil) {
										// assume EOL terminates the quoted string
										operand = [remainder_ substringFromIndex:1];
									} // end if
								}
								// otherwise if we don't have a quoted string
								else {
									// get the first word of the remaining characters on the line
									operand = remainder_;
								} // end if
							} // end if
							// *** this is the surviving branch - others are error branches ***
							// if this is a nested if-else block ...
							if (flags->condex) {
								// save flags to the stack
								[stack pushObject:flags];
								// and initialise a new set of flags
								flags = [TEFlags flags];
							} // end if
							// compare the value of the key to the operand
							flags->expand = ([value isEqual:operand] == YES) ^ complement;
							// remember evaluation
							flags->consumed = flags->expand;
							// remember that we're in an if-else block
							flags->condex = true;
						} // end if
					} // end if
				} else {
					++unexpandIf;
					flags->condex = false;
				} // end if
			}

			// ---------------------------------------------------------------
			//  % E L S I F E Q   a n d   % E L S I F N E Q   b r a n c h
			// ---------------------------------------------------------------
			
			if (!flags->forBranch && (([keyword isEqualToString:@"%ELSIFEQ"]) || ([keyword isEqualToString:@"%ELSIFNEQ"]))) {
				// we only care about this block if it is part of an open %IF
				if (flags->condex) {
					// ignore if already consumed
					if (flags->consumed) {
						// do not expand this block
						flags->expand = false;
					}
					else {
						// evaluate expression following %ELSIFEQ/%ELSIFNEQ
						key = [line wordAtIndex:2 usingDelimitersFromSet:whitespaceSet];
						// if there is no identifier following %ELSIFEQ/%ELSIFNEQ ...
						if ([key isEmpty]) {
							// this is an error - create a new error description
							error = [TEError error:TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR
											inLine:lineNumber atToken:(TE_ELSIFEQ + complement)];
							// and add this error to the error log
							[_errorLog addObject:error];
							// log this error to the console
							[error logErrorMessageForTemplate:kEmptyString];
							// clear the expand flag to ignore this elsif-branch
							flags->expand = false;
						}
						else {
							// look up the value of the key in the dictionary
							value = [NSString valueForDictionary:_dictionary key:key];
							// get the remaining characters following the key
							remainder_ = [[line restOfWordsUsingDelimitersFromSet:whitespaceSet]
									restOfWordsUsingDelimitersFromSet:whitespaceSet];
							// check if we have an operand
							len = [remainder_ length];
							if (len == 0) {
								// this is an error - no operand to compare
								error = [TEError error:TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR
												inLine:lineNumber atToken:TE_KEY];
								[error setLiteral:key];
								// and add this error to the error log
								[_errorLog addObject:error];
								// log this error to the console
								[error logErrorMessageForTemplate:kEmptyString];
								// clear the expand flag to ignore this elsif-branch
								flags->expand = false;
							}
							else {
								if (len == 1) {
									// only one character - use it as it is
									operand = [remainder_ copy];
								}
								else {
									// multiple characters left on the line
									// check if we have a quoted string using single quotes
									if ([remainder_ characterAtIndex:0] == '\'') {
										// get the characters enclosed by the single quotes
										operand = [remainder_ substringWithStringInSingleQuotes];
										// if there are no closing quotes
										if (operand == nil) {
											// assume EOL terminates the quoted string
											operand = [remainder_ substringFromIndex:1];
										} // end if
									}
									// alternatively, a quoted string using double quotes
									else if ([remainder_ characterAtIndex:0] == '"') {
										// get the characters enclosed by the double quotes
										operand = [remainder_ substringWithStringInDoubleQuotes];
										// if there are no closing quotes
										if (operand == nil) {
											// assume EOL terminates the quoted string
											operand = [remainder_ substringFromIndex:1];
										} // end if
									}
									// otherwise if we don't have a quoted string
									else {
										// get the first word of the remaining characters on the line
										operand = [remainder_ firstWordUsingDelimitersFromSet:whitespaceSet];
									} // end if
								} // end if
								// *** this is the surviving branch - others are error branches ***
								// compare the value of the key to the operand
								flags->expand = ([value isEqualToString:operand] == YES) ^ complement;
								// remember evaluation
								flags->consumed = flags->expand;
							} // end if
						} // end if
					} // end if
				}
				// if this block is not part of an open %IF ...
				else if(unexpandIf == 0) {
					// found %ELSIFEQ/%ELSIFNEQ without prior %IF block having been opened
					// this is an error - create a new error description
					error = [TEError error:TE_UNEXPECTED_TOKEN_ERROR
									inLine:lineNumber atToken:(TE_ELSIFEQ + complement)];
					// and add this error to the error log
					[_errorLog addObject:error];
					// log this error to the console
					[error logErrorMessageForTemplate:kEmptyString];
					// clear the expand flag to ignore this elsif-branch
					flags->expand = false;
				} // end if
			}
			
			// ---------------------------------------------------------------
			//  % I F D E F   a n d   % I F N D E F   b r a n c h
			// ---------------------------------------------------------------
			
			else if (!flags->forBranch && (([keyword isEqualToString:@"%IFDEF"]) || ([keyword isEqualToString:@"%IFNDEF"]))) {
				if(flags->expand) {
					// get the identifier following %IFDEF/%IFNDEF
					key = [line wordAtIndex:2 usingDelimitersFromSet:whitespaceSet];
					// if there is no identifier following %IFDEF/%IFNDEF ...
					if ([key isEmpty]) {
						// this is an error - create a new error description
						error = [TEError error:TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR
										inLine:lineNumber atToken:(TE_IFDEF + complement)];
						// and add this error to the error log
						[_errorLog addObject:error];
						// log this error to the console
						[error logErrorMessageForTemplate:kEmptyString];
						// *** we are going to ignore this entire if-elsif-else-endif block ***
						// if this is a nested if-else block ...
						if (flags->condex) {
							// save flags to the stack
							[stack pushObject:flags];
							// and initialise a new set of flags
							flags = [TEFlags flags];
						} // end if
						// clear the expand flag to ignore this if-branch
						flags->expand = false;
						// set the consumed flag to ignore any elsif- and else- branches
						flags->consumed = true;
						// set condex flag to indicate we're inside an if-else block
						flags->condex = true;
					}
					// if there is an identifier following %IFDEF/%IFNDEF ...
					else {
						// if this is a nested if-else block ...
						if (flags->condex) {
							// this is a nested %IFDEF - save flags to the stack
							[stack pushObject:flags];
							// and initialise a new set of flags
							flags = [TEFlags flags];
						} // end if
						// set expand flag to true if key is defined, false if undefined
						flags->expand = (keyDefined(_dictionary, key)) ^ complement;
						// remember evaluation
						flags->consumed = flags->expand;
						// remember that we're in an if-else block
						flags->condex = true;
					} // end if
				} else {
					++unexpandIf;
					flags->condex = false;
				} // end if
			}

			// ---------------------------------------------------------------
			//  % E L S I F D E F   a n d   % E L S I F N D E F   b r a n c h
			// ---------------------------------------------------------------

			else if (!flags->forBranch && (([keyword isEqualToString:@"%ELSIFDEF"]) || ([keyword isEqualToString:@"%ELSIFNDEF"]))) {
				if (flags->condex) {
					// if any branch in this if-else block was true ...
					if (flags->consumed) {
						// do not evaluate
						flags->expand = false;
					}
					else {
						// evaluate expression following %ELSIFDEF/%ELSIFNDEF
						key = [line wordAtIndex:2 usingDelimitersFromSet:whitespaceSet];
						// if there is no identifier following %ELSIFDEF/%ELSIFNDEF
						if ([key isEmpty]) {
							// this is an error - create a new error description
							error = [TEError error:TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR
											inLine:lineNumber atToken:(TE_ELSIFDEF + complement)];
							// and add this error to the error log
							[_errorLog addObject:error];
							// log this error to the console
							[error logErrorMessageForTemplate:kEmptyString];
							// clear the expand flag to ignore this elsif-branch
							flags->expand = false;
						}
						else {
							// set expand flag to true if key is defined, false if undefined
							flags->expand = (keyDefined(_dictionary, key)) ^ complement;
						} // end if			
					} // end if
				// remember evaluation
				flags->consumed = (flags->consumed || flags->expand);
				}
				else if(unexpandIf == 0) {
					// found %ELSIFDEF/%ELSIFNDEF without prior %IF block having been opened
					// this is an error - create a new error description
					error = [TEError error:TE_UNEXPECTED_TOKEN_ERROR
									inLine:lineNumber atToken:(TE_ELSIFDEF + complement)];
					// and add this error to the error log
					[_errorLog addObject:error];
					// log this error to the console
					[error logErrorMessageForTemplate:kEmptyString];
					// clear the expand flag to ignore this elsif-branch
					flags->expand = false;
				} // end if
			}

			// ---------------------------------------------------------------
			//  % E L S E   b r a n c h
			// ---------------------------------------------------------------

			else if (!flags->forBranch && [keyword isEqualToString:@"%ELSE"]) {
				if (flags->condex) {
					// if any branch in this if-else block was true ...
					flags->expand = !(flags->consumed);
					flags->consumed = true;
				}
				else if(unexpandIf == 0) {
					// found %ELSE without any prior %IF block having been opened
					// this is an error - create a new error description
					error = [TEError error:TE_UNEXPECTED_TOKEN_ERROR
									inLine:lineNumber atToken:TE_ELSE];
					// and add this error to the error log
					[_errorLog addObject:error];
					// log this error to the console
					[error logErrorMessageForTemplate:kEmptyString];
					// clear the expand flag to ignore this else-branch
					flags->expand = false;
				} // end if
			}

			// ---------------------------------------------------------------
			//  % E N D I F   b r a n c h
			// ---------------------------------------------------------------

			else if (!flags->forBranch && [keyword isEqualToString:@"%ENDIF"]) {
				if (flags->condex) {
					// we're leaving the if-else block ...
					// check if there were any enclosing blocks
					if ([stack count] > 0) {
						// we're in a nested if-block
						// restore the flags for the enclosing block
						flags = [stack popObject];
					}
					else {
						// we're not in a nested if-block
						// reset flags to start conditions
						flags->expand = true;
						flags->consumed = false;
						flags->condex = false;
						flags->forBranch = false;
					} // end if
				}
				else if(unexpandIf > 0) {
					--unexpandIf;
					if(unexpandIf == 0) flags->condex = true;
				} else {
					// found %ENDIF without prior %IF block having been opened
					// this is an error - create a new error description
					error = [TEError error:TE_UNEXPECTED_TOKEN_ERROR
									inLine:lineNumber atToken:TE_ENDIF];
					// and add this error to the error log
					[_errorLog addObject:error];
					// log this error to the console
					[error logErrorMessageForTemplate:kEmptyString];
				} // end if
			}

			// ---------------------------------------------------------------
			//  % D E F I N E   b r a n c h
			// ---------------------------------------------------------------

			else if (!flags->forBranch && [keyword isEqualToString:@"%DEFINE"]) {
				if (flags->expand) {
					// we are to define a new key ...
					// evaluate expression following %DEFINE
					key = [line wordAtIndex:2 usingDelimitersFromSet:whitespaceSet];
					// if there is no identifier following %DEFINE
					if ([key isEmpty]) {
						// this is an error - create a new error description
						error = [TEError error:TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR
										inLine:lineNumber atToken:TE_DEFINE];
						// and add this error to the error log
						[_errorLog addObject:error];
						// log this error to the console
						[error logErrorMessageForTemplate:kEmptyString];
					}
					else {
						// obtain the value for this key
						value = [[line restOfWordsUsingDelimitersFromSet:whitespaceSet]
									restOfWordsUsingDelimitersFromSet:whitespaceSet];
						// add the new key to the dictionary
						[_dictionary setObject:[value copy] forKey:key];
					} // end if
				} // end if
			}

			// ---------------------------------------------------------------
			//  % U N D E F   b r a n c h
			// ---------------------------------------------------------------

			else if (!flags->forBranch && [keyword isEqualToString:@"%UNDEF"]) {
				if (flags->expand) {
					// evaluate expression following %UNDEF
					key = [line wordAtIndex:2 usingDelimitersFromSet:whitespaceSet];
					// if there is no identifier following %UNDEF
					if ([key isEmpty]) {
						// this is an error - create a new error description
						error = [TEError error:TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR
										inLine:lineNumber atToken:TE_UNDEF];
						// and add this error to the error log
						[_errorLog addObject:error];
						// log this error to the console
						[error logErrorMessageForTemplate:kEmptyString];
					}
					else {
						// remove this key from the dictionary
						[_dictionary removeObjectForKey:key];
					} // end if
				} // end if
			}

			// ---------------------------------------------------------------
			//  % L O G   b r a n c h
			// ---------------------------------------------------------------

			else if (!flags->forBranch && [keyword isEqualToString:@"%LOG"]) {
				if (flags->expand) {
					// we are to log text/keys to the console ...
					
					// evaluate expression following %LOG
					key = [line wordAtIndex:2 usingDelimitersFromSet:whitespaceSet];
					// if there is no identifier following %UNDEF
					if ([key isEmpty]) {
						// this is an error - create a new error description
						error = [TEError error:TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR
										inLine:lineNumber atToken:TE_LOG];
						// and add this error to the error log
						[_errorLog addObject:error];
						// log this error to the console
						[error logErrorMessageForTemplate:kEmptyString];
					}
					else {
						// lookup the value for this key in the dictionary
						value = [NSString valueForDictionary:_dictionary key:key];
						// and log it to the console
						NSLog(@"value for key '%@' is '%@'", key, value);
					} // end if
				} // end if
			}
			
			// ---------------------------------------------------------------
			//  % E C H O   b r a n c h
			// ---------------------------------------------------------------
			
			else if (!flags->forBranch && [keyword isEqualToString:@"%ECHO"]) {
				if (flags->expand) {
					// we are to log text/keys to stdout ...
					TODO
					// this is not implemented yet
					error = [TEError error:TE_UNIMPLEMENTED_TOKEN_ERROR
									inLine:lineNumber atToken:TE_ECHO];
					// and add this error to the error log
					[_errorLog addObject:error];
					// log this error to the console
					[error logErrorMessageForTemplate:kEmptyString];
				} // end if
			}
			
			// ---------------------------------------------------------------
			//  % D E B U G   b r a n c h
			// ---------------------------------------------------------------
			
			else if (!flags->forBranch && [keyword isEqualToString:@"%DEBUG"]) {
				if (flags->expand) {
					// we are to enable/disable debug mode ...
					TODO
					// this is not implemented yet
					error = [TEError error:TE_UNIMPLEMENTED_TOKEN_ERROR
									inLine:lineNumber atToken:TE_DEBUG];
					// and add this error to the error log
					[_errorLog addObject:error];
					// log this error to the console
					[error logErrorMessageForTemplate:kEmptyString];
				} // end if
			}
			
			// ---------------------------------------------------------------
			//  % F O R E A C H   b r a n c h
			// ---------------------------------------------------------------
			
			else if([keyword isEqualToString:@"%FOREACH"]) {
				if(!flags->forBranch && flags->expand) {
					varName = [line wordAtIndex:2 usingDelimitersFromSet:whitespaceSet];
					key = [line wordAtIndex:4 usingDelimitersFromSet:whitespaceSet];
					
					if (flags->expand) {
						// if there is no identifier following %FOREACH ...
						if ([key isEmpty] || [varName isEmpty]) {
							// this is an error - create a new error description
							error = [TEError error:TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR
											inLine:lineNumber atToken:(complement)];
							// and add this error to the error log
							[_errorLog addObject:error];
							// log this error to the console
							[error logErrorMessageForTemplate:kEmptyString];
							// *** we are going to ignore this entire if-elsif-else-endif block ***
							// if this is a nested if-else block ...
							if (flags->condex) {
								// save flags to the stack
								[stack pushObject:flags];
								// and initialise a new set of flags
								flags = [TEFlags flags];
							} // end if
							// clear the expand flag to ignore this if-branch
							flags->expand = false;
							// set the consumed flag to ignore any elsif- and else- branches
							flags->consumed = true;
							// set condex flag to indicate we're inside an if-else block
							flags->condex = true;
						}
						// if there is an identifier following %FOREACH ...
						else {
							// look up the value of the key in the dictionary
							value = [NSString valueForDictionary:_dictionary key:key];
							if(value == nil || ![value isKindOfClass:[NSArray class]])
							{
								error = [TEError error:TE_UNDEFINED_PLACEHOLDER_FOUND_ERROR
												inLine:lineNumber atToken:TE_FOREACH];
								[error setLiteral:key];
								// and add this error to the error log
								[_errorLog addObject:error];
								// log this error to the console
								[error logErrorMessageForTemplate:kEmptyString];
							}
							
							// *** this is the surviving branch - others are error branches ***
							// if this is a nested if-else block ...
							if (flags->condex) {
								// save flags to the stack
								[stack pushObject:flags];
								// and initialise a new set of flags
								flags = [TEFlags flags];
							} // end if
							// compare the value of the key to the operand
							flags->expand = false;
							flags->consumed = true;
							flags->forBranch = true;
							flags->condex = true;
							
						} // end if
					} 
					else {
						[stack pushObject:flags];
						
						flags = [TEFlags flags];
						flags->expand = false;
						flags->consumed = true;
						flags->forBranch = true;
						flags->condex = false;
					} // end if
				} else {
					unexpandFor++;
				}
			}
			
			// ---------------------------------------------------------------
			//  % E N D F O R   b r a n c h
			// ---------------------------------------------------------------
			
			else if([keyword isEqualToString:@"%ENDFOR"]) {
				if(unexpandFor > 0) {
					--unexpandFor;
				} else {
					if (flags->forBranch && flags->condex) {
						// we're leaving the for block ...
						// check if there were any enclosing blocks
						if ([stack count] > 0) {
							// we're in a nested if-block
							// restore the flags for the enclosing block
							flags = [stack popObject];
						}
						else {
							// we're not in a nested if-block
							// reset flags to start conditions
							flags->expand = true;
							flags->consumed = false;
							flags->condex = false;
							flags->forBranch = false;
						} // end if
						
						NSArray *array = [NSString valueForDictionary:_dictionary key:key];
						for(id varValue in array) {
							[_dictionary setObject:varValue forKey:varName];
							[result appendString:[NSString stringByExpandingTemplate:innerString
																		withStartTag:startTag
																		   andEndTag:endTag
																	 usingDictionary:_dictionary
																	  errorsReturned:errorLog]];
						}
						[_dictionary removeObjectForKey:varName];
						
						[innerString release];
						innerString = nil;
					}
					else {
						if ([stack count] > 0) {
							// we're in a nested if-block
							// restore the flags for the enclosing block
							flags = [stack popObject];
						} else {
							// found %ENDIF without prior %IF block having been opened
							// this is an error - create a new error description
							error = [TEError error:TE_UNEXPECTED_TOKEN_ERROR
											inLine:lineNumber atToken:TE_ENDIF];
							// and add this error to the error log
							[_errorLog addObject:error];
							// log this error to the console
							[error logErrorMessageForTemplate:kEmptyString];
						}
					} // end if
				}
			}
			
			// ---------------------------------------------------------------
			//  % c o m m e n t   b r a n c h
			// ---------------------------------------------------------------

			// if the '%' character is not part of a placeholder/directive ...
			else {
				// then the current line is a template comment.
				// it will not be expanded nor copied to the result
			} // end if
		}
		// if line does not begin with a % character ...
		// then it is neither comment nor template command
		// if expand flag is set, expand it, otherwise ignore it
		else if (flags->expand) {
			// expand the line and add it to the result
			[result appendString:[line stringByExpandingPlaceholdersWithStartTag:startTag
																	   andEndTag:endTag
																 usingDictionary:_dictionary
																  errorsReturned:&lineErrors
																	  lineNumber:lineNumber]];
			[result appendString:kLineFeed];
			
			// if there were any errors ...
			if (lineErrorsHaveOcurred) {
				// add the errors to the error log
				[_errorLog addObjectsFromArray:lineErrors];
			} // end if
		} // end if
		if (flags->forBranch) {
			if(innerString == nil) {
				innerString = [[NSMutableString alloc] init];
			} else {
				[innerString appendString:line];
				[innerString appendString:kLineFeed];
			}
		} // end if
	} // end while
	if (flags->condex) {
		// we've reached the end of the template without previous %IF block having been closed
		// this is an error - create a new error description
		error = [TEError error:TE_EXPECTED_ENDIF_BUT_FOUND_TOKEN_ERROR
						inLine:lineNumber atToken:TE_EOF];
		// and add this error to the error log
		[_errorLog addObject:error];
		// log this error to the console
		[error logErrorMessageForTemplate:kEmptyString];
	} // end if
	// if there were any errors ...
	if (errorsHaveOcurred) {
		// pass the error log back to the caller
		*errorLog = _errorLog;
		// get rid of the following line after testing
		NSLog(@"errors have occurred while expanding placeholders in string using dictionary:\n%@", dictionary);
		NSLog(@"using template:\n%@", template);
	}
	// if there were no errors ...
	else {
		// pass nil in the errorLog back to the caller
		if(errorLog != nil) *errorLog = nil;
	} // end if
	// return the result string
	return [NSString stringWithString:result];
	#undef errorsHaveOcurred
	#undef lineErrorsHaveOcurred
} // end method

// ---------------------------------------------------------------------------
// Class Method:  stringByExpandingTemplateAtPath:usingDictionary:
//                encoding:errorsReturned:
// ---------------------------------------------------------------------------
//
// description:
//  Invokes method stringByExpandingTemplateAtPath:withStartTag:andEndTag:
//  usingDictionary:encoding:errorsReturned: with the template engine's
//  default tags: startTag "%«" and endTag "»". This method is source file
//  encoding-safe.

+ (id)stringByExpandingTemplateAtPath:(NSString *)path
					  usingDictionary:(NSDictionary *)dictionary
							 encoding:(NSStringEncoding)enc
					   errorsReturned:(NSArray **)errorLog
{
	return [NSString stringByExpandingTemplateAtPath:path
										withStartTag:[NSString defaultStartTag]
										   andEndTag:[NSString defaultEndTag]
									 usingDictionary:dictionary
											encoding:enc
									  errorsReturned:errorLog];
} // end method 

// ---------------------------------------------------------------------------
// Class Method:  stringByExpandingTemplateAtPath:withStartTag:andEndTag:
//                usingDictionary:encoding:errorsReturned:
// ---------------------------------------------------------------------------
//
// description:
//  Returns a new NSString made by expanding the template file at path. This
//  method reads the template file specified in path interpreted in the string
//  encoding specified by encoding and then it invokes class method
//  stringByExpandingTemplate:withStartTag:andEndTag:usingDictionary:
//  errorsReturned: to expand the template read from the template file.
//
// pre-conditions:
//  path is a valid path to the template file to be expanded.
//  startTag and endTag must not be empty strings and must not be nil.
//  dictionary contains keys to be replaced by their respective values.
//  encoding is a valid string encoding as defined by NSStringEncoding.
//  errorLog is an NSArray passed by reference.
//
// post-conditions:
//  Return value contains a new NSString made by expanding the template file
//  at path with lines outside of %IF blocks expanded unconditionally and
//  lines inside of %IF blocks expanded conditionally. If any errors are
//  encountered while attempting to read the template file or during template
//  expansion, errorLog will be set to an NSArray containing error
//	descriptions of class TEError for each error or warning. If there were
//	neither errors nor warnings during template expansion, errorLog is set to
//	nil.
//		Errors that prevent the template file to be found or read will cause
//	the method to abort the attempt to expand the template.
//		For a description of error recovery for other errors see method
//  stringByExpandingTemplate:withStartTag:andEndTag:usingDictionary:
//  errorsReturned:
//
// error-conditions:
//  If startTag is empty or nil, an exception StartTagEmptyOrNil will be
//  raised. If end tag is empty or nil, an exception EndTagEmptyOrNil will be
//  raised. It is the responsibility of the caller to catch the exception.
//  If the template file cannot be found or opened, or if there is an encoding
//  error with the contents of the file, one or more error descriptions of
//  class TEError are returned in errorLog.

+ (id)stringByExpandingTemplateAtPath:(NSString *)path
						 withStartTag:(NSString *)startTag
							andEndTag:(NSString *)endTag
					  usingDictionary:(NSDictionary *)dictionary
							 encoding:(NSStringEncoding)enc
					   errorsReturned:(NSArray **)errorLog
{
	NSFileManager *fileMgr = [NSFileManager defaultManager];
	NSString *templateString, *desc, *reason;
	NSData *templateData;
	NSError *fileError = nil;
	TEError *error;

	// check if a path was specified
	if ((path == nil) || ([path length] == 0)) {
		// create error description - invalid path
		error = [TEError error:TE_INVALID_PATH_ERROR inLine:0 atToken:TE_PATH];
		[error setLiteral:@"(empty path)"];
		// log this error to the console
		[error logErrorMessageForTemplate:path];
		// and add this error to the error log
		*errorLog = [NSArray arrayWithObject:error];
		// this error is not recoverable - abort
		return nil;
	} // end if
	
	// check if path is an absolute path
	path = [path stringByStandardizingPath];
	if ([path isAbsolutePath] == NO) {
		// create error description - invalid path
		error = [TEError error:TE_INVALID_PATH_ERROR inLine:0 atToken:TE_PATH];
		[error setLiteral:path];
		// log this error to the console
		[error logErrorMessageForTemplate:path];
		// and add this error to the error log
		*errorLog = [NSArray arrayWithObject:error];
		// this error is not recoverable - abort
		return nil;
	} // end if
	
	// if the specified file does not exist ...
	if ([fileMgr fileExistsAtPath:path] == NO) {
		// create error description - file not found
		error = [TEError error:TE_FILE_NOT_FOUND_ERROR inLine:0 atToken:TE_PATH];
		[error setLiteral:path];
		// log this error to the console
		[error logErrorMessageForTemplate:path];
		// and add this error to the error log
		*errorLog = [NSArray arrayWithObject:error];
		// this error is not recoverable - abort
		return nil;
	}
	// if the specified file is not readable ...
	else if ([fileMgr isReadableFileAtPath:path] == NO) {
		// create error description - cannot read file
		error = [TEError error:TE_UNABLE_TO_READ_FILE_ERROR inLine:0 atToken:TE_PATH];
		[error setLiteral:path];
		// log this error to the console
		[error logErrorMessageForTemplate:path];
		// and add this error to the error log
		*errorLog = [NSArray arrayWithObject:error];
		// this error is not recoverable - abort
		return nil;
	}
	// if the specified file is not a regular file nor a symlink pointing to a regular file ...
	else if ([fileMgr isRegularFileAtPath:path] == NO) {
		// create error description - not regular file
		error = [TEError error:TE_UNABLE_TO_READ_FILE_ERROR inLine:0 atToken:TE_PATH];
		[error setLiteral:path];
		// log this error to the console
		[error logErrorMessageForTemplate:path];
		// and add this error to the error log
		*errorLog = [NSArray arrayWithObject:error];
		// this error is not recoverable - abort
		return nil;
	} // end if
		
	if ([NSString respondsToSelector:@selector(stringWithContentsOfFile:encoding:error:)]) {
		// use newer method as of MacOS X 10.4
		templateString = [NSString stringWithContentsOfFile:path encoding:enc error:&fileError];
		
		if (fileError != nil) {
			desc = [fileError localizedDescription];
			reason = [fileError localizedFailureReason];
			// if an error in the Cocoa Error Domain ocurred ...
            if ([[fileError domain] isEqualToString:NSCocoaErrorDomain]){
				// get the error code and match it to a corresponding TEError
				switch([fileError code]) {
					case NSFileNoSuchFileError :
					case NSFileReadNoSuchFileError :
					case NSFileReadInvalidFileNameError :
						// create error description - file not found
						error = [TEError error:TE_FILE_NOT_FOUND_ERROR inLine:0 atToken:TE_PATH];
						break;
					case NSFileReadNoPermissionError :
						// create error description - cannot read file
						error = [TEError error:TE_UNABLE_TO_READ_FILE_ERROR inLine:0 atToken:TE_PATH];
						break;
					case NSFileReadCorruptFileError :
						// create error description - invalid file format
						error = [TEError error:TE_INVALID_FILE_FORMAT_ERROR inLine:0 atToken:TE_PATH];
						break;
					case NSFileReadInapplicableStringEncodingError :
						// create error description - encoding error
						error = [TEError error:TE_TEMPLATE_ENCODING_ERROR inLine:0 atToken:TE_PATH];
						break;
					default :
						// create error description - generic file error
						error = [TEError error:TE_GENERIC_ERROR inLine:0 atToken:TE_PATH];
						// embed the Cocoa generated error description
						[error setLiteral:[NSString stringWithFormat:
							@"while trying to access file at path %@\n%@\n%@", path, desc, reason]];
						break;
				} // end switch
			}
			// if the error is outside of the Cocoa Error Domain ...
			else {
				// create error description - generic file error
				error = [TEError error:TE_GENERIC_ERROR inLine:0 atToken:TE_PATH];
				// embed the Cocoa generated error description
				[error setLiteral:[NSString stringWithFormat:
					@"while trying to access file at path %@\n%@\n%@", path, desc, reason]];
			} // end if
			if ([[error literal] length] == 0) {
				[error setLiteral:path];
			} // end if
			// log this error to the console
			[error logErrorMessageForTemplate:path];
			// and add this error to the error log
			*errorLog = [NSArray arrayWithObject:error];
			// this error is not recoverable - abort
			return nil;			
		} // end if
	}
	else {
		// use alternative method before MacOS X 10.4
		templateData = [NSData dataWithContentsOfFile:path]; // path must be absolute
		templateString = [[[NSString alloc] initWithData:templateData encoding:enc] autorelease];
		if (false) { // how the heck do we know there was no encoding error?
			// create error description - encoding error
			error = [TEError error:TE_TEMPLATE_ENCODING_ERROR inLine:0 atToken:TE_PATH];
			[error setLiteral:path];
			// log this error to the console
			[error logErrorMessageForTemplate:path];
			// and add this error to the error log
			*errorLog = [NSArray arrayWithObject:error];
			// this error is not recoverable - abort
			return nil;
		} // end if
	} // end if
	
	return [NSString stringByExpandingTemplate:templateString
								  withStartTag:startTag
									 andEndTag:endTag
							   usingDictionary:dictionary
								errorsReturned:errorLog];
} // end method

+ (id)valueForDictionary:(id)dictionary key:(NSString *)key
{
	// use placeholder as key for dictionary lookup
	id currentPlace = dictionary;
	NSArray *path = [key componentsSeparatedByString:@"."];
	for(id component in path) {
		if(currentPlace != nil && [currentPlace respondsToSelector:@selector(valueForKey:)]) currentPlace = [currentPlace valueForKey:component];
	}
	return currentPlace;
}

@end // STSTemplateEngine
