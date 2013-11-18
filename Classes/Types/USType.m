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

#import "USType.h"

#import "NSBundle+USAdditions.h"
#import "NSString+USAdditions.h"
#import "USElement.h"
#import "USSchema.h"
#import "USWSDL.h"

static NSArray *flattedSubstitutions(NSArray *elements) {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:elements.count];
    for (USElement *element in elements) {
        [ret addObject:element];
        for (USElement *substitution in element.substitutions)
            [ret addObject:substitution];
    }
    return ret;
}

@interface USType ()
@property (nonatomic, strong) NSString *typeName;
@property (nonatomic, strong) NSString *prefix;

- (id)initWithName:(NSString *)name prefix:(NSString *)prefix;
@end

@interface USPrimitiveType : USType
@property (nonatomic, copy) NSString *representationType;
@end

@implementation USPrimitiveType
- (NSString *)templateFileHPath {
    return [[NSBundle mainBundle] pathForTemplateNamed:@"PrimitiveType_H"];
}

- (NSString *)templateFileMPath {
    return [[NSBundle mainBundle] pathForTemplateNamed:@"PrimitiveType_M"];
}

- (NSString *)variableTypeName {
    return self.representationType;
}

- (instancetype)deriveWithName:(NSString *)newTypeName prefix:(NSString *)newTypePrefix {
    return [USPrimitiveType primitiveTypeWithName:newTypeName prefix:newTypePrefix type:self.representationType];
}
@end

@interface USEnumType : USType
@property (nonatomic, strong) NSArray *enumValues;
@end

@implementation USEnumType
- (NSString *)templateFileHPath {
    return [[NSBundle mainBundle] pathForTemplateNamed:@"EnumType_H"];
}

- (NSString *)templateFileMPath {
    return [[NSBundle mainBundle] pathForTemplateNamed:@"EnumType_M"];
}

- (NSString *)variableTypeName {
    return [self.className stringByAppendingString:@"Enum"];
}

- (NSNumber *)isEnum {
    return @YES;
}

- (NSMutableDictionary *)templateKeyDictionary {
    NSMutableDictionary *ret = [super templateKeyDictionary];
    ret[@"enumerationValues"] = self.enumValues;

    NSMutableArray *mangledEnumerationValues = [NSMutableArray arrayWithCapacity:self.enumValues.count];
    for (NSString *str in self.enumValues)
        [mangledEnumerationValues addObject:[[[str
                                             stringByReplacingOccurrencesOfString:@" " withString:@"_"]
                                             stringByReplacingOccurrencesOfString:@":" withString:@"_"]
                                             stringByRemovingIllegalCharacters]];
    ret[@"mangledEnumerationValues"] = mangledEnumerationValues;
    return ret;
}

- (instancetype)deriveWithName:(NSString *)newTypeName prefix:(NSString *)newTypePrefix {
    return [USEnumType enumTypeWithName:newTypeName prefix:newTypePrefix values:self.enumValues];
}
@end

@interface USArrayType : USType
@property (nonatomic, strong) NSArray *choices;
@end

@implementation USArrayType
- (NSString *)templateFileHPath {
    return [[NSBundle mainBundle] pathForTemplateNamed:@"ArrayType_H"];
}

- (NSString *)templateFileMPath {
    return [[NSBundle mainBundle] pathForTemplateNamed:@"ArrayType_M"];
}

- (NSString *)variableTypeName {
    return @"NSArray *";
}

- (NSMutableDictionary *)templateKeyDictionary {
    NSMutableDictionary *ret = [super templateKeyDictionary];
    NSArray *choices = flattedSubstitutions(self.choices);
    ret[@"choices"] = choices;
    if (choices.count == 1)
        ret[@"onlyChoice"] = choices.firstObject;
    return ret;
}

- (instancetype)deriveWithName:(NSString *)newTypeName prefix:(NSString *)newTypePrefix {
    return [USArrayType arrayTypeWithName:newTypeName prefix:newTypePrefix choices:self.choices];
}
@end

@interface USChoiceType : USType
@property (nonatomic, strong) NSArray *choices;
@end

@implementation USChoiceType
- (NSString *)templateFileHPath {
    return [[NSBundle mainBundle] pathForTemplateNamed:@"ChoiceType_H"];
}

- (NSString *)templateFileMPath {
    return [[NSBundle mainBundle] pathForTemplateNamed:@"ChoiceType_M"];
}

- (NSString *)variableTypeName {
    return @"id"; // ARC doesn't support unions of Obj-C types :(
}

- (NSMutableDictionary *)templateKeyDictionary {
    NSMutableDictionary *ret = [super templateKeyDictionary];
    ret[@"choices"] = flattedSubstitutions(self.choices);
    return ret;
}

- (instancetype)deriveWithName:(NSString *)newTypeName prefix:(NSString *)newTypePrefix {
    return [USChoiceType choiceTypeWithName:newTypeName prefix:newTypePrefix choices:self.choices];
}
@end

@implementation USComplexType
- (NSString *)templateFileHPath {
    return [[NSBundle mainBundle] pathForTemplateNamed:@"ComplexType_H"];
}

- (NSString *)templateFileMPath {
    return [[NSBundle mainBundle] pathForTemplateNamed:@"ComplexType_M"];
}

- (NSString *)factoryClassName {
    return self.className;
}

- (USComplexType *)asComplex {
    return self;
}

- (NSMutableDictionary *)templateKeyDictionary {
    NSMutableDictionary *ret = [super templateKeyDictionary];
    ret[@"superClassName"] = @"NSObject";
    if (self.superClass) {
        ret[@"superClass"] = self.superClass;
        if (self.superClass.asComplex) {
            ret[@"superClassName"] = self.superClass.className;
            ret[@"complexSuper"] = @YES;
        }
        else if ([self.superClass isKindOfClass:[USPrimitiveType class]])
            ret[@"attributedSimpleType"] = @YES;
        for (USComplexType *parent = self.superClass.asComplex; parent; parent = parent.superClass.asComplex) {
            if ([parent.sequenceElements count] > 0)
                ret[@"hasSuperElements"] = @YES;
            if ([parent.attributes count] > 0)
                ret[@"hasSuperAttributes"] = @YES;
        }
    }
    ret[@"sequenceElements"] = flattedSubstitutions(self.sequenceElements ?: @[]);
    ret[@"hasSequenceElements"] = @([self.sequenceElements count]);
    ret[@"hasArrayElements"] = @NO;
    for (USElement *element in self.sequenceElements) {
        if (element.isArray) {
            ret[@"hasArrayElements"] = @YES;
            break;
        }
    }
    ret[@"attributes"] = self.attributes ?: @[];
    ret[@"hasAttributes"] = @([self.attributes count] > 0);
    ret[@"hasMembers"] = @([ret[@"hasSequenceElements"] boolValue]
                        || [ret[@"hasSuperElements"] boolValue]
                        || [ret[@"hasAttributes"] boolValue]
                        || [ret[@"hasSuperAttributes"] boolValue]);
    return ret;
}

- (instancetype)deriveWithName:(NSString *)newTypeName prefix:(NSString *)newTypePrefix {
    return [USComplexType complexTypeWithName:newTypeName prefix:newTypePrefix
                                     elements:@[] attributes:@[] base:self];
}
@end

@implementation USType
- (id)initWithName:(NSString *)name prefix:(NSString *)prefix {
    self = [super init];
    self.typeName = name;
    self.prefix = prefix;
    return self;
}

+ (instancetype)primitiveTypeWithName:(NSString *)name prefix:(NSString *)prefix
                                 type:(NSString *)representationType
{
    USPrimitiveType *type = [[USPrimitiveType alloc] initWithName:name prefix:prefix];
    type.representationType = representationType;
    return type;
}

+ (instancetype)enumTypeWithName:(NSString *)name prefix:(NSString *)prefix
                          values:(NSArray *)values
{
    USEnumType *type = [[USEnumType alloc] initWithName:name prefix:prefix];
    type.enumValues = values;
    return type;
}

+ (instancetype)arrayTypeWithName:(NSString *)name prefix:(NSString *)prefix choices:(NSArray *)choices {
    USArrayType *type = [[USArrayType alloc] initWithName:name prefix:prefix];
    type.choices = choices;
    return type;
}

+ (instancetype)choiceTypeWithName:(NSString *)name prefix:(NSString *)prefix choices:(NSArray *)choices {
    USChoiceType *type = [[USChoiceType alloc] initWithName:name prefix:prefix];
    type.choices = choices;
    return type;
}

+ (instancetype)complexTypeWithName:(NSString *)name prefix:(NSString *)prefix
                           elements:(NSArray *)elements attributes:(NSArray *)attributes base:(USType *)base
{
    USComplexType *type = [[USComplexType alloc] initWithName:name prefix:prefix];
    type.sequenceElements = elements;
    type.attributes = attributes;
    type.superClass = base;
    return type;
}

- (NSString *)className {
    return [NSString stringWithFormat:@"%@_%@",
            self.prefix, [self.typeName stringByRemovingIllegalCharacters]];
}

- (NSString *)factoryClassName {
    return nil;
}

- (NSString *)variableTypeName {
    return [NSString stringWithFormat:@"%@_%@ *",
            self.prefix, [self.typeName stringByRemovingIllegalCharacters]];
}
- (NSString *)templateFileHPath {
    return nil;
}

- (NSString *)templateFileMPath {
    return nil;
}

- (USComplexType *)asComplex {
    return nil;
}

- (NSNumber *)isEnum {
    return @NO;
}

- (NSMutableDictionary *)templateKeyDictionary {
	NSMutableDictionary *ret = [NSMutableDictionary dictionary];
	ret[@"className"] = self.className;
	ret[@"typeName"] = self.typeName;
	ret[@"prefix"] = self.prefix;
    if (self.factoryClassName)
        ret[@"factoryClassName"] = self.factoryClassName;
	ret[@"variableTypeName"] = self.variableTypeName;
	ret[@"isEnum"] = self.isEnum;
    return ret;
}

- (instancetype)deriveWithName:(NSString *)newTypeName prefix:(NSString *)newTypePrefix {
    return nil;
}
@end

@implementation USProxyType
- (instancetype)initWithName:(NSString *)typeName {
    self.typeName = typeName;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.type methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.type];
}

- (BOOL)respondsToSelector:(SEL)sel {
    return [self.type respondsToSelector:sel];
}
@end
