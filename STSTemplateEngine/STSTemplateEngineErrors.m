//
//	STSTemplateEngineErrors.h
//	STS Template Engine ver 1.00
//
//	Provides error reporting and error logging to the STS Template Engine.
//
//	Created by benjk on 7/4/05.
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
//	Still to do: read error messages from a localized strings file

// ---------------------------------------------------------------------------
// NSRange constant:  kZeroRange
// ---------------------------------------------------------------------------
//
// Defines an NSRange constant kZeroRange with zero location and zero length.
// This is used to indicate an undefined range to the TEError class.

const NSRange kZeroRange = { 0, 0 };

#import "STSTemplateEngineErrors.h"

@implementation TEError

// private method: initialise instance
- (id)init {
	self = [super init];
	return self;
} // end method

// private method: deallocate instance
- (void)dealloc {
    [self->literal release];
	[super dealloc];
} // end method

// ---------------------------------------------------------------------------
// Class Method:  error:inLine:atToken:
// ---------------------------------------------------------------------------
//
// Creates a new instance of TEError. Severity and remedy codes are set
// implicitly according to the parameters passed. The error code is defined by
// TEErrorCode, line indicates the line number in the template source in which
// the error ocurred, token indicates the offending token as defined by
// TEToken. The optional parameter range is initialised with kZeroRange and it
// may be set using method setRange:. The optional parameter literal is
// initialised with nil and it may be set using method setLiteral:

+ (TEError *)error:(enum TEErrorCode)code
			inLine:(unsigned)line 
		   atToken:(enum TEToken)token
{
	TEError *thisInstance = [[[TEError alloc] init] autorelease];
	NSException *exception;
	
	// initialise instance variables
	thisInstance->errorCode = code;
	thisInstance->lineNumber = line;
	thisInstance->token = token;
	thisInstance->range = kZeroRange;
	thisInstance->literal = nil; // this is optional info only
	
	// set remedy and severity according to error type and token
	switch(code) {
		case TE_GENERIC_ERROR :
			thisInstance->remedyCode = TE_ABORTING_TEMPLATE_EXPANSION;
			thisInstance->severityCode = TE_FATAL;
			break;
		case TE_INVALID_PATH_ERROR :
			thisInstance->remedyCode = TE_ABORTING_TEMPLATE_EXPANSION;
			thisInstance->severityCode = TE_FATAL;
			break;
		case TE_FILE_NOT_FOUND_ERROR :
			thisInstance->remedyCode = TE_ABORTING_TEMPLATE_EXPANSION;
			thisInstance->severityCode = TE_FATAL;
			break;
		case TE_UNABLE_TO_READ_FILE_ERROR :
			thisInstance->remedyCode = TE_ABORTING_TEMPLATE_EXPANSION;
			thisInstance->severityCode = TE_FATAL;
			break;
		case TE_INVALID_FILE_FORMAT_ERROR :
			thisInstance->remedyCode = TE_ABORTING_TEMPLATE_EXPANSION;
			thisInstance->severityCode = TE_FATAL;
			break;
		case TE_TEMPLATE_ENCODING_ERROR :
			thisInstance->remedyCode = TE_ABORTING_TEMPLATE_EXPANSION;
			thisInstance->severityCode = TE_FATAL;
			break;
		case TE_TEMPLATE_EMPTY_ERROR :
			thisInstance->remedyCode = TE_ABORTING_TEMPLATE_EXPANSION;
			thisInstance->severityCode = TE_FATAL;
			break;
		case TE_DICTIONARY_EMPTY_ERROR :
			thisInstance->remedyCode = TE_CONTINUING_WITH_EMPTY_DICTIONARY;
			thisInstance->severityCode = TE_WARNING;
			break;
		case TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR :
			switch(token) {
				case TE_LOG : // %LOG requires an argument
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_ECHO : // %ECHO will require an argument
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_DEBUG : // %DEBUG will require an argument
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_INCLUDE : // %INCLUDE will require an argument
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_IF : // %IF requires an argument
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_IFNOT : // %IFNOT requires an argument
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_ELSIF : // %ELSIF requires an argument
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_ELSIFNOT : // %ELSIFNOT requires an argument
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_IFEQ : // %IFEQ requires two arguments
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_IFNEQ : // %IFNEQ requires two arguments
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_ELSIFEQ : // %ELSIFEQ requires two arguments
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_ELSIFNEQ : // %ELSIFNEQ requires two arguments
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_IFDEF : // %IFDEF requires an argument
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_IFNDEF : // %IFNDEF requires an argument
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_ELSIFDEF : // %ELSIFDEF requires an argument
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_ELSIFNDEF : // %ELSIFNDEF requires an argument
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_ANY : // %ANY will require multiple arguments
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_EVERY : // %EVERY will require multiple arguments
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_DEFINE : // %DEFINE requires an argument
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_UNDEF : // %UNDEF requires an argument
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_KEY : // key after %IFEQ/%IFNEQ/%ELSIFEQ/%ELSIFNEQ must be followed by an operand
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_START_TAG : // start tag must be followed by a key
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_PLACEHOLDER : // placeholder must be followed by an end tag
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_TARGET : // %TARGET will require an argument
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_APPEND : // %APPED will require an argument
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_INSERT : // %INSERT will require an argument
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				default:
					// we should never get here -- bail out by raising an exception
					exception = [NSException exceptionWithName:@"UndefinedEnumValue"
														reason:@"undefined enum value encountered" userInfo:nil];
					[exception raise];
					break;
			} // end switch
			thisInstance->severityCode = TE_ERROR;
			break;
		case TE_EXPECTED_ENDIF_BUT_FOUND_TOKEN_ERROR :
			thisInstance->remedyCode = TE_CLOSING_IF_BLOCK_TO_CONTINUE;
			thisInstance->severityCode = TE_ERROR;
			break;
		case TE_UNEXPECTED_TOKEN_ERROR :
			thisInstance->remedyCode = TE_IGNORING_UNEXPECTED_TOKEN;
			thisInstance->severityCode = TE_ERROR;
			break;
		case TE_UNIMPLEMENTED_TOKEN_ERROR :
			thisInstance->remedyCode = TE_IGNORING_UNIMPLEMENTED_TOKEN;
			thisInstance->severityCode = TE_WARNING;
			break;
		case TE_UNDEFINED_PLACEHOLDER_FOUND_ERROR :
			thisInstance->remedyCode = TE_SKIPPING_PLACEHOLDER_TO_CONTINUE;
			thisInstance->severityCode = TE_ERROR;
			break;
		case TE_EXPECTED_ENDTAG_BUT_FOUND_TOKEN_ERROR :
			thisInstance->remedyCode = TE_IMPLYING_ENDTAG_TO_CONTINUE;
			thisInstance->severityCode = TE_ERROR;
			break;
		default:
			// we should never get here -- bail out by raising an exception
			exception = [NSException exceptionWithName:@"UndefinedEnumValue"
												reason:@"undefined enum value encountered" userInfo:nil];
			[exception raise];
			break;
	} // end switch
	
	return thisInstance;
} // end method

//
// ---------------------------------------------------------------------------
// Instance Method:  setRange:
// ---------------------------------------------------------------------------
//
// Sets the range of the receiver. This info is used to pinpoint the offending
// token's postion in the template source. By default it is initialised to
// kZeroRange (both position and length set to zero) indicating that range
// information is unavailable.

- (void)setRange:(NSRange)aRange
{
	self->range = aRange;
	return;
} // end method

// ---------------------------------------------------------------------------
// Instance Method:  setLiteral:
// ---------------------------------------------------------------------------
//
// Sets the *optional* clear text info of the receiver. This info is used to
// store the literal name of a placeholder when the token is TEplaceholder.
// By default it is initialised to nil.

- (void)setLiteral:(NSString *)literalString
{
    literalString = [literalString copy];
    [self->literal release];
	self->literal = literalString;
} // end method


// ---------------------------------------------------------------------------
// Instance Method:  errorCode
// ---------------------------------------------------------------------------
//
// Returns the error code of the receiver. The error code identifies the type
// of error described by the receiver as defined by TEErrorCode.

- (enum TEErrorCode)errorCode
{
	return self->errorCode;
} // end method;

// ---------------------------------------------------------------------------
// Instance Method:  severityCode
// ---------------------------------------------------------------------------
//
// Returns the severity code of the receiver. The severity code specifies the
// severity of the error described by the receiver as defined by TESeverity.

- (enum TESeverity)severityCode
{
	return self->severityCode;
} // end method

// ---------------------------------------------------------------------------
// Instance Method:  lineNumber
// ---------------------------------------------------------------------------
//
// Returns the line number in which the error described by the receiver
// ocurred. The line number may be 0 in the event of file access errors.

- (unsigned)lineNumber
{
	return self->lineNumber;
} // end method

// ---------------------------------------------------------------------------
// Instance Method:  token
// ---------------------------------------------------------------------------
//
// Returns the offending token of the error described by the receiver. Tokens
// represent parsed symbols in the template source and are defined by TEToken.

- (enum TEToken)token
{
	return self->token;
} // end method

// ---------------------------------------------------------------------------
// Instance Method:  range
// ---------------------------------------------------------------------------
//
// Returns an NSRange for the offending token of the error described by the
// receiver. The range pinpoints the offending token as it was encountered in
// the template source. This may be used to generate an attributed string
// representation of the template source to highlight where errors ocurred.

- (NSRange)range
{
	return self->range;
} // end method

// ---------------------------------------------------------------------------
// Instance Method:  remedyCode
// ---------------------------------------------------------------------------
//
// Returns the remedy code of the remedy taken for the error described by the
// receiver. Remedy codes are defined by TERemedy.

- (enum TERemedy)remedyCode
{
	return self->remedyCode;
} // end method

// ---------------------------------------------------------------------------
// Instance Method:  literal
// ---------------------------------------------------------------------------
//
// Returns an NSString with the optional clear text info of the receiver. This
// info is used to store the literal name of a placeholder when the token is
// TEplaceholder. Returns nil if the literal is nil (default).

- (NSString *)literal
{
	return self->literal;
} // end method

// ---------------------------------------------------------------------------
// Instance Method:  stringWithToken
// ---------------------------------------------------------------------------
//
// Returns an NSString with a human readable token string for the token of the
// error described by the receiver. Tokens are defined by TEToken.

- (NSString *)stringWithToken
{
	NSString *tokenString = nil;
	NSException *exception;
			
	// setting the token string
	switch(self->token) {
		case TE_TOKEN_NOT_AVAILABLE :
			tokenString = [NSString stringWithString:@""];
			break;
		case TE_LOG :
			tokenString = [NSString stringWithString:@"%LOG"];
			break;
		case TE_ECHO :
			tokenString = [NSString stringWithString:@"%ECHO"];
			break;
		case TE_DEBUG :
			tokenString = [NSString stringWithString:@"%DEBUG"];
			break;
		case TE_FOREACH :
			tokenString = [NSString stringWithString:@"%FOREACH"];
			break;
		case TE_INCLUDE :
			tokenString = [NSString stringWithString:@"%INCLUDE"];
			break;
		case TE_IF :
			tokenString = [NSString stringWithString:@"%IF"];
			break;
		case TE_IFNOT :
			tokenString = [NSString stringWithString:@"%IFNOT"];
			break;
		case TE_IFEQ :
			tokenString = [NSString stringWithString:@"%IFEQ"];
			break;
		case TE_IFNEQ :
			tokenString = [NSString stringWithString:@"%IFNEQ"];
			break;
		case TE_ELSIFEQ :
			tokenString = [NSString stringWithString:@"%ELSIFEQ"];
			break;
		case TE_ELSIFNEQ :
			tokenString = [NSString stringWithString:@"%ELSIFNEQ"];
			break;
		case TE_IFDEF :
			tokenString = [NSString stringWithString:@"%IFDEF"];
			break;
		case TE_IFNDEF :
			tokenString = [NSString stringWithString:@"%IFNDEF"];
			break;
		case TE_ELSIFDEF :
			tokenString = [NSString stringWithString:@"%ELSIFDEF"];
			break;
		case TE_ELSIFNDEF :
			tokenString = [NSString stringWithString:@"%ELSIFNDEF"];
			break;
		case TE_ANY :
			tokenString = [NSString stringWithString:@"%ANY"];
			break;
		case TE_EVERY :
			tokenString = [NSString stringWithString:@"%EVERY"];
			break;
		case TE_ELSE :
			tokenString = [NSString stringWithString:@"%ELSE"];
			break;
		case TE_ENDIF :
			tokenString = [NSString stringWithString:@"%ENDIF"];
			break;
		case TE_DEFINE :
			tokenString = [NSString stringWithString:@"%DEFINE"];
			break;
		case TE_UNDEF :
			tokenString = [NSString stringWithString:@"%UNDEF"];
			break;
		case TE_KEY :
			tokenString = [NSString stringWithString:@"%KEY"];
			break;
		case TE_START_TAG :
			tokenString = [NSString stringWithString:@"start tag"];
			break;
		case TE_END_TAG :
			tokenString = [NSString stringWithString:@"end tag"];
			break;
		case TE_PLACEHOLDER :
			tokenString = [NSString stringWithFormat:@"placeholder"];
			break;
		case TE_PATH :
			tokenString = [NSString stringWithString:@"path name"];
			break;
		case TE_TARGET :
			tokenString = [NSString stringWithString:@"%TARGET"];
			break;
		case TE_APPEND :
			tokenString = [NSString stringWithString:@"%APPEND"];
			break;
		case TE_INSERT :
			tokenString = [NSString stringWithString:@"%INSERT"];
			break;
		case TE_EOL :
			tokenString = [NSString stringWithString:@"EOL marker"];
			break;
		case TE_EOF :
			tokenString = [NSString stringWithString:@"EOF marker"];
			break;
		default:
			// we should never get here -- bail out by raising an exception
			exception = [NSException exceptionWithName:@"UndefinedEnumValue"
												reason:@"undefined enum value encountered" userInfo:nil];
			[exception raise];
			break;
	} // end switch
	
	// return the token string
	return [NSString stringWithString:tokenString];
} // end method	

// ---------------------------------------------------------------------------
// Instance Method:  stringWithDescription
// ---------------------------------------------------------------------------
//
// Returns an NSString with a human readable description of the error
// described by the receiver.

- (NSString *)stringWithDescription
{
	NSString *tokenString, *description = nil;
	NSException *exception;

	// setting the description string
	switch(self->errorCode) {
		case TE_GENERIC_ERROR :
			if (self->literal == nil) {
				description = [NSString stringWithString:@"Generic error: (no error description available)."];
			}
			else {
				description = [NSString stringWithFormat:@"'%@'", self->literal];
			} // end if
			break;
		case TE_INVALID_PATH_ERROR :
			description = [NSString stringWithString:@"Template file path is invalid."];
			break;
		case TE_FILE_NOT_FOUND_ERROR :
			if (self->literal == nil) {
				description = [NSString stringWithString:@"Template file not found."];
			}
			else {
				description = [NSString stringWithFormat:@"Template file at path '%@' not found.", self->literal];
			} // end if
			break;
		case TE_UNABLE_TO_READ_FILE_ERROR :
			if (self->literal == nil) {
				description = [NSString stringWithString:@"Unable to read template file."];
			}
			else {
				description = [NSString stringWithFormat:@"Unable to read template file at path '%@'.",
					self->literal];
			} // end if
			break;
		case TE_INVALID_FILE_FORMAT_ERROR :
			description = [NSString stringWithString:@"Unable to recognize template file format."];
			break;
		case TE_TEMPLATE_ENCODING_ERROR :
			description = [NSString stringWithString:@"Unable to decode string encoding."];
			break;
		case TE_TEMPLATE_EMPTY_ERROR :
			description = [NSString stringWithString:@"Template is empty."];
			break;
		case TE_DICTIONARY_EMPTY_ERROR :
			description = [NSString stringWithString:@"Dictionary is empty."];
			break;
		case TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR :
			tokenString = [self stringWithToken];
			description = [NSString stringWithFormat:@"Missing identifier after %@.", tokenString];
			break;
		case TE_EXPECTED_ENDIF_BUT_FOUND_TOKEN_ERROR :
			tokenString = [self stringWithToken];
			description = [NSString stringWithFormat:@"Expected %%ENDIF but found %@.", tokenString];
			break;
		case TE_UNEXPECTED_TOKEN_ERROR :
			tokenString = [self stringWithToken];
			description = [NSString stringWithFormat:@"Unexpected %@ found.", tokenString];
			break;
		case TE_UNIMPLEMENTED_TOKEN_ERROR :
			tokenString = [self stringWithToken];
			description = [NSString stringWithFormat:@"%@ has not been implemented yet.", tokenString];
			break;
		case TE_UNDEFINED_PLACEHOLDER_FOUND_ERROR :
			if (self->literal == nil) {
				tokenString = [NSString stringWithString:@"(unspecified)"];
			}
			else {
				tokenString = [NSString stringWithFormat:@"'%@'", self->literal];
			} // end if
			description = [NSString stringWithFormat:@"Placeholder %@ is undefined.", tokenString];
			break;
		case TE_EXPECTED_ENDTAG_BUT_FOUND_TOKEN_ERROR :
			tokenString = [self stringWithToken];
			description = [NSString stringWithFormat:@"Expected closing end tag but found %@.", tokenString];
			break;
		default:
			// we should never get here -- bail out by raising an exception
			exception = [NSException exceptionWithName:@"UndefinedEnumValue"
												reason:@"undefined enum value encountered" userInfo:nil];
			[exception raise];
			break;
	} // end switch
	
	// return the description string
	return [NSString stringWithString:description];
} // end method

// ---------------------------------------------------------------------------
// Instance Method:  stringWithRemedy
// ---------------------------------------------------------------------------
//
// Returns an NSString with a human readable description of the remedy taken
// for the error described by the receiver.

- (NSString *)stringWithRemedy
{
	NSString *tokenString, *remedy = nil;
	NSException *exception;
	
	// setting the remedy string
	switch(self->remedyCode) {
		case TE_REMEDY_NOT_AVAILABLE:
			remedy = [NSString stringWithString:@""];
			break;
		case TE_ASSUMING_TRUE_TO_CONTINUE :
			tokenString = [self stringWithToken];
			remedy = [NSString stringWithFormat:@"Assuming TRUE for this %@ block to continue.", tokenString];
			break;
		case TE_ASSUMING_FALSE_TO_CONTINUE :
			tokenString = [self stringWithToken];
			remedy = [NSString stringWithFormat:@"Assuming FALSE for this %@ block to continue.", tokenString];
			break;
		case TE_CONTINUING_WITH_EMPTY_DICTIONARY :
			remedy = [NSString stringWithString:@"Continuing with empty dictionary."];
			break;
		case TE_SKIPPING_PLACEHOLDER_TO_CONTINUE :
			if (self->literal == nil) {
				tokenString = [NSString stringWithString:@"(unspecified)"];
			}
			else {
				tokenString = [NSString stringWithFormat:@"'%@'", self->literal];
			} // end if
			remedy = [NSString stringWithFormat:@"Skipping placeholder %@ to continue.", tokenString];
			break;
		case TE_CLOSING_IF_BLOCK_TO_CONTINUE :
			remedy = [NSString stringWithString:@"Implicitly closing previous %IF block to continue."];
			break;
		case TE_IMPLYING_ENDTAG_TO_CONTINUE :
			remedy = [NSString stringWithString:@"Implying end tag to continue."];
			break;
		case TE_IGNORING_UNEXPECTED_TOKEN :
			tokenString = [self stringWithToken];
			remedy = [NSString stringWithFormat:@"Ignoring unexpected %@ to continue.", tokenString];
			break;
		case TE_IGNORING_UNIMPLEMENTED_TOKEN :
			tokenString = [self stringWithToken];
			remedy = [NSString stringWithFormat:@"Ignoring unimplemented %@ to continue.", tokenString];
			break;
		case TE_ABORTING_TEMPLATE_EXPANSION :
			remedy = [NSString stringWithString:@"Template expansion aborted."];
			break;
		default:
			// we should never get here -- bail out by raising an exception
			exception = [NSException exceptionWithName:@"UndefinedEnumValue"
												reason:@"undefined enum value encountered" userInfo:nil];
			[exception raise];
			break;
	} // end switch
	
	// return the remedy string
	return [NSString stringWithString:remedy];
} // end method	

// ---------------------------------------------------------------------------
// Instance Method:  stringWithErrorMessageForTemplate:
// ---------------------------------------------------------------------------
//
// Returns an NSString with a human readable detailed error message for the
// error described by the receiver comprising a prefix identifying the message
// to have come from the STS TemplateEngine, the severity of the error, the
// name or path and filename of the template, the line number in which the
// error ocurred and the error description and remedy taken. If an empty
// string is passed for nameOrPath, then the name of the template will be
// omitted in the error message returned.

- (NSString *)stringWithErrorMessageForTemplate:(NSString *)nameOrPath
{
	NSString *prefix, *severity = nil, *description, *remedy;
	NSException *exception;
	
	// setting the prefix text
	prefix = [NSString stringWithString:@"STS TemplateEngine"];
	
	// setting the severity string
	switch(self->severityCode) {
		case TE_WARNING :
			severity = [NSString stringWithString:@"*WARNING*"];
			break;
		case TE_ERROR :
			severity = [NSString stringWithString:@"*ERROR*"];
			break;
		case TE_FATAL :
			severity = [NSString stringWithString:@"*FATAL ERROR*"];
			break;
		default:
			// we should never get here -- bail out by raising an exception
			exception = [NSException exceptionWithName:@"UndefinedEnumValue"
												reason:@"undefined enum value encountered" userInfo:nil];
			[exception raise];
			break;
	} // end switch
	
	// get the description string
	description = [self stringWithDescription];
		
	// get the remedy string
	remedy = [self stringWithRemedy];
	
	// compose and return clear text message for message without template name
	if ([nameOrPath length] == 0) {
		if (self->lineNumber == 0) {
			// when line number is irrelevant
			return [NSString stringWithFormat:@"%@ encountered %@\n%@\n%@",
				prefix, severity, description, remedy];
		}
		else {
			// when line number is relevant
			return [NSString stringWithFormat:@"%@ encountered %@ in line %u \n%@\n%@",
				prefix, severity, self->lineNumber, description, remedy];
		} // end if
	}
	// compose and return clear text message for message with template name
	else {
		return [NSString stringWithFormat:@"%@ encountered %@ in template %@:%u \n%@\n%@",
			prefix, severity, nameOrPath, self->lineNumber, description, remedy];
	} // end if
} // end method

// ---------------------------------------------------------------------------
// Instance Method:  logErrorMessageForTemplate:
// ---------------------------------------------------------------------------
//
// Convenience method to invoke stringWithErrorMessageForTemplate: and log the
// result returned to the console.

- (void)logErrorMessageForTemplate:(NSString *)nameOrPath
{
    NSLog(@"Unable to parse template document %@: %@", nameOrPath, [self stringWithErrorMessageForTemplate:nameOrPath]);
} // end method

@end // STSTemplateEngineErrors
