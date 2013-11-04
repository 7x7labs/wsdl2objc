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

@interface USSchema : NSObject
@property (nonatomic, copy) NSString *prefix;			// unique global schema prefix (after all includes)
@property (nonatomic, copy) NSString *localPrefix;		// specified schema prefix within local scope
@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, strong) NSMutableArray *types;
@property (nonatomic, strong) NSMutableArray *elements;
@property (nonatomic, strong) NSMutableArray *attributes;
@property (nonatomic, strong) NSMutableArray *imports;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *portTypes;
@property (nonatomic, strong) NSMutableArray *bindings;
@property (nonatomic, strong) NSMutableArray *services;
@property (nonatomic, strong) USWSDL *wsdl;
@property (nonatomic) BOOL hasBeenParsed;
@property (nonatomic) BOOL hasBeenWritten;

- (id)initWithWSDL:(USWSDL *)aWsdl;

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

- (NSString *)templateFileHPath;
- (NSString *)templateFileMPath;
- (NSDictionary *)templateKeyDictionary;
@end
