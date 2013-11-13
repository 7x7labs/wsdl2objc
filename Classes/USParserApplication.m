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

#import "USParserApplication.h"

#import "STSTemplateEngine.h"

@implementation USParserApplication
#ifdef APPKIT_EXTERN
- (id)init
{
	if ((self = [super init])) {
		NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
		[defaults addObserver:self forKeyPath:@"values.wsdlPath" options:0 context:nil];
		[defaults addObserver:self forKeyPath:@"values.outPath" options:0 context:nil];
	}

	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"values.wsdlPath"] || [keyPath isEqualToString:@"values.outPath"]) {
		[self willChangeValueForKey:@"canParseWSDL"];
		[self didChangeValueForKey:@"canParseWSDL"];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (BOOL)canParseWSDL
{
	if ([self disableAllControls]) return NO;

	return self.wsdlURL && self.outURL;
}
#endif

- (NSURL *)wsdlURL
{
#ifdef APPKIT_EXTERN
	NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];

	NSString *pathString = [defaults valueForKeyPath:@"values.wsdlPath"];
#else
	NSString *pathString = [[NSUserDefaults standardUserDefaults] stringForKey:@"wsdlPath"];
#endif

	if ([pathString length] == 0) return nil;
    if ([pathString characterAtIndex:0] == '~') {
        pathString = [pathString stringByExpandingTildeInPath];
    }

    NSURL *wsdlURL = [NSURL URLWithString:pathString];
    return [wsdlURL scheme] ? wsdlURL : [NSURL fileURLWithPath:pathString];
}

- (NSURL *)outURL
{
#ifdef APPKIT_EXTERN
	NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];

	NSString *pathString = [defaults valueForKeyPath:@"values.outPath"];
#else
	NSString *pathString = [[NSUserDefaults standardUserDefaults] stringForKey:@"outPath"];
#endif

	if ([pathString length] == 0) return nil;

	if ([pathString characterAtIndex:0] == '/')
		return [NSURL fileURLWithPath:pathString];
	return [NSURL URLWithString:pathString];
}

#ifdef APPKIT_EXTERN
- (IBAction)browseWSDL:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = YES;
    panel.canChooseDirectories = NO;
    panel.resolvesAliases = NO;
    panel.allowsMultipleSelection = NO;
    panel.allowedFileTypes = @[@"wsdl"];

	if ([panel runModal] == NSOKButton) {
		NSURL *chosenPath = [[panel URLs] lastObject];
		NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
		[defaults setValue:[chosenPath absoluteString]
                forKeyPath:@"values.wsdlPath"];
	}
}

- (IBAction)browseOutput:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = NO;
    panel.canChooseDirectories = YES;
    panel.resolvesAliases = YES;
    panel.allowsMultipleSelection = NO;

	if ([panel runModal] == NSOKButton) {
		NSURL *chosenPath = [[panel URLs] lastObject];
		NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
		[defaults setValue:[chosenPath absoluteString]
                forKeyPath:@"values.outPath"];
	}
}

- (BOOL)disableAllControls
{
	return self.parsing;
}

- (IBAction)parseWSDL:(id)sender
{
	if (!self.parsing)
        [NSThread detachNewThreadSelector:@selector(doParseWSDL) toTarget:self withObject:nil];
}

- (void)setStatusString:(NSString *)aString
{
	[self willChangeValueForKey:@"statusString"];
	_statusString = [aString copy];
	[self didChangeValueForKey:@"statusString"];
}

- (void)setParsing:(BOOL)aBool
{
	[self willChangeValueForKey:@"canParseWSDL"];
	[self willChangeValueForKey:@"disableAllControls"];

	_parsing = aBool;

	[self didChangeValueForKey:@"disableAllControls"];
	[self didChangeValueForKey:@"canParseWSDL"];
}

- (void)doParseWSDL
{
    @autoreleasepool {
        self.parsing = YES;

        self.statusString = @"Parsing WSDL file...";

        USParser *parser = [[USParser alloc] initWithURL:self.wsdlURL];
        USWSDL *wsdl = [parser parse];

        [self writeDebugInfoForWSDL:wsdl];

        self.statusString = @"Generating Objective-C code into the output directory...";

        USWriter *writer = [[USWriter alloc] initWithWSDL:wsdl outputDirectory:self.outURL];
        [writer write];

        self.statusString = @"Finished!";

        self.parsing = NO;
    }
}
#endif

- (void)writeDebugInfoForWSDL:(USWSDL*)wsdl
{
	if (!wsdl) {
		NSLog(@"No WSDL!!");
		return;
	}

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"writeDebug"]) { //write out schemas
#ifdef APPKIT_EXTERN
        self.statusString = @"Writing debug info to console...";
#else
        NSLog(@"Writing debug info to console...");
#endif

#if 0
		for (USSchema *schema in wsdl.schemas) {
			NSLog(@"Schema: %@", schema.fullName);

            for (USType * t in schema.types) {
                if (t.isComplexType) {
                    NSLog(@"\tComplex type: %@", t.typeName);
                    for (USAttribute *at in t.attributes) {
                        if (at.type.isSimpleType) {
                            USType *st = at.type;
                            NSLog(@"\t\tSimple Type attribute: %@, type: %@ representation: %@, default: %@",at.name, st.typeName, st.representationClass, at.attributeDefault);
                        }
                        else {
                            USType *act = at.type;
                            NSString *baseClass = @"No base";
                            if (act.superClass)
                                baseClass = act.superClass.typeName;
                            NSLog(@"\t\tComplex type attribute: %@, type: %@, base: %@, default: %@", at.name, act.typeName, baseClass, at.attributeDefault);
                        }
                    }
                }
                else {
                    NSLog(@"\tSimple type: %@, representation class: %@", t.typeName, t.representationClass);
                    if ([t.enumerationValues count] > 0) {
                        NSLog(@"\t\tEnumeration values: ");
                        for (NSString *v in t.enumerationValues) {
                            NSLog(@"\t\t\t%@", v);
                        }
                    }
                }
            }
		}
#endif
    }
}
@end
