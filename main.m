/*
 Copyright (c) 2010 LightSPEED Technologies, Inc.
 
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

#import <Foundation/Foundation.h>
#import "USParserApplication.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool   *localAP = [NSAutoreleasePool new];
    USParserApplication *parserApp = [USParserApplication new];
    
    if(parserApp.wsdlURL == nil){
        NSString    *help = [NSString stringWithFormat:
                             @"%@ %@, %@\n"
                             "Usage: %s -wsdlPath <url or path> [-outPath <path>] [-addTagToServiceName <YES or NO>] [-usePrefix <YES or NO>] [-templateDirectory <path>] [-writeDebug <YES or NO>]\n"
                             "Generates ObjC classes able to perform SOAP requests defined by a WSDL file.\n"
                             "    -wsdlPath <url or path>\t\tURL or path to a WSDL file\n"
                             "    -outPath <path>\t\t\tDirectory output path. Defaults to current working directory\n"
                             "    -addTagToServiceName <YES or NO>\tSuffixes service name with 'Svc' (avoid name conflicts). Defaults to NO\n"
                             "    -usePrefix <YES or NO>\tPrefixes file names with service name (avoid name conflicts). Defaults to NO\n"
                             "    -templateDirectory <path>\t\tPath of folder containing wsdl2objc templates. By default will look in */Application Support/wsdl2objc directories\n"
                             "    -writeDebug <YES or NO>\t\tWrite Write debug info for WSDL. Defaults to NO.",
                             [[[NSBundle mainBundle] executablePath] lastPathComponent],
                             [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey],
                             [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleGetInfoString"],
                             argv[0]];
        
        fprintf(stderr, "%s\n", [help UTF8String]);
        [parserApp release];
        [localAP drain];
        
        exit(1);
    }
    if(parserApp.outURL == nil){
        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:[[NSFileManager defaultManager] currentDirectoryPath] forKey:@"outPath"]];
    }
    
	NSLog(@"Parsing WSDL file...");
    
	USParser    *parser = [[USParser alloc] initWithURL:parserApp.wsdlURL];
	USWSDL      *wsdl = [parser parse];
    
	[parserApp writeDebugInfoForWSDL:wsdl];

	[parser release];
    
	NSLog(@"Generating Objective C code into the output directory...");
	USWriter *writer = [[USWriter alloc] initWithWSDL:wsdl outputDirectory:parserApp.outURL];
	[writer write];
	
	NSLog(@"Finished!");
    
	[writer release];
    [parserApp release];
    [localAP drain];
    
    return 0;
}
