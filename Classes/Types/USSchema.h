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

#import <Cocoa/Cocoa.h>

@class USWSDL;
@class USType;
@class USElement;
@class USMessage;
@class USPortType;
@class USBinding;
@class USService;

@interface USSchema : NSObject {
	NSString *fullName;
	NSString *prefix;
	NSMutableArray *types;
	NSMutableArray *elements;
	NSMutableArray *imports;
	NSMutableArray *messages;
	NSMutableArray *portTypes;
	NSMutableArray *bindings;
	NSMutableArray *services;
	USWSDL *wsdl;
	
	BOOL hasBeenParsed;
	BOOL hasBeenWritten;
}

@property (copy) NSString *prefix;
@property (copy) NSString *fullName;
@property (retain) NSMutableArray *types;
@property (retain) NSMutableArray *elements;
@property (retain) NSMutableArray *imports;
@property (retain) NSMutableArray *messages;
@property (retain) NSMutableArray *portTypes;
@property (retain) NSMutableArray *bindings;
@property (retain) NSMutableArray *services;
@property (retain) USWSDL *wsdl;
@property (assign) BOOL hasBeenParsed;
@property (assign) BOOL hasBeenWritten;

-(id)initWithWSDL:(USWSDL *)aWsdl;
-(void)dealloc;

- (USType *)typeForName:(NSString *)aName;
- (USElement *)elementForName:(NSString *)aName;
- (USMessage *)messageForName:(NSString *)aName;
- (USPortType *)portTypeForName:(NSString *)aName;
- (USBinding *)bindingForName:(NSString *)aName;
- (USService *)serviceForName:(NSString *)aName;

- (void)addSimpleClassWithName:(NSString *)aName representationClass:(NSString *)aClass;
- (void)addComplexClassWithName:(NSString *)aName representationClass:(NSString *)aClass;

- (NSString *)templateFileHPath;
- (NSString *)templateFileMPath;
- (NSDictionary *)templateKeyDictionary;

@end
