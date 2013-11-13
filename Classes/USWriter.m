/*
 Copyright (c) 2008 LightSPEED Technologies, Inc.
 Modified by Matthew Faupel on 2009-05-06 to use NSDate instead of NSCalendarDate (for iPhone compatibility).
 Modifications copyright (c) 2009 Micropraxis Ltd.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "USWriter.h"

#import "NSBundle+USAdditions.h"
#import "STSTemplateEngine.h"
#import "USAttribute.h"
#import "USBinding.h"
#import "USElement.h"
#import "USPort.h"
#import "USSchema.h"
#import "USService.h"
#import "USType.h"

@interface USWriter ()
@property (nonatomic, copy) NSURL *outDir;
@property (nonatomic, strong) USWSDL *wsdl;
@end

@implementation USWriter
- (id)initWithWSDL:(USWSDL *)aWsdl outputDirectory:(NSURL *)anOutDir {
    if ((self = [super init])) {
        self.wsdl = aWsdl;
        self.outDir = anOutDir;
    }

    return self;
}

- (void)write {
    for (NSString *schema in self.wsdl.schemas)
        [self writeSchema:self.wsdl.schemas[schema]];

    [self copyStandardFilesToOutputDirectory];
}

- (void)writeSchema:(USSchema *)schema {
    if (schema.hasBeenWritten == YES) return;
    if (![schema shouldWrite]) return;

    schema.hasBeenWritten = YES;

    // Write out any imports first so they can have a prefix generated for them if needed
    for (USSchema *import in schema.imports)
        [self writeSchema:import];

    NSMutableString *hString = [NSMutableString string];
    NSMutableString *mString = [NSMutableString string];

    [self append:schema toHString:hString mString:mString];

    for (USType *type in [schema.types allValues])
        [self appendType:type toHString:hString mString:mString];

    for (USService *service in [schema.services allValues]) {
        [self append:service toHString:hString mString:mString];

        for (USPort *port in service.ports)
            [self append:port.binding toHString:hString mString:mString];
    }

    if ([hString length] > 0) {
        NSError *error;
        [hString writeToURL:[NSURL URLWithString:[schema.prefix stringByAppendingString:@".h"] relativeToURL:self.outDir]
                 atomically:NO
                   encoding:NSUTF8StringEncoding
                      error:&error];

        [mString writeToURL:[NSURL URLWithString:[schema.prefix stringByAppendingString:@".m"] relativeToURL:self.outDir]
                 atomically:NO
                   encoding:NSUTF8StringEncoding
                      error:&error];
    }
}

- (void)appendType:(USType *)type toHString:(NSMutableString *)hString mString:(NSMutableString *)mString
{
    if (type.hasBeenWritten) return;

    type.hasBeenWritten = YES;

    USComplexType *complexType = [type asComplex];
    if (complexType) {
        if (complexType.superClass)
            [self appendType:complexType.superClass toHString:hString mString:mString];

        // Simple types need to be written first, since they aren't forward declared
        // Complex types need to wait though, since they may be subclasses of this type
        for (USElement *seqElement in complexType.sequenceElements) {
            if (![seqElement.type asComplex])
                [self appendType:seqElement.type toHString:hString mString:mString];
        }

        for (USAttribute *attribute in complexType.attributes) {
            if (![attribute.type asComplex])
                [self appendType:attribute.type toHString:hString mString:mString];
        }
    }
    
    [self append:type toHString:hString mString:mString];
}

- (void)append:(id)item toHString:(NSMutableString *)hString mString:(NSMutableString *)mString {
    NSMutableDictionary *templateKeys = [[item templateKeyDictionary] mutableCopy];
    templateKeys[@"wsdl"] = [self.wsdl templateKeyDictionary];

    NSArray *errors;
    NSString *newHString = [NSString stringByExpandingTemplateAtPath:[item templateFileHPath]
                                                     usingDictionary:templateKeys
                                                            encoding:NSUTF8StringEncoding
                                                      errorsReturned:&errors];

    if (errors == nil)
        [hString appendString:newHString];
    else
        NSLog(@"Errors encountered generating header: %@", errors);

    NSString *newMString = [NSString stringByExpandingTemplateAtPath:[item templateFileMPath]
                                                     usingDictionary:templateKeys
                                                            encoding:NSUTF8StringEncoding
                                                      errorsReturned:&errors];

    if (errors == nil)
        [mString appendString:newMString];
    else
        NSLog(@"Errors encountered while generating implementation: %@", errors);

}

- (void)copyStandardFilesToOutputDirectory {
    // Copy additions files
    [self writeResourceName:@"USAdditions_H" toFilename:@"USAdditions.h"];
    [self writeResourceName:@"USAdditions_M" toFilename:@"USAdditions.m"];

    // Copy additions dependencies
    [self writeResourceName:@"NSDate+ISO8601Parsing_H" toFilename:@"NSDate+ISO8601Parsing.h"];
    [self writeResourceName:@"NSDate+ISO8601Parsing_M" toFilename:@"NSDate+ISO8601Parsing.m"];
    [self writeResourceName:@"NSDate+ISO8601Unparsing_H" toFilename:@"NSDate+ISO8601Unparsing.h"];
    [self writeResourceName:@"NSDate+ISO8601Unparsing_M" toFilename:@"NSDate+ISO8601Unparsing.m"];

    // Copy globals
    [self writeResourceName:@"USGlobals_H" toFilename:@"USGlobals.h"];
    [self writeResourceName:@"USGlobals_M" toFilename:@"USGlobals.m"];
}

- (void)writeResourceName:(NSString *)resourceName toFilename:(NSString *)fileName {
    NSString *path = [[NSBundle mainBundle] pathForTemplateNamed:resourceName];
    NSString *resourceContents = [NSString stringWithContentsOfFile:path usedEncoding:nil error:nil];
    [resourceContents writeToURL:[NSURL URLWithString:fileName relativeToURL:self.outDir]
                      atomically:NO
                        encoding:NSUTF8StringEncoding
                           error:nil];
}

@end
