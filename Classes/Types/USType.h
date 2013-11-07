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

@class USWSDL;
@class USSchema;

typedef enum {
	TypeBehavior_uninitialized = 0,
	TypeBehavior_simple,
	TypeBehavior_complex
} TypeBehavior;

@interface USType : NSObject
+ (USType *)simpleTypeWithName:(NSString *)name prefix:(NSString *)prefix;
+ (USType *)complexTypeWithName:(NSString *)name prefix:(NSString *)prefix;

@property (nonatomic, copy) NSString *typeName;
@property (nonatomic, copy) NSString *prefix;
@property (nonatomic) TypeBehavior behavior;
@property (nonatomic) BOOL hasBeenWritten;

#pragma mark Global type methods
@property (nonatomic, readonly) BOOL isSimpleType;
@property (nonatomic, readonly) BOOL isComplexType;

@property (nonatomic, readonly) NSString *className;
@property (nonatomic, readonly) NSString *classNameWithPtr;
@property (nonatomic, readonly) NSString *classNameWithoutPtr;
@property (nonatomic, readonly) NSString *assignOrRetain;

- (NSString *)templateFileHPath;
- (NSString *)templateFileMPath;
- (NSDictionary *)templateKeyDictionary;

#pragma mark Simple type methods
@property (nonatomic, copy) NSString *representationClass;
@property (nonatomic, strong) NSArray *enumerationValues;
@property (nonatomic, readonly) NSString *enumCount;

#pragma mark Complex type methods
@property (nonatomic, strong) USType *superClass;
@property (nonatomic, strong) NSMutableArray *sequenceElements;
@property (nonatomic, strong) NSMutableArray *attributes;

@end
