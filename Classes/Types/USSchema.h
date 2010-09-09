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

#import <Foundation/Foundation.h>

@class USObjCKeywords;
@class USWSDL;
@class USType;
@class USElement;
@class USAttribute;
@class USMessage;
@class USPortType;
@class USBinding;
@class USService;


@interface USSchema : NSObject {
	NSString *fullName;
	NSString *prefix;
	NSString *localPrefix;
	NSMutableArray *types;
	NSMutableArray *elements;
	NSMutableArray *attributes;
	NSMutableArray *imports;
	NSMutableArray *messages;
	NSMutableArray *portTypes;
	NSMutableArray *bindings;
	NSMutableArray *services;
	USWSDL *wsdl;
	
	BOOL hasBeenParsed;
	BOOL hasBeenWritten;
}

@property (nonatomic, copy) NSString *prefix;			// unique global schema prefix (after all includes)
@property (nonatomic, copy) NSString *localPrefix;		// specified schema prefix within local scope
@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, retain) NSMutableArray *types;
@property (nonatomic, retain) NSMutableArray *elements;
@property (nonatomic, retain) NSMutableArray *attributes;
@property (nonatomic, retain) NSMutableArray *imports;
@property (nonatomic, retain) NSMutableArray *messages;
@property (nonatomic, retain) NSMutableArray *portTypes;
@property (nonatomic, retain) NSMutableArray *bindings;
@property (nonatomic, retain) NSMutableArray *services;
@property (nonatomic, assign) USWSDL *wsdl;
@property (nonatomic) BOOL hasBeenParsed;
@property (nonatomic) BOOL hasBeenWritten;

- (id)initWithWSDL:(USWSDL *)aWsdl;
- (void)dealloc;

- (USType *)typeForName:(NSString *)aName;
- (USElement *)elementForName:(NSString *)aName;
- (USAttribute *)attributeForName:(NSString *)aName;
- (USMessage *)messageForName:(NSString *)aName;
- (USPortType *)portTypeForName:(NSString *)aName;
- (USBinding *)bindingForName:(NSString *)aName;
- (USService *)serviceForName:(NSString *)aName;

- (void)addSimpleClassWithName:(NSString *)aName representationClass:(NSString *)aClass;
- (void)addComplexClassWithName:(NSString *)aName representationClass:(NSString *)aClass;

- (BOOL)shouldNotWrite;
- (NSString *)shouldNotWriteString;

- (NSString *)templateFileHPath;
- (NSString *)templateFileMPath;
- (NSDictionary *)templateKeyDictionary;

@end
