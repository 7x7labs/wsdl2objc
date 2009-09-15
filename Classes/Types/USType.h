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
@class USSchema;

typedef enum {
	TypeBehavior_uninitialized = 0,
	TypeBehavior_simple,
	TypeBehavior_complex
} TypeBehavior;

@interface USType : NSObject {
	
	
#pragma mark Global type fields
	NSString *typeName;
	USSchema *schema;
	TypeBehavior behavior;
	BOOL hasBeenParsed;
	BOOL hasBeenWritten;
	
	
	
#pragma mark Simple type fields
	NSString *representationClass;
	NSMutableArray *enumerationValues;
	
	
	
#pragma mark Complex type fields
	USType *superClass;
	NSMutableArray *sequenceElements;
	NSMutableArray *attributes;
}

#pragma mark Global type methods
-(BOOL)isSimpleType;
-(BOOL)isComplexType;
-(NSString *)isSimpleTypeString;
-(NSString *)isComplexTypeString;

- (NSString *)className;
- (NSString *)classNameWithPtr;
- (NSString *)classNameWithoutPtr;
- (NSString *)assignOrRetain;

@property (copy) NSString *typeName;
@property (retain) USSchema *schema;
@property (assign) TypeBehavior behavior;
@property (assign) BOOL hasBeenParsed;
@property (assign) BOOL hasBeenWritten;

- (NSString *)templateFileHPath;
- (NSString *)templateFileMPath;
- (NSDictionary *)templateKeyDictionary;



#pragma mark Simple type methods
@property (copy) NSString *representationClass;
@property (retain) NSMutableArray *enumerationValues;

- (NSString *)enumCount;



#pragma mark Complex type methods
@property (retain) USType *superClass;
@property (retain) NSMutableArray *sequenceElements;
@property (retain) NSMutableArray *attributes;

@end




