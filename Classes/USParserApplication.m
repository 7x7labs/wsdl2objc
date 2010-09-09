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

@dynamic wsdlURL;
@dynamic outURL;
#ifdef APPKIT_EXTERN
@dynamic statusString;
@dynamic parsing;
#endif

#ifdef APPKIT_EXTERN
- (id)init
{
	if((self = [super init])) {
		NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
		[defaults addObserver:self forKeyPath:@"values.wsdlPath" options:0 context:nil];
		[defaults addObserver:self forKeyPath:@"values.outPath" options:0 context:nil];
		
		statusString = nil;
		
		parsing = NO;
	}
	
	return self;
}
		 
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"values.wsdlPath"] ||
	   [keyPath isEqualToString:@"values.outPath"]) {
		[self willChangeValueForKey:@"canParseWSDL"];
		[self didChangeValueForKey:@"canParseWSDL"];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (BOOL)canParseWSDL
{
	if([self disableAllControls]) return NO;
	
	return (self.wsdlURL != nil && self.outURL != nil);
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
	
	if(pathString == nil) return nil;
	if ([pathString length] == 0) return nil;

	if([pathString characterAtIndex:0] == '/') {
		return [NSURL fileURLWithPath:pathString];
	}
	
	return [NSURL URLWithString:pathString];
}

- (NSURL *)outURL
{
#ifdef APPKIT_EXTERN
	NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
	
	NSString *pathString = [defaults valueForKeyPath:@"values.outPath"];
#else
	NSString *pathString = [[NSUserDefaults standardUserDefaults] stringForKey:@"outPath"];
#endif
	
	if(pathString == nil) return nil;
	if ([pathString length] == 0) return nil;
	
	if([pathString characterAtIndex:0] == '/') {
		return [NSURL fileURLWithPath:pathString];
	}

	return [NSURL URLWithString:pathString];
}


#ifdef APPKIT_EXTERN
- (IBAction)browseWSDL:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:YES];
	[panel setCanChooseDirectories:NO];
	[panel setResolvesAliases:NO]; // When set to YES, refuses to select .wsdl symlink pointing to .xml file
	[panel setAllowsMultipleSelection:NO];
	
	if([panel runModalForTypes:[NSArray arrayWithObject:@"wsdl"]] == NSOKButton) {
		NSString *chosenPath = [[panel filenames] lastObject];
		NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
		[defaults setValue:chosenPath forKeyPath:@"values.wsdlPath"];
	}
}

- (IBAction)browseOutput:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:NO];
	[panel setCanChooseDirectories:YES];
	[panel setResolvesAliases:YES];
	[panel setAllowsMultipleSelection:NO];
	
	if([panel runModalForTypes:nil] == NSOKButton) {
		NSString *chosenPath = [[panel filenames] lastObject];
		NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
		[defaults setValue:chosenPath forKeyPath:@"values.outPath"];
	}
}

- (BOOL)disableAllControls
{
	return parsing;
}

- (IBAction)parseWSDL:(id)sender
{
	if(!parsing) [NSThread detachNewThreadSelector:@selector(doParseWSDL) toTarget:self withObject:nil];
}

- (void)setStatusString:(NSString *)aString
{
	[self willChangeValueForKey:@"statusString"];
	
	if(statusString != nil) [statusString release];
	statusString = [aString copy];
	
	[self didChangeValueForKey:@"statusString"];
}

- (void)setParsing:(BOOL)aBool
{
	[self willChangeValueForKey:@"canParseWSDL"];
	[self willChangeValueForKey:@"disableAllControls"];
	
	parsing = aBool;
	
	[self didChangeValueForKey:@"disableAllControls"];
	[self didChangeValueForKey:@"canParseWSDL"];
}

- (void)doParseWSDL
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	self.parsing = YES;
	
	self.statusString = @"Parsing WSDL file...";
	
	USParser *parser = [[USParser alloc] initWithURL:self.wsdlURL];
	USWSDL *wsdl = [parser parse];
	
	[self writeDebugInfoForWSDL:wsdl];
	
	[parser release];
	
	self.statusString = @"Generating Objective C code into the output directory...";
	
	USWriter *writer = [[USWriter alloc] initWithWSDL:wsdl outputDirectory:self.outURL];
	[writer write];
	[writer release];
	
	self.statusString = @"Finished!";
	
	self.parsing = NO;
	
	[pool drain];
}
#endif

- (void)writeDebugInfoForWSDL:(USWSDL*)wsdl
{
	if(!wsdl)
	{
		NSLog(@"No WSDL!!");
		return;
	}
	
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"writeDebug"]) //write out schemas
	{
#ifdef APPKIT_EXTERN
        self.statusString = @"Writing debug info to console...";
#else
        NSLog(@"Writing debug info to console...");
#endif
        
		for(USSchema *schema in wsdl.schemas)
		{
			NSLog(@"Schema: %@", [schema fullName]);
			
			if(YES) //write out types
			{
				for(USType * t in [schema types])
				{
					if([t isComplexType])
					{
						NSLog(@"\tComplex type: %@", t.typeName);
						for(USAttribute *at in t.attributes)
						{
							if([at.type isSimpleType])
							{
								USType *st = at.type;
								NSLog(@"\t\tSimple Type attribute: %@, type: %@ representation: %@, default: %@",at.name, st.typeName, st.representationClass, at.attributeDefault);
							}
							else
							{
								USType *act = at.type;
								NSString *baseClass = @"No base";
								if(act.superClass)
									baseClass = act.superClass.typeName;
								NSLog(@"\t\tComplex type attribute: %@, type: %@, base: %@, default: %@", at.name, act.typeName, baseClass, at.attributeDefault);
							}
						}
					}
					else
					{
						NSLog(@"\tSimple type: %@, representation class: %@", t.typeName, t.representationClass);
						if([t.enumerationValues count] > 0)
						{
							NSLog(@"\t\tEnumeration values: ");
							for(NSString *v in t.enumerationValues)
							{
								NSLog(@"\t\t\t%@", v);
							}
						}
					}
				}
			}
		}
		
			}
	
	if(YES) //write potential problems
	{
		for(USSchema *schema in wsdl.schemas)
		{
			if([schema.types count] == 0)
			{
			}
		}
		
	}
}
@end
