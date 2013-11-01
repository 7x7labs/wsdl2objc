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
#import "USObjCKeywords.h"
#import "USSchema.h"
#import "USSequenceElement.h"
#import "USWSDL.h"

@implementation USType

- (id)init
{
	if((self = [super init]))
	{
		self.typeName = @"";
		self.schema = nil;
		self.behavior = TypeBehavior_uninitialized;
		self.hasBeenParsed = NO;
		self.hasBeenWritten = NO;
		
		self.representationClass = @"";
		self.enumerationValues = [NSMutableArray array];
		
		self.superClass = nil;
		self.sequenceElements = [NSMutableArray array];
		self.attributes = [NSMutableArray array];
	}
	return self;
}

- (void) dealloc
{
	[_typeName release];
	[_representationClass release];
	[_enumerationValues release];
	[_superClass release];
	[_sequenceElements release];
	[_attributes release];
	[super dealloc];
}

- (BOOL)isSimpleType
{
	return self.behavior == TypeBehavior_simple;
}

- (BOOL)isComplexType
{
	return self.behavior == TypeBehavior_complex;
}

- (NSString *)className
{
	if([self.schema prefix]) {
		if (self.isSimpleType && [self.representationClass length] && [self.enumerationValues count] == 0) {
			return self.representationClass;
		}
		return [NSString stringWithFormat:@"%@_%@",
				[self.schema prefix],
				[[self.typeName componentsSeparatedByCharactersInSet:kIllegalClassCharactersSet]
				 componentsJoinedByString:@""]];
	}
	
	return [[self.typeName componentsSeparatedByCharactersInSet:kIllegalClassCharactersSet] componentsJoinedByString:@""];
}

- (NSString *)classNameWithPtr
{
	if (self.isSimpleType)
		return [self className];
	if (self.isComplexType)
		return [NSString stringWithFormat:@"%@ *", [self className]];

	return self.typeName;
}

- (NSString *)classNameWithoutPtr
{
	return [[self className] stringByReplacingOccurrencesOfString:@" *" withString:@""];
}

- (NSString *)assignOrRetain
{
	if (self.isSimpleType) {
		if ([[self className] rangeOfString:@"*" options:NSLiteralSearch].location == NSNotFound) {
			return @"weak";
		}
	}
	
	return @"strong";
}

- (NSString *)enumCount
{
	return [[NSNumber numberWithUnsignedInt:[self.enumerationValues count]] stringValue];
}

- (NSString *)templateFileHPath
{
	switch (self.behavior) {
		case TypeBehavior_simple:
			return [[NSBundle mainBundle] pathForTemplateNamed:@"SimpleType_H"];
		case TypeBehavior_complex:
			return [[NSBundle mainBundle] pathForTemplateNamed:@"ComplexType_H"];
		default:
			return nil;
	}
}

- (NSString *)templateFileMPath
{
	switch (self.behavior) {
		case TypeBehavior_simple:
			return [[NSBundle mainBundle] pathForTemplateNamed:@"SimpleType_M"];
		case TypeBehavior_complex:
			return [[NSBundle mainBundle] pathForTemplateNamed:@"ComplexType_M"];
		default:
			return nil;
	}
}

- (NSDictionary *)templateKeyDictionary
{
	NSMutableDictionary *returning = [NSMutableDictionary dictionary];
	returning[@"className"] = [self className];
	returning[@"schema"] = self.schema;
	returning[@"typeName"] = self.typeName;
	returning[@"classNameWithPtr"] = [self classNameWithPtr];
	returning[@"classNameWithoutPtr"] = [self classNameWithoutPtr];

	switch (self.behavior) {
		case TypeBehavior_simple:
			if (self.representationClass) returning[@"representationClass"] = self.representationClass;
			returning[@"enumerationValues"] = self.enumerationValues;
			returning[@"enumCount"] = [self enumCount];
			break;

		case TypeBehavior_complex: {
			if (self.superClass) {
				returning[@"superClass"] = self.superClass;
				returning[@"superClassIsComplex"] = @([self.superClass isComplexType]);
				for (USType *tempParent = self.superClass; tempParent; tempParent = tempParent.superClass) {
					if ([tempParent.sequenceElements count] > 0)
						returning[@"hasSuperElements"] = @YES;
					if ([tempParent.attributes count] > 0)
						returning[@"hasSuperAttributes"] = @YES;
				}
			}
			returning[@"sequenceElements"] = self.sequenceElements ?: @[];
			returning[@"hasSequenceElements"] = @([self.sequenceElements count]);
			returning[@"hasArraySequenceElements"] = @NO;
			returning[@"attributes"] = self.attributes ?: @[];
			returning[@"hasAttributes"] = @([self.attributes count] > 0);
			returning[@"isInTargetNamespace"] = @([self.schema.fullName isEqualToString:self.schema.wsdl.targetNamespace.fullName]);

			for (USSequenceElement *element in self.sequenceElements) {
				if (element.maxOccurs < 0 || element.maxOccurs > 1) {
					returning[@"hasArraySequenceElements"] = @YES;
					break;
				}
			}
			break;
		}

		default:
			break;
	}

	return returning;
}

@end
