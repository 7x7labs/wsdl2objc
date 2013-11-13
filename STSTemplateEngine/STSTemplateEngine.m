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

#import "LIFO.h"
#import "STSStringOps.h"

#import "STSTemplateEngine.h"

#define kLineFeed @"\n"

#define keyDefined(x,y) ([NSString valueForDictionary:x key:y] != nil)
#define keyNotDefined(x,y) ([NSString valueForDictionary:x key:y] == nil)

@interface NSString (STSTemplateEnginePrivateCategory2)
+ (NSString *)defaultStartTag;
+ (NSString *)defaultEndTag;
- (NSString *)stringByExpandingPlaceholdersWithStartTag:(NSString *)startTag
											  andEndTag:(NSString *)endTag
										usingDictionary:(NSDictionary *)dictionary
										 errorsReturned:(NSArray **)errorLog
											 lineNumber:(unsigned)lineNumber;
@end

@implementation NSString (STSTemplateEnginePrivateCategory2)

+ (NSString *)defaultStartTag
{
	return [[NSString alloc] initWithUTF8String:"%\xC2\xAB"];
}

+ (NSString *)defaultEndTag
{
	return [[NSString alloc] initWithUTF8String:"\xC2\xBB"];
}

- (NSString *)stringByExpandingPlaceholdersWithStartTag:(NSString *)startTag
											  andEndTag:(NSString *)endTag
										usingDictionary:(NSDictionary *)dictionary
										 errorsReturned:(NSArray **)errorLog
											 lineNumber:(unsigned)lineNumber
{
	if ([startTag length] == 0)
        @throw [NSException exceptionWithName:@"TEStartTagEmptyOrNil"
                                       reason:@"startTag is empty or nil" userInfo:nil];

	if ([endTag length] == 0)
		@throw [NSException exceptionWithName:@"TEEndTagEmptyOrNil"
                                       reason:@"endTag is empty or nil" userInfo:nil];

    *errorLog = nil;

	NSRange tag = [self rangeOfString:startTag];
    if (tag.location == NSNotFound)
        return self;

	NSMutableString *remainder = [self mutableCopy];
	NSMutableString *result = [NSMutableString stringWithCapacity:[self length]];
	NSMutableArray *_errorLog = [NSMutableArray arrayWithCapacity:5];

    while (tag.location != NSNotFound) {
        [result appendString:[remainder substringToIndex:tag.location]];
        [remainder deleteCharactersInRange:NSMakeRange(0, tag.location + tag.length)];

        tag = [remainder rangeOfString:endTag];
        if (tag.location != NSNotFound) {
            NSString *placeholder = [remainder substringToIndex:tag.location];
            NSString *value = [NSString valueForDictionary:dictionary key:placeholder];
            if (value == nil) {
                [result appendFormat:@"%@%@%@ *** ERROR: undefined key *** ", startTag, placeholder, endTag];
                TEError *error = [TEError error:TE_UNDEFINED_PLACEHOLDER_FOUND_ERROR
                                         inLine:lineNumber atToken:TE_PLACEHOLDER];
                [error setLiteral:placeholder];
                [_errorLog addObject:error];
                [error logErrorMessageForTemplate:@""];
            }
            else {
                [result appendString:value];
            }

            [remainder deleteCharactersInRange:NSMakeRange(0, tag.location + tag.length)];
        }

        else {
            [result appendFormat:@"%@ *** ERROR: end tag missing *** ", startTag];
            [remainder setString:@""];
            TEError *error = [TEError error:TE_EXPECTED_ENDTAG_BUT_FOUND_TOKEN_ERROR
                                     inLine:lineNumber atToken:TE_EOL];
            [_errorLog addObject:error];
            [error logErrorMessageForTemplate:@""];
        }

        tag = [remainder rangeOfString:startTag];
    }

    [result appendString:remainder];

	if ([_errorLog count] > 0) {
		*errorLog = _errorLog;
		NSLog(@"errors have ocurred while expanding placeholders in string");
	}

	return result;
}

@end

@interface TEFlags : NSObject {
@public bool consumed, expand, condex, forBranch;
}
+ (TEFlags *)flags;
@end

@implementation TEFlags
+ (TEFlags *)flags {
	TEFlags *thisInstance = [[TEFlags alloc] init];
	thisInstance->consumed = false;
	thisInstance->expand = true;
	thisInstance->condex = false;
	thisInstance->forBranch = false;
	return thisInstance;
}

@end

@implementation NSString (STSTemplateEngine)
+ (id)stringByExpandingTemplate:(NSString *)templateString
				usingDictionary:(NSDictionary *)dictionary
				 errorsReturned:(NSArray **)errorLog
{
	return [NSString stringByExpandingTemplate:templateString
								  withStartTag:[NSString defaultStartTag]
									 andEndTag:[NSString defaultEndTag]
							   usingDictionary:dictionary
								errorsReturned:errorLog];
}

+ (id)stringByExpandingTemplate:(NSString *)templateString
				   withStartTag:(NSString *)startTag
					  andEndTag:(NSString *)endTag
				usingDictionary:(NSDictionary *)dictionary
				 errorsReturned:(NSArray **)errorLog
{
	if ([startTag length] == 0)
        @throw [NSException exceptionWithName:@"TEStartTagEmptyOrNil"
                                       reason:@"startTag is empty or nil" userInfo:nil];

	if ([endTag length] == 0)
		@throw [NSException exceptionWithName:@"TEEndTagEmptyOrNil"
                                       reason:@"endTag is empty or nil" userInfo:nil];

	NSMutableString *result = [NSMutableString stringWithCapacity:[templateString length]];
	NSMutableCharacterSet *whitespaceSet = [NSMutableCharacterSet whitespaceCharacterSet];
	[whitespaceSet addCharactersInString:@"\""];
	NSMutableDictionary *_dictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];

	TEFlags *flags = [TEFlags flags];
	LIFO *stack = [LIFO stackWithCapacity:8];

	NSMutableArray *_errorLog = [NSMutableArray arrayWithCapacity:5];
	NSMutableArray *lineErrors = [NSMutableArray arrayWithCapacity:2];
	TEError *error;

	NSString *remainder_ = nil, *key = nil, *operand = nil, *varName = nil;
	NSMutableString *innerString = nil;
	unsigned lineNumber = 0, unexpandIf = 0, unexpandFor = 0;

	NSProcessInfo *processInfo = [NSProcessInfo processInfo];
	_dictionary[@"_timestamp"] = [[NSDate date] description];
	_dictionary[@"_uniqueID"] = [processInfo globallyUniqueString];
	_dictionary[@"_hostname"] = [processInfo hostName];

	NSLocale *locale = [NSLocale currentLocale];
	_dictionary[@"_userCountryCode"] = [locale objectForKey:NSLocaleCountryCode];
	_dictionary[@"_userLanguage"] = [locale objectForKey:NSLocaleLanguageCode];

	locale = [NSLocale systemLocale];
	_dictionary[@"_systemCountryCode"] = [locale objectForKey:NSLocaleCountryCode] ?: @"";
	_dictionary[@"_systemLanguage"] = [locale objectForKey:NSLocaleLanguageCode] ?: @"";

	unsigned complement = 0;

    for (NSString *line in [templateString arrayBySeparatingLinesUsingEOLmarkers]) {
        lineNumber++;
		if (([line length] > 0) && ([line hasPrefix:startTag] == NO) && ([line characterAtIndex:0] == '%')) {
			NSString *keyword = [line firstWordUsingDelimitersFromSet:whitespaceSet];
			complement = (([keyword hasPrefix:@"%IFN"]) || ([keyword hasPrefix:@"%ELSIFN"]));

			if (!flags->forBranch && (([keyword isEqualToString:@"%IF"]) || ([keyword isEqualToString:@"%IFNOT"]))) {
				if (flags->expand) {
					key = [line wordAtIndex:2 usingDelimitersFromSet:whitespaceSet];
					if ([key isEmpty]) {
						error = [TEError error:TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR
										inLine:lineNumber atToken:(TE_IF + complement)];
						[_errorLog addObject:error];
						[error logErrorMessageForTemplate:@""];
						if (flags->condex) {
							[stack pushObject:flags];
							flags = [TEFlags flags];
						}
						flags->expand = false;
						flags->consumed = true;
						flags->condex = true;
					}
					else {
						id value = [self valueForDictionary:_dictionary key:key];
						if (flags->condex) {
							[stack pushObject:flags];
							flags = [TEFlags flags];
						}

						flags->expand = ([value representsTrue]) ^ complement;
						flags->consumed = flags->expand;
						flags->condex = true;
					}
				} else {
					++unexpandIf;
					flags->condex = false;
				}
			}

			else if (!flags->forBranch && (([keyword isEqualToString:@"%ELSIF"]) || ([keyword isEqualToString:@"%ELSIFNOT"]))) {
				if (flags->condex) {
					if (flags->consumed) {
						flags->expand = false;
					}
					else {
						key = [line wordAtIndex:2 usingDelimitersFromSet:whitespaceSet];
						if ([key isEmpty]) {
							error = [TEError error:TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR
											inLine:lineNumber atToken:(TE_ELSIF + complement)];
							[_errorLog addObject:error];
							[error logErrorMessageForTemplate:@""];
							flags->expand = false;
						}
						else {
							id value = [self valueForDictionary:dictionary key:key];
							flags->expand = ([value representsTrue]) ^ complement;
						}
					}

					flags->consumed = (flags->consumed || flags->expand);
				}
				else if (unexpandIf == 0) {
					error = [TEError error:TE_UNEXPECTED_TOKEN_ERROR
									inLine:lineNumber atToken:(TE_ELSIF + complement)];
					[_errorLog addObject:error];
					[error logErrorMessageForTemplate:@""];
					flags->expand = false;
				}
			}

			else if (!flags->forBranch && (([keyword isEqualToString:@"%IFEQ"]) || ([keyword isEqualToString:@"%IFNEQ"]))) {
				if (flags->expand) {
					key = [line wordAtIndex:2 usingDelimitersFromSet:whitespaceSet];
					if ([key isEmpty]) {
						error = [TEError error:TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR
										inLine:lineNumber atToken:(TE_IFEQ + complement)];
						[_errorLog addObject:error];
						[error logErrorMessageForTemplate:@""];
						if (flags->condex) {
							[stack pushObject:flags];
							flags = [TEFlags flags];
						}

						flags->expand = false;
						flags->consumed = true;
						flags->condex = true;
					}
					else {
						id value = [NSString valueForDictionary:_dictionary key:key];
						remainder_ = [[line restOfWordsUsingDelimitersFromSet:whitespaceSet]
                                      restOfWordsUsingDelimitersFromSet:whitespaceSet];
                        operand = [remainder_ copy];
                        if (flags->condex) {
                            [stack pushObject:flags];
                            flags = [TEFlags flags];
                        }
                        flags->expand = ([value isEqual:operand] == YES) ^ complement;
                        flags->consumed = flags->expand;
                        flags->condex = true;
					}
				} else {
					++unexpandIf;
					flags->condex = false;
				}
			}

			if (!flags->forBranch && (([keyword isEqualToString:@"%ELSIFEQ"]) || ([keyword isEqualToString:@"%ELSIFNEQ"]))) {
				if (flags->condex) {
					if (flags->consumed) {
						flags->expand = false;
					}
					else {
						key = [line wordAtIndex:2 usingDelimitersFromSet:whitespaceSet];
						if ([key isEmpty]) {
							error = [TEError error:TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR
											inLine:lineNumber atToken:(TE_ELSIFEQ + complement)];
							[_errorLog addObject:error];
							[error logErrorMessageForTemplate:@""];
							flags->expand = false;
						}
						else {
							id value = [NSString valueForDictionary:_dictionary key:key];
							remainder_ = [[line restOfWordsUsingDelimitersFromSet:whitespaceSet]
                                          restOfWordsUsingDelimitersFromSet:whitespaceSet];
                            operand = [remainder_ copy];
                            flags->expand = ([value isEqualToString:operand] == YES) ^ complement;
                            flags->consumed = flags->expand;
						}
					}
				}
				else if (unexpandIf == 0) {
					error = [TEError error:TE_UNEXPECTED_TOKEN_ERROR
									inLine:lineNumber atToken:(TE_ELSIFEQ + complement)];
					[_errorLog addObject:error];
					[error logErrorMessageForTemplate:@""];
					flags->expand = false;
				}
			}

			else if (!flags->forBranch && (([keyword isEqualToString:@"%IFDEF"]) || ([keyword isEqualToString:@"%IFNDEF"]))) {
				if (flags->expand) {
					key = [line wordAtIndex:2 usingDelimitersFromSet:whitespaceSet];
					if ([key isEmpty]) {
						error = [TEError error:TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR
										inLine:lineNumber atToken:(TE_IFDEF + complement)];
						[_errorLog addObject:error];
						[error logErrorMessageForTemplate:@""];
						if (flags->condex) {
							[stack pushObject:flags];
							flags = [TEFlags flags];
						}
						flags->expand = false;
						flags->consumed = true;
						flags->condex = true;
					}
					else {
						if (flags->condex) {
							[stack pushObject:flags];
							flags = [TEFlags flags];
						}
						flags->expand = (keyDefined(_dictionary, key)) ^ complement;
						flags->consumed = flags->expand;
						flags->condex = true;
					}
				} else {
					++unexpandIf;
					flags->condex = false;
				}
			}

			else if (!flags->forBranch && (([keyword isEqualToString:@"%ELSIFDEF"]) || ([keyword isEqualToString:@"%ELSIFNDEF"]))) {
				if (flags->condex) {
					if (flags->consumed) {
						flags->expand = false;
					}
					else {
						key = [line wordAtIndex:2 usingDelimitersFromSet:whitespaceSet];
						if ([key isEmpty]) {
							error = [TEError error:TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR
											inLine:lineNumber atToken:(TE_ELSIFDEF + complement)];
							[_errorLog addObject:error];
							[error logErrorMessageForTemplate:@""];
							flags->expand = false;
						}
						else {
							flags->expand = (keyDefined(_dictionary, key)) ^ complement;
						}
					}
                    flags->consumed = (flags->consumed || flags->expand);
				}
				else if (unexpandIf == 0) {
					error = [TEError error:TE_UNEXPECTED_TOKEN_ERROR
									inLine:lineNumber atToken:(TE_ELSIFDEF + complement)];
					[_errorLog addObject:error];
					[error logErrorMessageForTemplate:@""];
					flags->expand = false;
				}
			}

			else if (!flags->forBranch && [keyword isEqualToString:@"%ELSE"]) {
				if (flags->condex) {
					flags->expand = !(flags->consumed);
					flags->consumed = true;
				}
				else if (unexpandIf == 0) {
					error = [TEError error:TE_UNEXPECTED_TOKEN_ERROR
									inLine:lineNumber atToken:TE_ELSE];
					[_errorLog addObject:error];
					[error logErrorMessageForTemplate:@""];
					flags->expand = false;
				}
			}

			else if (!flags->forBranch && [keyword isEqualToString:@"%ENDIF"]) {
				if (flags->condex) {
					if ([stack count] > 0) {
						flags = [stack popObject];
					}
					else {
						flags->expand = true;
						flags->consumed = false;
						flags->condex = false;
						flags->forBranch = false;
					}
				}
				else if (unexpandIf > 0) {
					--unexpandIf;
					if (unexpandIf == 0) flags->condex = true;
				} else {
					error = [TEError error:TE_UNEXPECTED_TOKEN_ERROR
									inLine:lineNumber atToken:TE_ENDIF];
					[_errorLog addObject:error];
					[error logErrorMessageForTemplate:@""];
				}
			}

			else if (!flags->forBranch && [keyword isEqualToString:@"%DEFINE"]) {
				if (flags->expand) {
					key = [line wordAtIndex:2 usingDelimitersFromSet:whitespaceSet];
					if ([key isEmpty]) {
						error = [TEError error:TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR
										inLine:lineNumber atToken:TE_DEFINE];
						[_errorLog addObject:error];
						[error logErrorMessageForTemplate:@""];
					}
					else {
						id value = [[line restOfWordsUsingDelimitersFromSet:whitespaceSet]
									restOfWordsUsingDelimitersFromSet:whitespaceSet];
						_dictionary[key] = [value copy];
					}
				}
			}

			else if (!flags->forBranch && [keyword isEqualToString:@"%UNDEF"]) {
				if (flags->expand) {
					key = [line wordAtIndex:2 usingDelimitersFromSet:whitespaceSet];
					if ([key isEmpty]) {
						error = [TEError error:TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR
										inLine:lineNumber atToken:TE_UNDEF];
						[_errorLog addObject:error];
						[error logErrorMessageForTemplate:@""];
					}
					else {
						[_dictionary removeObjectForKey:key];
					}
				}
			}

			else if (!flags->forBranch && [keyword isEqualToString:@"%LOG"]) {
				if (flags->expand) {

					key = [line wordAtIndex:2 usingDelimitersFromSet:whitespaceSet];
					if ([key isEmpty]) {
						error = [TEError error:TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR
										inLine:lineNumber atToken:TE_LOG];
						[_errorLog addObject:error];
						[error logErrorMessageForTemplate:@""];
					}
					else {
						id value = [NSString valueForDictionary:_dictionary key:key];
						NSLog(@"value for key '%@' is '%@'", key, value);
					}
				}
			}

			else if ([keyword isEqualToString:@"%FOREACH"]) {
				if (!flags->forBranch && flags->expand) {
					varName = [line wordAtIndex:2 usingDelimitersFromSet:whitespaceSet];
					key = [line wordAtIndex:4 usingDelimitersFromSet:whitespaceSet];

					if (flags->expand) {
						if ([key isEmpty] || [varName isEmpty]) {
							error = [TEError error:TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR
											inLine:lineNumber atToken:(complement)];
							[_errorLog addObject:error];
							[error logErrorMessageForTemplate:@""];
							if (flags->condex) {
								[stack pushObject:flags];
								flags = [TEFlags flags];
							}
							flags->expand = false;
							flags->consumed = true;
							flags->condex = true;
						}
						else {
							id value = [NSString valueForDictionary:_dictionary key:key];
							if (value == nil || ![value conformsToProtocol:@protocol(NSFastEnumeration)])
							{
								error = [TEError error:TE_UNDEFINED_PLACEHOLDER_FOUND_ERROR
												inLine:lineNumber atToken:TE_FOREACH];
								[error setLiteral:key];
								[_errorLog addObject:error];
								[error logErrorMessageForTemplate:@""];
							}

							if (flags->condex) {
								[stack pushObject:flags];
								flags = [TEFlags flags];
							}
							flags->expand = false;
							flags->consumed = true;
							flags->forBranch = true;
							flags->condex = true;

						}
					}
					else {
						[stack pushObject:flags];

						flags = [TEFlags flags];
						flags->expand = false;
						flags->consumed = true;
						flags->forBranch = true;
						flags->condex = false;
					}
				} else {
					unexpandFor++;
				}
			}

			else if ([keyword isEqualToString:@"%ENDFOR"]) {
				if (unexpandFor > 0) {
					--unexpandFor;
				} else {
					if (flags->forBranch && flags->condex) {
						if ([stack count] > 0) {
							flags = [stack popObject];
						}
						else {
							flags->expand = true;
							flags->consumed = false;
							flags->condex = false;
							flags->forBranch = false;
						}

						NSArray *array = [NSString valueForDictionary:_dictionary key:key];
						for (id varValue in array) {
							_dictionary[varName] = varValue;
							[result appendString:[NSString stringByExpandingTemplate:innerString
																		withStartTag:startTag
																		   andEndTag:endTag
																	 usingDictionary:_dictionary
																	  errorsReturned:errorLog]];
						}
						[_dictionary removeObjectForKey:varName];

						innerString = nil;
					}
					else {
						if ([stack count] > 0) {
							flags = [stack popObject];
						} else {
							error = [TEError error:TE_UNEXPECTED_TOKEN_ERROR
											inLine:lineNumber atToken:TE_ENDIF];
							[_errorLog addObject:error];
							[error logErrorMessageForTemplate:@""];
						}
					}
				}
			}
		}
		else if (flags->expand) {
			[result appendString:[line stringByExpandingPlaceholdersWithStartTag:startTag
																	   andEndTag:endTag
																 usingDictionary:_dictionary
																  errorsReturned:&lineErrors
																	  lineNumber:lineNumber]];
			[result appendString:kLineFeed];

			if ([lineErrors count] > 0) {
				[_errorLog addObjectsFromArray:lineErrors];
			}
		}
		if (flags->forBranch) {
			if (innerString == nil) {
				innerString = [[NSMutableString alloc] init];
			} else {
				[innerString appendString:line];
				[innerString appendString:kLineFeed];
			}
		}
	}
	if (flags->condex) {
		error = [TEError error:TE_EXPECTED_ENDIF_BUT_FOUND_TOKEN_ERROR
						inLine:lineNumber atToken:TE_EOF];
		[_errorLog addObject:error];
		[error logErrorMessageForTemplate:@""];
	}
	if ([_errorLog count] > 0) {
		*errorLog = _errorLog;
		NSLog(@"errors have occurred while expanding placeholders in string using dictionary:\n%@", dictionary);
		NSLog(@"using template:\n%@", templateString);
	}
	else {
		if (errorLog != nil) *errorLog = nil;
	}
	return [NSString stringWithString:result];
}

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
}

+ (id)stringByExpandingTemplateAtPath:(NSString *)path
						 withStartTag:(NSString *)startTag
							andEndTag:(NSString *)endTag
					  usingDictionary:(NSDictionary *)dictionary
							 encoding:(NSStringEncoding)enc
					   errorsReturned:(NSArray **)errorLog
{
    NSError *fileError;
    NSString *templateString = [NSString stringWithContentsOfFile:path encoding:enc error:&fileError];

    if (templateString) {
        return [NSString stringByExpandingTemplate:templateString
                                      withStartTag:startTag
                                         andEndTag:endTag
                                   usingDictionary:dictionary
                                    errorsReturned:errorLog];
    }

    TEError *error;
    NSString *desc = [fileError localizedDescription];
    NSString *reason = [fileError localizedFailureReason];
    if ([[fileError domain] isEqualToString:NSCocoaErrorDomain]) {
        switch ([fileError code]) {
            case NSFileNoSuchFileError :
            case NSFileReadNoSuchFileError :
            case NSFileReadInvalidFileNameError :
                error = [TEError error:TE_FILE_NOT_FOUND_ERROR inLine:0 atToken:TE_PATH];
                break;
            case NSFileReadNoPermissionError :
                error = [TEError error:TE_UNABLE_TO_READ_FILE_ERROR inLine:0 atToken:TE_PATH];
                break;
            case NSFileReadCorruptFileError :
                error = [TEError error:TE_INVALID_FILE_FORMAT_ERROR inLine:0 atToken:TE_PATH];
                break;
            case NSFileReadInapplicableStringEncodingError :
                error = [TEError error:TE_TEMPLATE_ENCODING_ERROR inLine:0 atToken:TE_PATH];
                break;
            default :
                error = [TEError error:TE_GENERIC_ERROR inLine:0 atToken:TE_PATH];
                [error setLiteral:[NSString stringWithFormat:
                                   @"while trying to access file at path %@\n%@\n%@", path, desc, reason]];
                break;
        }
    }
    else {
        error = [TEError error:TE_GENERIC_ERROR inLine:0 atToken:TE_PATH];
        [error setLiteral:[NSString stringWithFormat:
                           @"while trying to access file at path %@\n%@\n%@", path, desc, reason]];
    }
    if ([[error literal] length] == 0) {
        [error setLiteral:path];
    }
    [error logErrorMessageForTemplate:path];
    *errorLog = @[error];
    return nil;
}

+ (id)valueForDictionary:(id)dictionary key:(NSString *)key
{
	id currentPlace = dictionary;
	NSArray *path = [key componentsSeparatedByString:@"."];
	for (id component in path) {
		if ([currentPlace respondsToSelector:@selector(valueForKey:)])
			currentPlace = [currentPlace valueForKey:component];
	}
	return currentPlace;
}

@end
