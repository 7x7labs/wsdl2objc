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

const NSRange kZeroRange = { 0, 0 };

#import "STSTemplateEngineErrors.h"

@implementation TEError

- (id)init {
	self = [super init];
	return self;
}

+ (TEError *)error:(enum TEErrorCode)code
			inLine:(unsigned)line
		   atToken:(enum TEToken)token
{
	TEError *thisInstance = [[TEError alloc] init];
	NSException *exception;

	thisInstance->errorCode = code;
	thisInstance->lineNumber = line;
	thisInstance->token = token;
	thisInstance->range = kZeroRange;
	thisInstance->literal = nil;

	switch (code) {
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
			switch (token) {
				case TE_LOG :
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_ECHO :
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_DEBUG :
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_INCLUDE :
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_IF :
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_IFNOT :
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_ELSIF :
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_ELSIFNOT :
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_IFEQ :
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_IFNEQ :
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_ELSIFEQ :
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_ELSIFNEQ :
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_IFDEF :
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_IFNDEF :
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_ELSIFDEF :
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_ELSIFNDEF :
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_ANY :
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_EVERY :
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_DEFINE :
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_UNDEF :
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_KEY :
					thisInstance->remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
					break;
				case TE_START_TAG :
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_PLACEHOLDER :
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_TARGET :
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_APPEND :
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				case TE_INSERT :
					thisInstance->remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
					break;
				default:
					exception = [NSException exceptionWithName:@"UndefinedEnumValue"
														reason:@"undefined enum value encountered" userInfo:nil];
					[exception raise];
					break;
			}
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
			exception = [NSException exceptionWithName:@"UndefinedEnumValue"
												reason:@"undefined enum value encountered" userInfo:nil];
			[exception raise];
			break;
	}

	return thisInstance;
}

- (void)setRange:(NSRange)aRange
{
	self->range = aRange;
	return;
}

- (void)setLiteral:(NSString *)literalString
{
	self->literal = [literalString copy];
}

- (enum TEErrorCode)errorCode
{
	return self->errorCode;
}

- (enum TESeverity)severityCode
{
	return self->severityCode;
}

- (unsigned)lineNumber
{
	return self->lineNumber;
}

- (enum TEToken)token
{
	return self->token;
}

- (NSRange)range
{
	return self->range;
}

- (enum TERemedy)remedyCode
{
	return self->remedyCode;
}

- (NSString *)literal
{
	return self->literal;
}

- (NSString *)stringWithToken
{
	NSString *tokenString = nil;
	NSException *exception;

	switch (self->token) {
		case TE_TOKEN_NOT_AVAILABLE :
			tokenString = @"";
			break;
		case TE_LOG :
			tokenString = @"%LOG";
			break;
		case TE_ECHO :
			tokenString = @"%ECHO";
			break;
		case TE_DEBUG :
			tokenString = @"%DEBUG";
			break;
		case TE_FOREACH :
			tokenString = @"%FOREACH";
			break;
		case TE_INCLUDE :
			tokenString = @"%INCLUDE";
			break;
		case TE_IF :
			tokenString = @"%IF";
			break;
		case TE_IFNOT :
			tokenString = @"%IFNOT";
			break;
		case TE_IFEQ :
			tokenString = @"%IFEQ";
			break;
		case TE_IFNEQ :
			tokenString = @"%IFNEQ";
			break;
		case TE_ELSIFEQ :
			tokenString = @"%ELSIFEQ";
			break;
		case TE_ELSIFNEQ :
			tokenString = @"%ELSIFNEQ";
			break;
		case TE_IFDEF :
			tokenString = @"%IFDEF";
			break;
		case TE_IFNDEF :
			tokenString = @"%IFNDEF";
			break;
		case TE_ELSIFDEF :
			tokenString = @"%ELSIFDEF";
			break;
		case TE_ELSIFNDEF :
			tokenString = @"%ELSIFNDEF";
			break;
		case TE_ANY :
			tokenString = @"%ANY";
			break;
		case TE_EVERY :
			tokenString = @"%EVERY";
			break;
		case TE_ELSE :
			tokenString = @"%ELSE";
			break;
		case TE_ENDIF :
			tokenString = @"%ENDIF";
			break;
		case TE_DEFINE :
			tokenString = @"%DEFINE";
			break;
		case TE_UNDEF :
			tokenString = @"%UNDEF";
			break;
		case TE_KEY :
			tokenString = @"%KEY";
			break;
		case TE_START_TAG :
			tokenString = @"start tag";
			break;
		case TE_END_TAG :
			tokenString = @"end tag";
			break;
		case TE_PLACEHOLDER :
			tokenString = [NSString stringWithFormat:@"placeholder"];
			break;
		case TE_PATH :
			tokenString = @"path name";
			break;
		case TE_TARGET :
			tokenString = @"%TARGET";
			break;
		case TE_APPEND :
			tokenString = @"%APPEND";
			break;
		case TE_INSERT :
			tokenString = @"%INSERT";
			break;
		case TE_EOL :
			tokenString = @"EOL marker";
			break;
		case TE_EOF :
			tokenString = @"EOF marker";
			break;
		default:
			exception = [NSException exceptionWithName:@"UndefinedEnumValue"
												reason:@"undefined enum value encountered" userInfo:nil];
			[exception raise];
			break;
	}

	return [NSString stringWithString:tokenString];
}

- (NSString *)stringWithDescription
{
	NSString *tokenString, *description = nil;
	NSException *exception;

	switch (self->errorCode) {
		case TE_GENERIC_ERROR :
			if (self->literal == nil) {
				description = @"Generic error: (no error description available).";
			}
			else {
				description = [NSString stringWithFormat:@"'%@'", self->literal];
			}
			break;
		case TE_INVALID_PATH_ERROR :
			description = @"Template file path is invalid.";
			break;
		case TE_FILE_NOT_FOUND_ERROR :
			if (self->literal == nil) {
				description = @"Template file not found.";
			}
			else {
				description = [NSString stringWithFormat:@"Template file at path '%@' not found.", self->literal];
			}
			break;
		case TE_UNABLE_TO_READ_FILE_ERROR :
			if (self->literal == nil) {
				description = @"Unable to read template file.";
			}
			else {
				description = [NSString stringWithFormat:@"Unable to read template file at path '%@'.",
                               self->literal];
			}
			break;
		case TE_INVALID_FILE_FORMAT_ERROR :
			description = @"Unable to recognize template file format.";
			break;
		case TE_TEMPLATE_ENCODING_ERROR :
			description = @"Unable to decode string encoding.";
			break;
		case TE_TEMPLATE_EMPTY_ERROR :
			description = @"Template is empty.";
			break;
		case TE_DICTIONARY_EMPTY_ERROR :
			description = @"Dictionary is empty.";
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
				tokenString = @"(unspecified)";
			}
			else {
				tokenString = [NSString stringWithFormat:@"'%@'", self->literal];
			}
			description = [NSString stringWithFormat:@"Placeholder %@ is undefined.", tokenString];
			break;
		case TE_EXPECTED_ENDTAG_BUT_FOUND_TOKEN_ERROR :
			tokenString = [self stringWithToken];
			description = [NSString stringWithFormat:@"Expected closing end tag but found %@.", tokenString];
			break;
		default:
			exception = [NSException exceptionWithName:@"UndefinedEnumValue"
												reason:@"undefined enum value encountered" userInfo:nil];
			[exception raise];
			break;
	}

	return [NSString stringWithString:description];
}

- (NSString *)stringWithRemedy
{
	NSString *tokenString, *remedy = nil;
	NSException *exception;

	switch (self->remedyCode) {
		case TE_REMEDY_NOT_AVAILABLE:
			remedy = @"";
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
			remedy = @"Continuing with empty dictionary.";
			break;
		case TE_SKIPPING_PLACEHOLDER_TO_CONTINUE :
			if (self->literal == nil) {
				tokenString = @"(unspecified)";
			}
			else {
				tokenString = [NSString stringWithFormat:@"'%@'", self->literal];
			}
			remedy = [NSString stringWithFormat:@"Skipping placeholder %@ to continue.", tokenString];
			break;
		case TE_CLOSING_IF_BLOCK_TO_CONTINUE :
			remedy = @"Implicitly closing previous %IF block to continue.";
			break;
		case TE_IMPLYING_ENDTAG_TO_CONTINUE :
			remedy = @"Implying end tag to continue.";
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
			remedy = @"Template expansion aborted.";
			break;
		default:
			exception = [NSException exceptionWithName:@"UndefinedEnumValue"
												reason:@"undefined enum value encountered" userInfo:nil];
			[exception raise];
			break;
	}

	return [NSString stringWithString:remedy];
}

- (NSString *)stringWithErrorMessageForTemplate:(NSString *)nameOrPath
{
	NSString *prefix, *severity = nil, *description, *remedy;
	NSException *exception;

	prefix = @"STS TemplateEngine";

	switch (self->severityCode) {
		case TE_WARNING :
			severity = @"*WARNING*";
			break;
		case TE_ERROR :
			severity = @"*ERROR*";
			break;
		case TE_FATAL :
			severity = @"*FATAL ERROR*";
			break;
		default:
			exception = [NSException exceptionWithName:@"UndefinedEnumValue"
												reason:@"undefined enum value encountered" userInfo:nil];
			[exception raise];
			break;
	}

	description = [self stringWithDescription];

	remedy = [self stringWithRemedy];

	if ([nameOrPath length] == 0) {
		if (self->lineNumber == 0) {
			return [NSString stringWithFormat:@"%@ encountered %@\n%@\n%@",
				prefix, severity, description, remedy];
		}
		else {
			return [NSString stringWithFormat:@"%@ encountered %@ in line %u \n%@\n%@",
				prefix, severity, self->lineNumber, description, remedy];
		}
	}
	else {
		return [NSString stringWithFormat:@"%@ encountered %@ in template %@:%u \n%@\n%@",
			prefix, severity, nameOrPath, self->lineNumber, description, remedy];
	}
}

- (void)logErrorMessageForTemplate:(NSString *)nameOrPath
{
    NSLog(@"Unable to parse template document %@: %@", nameOrPath, [self stringWithErrorMessageForTemplate:nameOrPath]);
}

@end
