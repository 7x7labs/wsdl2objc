//    Copyright 2005 Sunrise Telephone Systems Ltd. All rights reserved.
//
//    Redistribution and use in source and binary forms, with or without modi-
//    fication, are permitted provided that the following conditions are met:
//
//    Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.  Redistributions in
//    binary form must reproduce the above copyright notice, this list of
//    conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.  Neither the name of Sunrise
//    Telephone Systems Ltd. nor the names of its contributors may be used to
//    endorse or promote products derived from this software without specific
//    prior written permission.
//
//    THIS  SOFTWARE  IS  PROVIDED  BY  THE  COPYRIGHT HOLDERS  AND CONTRIBUTORS
//    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,  INCLUDING, BUT NOT LIMITED
//    TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//    PURPOSE  ARE  DISCLAIMED.  IN  NO  EVENT  SHALL  THE  COPYRIGHT  OWNER  OR
//    CONTRIBUTORS  BE  LIABLE  FOR  ANY  DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//    EXEMPLARY,  OR  CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT LIMITED  TO,
//    PROCUREMENT  OF SUBSTITUTE  GOODS  OR  SERVICES;  LOSS  OF  USE,  DATA, OR
//    PROFITS;  OR  BUSINESS  INTERRUPTION)  HOWEVER CAUSED AND ON ANY THEORY OF
//    LIABILITY,  WHETHER  IN  CONTRACT,  STRICT LIABILITY,  OR TORT  (INCLUDING
//    NEGLIGENCE OR OTHERWISE)  ARISING  IN  ANY  WAY  OUT  OF  THE  USE OF THIS
//    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "STSTemplateEngineErrors.h"

@implementation TEError
+ (TEError *)error:(enum TEErrorCode)code
            inLine:(unsigned)line
           atToken:(enum TEToken)token
{
    TEError *thisInstance = [[TEError alloc] init];
    thisInstance.errorCode = code;
    thisInstance.lineNumber = line;
    thisInstance.token = token;
    thisInstance.range = NSMakeRange(0, 0);
    thisInstance.literal = nil;

    switch (code) {
        case TE_GENERIC_ERROR :
        case TE_INVALID_PATH_ERROR :
        case TE_FILE_NOT_FOUND_ERROR :
        case TE_UNABLE_TO_READ_FILE_ERROR :
        case TE_INVALID_FILE_FORMAT_ERROR :
        case TE_TEMPLATE_ENCODING_ERROR :
        case TE_TEMPLATE_EMPTY_ERROR :
            thisInstance.remedyCode = TE_ABORTING_TEMPLATE_EXPANSION;
            thisInstance.severityCode = TE_FATAL;
            break;

        case TE_DICTIONARY_EMPTY_ERROR :
            thisInstance.remedyCode = TE_CONTINUING_WITH_EMPTY_DICTIONARY;
            thisInstance.severityCode = TE_WARNING;
            break;
        case TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR :
            switch (token) {
                case TE_LOG :
                case TE_ECHO :
                case TE_DEBUG :
                case TE_INCLUDE :
                case TE_ANY :
                case TE_EVERY :
                case TE_DEFINE :
                case TE_UNDEF :
                case TE_START_TAG :
                case TE_PLACEHOLDER :
                case TE_TARGET :
                case TE_APPEND :
                case TE_INSERT :
                    thisInstance.remedyCode = TE_IGNORING_DIRECTIVE_TO_CONTINUE;
                    break;

                case TE_IF :
                case TE_IFNOT :
                case TE_ELSIF :
                case TE_ELSIFNOT :
                case TE_IFEQ :
                case TE_IFNEQ :
                case TE_ELSIFEQ :
                case TE_ELSIFNEQ :
                case TE_IFDEF :
                case TE_IFNDEF :
                case TE_ELSIFDEF :
                case TE_ELSIFNDEF :
                case TE_KEY :
                    thisInstance.remedyCode = TE_ASSUMING_FALSE_TO_CONTINUE;
                    break;

                default:
                    @throw [NSException exceptionWithName:@"UndefinedEnumValue"
                                                   reason:@"undefined enum value encountered" userInfo:nil];
            }
            thisInstance.severityCode = TE_ERROR;
            break;
        case TE_EXPECTED_ENDIF_BUT_FOUND_TOKEN_ERROR :
            thisInstance.remedyCode = TE_CLOSING_IF_BLOCK_TO_CONTINUE;
            thisInstance.severityCode = TE_ERROR;
            break;
        case TE_UNEXPECTED_TOKEN_ERROR :
            thisInstance.remedyCode = TE_IGNORING_UNEXPECTED_TOKEN;
            thisInstance.severityCode = TE_ERROR;
            break;
        case TE_UNIMPLEMENTED_TOKEN_ERROR :
            thisInstance.remedyCode = TE_IGNORING_UNIMPLEMENTED_TOKEN;
            thisInstance.severityCode = TE_WARNING;
            break;
        case TE_UNDEFINED_PLACEHOLDER_FOUND_ERROR :
            thisInstance.remedyCode = TE_SKIPPING_PLACEHOLDER_TO_CONTINUE;
            thisInstance.severityCode = TE_ERROR;
            break;
        case TE_EXPECTED_ENDTAG_BUT_FOUND_TOKEN_ERROR :
            thisInstance.remedyCode = TE_IMPLYING_ENDTAG_TO_CONTINUE;
            thisInstance.severityCode = TE_ERROR;
            break;
        default:
            @throw [NSException exceptionWithName:@"UndefinedEnumValue"
                                           reason:@"undefined enum value encountered" userInfo:nil];
    }

    return thisInstance;
}

- (NSString *)stringWithToken
{
    switch (self.token) {
        case TE_TOKEN_NOT_AVAILABLE: return @"";
        case TE_LOG:                 return @"%LOG";
        case TE_ECHO:                return @"%ECHO";
        case TE_DEBUG:               return @"%DEBUG";
        case TE_FOREACH:             return @"%FOREACH";
        case TE_INCLUDE:             return @"%INCLUDE";
        case TE_IF:                  return @"%IF";
        case TE_IFNOT:               return @"%IFNOT";
        case TE_IFEQ:                return @"%IFEQ";
        case TE_IFNEQ:               return @"%IFNEQ";
        case TE_ELSIFEQ:             return @"%ELSIFEQ";
        case TE_ELSIFNEQ:            return @"%ELSIFNEQ";
        case TE_IFDEF:               return @"%IFDEF";
        case TE_IFNDEF:              return @"%IFNDEF";
        case TE_ELSIFDEF:            return @"%ELSIFDEF";
        case TE_ELSIFNDEF:           return @"%ELSIFNDEF";
        case TE_ANY:                 return @"%ANY";
        case TE_EVERY:               return @"%EVERY";
        case TE_ELSE:                return @"%ELSE";
        case TE_ENDIF:               return @"%ENDIF";
        case TE_DEFINE:              return @"%DEFINE";
        case TE_UNDEF:               return @"%UNDEF";
        case TE_KEY:                 return @"%KEY";
        case TE_START_TAG:           return @"start tag";
        case TE_END_TAG:             return @"end tag";
        case TE_PLACEHOLDER:         return @"placeholder";
        case TE_PATH:                return @"path name";
        case TE_TARGET:              return @"%TARGET";
        case TE_APPEND:              return @"%APPEND";
        case TE_INSERT:              return @"%INSERT";
        case TE_EOL:                 return @"EOL marker";
        case TE_EOF:                 return @"EOF marker";
        default:
            @throw [NSException exceptionWithName:@"UndefinedEnumValue"
                                           reason:@"undefined enum value encountered" userInfo:nil];
    }
}

- (NSString *)stringWithDescription
{
    switch (self.errorCode) {
        case TE_GENERIC_ERROR :
            if (self.literal == nil)
                return @"Generic error: (no error description available).";
            return [NSString stringWithFormat:@"'%@'", self.literal];
        case TE_INVALID_PATH_ERROR :
            return @"Template file path is invalid.";
        case TE_FILE_NOT_FOUND_ERROR :
            if (self.literal == nil)
                return @"Template file not found.";
            return [NSString stringWithFormat:@"Template file at path '%@' not found.", self.literal];
        case TE_UNABLE_TO_READ_FILE_ERROR :
            if (self.literal == nil)
                return @"Unable to read template file.";
            return [NSString stringWithFormat:@"Unable to read template file at path '%@'.", self.literal];
        case TE_INVALID_FILE_FORMAT_ERROR :
            return @"Unable to recognize template file format.";
        case TE_TEMPLATE_ENCODING_ERROR :
            return @"Unable to decode string encoding.";
        case TE_TEMPLATE_EMPTY_ERROR :
            return @"Template is empty.";
        case TE_DICTIONARY_EMPTY_ERROR :
            return @"Dictionary is empty.";
        case TE_MISSING_IDENTIFIER_AFTER_TOKEN_ERROR :
            return [NSString stringWithFormat:@"Missing identifier after %@.", [self stringWithToken]];
        case TE_EXPECTED_ENDIF_BUT_FOUND_TOKEN_ERROR :
            return [NSString stringWithFormat:@"Expected %%ENDIF but found %@.", [self stringWithToken]];
        case TE_UNEXPECTED_TOKEN_ERROR :
            return [NSString stringWithFormat:@"Unexpected %@ found.", [self stringWithToken]];
        case TE_UNIMPLEMENTED_TOKEN_ERROR :
            return [NSString stringWithFormat:@"%@ has not been implemented yet.", [self stringWithToken]];
        case TE_UNDEFINED_PLACEHOLDER_FOUND_ERROR : {
            NSString *tokenString = [NSString stringWithFormat:@"'%@'", self.literal ?: @"(unspecified)"];
            return [NSString stringWithFormat:@"Placeholder %@ is undefined.", tokenString];
        }
        case TE_EXPECTED_ENDTAG_BUT_FOUND_TOKEN_ERROR :
            return [NSString stringWithFormat:@"Expected closing end tag but found %@.", [self stringWithToken]];
        default:
            break;
    }

    @throw [NSException exceptionWithName:@"UndefinedEnumValue"
                                   reason:@"undefined enum value encountered" userInfo:nil];
}

- (NSString *)stringWithRemedy
{
    switch (self.remedyCode) {
        case TE_REMEDY_NOT_AVAILABLE:
            return @"";
        case TE_ASSUMING_TRUE_TO_CONTINUE :
            return [NSString stringWithFormat:@"Assuming TRUE for this %@ block to continue.", [self stringWithToken]];
        case TE_ASSUMING_FALSE_TO_CONTINUE :
            return [NSString stringWithFormat:@"Assuming FALSE for this %@ block to continue.", [self stringWithToken]];
        case TE_CONTINUING_WITH_EMPTY_DICTIONARY :
            return @"Continuing with empty dictionary.";
        case TE_SKIPPING_PLACEHOLDER_TO_CONTINUE : {
            NSString *tokenString = [NSString stringWithFormat:@"'%@'", self.literal ?: @"(unspecified)"];
            return [NSString stringWithFormat:@"Skipping placeholder %@ to continue.", tokenString];
        }
        case TE_CLOSING_IF_BLOCK_TO_CONTINUE :
            return @"Implicitly closing previous %IF block to continue.";
        case TE_IMPLYING_ENDTAG_TO_CONTINUE :
            return @"Implying end tag to continue.";
        case TE_IGNORING_UNEXPECTED_TOKEN :
            return [NSString stringWithFormat:@"Ignoring unexpected %@ to continue.", [self stringWithToken]];
        case TE_IGNORING_UNIMPLEMENTED_TOKEN :
            return [NSString stringWithFormat:@"Ignoring unimplemented %@ to continue.", [self stringWithToken]];
        case TE_ABORTING_TEMPLATE_EXPANSION :
            return @"Template expansion aborted.";
        default:
            @throw [NSException exceptionWithName:@"UndefinedEnumValue"
                                           reason:@"undefined enum value encountered" userInfo:nil];
    }
}

- (NSString *)stringWithErrorMessageForTemplate:(NSString *)nameOrPath
{
    NSString *severity = nil;
    switch (self.severityCode) {
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
            @throw [NSException exceptionWithName:@"UndefinedEnumValue"
                                           reason:@"undefined enum value encountered" userInfo:nil];
    }

    NSString *prefix = @"STS TemplateEngine";
    NSString *description = [self stringWithDescription];
    NSString *remedy = [self stringWithRemedy];

    if ([nameOrPath length] == 0) {
        if (self.lineNumber == 0)
            return [NSString stringWithFormat:@"%@ encountered %@\n%@\n%@",
                    prefix, severity, description, remedy];
        return [NSString stringWithFormat:@"%@ encountered %@ in line %u \n%@\n%@",
                prefix, severity, self.lineNumber, description, remedy];
    }
    return [NSString stringWithFormat:@"%@ encountered %@ in template %@:%u \n%@\n%@",
            prefix, severity, nameOrPath, self.lineNumber, description, remedy];
}

- (void)logErrorMessageForTemplate:(NSString *)nameOrPath
{
    NSLog(@"Unable to parse template document %@: %@", nameOrPath, [self stringWithErrorMessageForTemplate:nameOrPath]);
}

@end
