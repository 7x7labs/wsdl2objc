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

#import "NSBundle+USAdditions.h"


@implementation NSBundle(USAdditions)

/*
 * Will look for templateName.template in:
 * - directory defined by user default 'templateDirectory'
 * - ~/Library/Application Support/wsdl2objc/
 * - /Library/Application Support/wsdl2objc/
 * - /Network/Library/Application Support/wsdl2objc/
 * - application bundle resources
 */
- (NSString *)pathForTemplateNamed:(NSString *)templateName
{
    NSString    *templateDirectory = [[NSUserDefaults standardUserDefaults] stringForKey:@"templateDirectory"];
    
    templateName = [templateName stringByAppendingPathExtension:@"template"];
    if(templateDirectory == nil){
        for (templateDirectory in NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSAllDomainsMask, YES)) {
            NSString    *path = [templateDirectory stringByAppendingPathComponent:[@"wsdl2objc" stringByAppendingPathComponent:templateName]];
            
            if([[NSFileManager defaultManager] fileExistsAtPath:path]){
                return path;
            }
        }
#ifdef APPKIT_EXTERN
        return [self pathForResource:[templateName stringByDeletingPathExtension] ofType:@"template"];
#else
        return nil;
#endif
    }
    else{
        return [templateDirectory stringByAppendingPathComponent:templateName];
    }
}

@end
