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

#import "USParser+Types.h"
#import "USObjCKeywords.h"
#import "STSStringOps.h"

#import "USWSDL.h"
#import "USSchema.h"
#import "USType.h"
#import "USSequenceElement.h"
#import "USAttribute.h"
#import "USElement.h"

@implementation USParser (Types)

#pragma mark Types
- (void)processTypesElement:(NSXMLElement *)el wsdl:(USWSDL *)wsdl
{
	for(NSXMLNode *child in [el children]) {
		if([child kind] == NSXMLElementKind) {
			[self processTypesChildElement:(NSXMLElement*)child wsdl:wsdl];
		}
	}
}

- (void)processTypesChildElement:(NSXMLElement *)el wsdl:(USWSDL *)wsdl
{
	NSString *localName = [el localName];
	
	if([localName isEqualToString:@"schema"]) {
		[self processSchemaElement:el wsdl:wsdl];
	} else if([localName isEqualToString:@"import"]) {
		[self processImportElement:el wsdl:wsdl];
	}
}

#pragma mark Types:Schema:SimpleType
- (void)processSimpleTypeElement:(NSXMLElement *)el schema:(USSchema *)schema
{
	NSString *typeName = [[el attributeForName:@"name"] stringValue];
	
	USType *type = [schema typeForName:typeName];
	
	if(!type.hasBeenParsed) {
		type.behavior = TypeBehavior_simple;
		
		for(NSXMLNode *child in [el children]) {
			if([child kind] == NSXMLElementKind) {
				[self processSimpleTypeChildElement:(NSXMLElement*)child type:type];
			}
		}
		
		type.hasBeenParsed = YES;
	}
}

- (void)processSimpleTypeChildElement:(NSXMLElement *)el type:(USType *)type
{
	NSString *localName = [el localName];
	
	if([localName isEqualToString:@"restriction"]) {
		[self processRestrictionElement:el type:type];
	} else if([localName isEqualToString:@"union"]) {
		[self processUnionElement:el type:type];
	} else if([localName isEqualToString:@"list"]) {
		[self processListElement:el type:type];
	}
}

- (void)processUnionElement:(NSXMLElement *)el type:(USType *)type {
	// TODO:	properly support union.
	type.representationClass = @"NSString *";
	NVLOG(@"TYPE IS: %@, %@", type.typeName, type.representationClass);
}

- (void)processListElement:(NSXMLElement *)el type:(USType *)type {
	type.representationClass = @"NSString *";
	NVLOG(@"TYPE IS: %@, %@", type.typeName, type.representationClass);
}

- (void)processRestrictionElement:(NSXMLElement *)el type:(USType *)type
{
	NSString *base = [[el attributeForName:@"base"] stringValue];
	
	NSString *uri = [[el resolveNamespaceForName:base] stringValue];
	NSString *name = [NSXMLNode localNameForName:base];
	
	USSchema *schema = type.schema;
	USWSDL *wsdl = schema.wsdl;
	
	USType *baseType = [wsdl typeForNamespace:uri name:name];
	if(baseType == nil) {
		type.representationClass = base;
	} else {
		if([baseType isSimpleType]) {
			type.representationClass = baseType.representationClass;
		}
	}
	
	for(NSXMLNode *child in [el children]) {
		if([child kind] == NSXMLElementKind) {
			[self processRestrictionChildElement:(NSXMLElement*)child type:type];
		}
	}
}

- (void)processRestrictionChildElement:(NSXMLElement *)el type:(USType *)type
{
	NSString *localName = [el localName];
	
	if([localName isEqualToString:@"enumeration"]) {
		[self processEnumerationElement:el type:type];
	}
}

- (void)processEnumerationElement:(NSXMLElement *)el type:(USType *)type
{
	NSString *enumerationValue = [[el attributeForName:@"value"] stringValue];
	// Get rid of the useless current local prefix if it exists
	NSString *localPrefix = [[[type schema] localPrefix] stringByAppendingString:@":"];
	if (localPrefix && [enumerationValue hasPrefix:localPrefix]) {
		enumerationValue = [enumerationValue substringFromIndex:[localPrefix length]];
	}
	enumerationValue = [enumerationValue stringByReplacingOccurrencesOfString:@" " withString:@"_"];
	enumerationValue = [enumerationValue stringByReplacingOccurrencesOfString:@":" withString:@"_"];
	[type.enumerationValues addObject:[[enumerationValue componentsSeparatedByCharactersInSet:kIllegalClassCharactersSet] componentsJoinedByString:@""]];
}

#pragma mark Types:Schema:ComplexType
- (void)processComplexTypeElement:(NSXMLElement *)el schema:(USSchema *)schema
{
	NSString *typeName = [[el attributeForName:@"name"] stringValue];
	
	USType *type = [schema typeForName:typeName];
	
	if(!type.hasBeenParsed) {
		type.behavior = TypeBehavior_complex;
		
		for(NSXMLNode *child in [el children]) {
			if([child kind] == NSXMLElementKind) {
				[self processComplexTypeChildElement:(NSXMLElement*)child type:type];
			}
		}
		
		type.hasBeenParsed = YES;
	}
}

- (void)processComplexTypeChildElement:(NSXMLElement *)el type:(USType *)type
{
	NSString *localName = [el localName];
	
	if(([localName isEqualToString:@"sequence"]) ||
	   ([localName isEqualToString:@"choice"]) ||
	   ([localName isEqualToString:@"any"])){
		// TODO: Actually support choice and any with the proper templates
		[self processSequenceElement:el type:type];
	} else if([localName isEqualToString:@"attribute"]) {
		[self processAttributeElement:el schema:nil type:type];
	} else if([localName isEqualToString:@"complexContent"]) {
		[self processComplexContentElement:el type:type];
	} else if([localName isEqualToString:@"simpleContent"]) {
		[self processSimpleContentElement:el type:type];
	}
}

- (void)processSequenceElement:(NSXMLElement *)el type:(USType *)type
{
	NVLOG(@"PROCESSING SEQ/CHOICE/ANY: %@ (%@)", el.name, [[el parent] name]);
	for(NSXMLNode *child in [el children]) {
		NSString *localName = [child localName];
		if(([localName isEqualToString:@"sequence"]) ||
		   ([localName isEqualToString:@"choice"]) ||
		   ([localName isEqualToString:@"any"])){
			// don't properly handle choice and any yet, but encompass all their elements
			// into the sequence as if it were one big sequence
			[self processSequenceElement:(NSXMLElement*)child type:type];
		}
		if([child kind] == NSXMLElementKind) {
			[self processSequenceChildElement:(NSXMLElement*)child type:type];
		}
	}
}

- (void)processSequenceChildElement:(NSXMLElement *)el type:(USType *)type
{
	NVLOG(@"PROCESSING: %@ (%@)", el.name, [[el parent] name]);
	NSString *localName = [el localName];
	
	if([localName isEqualToString:@"element"]) {
		[self processSequenceElementElement:el type:type];
	}
}

- (void)processSequenceElementElement:(NSXMLElement *)el type:(USType *)type
{
	USSequenceElement *seqElement = [USSequenceElement new];
	
	NSXMLNode *refNode = [el attributeForName:@"ref"];
	if(refNode != nil) {
		
		NSString *elementQName = [refNode stringValue];
		NSString *elementURI = [[el resolveNamespaceForName:elementQName] stringValue];
		NSString *elementLocalName = [NSXMLNode localNameForName:elementQName];
		
		USSchema *schema = [type.schema.wsdl schemaForNamespace:elementURI];
		USElement *element = [schema elementForName:elementLocalName];
		
		if(element.hasBeenParsed) {
			seqElement.name = element.name;
			seqElement.type = element.type;
			NVLOG(@"REF PARSED SEQELEMENT NAME: %@ (%@)", element.name, [[el parent] name]);
		} else {
			// the sequence element name and type will be assigned after its referring element is parsed
			[element.waitingSeqElements addObject:seqElement];
			NVLOG(@"REF NOT PARSED SEQELEMENT NAME: %@ (%@)", element.name, [[el parent] name]);
		}		
		
	} else {
		
		NSString *name = [[[[el attributeForName:@"name"] stringValue] componentsSeparatedByCharactersInSet:kIllegalClassCharactersSet] componentsJoinedByString:@""];
		seqElement.name = name;
		NVLOG(@"SEQELEMENT NAME: %@ (%@)", name, [[[el parent] parent] name]);
		
		NSString *prefixedType = [[el attributeForName:@"type"] stringValue];
		if (prefixedType == nil) {
			// The type is inline, as a subnode <complexType> or <simpleType>
			prefixedType = name;
			NSUInteger childIdx = 0;
			for(NSXMLNode *child in [el children]) {			
				if([[child localName] hasSuffix:@"Type"]) {
					// We found the type definition. Let's give it the element's name and send it over to the processor
					[(NSXMLElement*)child addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:prefixedType]];
					[self processSchemaChildElement:(NSXMLElement*)child schema:type.schema];
					// and now re-process the element itself with the correct type
					// using the original local prefix because we're back in a local scope still
					NSString *elType = [type.schema.localPrefix stringByAppendingFormat:@":%@", prefixedType];
					[el addAttribute:[NSXMLNode attributeWithName:@"type" stringValue:elType]];
					[el removeChildAtIndex:childIdx];
					NVLOG(@"*** Reprocessing a type: %@", elType);
					[self processSequenceElementElement:el type:type];
                    [seqElement release];
					return;
				}
				childIdx++;
			}			
		}
		NSString *uri = [[el resolveNamespaceForName:prefixedType] stringValue];
		NSString *typeName = [NSXMLNode localNameForName:prefixedType];
		seqElement.type = [type.schema.wsdl typeForNamespace:uri name:typeName];
	}
	
	NSXMLNode *minOccursNode = [el attributeForName:@"minOccurs"];
	if(minOccursNode != nil) {
		seqElement.minOccurs = [[minOccursNode stringValue] intValue];
	} else {
		seqElement.minOccurs = 0;
	}
	
	NSXMLNode *maxOccursNode = [el attributeForName:@"maxOccurs"];
	if(maxOccursNode != nil) {
		NSString *maxOccursValue = [maxOccursNode stringValue];
		
		if([maxOccursValue isEqualToString:@"unbounded"]) {
			seqElement.maxOccurs = -1;
		} else {
			seqElement.maxOccurs = [maxOccursValue intValue];
		}
	} else {
		seqElement.maxOccurs = 0;
	}
	
	[type.sequenceElements addObject:seqElement];
    [seqElement release];
}

- (void)processComplexContentElement:(NSXMLElement *)el type:(USType *)type
{
	for(NSXMLNode *child in [el children]) {
		if([child kind] == NSXMLElementKind) {
			[self processComplexContentChildElement:(NSXMLElement*)child type:type];
		}
	}
}

- (void)processComplexContentChildElement:(NSXMLElement *)el type:(USType *)type
{
	NSString *localName = [el localName];
	
	if([localName isEqualToString:@"extension"]) {
		[self processExtensionElement:el type:type];
	}
}

- (void)processSimpleContentElement:(NSXMLElement *)el type:(USType *)type
{
	for(NSXMLNode *child in [el children]) {
		if([child kind] == NSXMLElementKind) {
			[self processSimpleContentChildElement:(NSXMLElement*)child type:type];
		}
	}
}

- (void)processSimpleContentChildElement:(NSXMLElement *)el type:(USType *)type
{
	NSString *localName = [el localName];
	
	if([localName isEqualToString:@"extension"]) {
		[self processExtensionElement:el type:type];
	}
}

- (void)processExtensionElement:(NSXMLElement *)el type:(USType *)type
{
	NSString *prefixedType = [[el attributeForName:@"base"] stringValue];
	NSString *uri = [[el resolveNamespaceForName:prefixedType] stringValue];
	NSString *typeName = [NSXMLNode localNameForName:prefixedType];
	USType *baseType = [type.schema.wsdl typeForNamespace:uri name:typeName];
	
	type.superClass = baseType;
	
	for(NSXMLNode *child in [el children]) {
		if([child kind] == NSXMLElementKind) {
			[self processExtensionChildElement:(NSXMLElement*)child type:type];
		}
	}
}

- (void)processExtensionChildElement:(NSXMLElement *)el type:(USType *)type
{
//	NSLog(@"Processing extension: %@", [el description]);
	[self processComplexTypeChildElement:el type:type];
}

#pragma mark Types:Schema:Element
- (void)processElementElement:(NSXMLElement *)el schema:(USSchema *)schema
{
	NSString *elementName = [[el attributeForName:@"name"] stringValue];
	USElement *element = [schema elementForName:elementName];
	
	if(!element.hasBeenParsed) {
		NSString *prefixedType = [[el attributeForName:@"type"] stringValue];
		
		if(prefixedType != nil) {
			NSString *uri = [[el resolveNamespaceForName:prefixedType] stringValue];
			NSString *typeName = [NSXMLNode localNameForName:prefixedType];
			USType *type = [schema.wsdl typeForNamespace:uri name:typeName];
			element.type = type;
			
		} else {
			for(NSXMLNode *child in [el children]) {
				if([child kind] == NSXMLElementKind) {
					[self processElementElementChildElement:(NSXMLElement*)child element:element];
				}
			}
		}
		
		for(USSequenceElement *seqElement in element.waitingSeqElements) {
			// NSLog(@"Assigning %@ for %@", element.name, seqElement);
			seqElement.name = element.name;
			seqElement.type = element.type;
		}
		element.hasBeenParsed = YES;
	}
}

- (void)processElementElementChildElement:(NSXMLElement *)el element:(USElement *)element
{
	NSString *localName = [el localName];
	
	if([localName isEqualToString:@"simpleType"]) {
		[self processElementElementSimpleTypeElement:el element:element];
	} else if([localName isEqualToString:@"complexType"]) {
		[self processElementElementComplexTypeElement:el element:element];
	}
}

- (void)processElementElementSimpleTypeElement:(NSXMLElement *)el element:(USElement *)element
{
	USType *type = [element.schema typeForName:element.name];
	
	if(!type.hasBeenParsed) {
		type.behavior = TypeBehavior_simple;
		
		for(NSXMLNode *child in [el children]) {
			if([child kind] == NSXMLElementKind) {
				[self processSimpleTypeChildElement:(NSXMLElement*)child type:type];
			}
		}
		type.hasBeenParsed = YES;
	}
	// assign the inline definition to its parent element
	element.type = type;
}

- (void)processElementElementComplexTypeElement:(NSXMLElement *)el element:(USElement *)element
{
	USType *type = [element.schema typeForName:element.name];
	
	if(!type.hasBeenParsed) {
		type.behavior = TypeBehavior_complex;
		
		for(NSXMLNode *child in [el children]) {
			if([child kind] == NSXMLElementKind) {
				[self processComplexTypeChildElement:(NSXMLElement*)child type:type];
			}
		}
          
		type.hasBeenParsed = YES;
	}
	// assign the inline definition to its parent element
	element.type = type;
}

#pragma mark Types:Schema:Attribute

- (void)processAttributeElement:(NSXMLElement *)el schema:(USSchema *)schema type:(USType *)type
{
	// If the schema is not nil, we assign the attribute to the schema
	// Otherwise we assume the type is not nil and we assign the attribute to the type
	
	USAttribute *attribute = [USAttribute new];
	if (schema != nil) {
		attribute.schema = schema;
	} else {
		attribute.schema = type.schema;
	}
	
	// Check if it's a referred attribute
	NSXMLNode *refNode = [el attributeForName:@"ref"];
	if(refNode != nil) {
		
		NSString *attributeQName = [refNode stringValue];
		NSString *attributeURI = [[el resolveNamespaceForName:attributeQName] stringValue];
		NSString *attributeLocalName = [NSXMLNode localNameForName:attributeQName];
		
		USAttribute *refAttribute;
		if (schema != nil) {
			refAttribute = [schema attributeForName:attributeLocalName];
		} else {
			USSchema *theSchema = [type.schema.wsdl schemaForNamespace:attributeURI];
			refAttribute = [theSchema attributeForName:attributeLocalName];
		}
		
		attribute.name = refAttribute.name;
		attribute.type = refAttribute.type;
		
	} else {
		
		NSString *name = [[el attributeForName:@"name"] stringValue];
		attribute.name = name;
		if (name == nil) {
			NSLog(@"\n-----\nATT NAME IS NIL: %@\n-----", el);
		}
		
		NSString *prefixedType = [[el attributeForName:@"type"] stringValue];
		if (prefixedType != nil) {
			NSString *uri = [[el resolveNamespaceForName:prefixedType] stringValue];
			NSString *typeName = [NSXMLNode localNameForName:prefixedType];
			USType *attributeType;
			attributeType = [attribute.schema.wsdl typeForNamespace:uri name:typeName];
			attribute.type = attributeType;
		} else {
			for(NSXMLNode *child in [el children]) {
				if([child kind] == NSXMLElementKind) {
					[self processAttributeElementChildElement:(NSXMLElement*)child attribute:attribute];
				}
			}		
		}
		
		
		NSXMLNode *defaultNode = [el attributeForName:@"default"];
		if(defaultNode != nil) {
			NSString *defaultValue = [defaultNode stringValue];
			attribute.attributeDefault = defaultValue;
		}
	}
	if (schema != nil) {
		[schema.attributes addObject:attribute];
	} else {
		[type.attributes addObject:attribute];
	}
    [attribute release];
}

- (void)processAttributeElementChildElement:(NSXMLElement *)el attribute:(USAttribute *)attribute
{
	NSString *localName = [el localName];
	
	if([localName isEqualToString:@"simpleType"]) {
		[self processAttributeElementSimpleTypeElement:el attribute:attribute];
	} else if([localName isEqualToString:@"complexType"]) {
		[self processAttributeElementComplexTypeElement:el attribute:attribute];
	}
}

- (void)processAttributeElementSimpleTypeElement:(NSXMLElement *)el attribute:(USAttribute *)attribute
{
	USType *type = [attribute.schema typeForName:attribute.name];
	
	if(!type.hasBeenParsed) {
		type.behavior = TypeBehavior_simple;
		
		for(NSXMLNode *child in [el children]) {
			if([child kind] == NSXMLElementKind) {
				[self processSimpleTypeChildElement:(NSXMLElement*)child type:type];
			}
		}
		type.hasBeenParsed = YES;
	}
	// assign the inline definition to its parent attribute
	attribute.type = type;
}

- (void)processAttributeElementComplexTypeElement:(NSXMLElement *)el attribute:(USAttribute *)attribute
{
	USType *type = [attribute.schema typeForName:attribute.name];
	
	if(!type.hasBeenParsed) {
		type.behavior = TypeBehavior_complex;
		
		for(NSXMLNode *child in [el children]) {
			if([child kind] == NSXMLElementKind) {
				[self processComplexTypeChildElement:(NSXMLElement*)child type:type];
			}
		}
		
		type.hasBeenParsed = YES;
	}
	// assign the inline definition to its parent attribute
	attribute.type = type;
}

@end
