//
//	STSTemplateEngine.h
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

#import <Foundation/Foundation.h>
#import "STSTemplateEngineErrors.h"

// ---------------------------------------------------------------------------
//  T e m p l a t e   E n g i n e   C a t e g o r y   o f   N S S t r i n g
// ---------------------------------------------------------------------------

@interface NSString (STSTemplateEngine)

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
				 errorsReturned:(NSArray **)errorLog;

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
//  error message appended to it and the remainder of the line is not
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
				 errorsReturned:(NSArray **)errorLog;

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
					   errorsReturned:(NSArray **)errorLog;

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
					   errorsReturned:(NSArray **)errorLog;

+ (id)valueForDictionary:(id)dictionary key:(NSString *)key;

@end // STSTemplateEngine
