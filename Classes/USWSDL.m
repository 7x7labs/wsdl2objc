/*
 Copyright (c) 2008 LightSPEED Technologies, Inc.
 Modified by Matthew Faupel on 2009-05-06 to use NSDate instead of NSCalendarDate (for iPhone compatibility).
 Modifications copyright (c) 2009 Micropraxis Ltd.

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

#import "USWSDL.h"

#import "USAttribute.h"
#import "USSchema.h"

@interface USWSDL ()
@property (nonatomic, strong) NSMutableDictionary *schemaPrefixes;
@end

@implementation USWSDL
- (id)init {
	if (!(self = [super init])) return nil;

    self.schemas = [NSMutableDictionary new];
    self.schemaPrefixes = [NSMutableDictionary new];

    USSchema *xsd = [self createSchemaForNamespace:@"http://www.w3.org/2001/XMLSchema" prefix:@"xsd"];
	[xsd addSimpleClassWithName:@"boolean" representationClass:@"NSNumber *"];
	[xsd addSimpleClassWithName:@"byte" representationClass:@"NSNumber *"];
	[xsd addSimpleClassWithName:@"int" representationClass:@"NSNumber *"];
	[xsd addSimpleClassWithName:@"integer" representationClass:@"NSNumber *"];
	[xsd addSimpleClassWithName:@"nonNegativeInteger" representationClass:@"NSNumber *"];
	[xsd addSimpleClassWithName:@"positiveInteger" representationClass:@"NSNumber *"];
	[xsd addSimpleClassWithName:@"unsignedByte" representationClass:@"NSNumber *"];
	[xsd addSimpleClassWithName:@"unsignedInt" representationClass:@"NSNumber *"];
	[xsd addSimpleClassWithName:@"unsignedLong" representationClass:@"NSNumber *"];
	[xsd addSimpleClassWithName:@"unsignedShort" representationClass:@"NSNumber *"];
	[xsd addSimpleClassWithName:@"double" representationClass:@"NSNumber *"];
	[xsd addSimpleClassWithName:@"long" representationClass:@"NSNumber *"];
	[xsd addSimpleClassWithName:@"short" representationClass:@"NSNumber *"];
	[xsd addSimpleClassWithName:@"float" representationClass:@"NSNumber *"];
	[xsd addSimpleClassWithName:@"dateTime" representationClass:@"NSDate *"];
	[xsd addSimpleClassWithName:@"date" representationClass:@"NSDate *"];
	[xsd addSimpleClassWithName:@"time" representationClass:@"NSDate *"];
	[xsd addSimpleClassWithName:@"duration" representationClass:@"NSDate *"];
	[xsd addSimpleClassWithName:@"base64Binary" representationClass:@"NSData *"];
	[xsd addSimpleClassWithName:@"decimal" representationClass:@"NSDecimalNumber *"];
	[xsd addSimpleClassWithName:@"QName" representationClass:@"NSString *"];
	[xsd addSimpleClassWithName:@"anyURI" representationClass:@"NSString *"];
	[xsd addSimpleClassWithName:@"string" representationClass:@"NSString *"];
	[xsd addSimpleClassWithName:@"normalizedString" representationClass:@"NSString *"];
	[xsd addSimpleClassWithName:@"token" representationClass:@"NSString *"];
	[xsd addSimpleClassWithName:@"language" representationClass:@"NSString *"];
	[xsd addSimpleClassWithName:@"Name" representationClass:@"NSString *"];
	[xsd addSimpleClassWithName:@"NCName" representationClass:@"NSString *"];
	[xsd addSimpleClassWithName:@"anyType" representationClass:@"NSString *"];
	[xsd addSimpleClassWithName:@"ID" representationClass:@"NSString *"];
	[xsd addSimpleClassWithName:@"ENTITY" representationClass:@"NSString *"];
	[xsd addSimpleClassWithName:@"IDREF" representationClass:@"NSString *"];
	[xsd addSimpleClassWithName:@"NMTOKEN" representationClass:@"NSString *"];

    USSchema *xml = [self createSchemaForNamespace:@"http://www.w3.org/XML/1998/namespace" prefix:@"xml"];
    USAttribute *attr = [USAttribute new];
    attr.name = @"lang";
    attr.wsdlName = @"lang";
    attr.type = xsd.types[@"string"];
    [xml registerAttribute:attr];

	return self;
}

- (USSchema *)createSchemaForNamespace:(NSString *)xmlNS prefix:(NSString *)prefix {
    USSchema *schema = [[USSchema alloc] initWithWSDL:self];
    schema.fullName = xmlNS;
    schema.prefix = prefix;
    for (int i = 2; self.schemaPrefixes[schema.prefix]; ++i)
        schema.prefix = [NSString stringWithFormat:@"%@%d", prefix, i];

    assert(!self.schemas[xmlNS]);
    self.schemas[xmlNS] = schema;
    self.schemaPrefixes[schema.prefix] = schema;
    return schema;
}

- (USSchema *)schemaForPrefix:(NSString *)prefix {
    return self.schemaPrefixes[prefix];
}

- (NSDictionary *)templateKeyDictionary {
    return @{@"schemas": [self.schemas allValues]};
}

@end
