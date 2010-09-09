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

#import <Foundation/Foundation.h>

// ---------------------------------------------------------------------------
// Enum typedef:  TEErrorCode
// ---------------------------------------------------------------------------
//
// Defines error codes representing various error types handled by the
// template engine during template expansion.

enum TEErrorCode {
	TE_GENERIC_ERROR,							// unknown, treat as fatal
	TE_INVALID_PATH_ERROR,						// fatal
	TE_FILE_NOT_FOUND_ERROR,					// fatal
	TE_UNABLE_TO_READ_FILE_ERROR,				// fatal
	TE_INVALID_FILE_FORMAT_ERROR,				// fatal
	TE_TEMPLATE_ENCODING_ERROR,					// fatal
	TE_TEMPLATE_EMPTY_ERROR,					// fatal
	TE_DICTIONARY_EMPTY_ERROR,					// warning
	TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR,	// error
	TE_EXPECTED_ENDIF_BUT_FOUND_TOKEN_ERROR,	// error, warning
	TE_UNEXPECTED_TOKEN_ERROR,					// error
	TE_UNIMPLEMENTED_TOKEN_ERROR,				// warning
	TE_UNDEFINED_PLACEHOLDER_FOUND_ERROR,		// error
	TE_EXPECTED_ENDTAG_BUT_FOUND_TOKEN_ERROR	// error
};

// ---------------------------------------------------------------------------
// Enum typedef:  TESeverity
// ---------------------------------------------------------------------------
//
// Defines severity codes representing the error severities used to classify
// errors depending on recoverability.

enum TESeverity {
	TE_WARNING,	// error is recoverable without consequences
	TE_ERROR,	// error is recoverable within reason
	TE_FATAL	// error is not recoverable
};

// ---------------------------------------------------------------------------
// Enum typedef:  TEToken
// ---------------------------------------------------------------------------
//
// Defines tokens representing parsed symbols in the template source.

enum TEToken {
	TE_TOKEN_NOT_AVAILABLE,
	TE_LOG,			// %LOG keyword
	TE_ECHO,		// %ECHO keyword - reserved for future use
	TE_DEBUG,		// %DEBUG keyword - reserved for future use
	TE_FOREACH,		// %FOREACH keyword
	TE_INCLUDE,		// %INCLUDE keyword - reserved for future use
	TE_IF,			// %IF keyword
	TE_IFNOT,		// %IFNOT keyword - must be successor to %IF
	TE_ELSIF,		// %ELSIF keyword
	TE_ELSIFNOT,	// %ELSIFNOT keyword - must be successort to ELSIF
	TE_IFEQ,		// %IFEQ keyword
	TE_IFNEQ,		// %IFNEQ keyword - must be successor to %IFEQ
	TE_ELSIFEQ,		// %ELSIFEQ keyword
	TE_ELSIFNEQ,	// %ELSIFNEQ keyword - must be successor to %ELSIFEQ
	TE_IFDEF,		// %IFDEF keyword
	TE_IFNDEF,		// %IFNDEF keyword - must be successor to %IFDEF
	TE_ELSIFDEF,	// %ELSEIF keyword
	TE_ELSIFNDEF,	// %ELSIFNDEF keyword - must be successor to %ELSIFDEF
	TE_ANY,			// %ANY keyword - reserved for future use
	TE_EVERY,		// %EVERY keyword - reserved for future use
	TE_ELSE,		// %ELSE keyword
	TE_ENDIF,		// %ENDIF keyword
	TE_DEFINE,		// %DEFINE keyword
	TE_UNDEF,		// %UNDEF keyword
	TE_KEY,			// key following an %IF, %DEFINE or %UNDEF
	TE_START_TAG,	// placeholder start tag
	TE_END_TAG,		// placeholder end tag
	TE_PLACEHOLDER, // placeholder
	TE_PATH,		// pathname
	TE_TARGET,		// %TARGET keyword - reserved for future use
	TE_APPEND,		// %APPEND keyword - reserved for future use
	TE_INSERT,		// %INSERT keyword - reserved for future use
	TE_EOL,			// the EOL marker
	TE_EOF			// the EOF marker
};

// ---------------------------------------------------------------------------
// Enum typedef:  TERemedy
// ---------------------------------------------------------------------------
//
// Defines remedy codes representing various error recovery actions taken by
// the template engine depending on the type of error encountered.

enum TERemedy {
	TE_REMEDY_NOT_AVAILABLE,
	TE_ASSUMING_TRUE_TO_CONTINUE,
	TE_ASSUMING_FALSE_TO_CONTINUE,
	TE_IGNORING_DIRECTIVE_TO_CONTINUE,
	TE_CONTINUING_WITH_EMPTY_DICTIONARY,
	TE_SKIPPING_PLACEHOLDER_TO_CONTINUE,
	TE_CLOSING_IF_BLOCK_TO_CONTINUE,
	TE_IMPLYING_ENDTAG_TO_CONTINUE,
	TE_IGNORING_UNEXPECTED_TOKEN,
	TE_IGNORING_UNIMPLEMENTED_TOKEN,
	TE_ABORTING_TEMPLATE_EXPANSION
};


// ---------------------------------------------------------------------------
// Class definition:  TEError
// ---------------------------------------------------------------------------

@interface TEError : NSObject {
	// instance variable declaration
	@private
		enum TEErrorCode errorCode;		// error code
		enum TESeverity severityCode;	// severity of the error
		unsigned lineNumber;		// line number in which the error ocurred
		NSRange range;				// range in the line pinpointing the error
		enum TEToken token;			// offending token which caused the error
		enum TERemedy remedyCode;	// remedy taken for error recovery
		NSString *literal;			// optional info used for placeholder name
} // end var

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
		   atToken:(enum TEToken)token;

// ---------------------------------------------------------------------------
// Instance Method:  setLiteral:
// ---------------------------------------------------------------------------
//
// Sets the *optional* clear text info of the receiver. This info is used to
// store the literal name of a placeholder when the token is TEplaceholder.
// Otherwise it is set to nil.

- (void)setLiteral:(NSString *)literal;

// ---------------------------------------------------------------------------
// Instance Method:  errorCode
// ---------------------------------------------------------------------------
//
// Returns the error code of the receiver. The error code identifies the type
// of error described by the receiver as defined by TEErrorCode.

- (enum TEErrorCode)errorCode;

// ---------------------------------------------------------------------------
// Instance Method:  severityCode
// ---------------------------------------------------------------------------
//
// Returns the severity code of the receiver. The severity code specifies the
// severity of the error described by the receiver as defined by TESeverity.

- (enum TESeverity)severityCode;

// ---------------------------------------------------------------------------
// Instance Method:  lineNumber
// ---------------------------------------------------------------------------
//
// Returns the line number in which the error described by the receiver
// ocurred. The line number may be 0 in the event of file access errors.

- (unsigned)lineNumber;

// ---------------------------------------------------------------------------
// Instance Method:  token
// ---------------------------------------------------------------------------
//
// Returns the offending token of the error described by the receiver. Tokens
// represent parsed symbols in the template source and are defined by TEToken.

- (enum TEToken)token;

// ---------------------------------------------------------------------------
// Instance Method:  range
// ---------------------------------------------------------------------------
//
// Returns an NSRange for the offending token of the error described by the
// receiver. The range pinpoints the offending token as it was encountered in
// the template source. This may be used to generate an attributed string
// representation of the template source to highlight where errors ocurred.

- (NSRange)range;

// ---------------------------------------------------------------------------
// Instance Method:  remedyCode
// ---------------------------------------------------------------------------
//
// Returns the remedy code of the remedy taken for the error described by the
// receiver. Remedy codes are defined by TERemedy.

- (enum TERemedy)remedyCode;

// ---------------------------------------------------------------------------
// Instance Method:  literal
// ---------------------------------------------------------------------------
//
// Returns an NSString with the optional clear text info of the receiver. This
// info is used to store the literal name of a placeholder when the token is
// TEplaceholder. Returns nil if the literal is nil (default).

- (NSString *)literal;

// ---------------------------------------------------------------------------
// Instance Method:  stringWithToken
// ---------------------------------------------------------------------------
//
// Returns an NSString with a human readable token string for the token of the
// error described by the receiver. Tokens are defined by TEToken.

- (NSString *)stringWithToken;

// ---------------------------------------------------------------------------
// Instance Method:  stringWithDescription
// ---------------------------------------------------------------------------
//
// Returns an NSString with a human readable description of the error
// described by the receiver.

- (NSString *)stringWithDescription;

// ---------------------------------------------------------------------------
// Instance Method:  stringWithRemedy
// ---------------------------------------------------------------------------
//
// Returns an NSString with a human readable description of the remedy taken
// for the error described by the receiver.

- (NSString *)stringWithRemedy;

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

- (NSString *)stringWithErrorMessageForTemplate:(NSString *)nameOrPath;

// ---------------------------------------------------------------------------
// Instance Method:  logErrorMessageForTemplate:
// ---------------------------------------------------------------------------
//
// Convenience method to invoke stringWithErrorMessageForTemplate: and log the
// result returned to the console.

- (void)logErrorMessageForTemplate:(NSString *)nameOrPath;

@end // STSTemplateEngineErrors
