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
@class USComplexType;

@interface USType : NSObject
+ (instancetype)primitiveTypeWithName:(NSString *)name prefix:(NSString *)prefix type:(NSString *)type;
+ (instancetype)enumTypeWithName:(NSString *)name prefix:(NSString *)prefix values:(NSArray *)values;
+ (instancetype)arrayTypeWithName:(NSString *)name prefix:(NSString *)prefix choices:(NSArray *)choices;
+ (instancetype)choiceTypeWithName:(NSString *)name prefix:(NSString *)prefix choices:(NSArray *)choices;
+ (instancetype)complexTypeWithName:(NSString *)name prefix:(NSString *)prefix
                           elements:(NSArray *)elements attributes:(NSArray *)attributes base:(USType *)base;

@property (nonatomic, readonly) NSString *typeName;
@property (nonatomic, readonly) NSString *prefix;
@property (nonatomic) BOOL hasBeenWritten;

@property (nonatomic, readonly) NSNumber *isEnum;

// Name of class used to serialize and deserialize values of this type
@property (nonatomic, readonly) NSString *className;
// Name of class which can create instances of this type, or nil for primitives
// and things that can not be automatically created
@property (nonatomic, readonly) NSString *factoryClassName;
// Name of type for variables which are instances of this type
@property (nonatomic, readonly) NSString *variableTypeName;

- (NSString *)templateFileHPath;
- (NSString *)templateFileMPath;
- (NSMutableDictionary *)templateKeyDictionary;

- (USComplexType *)asComplex;
- (instancetype)deriveWithName:(NSString *)newTypeName prefix:(NSString *)newTypePrefix;
@end

@interface USComplexType : USType
@property (nonatomic, strong) NSArray *sequenceElements;
@property (nonatomic, strong) NSArray *attributes;
@property (nonatomic, strong) USType *superClass;
@end

@interface USProxyType : NSProxy
- (instancetype)initWithName:(NSString *)typeName;

@property (nonatomic, strong) NSString *typeName;
@property (nonatomic, strong) USType *type;
@end
