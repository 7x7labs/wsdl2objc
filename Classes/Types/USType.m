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

#import "USObjCKeywords.h"
#import "USSchema.h"
#import "USWSDL.h"
#import "NSBundle+USAdditions.h"

@implementation USType

#pragma mark Global type methods
@synthesize typeName;
@synthesize schema;
@synthesize behavior;
@synthesize hasBeenParsed;
@synthesize hasBeenWritten;

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
    [typeName release];
    [representationClass release];
    [enumerationValues release];
    [superClass release];
    [sequenceElements release];
    [attributes release];
    [super dealloc];
}

- (BOOL)isSimpleType
{
	return (self.behavior == TypeBehavior_simple);
}

- (BOOL)isComplexType
{
	return (self.behavior == TypeBehavior_complex);
}

- (NSString *)isSimpleTypeString
{
	return [self isSimpleType] ? @"true" : @"false";
}

- (NSString *)isComplexTypeString
{
	return [self isComplexType] ? @"true" : @"false";
}

- (NSString *)className
{
	
	if([schema prefix] != nil) {
		if(self.behavior == TypeBehavior_simple && [self.representationClass length] > 0 && [self.enumerationValues count] == 0) {
			return self.representationClass;
		}
		return [NSString stringWithFormat:@"%@_%@", [schema prefix], [[self.typeName componentsSeparatedByCharactersInSet:kIllegalClassCharactersSet] componentsJoinedByString:@""]];
	}
	
	return [[self.typeName componentsSeparatedByCharactersInSet:kIllegalClassCharactersSet] componentsJoinedByString:@""];
}

- (NSString *)classNameWithPtr
{
	if([self isSimpleType]) {
		return [self className];
	} else if([self isComplexType]) {
		return [NSString stringWithFormat:@"%@ *", [self className]];
	}
	
	return self.typeName;
}

- (NSString *)classNameWithoutPtr
{
	return [[self className] stringByReplacingOccurrencesOfString:@" *" withString:@""];
}

- (NSString *)assignOrRetain
{
	if(self.behavior == TypeBehavior_simple) {
		if([[self classNameWithPtr] rangeOfString:@"*" options:NSLiteralSearch].location == NSNotFound) {
			return @"assign";
		}
	}
	
	return @"retain";
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
			break;
		case TypeBehavior_complex:
			return [[NSBundle mainBundle] pathForTemplateNamed:@"ComplexType_H"];
			break;
			
		default:
			return nil;
	}
}

- (NSString *)templateFileMPath
{
	switch (self.behavior) {
		case TypeBehavior_simple:
			return [[NSBundle mainBundle] pathForTemplateNamed:@"SimpleType_M"];
			break;
			
		case TypeBehavior_complex:
			return [[NSBundle mainBundle] pathForTemplateNamed:@"ComplexType_M"];
			break;
			
		default:
			return nil;
	}
}

- (NSDictionary *)templateKeyDictionary
{
	NSMutableDictionary *returning = [NSMutableDictionary dictionary];
	[returning setObject:[self className] forKey:@"className"];
	[returning setObject:schema forKey:@"schema"];
	[returning setObject:typeName forKey:@"typeName"];
	[returning setObject:[self classNameWithPtr] forKey:@"classNameWithPtr"];
	[returning setObject:[self classNameWithoutPtr] forKey:@"classNameWithoutPtr"];
	BOOL needsSuperElements = NO;
	
	switch (self.behavior) {
		case TypeBehavior_simple:
			
			if(representationClass != nil) [returning setObject:self.representationClass forKey:@"representationClass"];
			[returning setObject:self.enumerationValues forKey:@"enumerationValues"];
			[returning setObject:[self enumCount] forKey:@"enumCount"];			
			
			break;
			
		case TypeBehavior_complex:
			if(superClass != nil) {
				[returning setObject:superClass forKey:@"superClass"];
				[returning setObject:([superClass isComplexType] ? @"true" : @"false") forKey:@"superClassIsComplex"];
				USType *tempParent = superClass;
				while (tempParent != nil) {
					if ([tempParent.sequenceElements count] > 0) {
						needsSuperElements = YES;
					}
					tempParent = tempParent.superClass;
				}
			}
			[returning setObject:sequenceElements forKey:@"sequenceElements"];
			[returning setObject:(([sequenceElements count] > 0 || needsSuperElements) ? @"true" : @"false") forKey:@"hasSequenceElements"];
			[returning setObject:attributes forKey:@"attributes"];
			[returning setObject:([attributes count] > 0 ? @"true" : @"false") forKey:@"hasAttributes"];
			[returning setObject:([schema.fullName isEqualToString:schema.wsdl.targetNamespace.fullName] ? @"true" : @"false")
						  forKey:@"isInTargetNamespace"];			
			break;
			
		default:
			break;
	}
	
	return returning;
}



#pragma mark Simple type methods
@synthesize representationClass;
@synthesize enumerationValues;


#pragma mark Complex type methods
@synthesize superClass;
@synthesize sequenceElements;
@synthesize attributes;

@end
