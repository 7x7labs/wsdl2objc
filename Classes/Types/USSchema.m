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

#import "USObjCKeywords.h"
#import "USSchema.h"
#import "USType.h"
#import "USElement.h"
#import "USAttribute.h"
#import "USMessage.h"
#import "USPortType.h"
#import "USBinding.h"
#import "USService.h"
#import "NSBundle+USAdditions.h"

@implementation USSchema

@synthesize fullName;
@synthesize prefix;
@synthesize localPrefix;
@synthesize types;
@synthesize elements;
@synthesize attributes;
@synthesize imports;
@synthesize messages;
@synthesize portTypes;
@synthesize bindings;
@synthesize services;
@synthesize wsdl;
@synthesize hasBeenParsed;
@synthesize hasBeenWritten;

- (id)initWithWSDL:(USWSDL *)aWsdl
{
	if((self = [super init]))
	{
		self.fullName = @"";
		self.prefix = nil;
		self.localPrefix = nil;
		self.types = [NSMutableArray array];
		self.elements = [NSMutableArray array];
		self.attributes = [NSMutableArray array];
		self.imports = [NSMutableArray array];
		self.messages = [NSMutableArray array];
		self.portTypes = [NSMutableArray array];
		self.bindings = [NSMutableArray array];
		self.services = [NSMutableArray array];
		self.wsdl = aWsdl;
		self.hasBeenParsed = NO;
		self.hasBeenWritten = NO;
	}
	return self;
}


- (void)dealloc
{
	[fullName release];
    [prefix release];
    [localPrefix release];
	[types release];
	[elements release];
	[attributes release];
	[imports release];
	[messages release];
	[portTypes release];
	[bindings release];
	[services release];
	[super dealloc];
}

- (USType *)typeForName:(NSString *)aName
{
	if(aName == nil) return nil;
	
	for(USType * type in self.types) {
		if([type.typeName isEqualToString:aName]) {
			// NSLog(@"Found Type: %@ (%@)", type.typeName, type);
			return type;
		}
	}
	
	USType *newType = [USType new];
	newType.typeName = aName;
	newType.schema = self;
	
	[self.types addObject:newType];
    [newType release];
	
	// NSLog(@"New Type: %@ (%@)", newType.typeName, newType);
	return newType;
}

- (USElement *)elementForName:(NSString *)aName
{
	if(aName == nil) return nil;
	
	USObjCKeywords *keywords = [USObjCKeywords sharedInstance];
	if([keywords isAKeyword:aName]) {
		aName = [NSString stringWithFormat:@"%@_", aName];
	}
	
	for(USElement * element in self.elements) {
		if([element.name isEqual:aName]) {
			// NSLog(@"Found Element: %@ (%@), type: %@ (%@)", element.name, element, element.type.typeName, element.type);
			return element;
		}
	}
	
	USElement *newElement = [USElement new];
	newElement.name = aName;
	newElement.schema = self;
	
	[self.elements addObject:newElement];
    [newElement release];
	
	// NSLog(@"New Element: %@ (%@), type: %@ (%@)", newElement.name, newElement, newElement.type.typeName, newElement.type);
	return newElement;
}

- (USAttribute *)attributeForName:(NSString *)aName
{
	if(aName == nil) return nil;

	USObjCKeywords *keywords = [USObjCKeywords sharedInstance];
	if([keywords isAKeyword:aName]) {
		aName = [NSString stringWithFormat:@"%@_", aName];
	}
		
	for(USAttribute * attribute in self.attributes) {
		if([attribute.name isEqual:aName]) {
			// NSLog(@"Found attribute: %@ (%@), type: %@ (%@)", attribute.name, attribute, attribute.type.typeName, attribute.type);
			return attribute;
		}
	}
	
	USAttribute *newAttribute = [USAttribute new];
	newAttribute.name = aName;
	newAttribute.schema = self;
	
	[self.attributes addObject:newAttribute];
    [newAttribute release];
	
	// NSLog(@"New attribute: %@ (%@), type: %@ (%@)", newattribute.name, newattribute, newattribute.type.typeName, newattribute.type);
	return newAttribute;
}

- (USMessage *)messageForName:(NSString *)aName
{
	if(aName == nil) return nil;
	
	for(USMessage *message in self.messages) {
		if([message.name isEqualToString:aName]) {
			return message;
		}
	}
	
	USMessage *newMessage = [USMessage new];
	newMessage.schema = self;
	newMessage.name = aName;
	[self.messages addObject:newMessage];
    [newMessage release];
	
	return newMessage;
}

- (USPortType *)portTypeForName:(NSString *)aName
{
	if(aName == nil) return nil;
	
	for(USPortType *portType in self.portTypes) {
		if([portType.name isEqualToString:aName]) {
			return portType;
		}
	}
	
	USPortType *newPortType = [USPortType new];
	newPortType.schema = self;
	newPortType.name = aName;
	[self.portTypes addObject:newPortType];
    [newPortType release];
	
	return newPortType;
}

- (USBinding *)bindingForName:(NSString *)aName
{
	if(aName == nil) return nil;
	
	for(USBinding *binding in self.bindings) {
		if([binding.name isEqualToString:aName]) {
			return binding;
		}
	}
	
	USBinding *newBinding = [USBinding new];
	newBinding.schema = self;
	newBinding.name = aName;
	[self.bindings addObject:newBinding];
    [newBinding release];
	
	return newBinding;
}

- (USService *)serviceForName:(NSString *)aName
{
	if(aName == nil) return nil;
	
	for(USService *service in self.services) {
		if([service.name isEqualToString:aName]) {
			return service;
		}
	}
	
	USService *newService = [USService new];
	newService.schema = self;
	newService.name = aName;
	[self.services addObject:newService];
    [newService release];
	
	return newService;
}

- (void)addSimpleClassWithName:(NSString *)aName representationClass:(NSString *)aClass
{
	USType *type = [self typeForName:aName];
	type.behavior = TypeBehavior_simple;
	type.representationClass = aClass;
	type.hasBeenParsed = YES;
}

- (void)addComplexClassWithName:(NSString *)aName representationClass:(NSString *)aClass
{
	USType *type = [self typeForName:aName];
	type.behavior = TypeBehavior_complex;
	[self addSimpleClassWithName:aClass representationClass:aClass];
	USType *baseType = [self typeForName:aClass];
	type.superClass = baseType;
	type.hasBeenParsed = YES;
}

- (BOOL)shouldNotWrite
{
	if([self.types count] == 0 &&
	   [self.elements count] == 0 &&
	   [self.imports count] == 0 &&
	   [self.bindings count] == 0 &&
	   [self.services count] == 0) return YES;
	
	return NO;
}

- (NSString *)shouldNotWriteString
{
	return ([self shouldNotWrite] ? @"true" : @"false");
}

- (NSString *)templateFileHPath
{
	return [[NSBundle mainBundle] pathForTemplateNamed:@"Schema_H"];
}

- (NSString *)templateFileMPath
{
	return [[NSBundle mainBundle] pathForTemplateNamed:@"Schema_M"];
}

- (NSDictionary *)templateKeyDictionary
{
	NSMutableDictionary *returning = [NSMutableDictionary dictionary];
	
	[returning setObject:self.fullName forKey:@"fullName"];
	[returning setObject:self.prefix forKey:@"prefix"];
	[returning setObject:[[NSNumber numberWithUnsignedInt:[self.types count]] stringValue] forKey:@"typeCount"];
	[returning setObject:self.imports forKey:@"imports"];
	[returning setObject:self.types forKey:@"types"];
	[returning setObject:self.wsdl forKey:@"wsdl"];
	
	return returning;
}

@end
