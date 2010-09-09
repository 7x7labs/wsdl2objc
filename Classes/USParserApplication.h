/*
 Copyright (c) 2008 LightSPEED Technologies, Inc.
 
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

#ifdef APPKIT_EXTERN
    #import <Cocoa/Cocoa.h>
#else
    #import <Foundation/Foundation.h>
#endif
#import "USType.h"
#import "USAttribute.h"
#import "USParser.h"
#import "USWSDL.h"
#import "USSchema.h"
#import "USWriter.h"

@interface USParserApplication : NSObject {
	BOOL parsing;
#ifdef APPKIT_EXTERN
	NSString *statusString;
#endif
}

#ifdef APPKIT_EXTERN
- (BOOL)canParseWSDL;
- (BOOL)disableAllControls;
#endif

#ifdef APPKIT_EXTERN
- (IBAction)browseWSDL:(id)sender;
- (IBAction)browseOutput:(id)sender;

- (IBAction)parseWSDL:(id)sender;
#endif

@property (nonatomic, readonly) NSURL *wsdlURL;
@property (nonatomic, readonly) NSURL *outURL;
#ifdef APPKIT_EXTERN
@property (nonatomic, copy) NSString *statusString;
@property (nonatomic) BOOL parsing;
#endif

- (void)writeDebugInfoForWSDL:(USWSDL*)wsdl;

@end
