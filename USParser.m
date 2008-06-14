
#import "USParser.h"


@implementation USParser
-(id)initWithWSDL: (NSXMLDocument*)wsdl
{
	if((self = [super init]))
	{
		wsdlXML = [wsdl retain];
		namespaceAliases = nil;
	}
	
	return self;
}

-(void)dealloc
{
	[wsdlXML release];
	[namespaceAliases release]; 
	[super dealloc];
}

-(USWSDL*)parse
{
	if(!wsdlXML) return nil;
	
	NSString *targetNamespace = @"";
	NSDictionary *typeNodes = [NSDictionary dictionary];
	NSMutableDictionary *parsedTypes = [NSMutableDictionary dictionary];
	NSMutableDictionary *parsedMessages = [NSMutableDictionary dictionary];
	
	
	NSXMLNode *definitions = [wsdlXML rootElement];
	
	if(!definitions)
	{
		NSLog(@"Could not get root node from XML document.");
		return nil;
	}
	
	targetNamespace = [USUtilities valueForAttributeNamed:@"targetNamespace" onNode:definitions];
	namespaceAliases = [[self allNamespacesFromXML:definitions] retain];
	typeNodes = [self allTypeNodesFromXML:definitions];

	for(USOrderedPair *p in [self builtInSchemas])
	{
		NSString *namespace = p.firstObject;
		for(id<USType> type in (NSArray*)p.secondObject)
		{
			[parsedTypes setValue:type forKey:[self fullNameForType:[type typeName] inNamespace:namespace]];
		}
	}

	//Add placeholders for all the types that will eventually need to be parsed
	for(NSString *fullName in [typeNodes allKeys])
	{
		NSXMLNode *typeNode = [typeNodes valueForKey:fullName];
		if([self xmlNodeIsComplexType:typeNode])
		{	
			//Don't add a type that's already present as this can screw things up. The WSDL I care about redefines "guid" and I don't 
			//want that. Not sure what consequence this will have on other WSDL files.
			if(![parsedTypes valueForKey:fullName])
				[parsedTypes setValue:[[[USComplexType alloc] init] autorelease] forKey:fullName];
		}
		else if([self xmlNodeIsSimpleType:typeNode])
		{
			//Don't add a type that's already present as this can screw things up. The WSDL I care about redefines "guid" and I don't 
			//want that. Not sure what consequence this will have on other WSDL files.
			if(![parsedTypes valueForKey:fullName])
				[parsedTypes setValue:[[[USSimpleType alloc] init] autorelease] forKey:fullName];
		}
	}
	
	NSArray *unparsedTypes = [self allUnparsedTypesInTypeDictionary:parsedTypes];
	while([unparsedTypes count] > 0)
	{
		for(USOrderedPair* unparsedType in unparsedTypes)
		{
			[self parseType:unparsedType withParsedTypes:parsedTypes andXMLTypeNodes:typeNodes];				
		}
		
		unparsedTypes = [self allUnparsedTypesInTypeDictionary:parsedTypes];
	}
	
	NSArray *messageNodes = [USUtilities allXMLNodesWithLocalName:@"message" andParent:definitions];
	
	for(NSXMLNode *messageNode in messageNodes)
	{
		USMessage *m = [self parseMessage:messageNode withParsedTypes:parsedTypes];
		[parsedMessages setValue:m forKey:m.messageName];
	}
	
	USWSDL *r = [[[USWSDL alloc] init] autorelease];
	NSMutableArray *schemas = [NSMutableArray array];
	
	for(NSString *schemaName in [self allNamespacesFromXML:definitions])
	{
		schemaName = [self translateAliasToNamespace:schemaName];
		USSchema *schema = [[[USSchema alloc] init] autorelease];
//		[schema setFullName:schemaName];
//		[schema setTypes:[self allObjectsForSchema:schemaName inDictionary:parsedTypes]];
		schema.fullName = schemaName;
		schema.types = [self allObjectsForSchema:schemaName inDictionary:parsedTypes];
		
		[schemas addObject:schema];
		
	}
	
	r.schemas = schemas;
	r.messages = [parsedMessages allValues];
	return r;
	
}

-(NSArray*) allObjectsForSchema: (NSString*)schemaName inDictionary: (NSDictionary*)dictionary
{
	NSMutableArray *r = [NSMutableArray array];
	
	for(NSString *fullName in [dictionary allKeys])
	{
		if([[self namespaceNameFromFullName:fullName] compare:schemaName options:NSLiteralSearch] == 0)
		{
			[r addObject:[dictionary valueForKey:fullName]];
		}
	}
	
	return r;
}


-(NSString*) translateAliasInFullTypeName: (NSString*)fullName
{
	NSString *typeName = [self typeNameFromFullName:fullName];
	NSString *aliasName = [self namespaceNameFromFullName:fullName];
	NSString *namespace = [self translateAliasToNamespace:aliasName];
	
	return [self fullNameForType:typeName inNamespace:namespace];
}

-(NSString*)translateAliasToNamespace: (NSString*)alias
{
	NSString *r = [namespaceAliases valueForKey:alias];
	if(r && [r length] > 0)
		return r;
	return alias;
}

-(NSString*)translateNamespaceToAlias: (NSString*)nsName
{
	for(NSString *alias in namespaceAliases)
	{
		if([nsName compare:[namespaceAliases valueForKey:alias] options:NSLiteralSearch] == 0)
			return alias;
	}
	
	return nsName;
}

-(NSString*) fullNameForType:(NSString*)typeName inNamespace:(NSString*)nsName
{
	return [NSString stringWithFormat:@"%@:%@", nsName, typeName];
}

-(NSString*) namespaceNameFromFullName:(NSString*)fullName
{
	NSInteger sep = [USUtilities findLastOccurrenceOfString:@":" inString:fullName withOptions:NSLiteralSearch];
	if(sep >= 0)
		return [fullName substringToIndex:sep];
	return fullName;
}

-(NSString*) typeNameFromFullName:(NSString*)fullName
{
	NSInteger sep = [USUtilities findLastOccurrenceOfString:@":" inString:fullName withOptions:NSLiteralSearch];
	if(sep >= 0)
		return [fullName substringFromIndex:sep+1];
	return fullName;
}

-(NSDictionary*) allTypeNodesFromXML: (NSXMLNode*) definitions
{
	NSMutableDictionary *r = [NSMutableDictionary dictionary];
	
	NSArray *typeNodes = [USUtilities allXMLNodesWithLocalName:@"types" andParent:definitions];
	for(NSXMLNode *t in typeNodes)
	{
		NSArray *schemaNodes = [USUtilities allXMLNodesWithLocalName:@"schema" andParent:t];
		for(NSXMLNode *s in schemaNodes)
		{
			NSString *targetNamespace = [USUtilities valueForAttributeNamed:@"targetNamespace" onNode:s];
			NSArray *complexTypes = [USUtilities allXMLNodesWithLocalName:@"complexType" andParent:s];
			NSArray *simpleTypes = [USUtilities allXMLNodesWithLocalName:@"simpleType" andParent:s];
			NSArray *elements = [USUtilities allXMLNodesWithLocalName:@"element" andParent:s];
			for(NSXMLNode *complexType in complexTypes)
			{
				[r setValue:complexType forKey:[self fullNameForType:[USUtilities valueForAttributeNamed:@"name" onNode:complexType] inNamespace:targetNamespace]];
			}
			
			for(NSXMLNode *simpleType in simpleTypes)
			{
				[r setValue:simpleType forKey:[self fullNameForType:[USUtilities valueForAttributeNamed:@"name" onNode:simpleType] inNamespace:targetNamespace]];
			}
			
			for(NSXMLNode *element in elements)
			{
				NSString *name = [USUtilities valueForAttributeNamed:@"name" onNode:element];
				NSString *fullTypeName = [self fullNameForType:name inNamespace:targetNamespace];
				
				NSXMLNode *child = nil;
				if([[element children] count] > 0)
					child = [[element children] objectAtIndex:0];
				
				if(child)
				{
					if( ([[child localName] compare:@"complexType" options:NSLiteralSearch] == 0) ||
					   ([[child localName] compare:@"simpleType" options:NSLiteralSearch] == 0))
					{
						if([r valueForKey:fullTypeName])
							NSLog(@"Adding a type node for a type which already exists: %@!!", fullTypeName);
						
						[r setValue:child forKey:fullTypeName];					
					}
					
				}
				
				//In this case, this element is basically describing a simple type. Construct a fake simpleType node to parse
				//later. This is a tremendous hack and I apologize for it.
				if(!child && ![r valueForKey:fullTypeName])
				{
					NSString *simpleTypeNamespace = [self translateNamespaceToAlias:@"http://www.w3.org/2001/XMLSchema"];
					NSXMLNode *simpleTypeNode = [[[NSXMLNode alloc] initWithKind:NSXMLElementKind] autorelease];
					NSXMLNode *simpleTypeNameAttribute = [[[NSXMLNode alloc] initWithKind:NSXMLAttributeKind] autorelease];
					NSXMLNode *restrictionNode = [[[NSXMLNode alloc] initWithKind:NSXMLElementKind] autorelease];
					NSXMLNode *baseTypeAttribute = [[[NSXMLNode alloc] initWithKind:NSXMLAttributeKind] autorelease];
					
					[baseTypeAttribute setName:@"base"];
					[baseTypeAttribute setObjectValue:[USUtilities valueForAttributeNamed:@"type" onNode:element]];
					
					[restrictionNode setName:[NSString stringWithFormat:@"%@:restriction", simpleTypeNamespace]];
					[(NSXMLElement*)restrictionNode addAttribute:baseTypeAttribute];
					
					[simpleTypeNameAttribute setName:@"name"];
					[simpleTypeNameAttribute setObjectValue:name];
					
					[simpleTypeNode setName:[NSString stringWithFormat:@"%@:simpleType",simpleTypeNamespace]];
					[(NSXMLElement*)simpleTypeNode addAttribute:simpleTypeNameAttribute];
					[(NSXMLElement*)simpleTypeNode addChild:restrictionNode];
					
					[r setValue:simpleTypeNode forKey:fullTypeName];
				}
				
			}
		}
	}
	
	return r;
}

-(NSDictionary*) allNamespacesFromXML: (NSXMLNode*) definitions
{
	NSMutableDictionary *r = [NSMutableDictionary dictionary];
	
	for(NSXMLNode *ns in [(NSXMLElement*)definitions namespaces])
	{
		[r setValue:[ns stringValue] forKey:[ns name]];
	}
	
	return r;
}

-(BOOL) xmlNodeIsComplexType: (NSXMLNode*)node
{
	if([[node localName] compare:@"complexType" options:NSLiteralSearch] == 0)	
		return YES;
	
	return NO;
}

-(BOOL) xmlNodeIsSimpleType: (NSXMLNode*)node
{
	if([[node localName] compare:@"simpleType" options:NSLiteralSearch] == 0)	
		return YES;
	
	return NO;
}

-(NSArray*)allUnparsedTypesInTypeDictionary: (NSDictionary*)types
{
	NSMutableArray *r = [NSMutableArray array];
	
	for(NSString *fullName in [types allKeys])
	{
		id <USType> type = [types valueForKey:fullName];
		if(![type hasBeenParsed])
		{
			[r addObject:[USOrderedPair orderPairWithFirstObject:fullName andSecondObject:type]];
		}
	}
	
	return r;
}

-(USMessage*)parseMessage: (NSXMLNode*)messageNode withParsedTypes: (NSDictionary*)parsedTypes;
{
	USMessage *r = [[[USMessage alloc] init] autorelease];
	r.messageName = [USUtilities valueForAttributeNamed:@"name" onNode:messageNode];
	NSXMLNode *partNode = [USUtilities firstXMLNodeWithLocalName:@"part" andParent:messageNode];
	r.partName = [USUtilities valueForAttributeNamed:@"name" onNode:partNode];
	NSString *partType = [USUtilities valueForAttributeNamed:@"element" onNode:partNode];
	partType = [self translateAliasInFullTypeName:partType];
	r.partType = [parsedTypes valueForKey:partType];
	
	return r;
}

-(void)parseType: (USOrderedPair*)typeToParse withParsedTypes: (NSDictionary*)parsedTypes andXMLTypeNodes: (NSDictionary*)xmlTypeNodes
{
	id <USType> unparsedType = typeToParse.secondObject;
	
	if([unparsedType hasBeenParsed])
		return;
	
	NSString *fullName = typeToParse.firstObject;
	
	NSXMLNode *typeNode = [xmlTypeNodes valueForKey:fullName];
	
	if([unparsedType isComplexType])
		[self parseComplexType:(USComplexType*)unparsedType named:fullName withParsedTypes:parsedTypes andXMLNode:typeNode];
	else if([unparsedType isSimpleType])
		[self parseSimpleType:(USSimpleType*)unparsedType named:fullName withParsedTypes:parsedTypes andXMLNode:typeNode];
	
}

-(void)parseSimpleType: (USSimpleType*)typeToParse named: (NSString*)fullName withParsedTypes: (NSDictionary*)parsedTypes andXMLNode: (NSXMLNode*)typeNode
{
	if([typeToParse hasBeenParsed])
		NSLog(@"Has Been Parsed!!");
	
	NSString *typeName = [self typeNameFromFullName:fullName];
	typeToParse.typeName = typeName;
	
	NSXMLNode *restrictionNode = [USUtilities firstXMLNodeWithLocalName:@"restriction" andParent:typeNode];
	NSString *baseAttribute = [USUtilities valueForAttributeNamed:@"base" onNode:restrictionNode];
	NSString *baseTypeName = [self translateAliasInFullTypeName:baseAttribute];
	id<USType> baseType = [parsedTypes objectForKey:baseTypeName];
	
	if([baseType isSimpleType])
	{
		USSimpleType *st = (USSimpleType*)baseType;
		typeToParse.representationClass = st.representationClass;
	}
	else
	{
		//TODO What to do for complex types? 
		NSLog(@"Found complex type");
	}
	
	NSArray *enumerationNodes = [USUtilities allXMLNodesWithLocalName:@"enumeration" andParent:restrictionNode];
	NSMutableArray *enumerationValues = [NSMutableArray arrayWithCapacity:[enumerationNodes count]];
	for(NSXMLNode *enumerationNode in enumerationNodes)
	{
		[enumerationValues addObject:[USUtilities valueForAttributeNamed:@"value" onNode:enumerationNode]];
	}
	typeToParse.enumerationValues = enumerationValues;
	
	[typeToParse setHasBeenParsed:YES];
	
}

-(void)parseComplexType: (USComplexType*)typeToParse named: (NSString*)fullName withParsedTypes: (NSDictionary*)parsedTypes andXMLNode: (NSXMLNode*)typeNode
{
	NSString *typeName = [self typeNameFromFullName:fullName];
	typeToParse.typeName = typeName;
	
	if([[typeNode localName] compare:@"complexType" options:NSLiteralSearch] !=0)
	{
		NSLog(@"Oops");
	}
	
	if([[typeNode localName] compare:@"element" options:NSLiteralSearch] == 0)
	{
		typeNode = [[typeNode children] objectAtIndex:0];
	}
	
	NSXMLNode *complexContentNode = [USUtilities firstXMLNodeWithLocalName:@"complexContent" andParent:typeNode];
	NSXMLNode *sequenceNode = [USUtilities firstXMLNodeWithLocalName:@"sequence" andParent:typeNode];
	NSArray *attributeNodes = [USUtilities allXMLNodesWithLocalName:@"attribute" andParent:typeNode];
	
	if(complexContentNode)
		[self parseComplexContent:complexContentNode forTypeToParse:typeToParse withParsedTypes:parsedTypes];
	if(sequenceNode)
		[self parseComplexSequence:sequenceNode forTypeToParse:typeToParse withParsedTypes:parsedTypes];
	if(attributeNodes && [attributeNodes count] > 0)
		[self parseComplexAttributes:attributeNodes forTypeToParse:typeToParse withParsedTypes:parsedTypes];
	
	[typeToParse setHasBeenParsed:YES];
}

-(void)parseComplexContent: (NSXMLNode*)complexContent forTypeToParse: (USComplexType*)typeToParse withParsedTypes: (NSDictionary*)parsedTypes
{
	NSXMLNode *extensionNode = [USUtilities firstXMLNodeWithLocalName:@"extension" andParent:complexContent];
	if(extensionNode)
	{
		NSString *baseClassName = [USUtilities valueForAttributeNamed:@"base" onNode:extensionNode];
		id<USType> baseType = [parsedTypes valueForKey:[self translateAliasInFullTypeName:baseClassName]];
		if([baseType isComplexType])
			typeToParse.superClass = (USComplexType*)baseType;
		
		NSXMLNode *sequenceNode = [USUtilities firstXMLNodeWithLocalName:@"sequence" andParent:extensionNode];
		NSArray *attributeNodes = [USUtilities allXMLNodesWithName:@"attribute" andParent:extensionNode];
		
		if(sequenceNode)
			[self parseComplexSequence:sequenceNode forTypeToParse:typeToParse withParsedTypes:parsedTypes];
		if(attributeNodes && [attributeNodes count] > 0)
			[self parseComplexAttributes:attributeNodes forTypeToParse:typeToParse withParsedTypes:parsedTypes];
		
	}
}

-(void)parseComplexSequence: (NSXMLNode*)sequenceNode forTypeToParse: (USComplexType*)typeToParse withParsedTypes: (NSDictionary*)parsedTypes
{
	NSArray *elementNodes = [USUtilities allXMLNodesWithLocalName:@"element" andParent:sequenceNode];
	NSMutableArray *parsedElements = [NSMutableArray array];
	
	for(NSXMLNode *elementNode in elementNodes)
	{
		USSequenceElement *e = [[[USSequenceElement alloc] init] autorelease];
		NSString *elementTypeName = [USUtilities valueForAttributeNamed:@"type" onNode:elementNode];
		elementTypeName = [self translateAliasInFullTypeName:elementTypeName];
		
		e.name = [USUtilities valueForAttributeNamed:@"name" onNode:elementNode];
		e.minOccurs = [[USUtilities valueForAttributeNamed:@"minOccurs" onNode:elementNode] integerValue];
		e.maxOccurs = [[USUtilities valueForAttributeNamed:@"maxOccurs" onNode:elementNode] integerValue];
		id<USType> elementType = [parsedTypes valueForKey:elementTypeName];
		e.type = elementType;
		
		[parsedElements addObject:e];
	}
	
	typeToParse.sequenceElements = parsedElements;
}

-(void)parseComplexAttributes: (NSArray*)attributeNodes forTypeToParse: (USComplexType*)typeToParse withParsedTypes: (NSDictionary*)parsedTypes
{
	NSMutableArray *parsedAttributes = [NSMutableArray array];
	
	for(NSXMLNode *attributeNode in attributeNodes)
	{
		USAttribute *a = [[[USAttribute alloc] init] autorelease];
		NSString *typeName = [USUtilities valueForAttributeNamed:@"type" onNode:attributeNode];
		
		BOOL isGuid;
		isGuid = NO;
		if([typeName compare:@"s1:guid"])
		{
			isGuid =YES;
		}
		
		typeName = [self translateAliasInFullTypeName:typeName];
		
		a.attributeName = [USUtilities valueForAttributeNamed:@"name" onNode:attributeNode];
		a.attributeDefault = [USUtilities valueForAttributeNamed:@"default" onNode:attributeNode];
		a.type = [parsedTypes valueForKey:typeName];
		
		if(isGuid)
		{
			//	NSLog(@"a.type.representationClass: %@", ((USSimpleType*)a.type).representationClass);
		}
		[parsedAttributes addObject:a];
	}
	
	typeToParse.attributes = parsedAttributes;
}

-(NSArray*)builtInSchemas
{
	NSMutableArray *microsoft = [NSMutableArray array];
	NSMutableArray *w3wsdl = [NSMutableArray array];
	
	[microsoft addObject:[USSimpleType typeWithName:@"boolean" andRepresentationClass:@"USBoolean"]];
	[microsoft addObject:[USSimpleType typeWithName:@"unsignedByte" andRepresentationClass:@"NSNumber"]];
	[microsoft addObject:[USSimpleType typeWithName:@"char" andRepresentationClass:@"NSString"]];
	[microsoft addObject:[USSimpleType typeWithName:@"dateTime" andRepresentationClass:@"NSDate"]];
	[microsoft addObject:[USSimpleType typeWithName:@"decimal" andRepresentationClass:@"NSNumber"]];
	[microsoft addObject:[USSimpleType typeWithName:@"double" andRepresentationClass:@"NSNumber"]];
	[microsoft addObject:[USSimpleType typeWithName:@"short" andRepresentationClass:@"NSNumber"]];
	[microsoft addObject:[USSimpleType typeWithName:@"int" andRepresentationClass:@"NSNumber"]];
	[microsoft addObject:[USSimpleType typeWithName:@"long" andRepresentationClass:@"NSNumber"]];
	[microsoft addObject:[USSimpleType typeWithName:@"anyType" andRepresentationClass:@"NSObject"]];
	[microsoft addObject:[USSimpleType typeWithName:@"byte" andRepresentationClass:@"NSNumber"]];
	[microsoft addObject:[USSimpleType typeWithName:@"float" andRepresentationClass:@"NSNumber"]];
	[microsoft addObject:[USSimpleType typeWithName:@"string" andRepresentationClass:@"NSString"]];
	[microsoft addObject:[USSimpleType typeWithName:@"unsignedShort" andRepresentationClass:@"NSNumber"]];
	[microsoft addObject:[USSimpleType typeWithName:@"unsignedInt" andRepresentationClass:@"NSNumber"]];
	[microsoft addObject:[USSimpleType typeWithName:@"unsignedLong" andRepresentationClass:@"NSNumber"]];
	//	[microsoft addObject:[USSimpleType typeWithName:@"guid" andRepresentationClass:@"USGuid"]];
	
	//TODO HACK It looks like http://www.w3.org/2001/XMLSchema has a lot of the same types as http://microsoft.com/wsdl/types. So 
	//I just copy and pasted from above. Need to check the spec and actually do the right thing here.
	
	[w3wsdl addObject:[USSimpleType typeWithName:@"boolean" andRepresentationClass:@"USBoolean"]];
	[w3wsdl addObject:[USSimpleType typeWithName:@"unsignedByte" andRepresentationClass:@"NSNumber"]];
	[w3wsdl addObject:[USSimpleType typeWithName:@"char" andRepresentationClass:@"NSString"]];
	[w3wsdl addObject:[USSimpleType typeWithName:@"dateTime" andRepresentationClass:@"NSDate"]];
	[w3wsdl addObject:[USSimpleType typeWithName:@"decimal" andRepresentationClass:@"NSNumber"]];
	[w3wsdl addObject:[USSimpleType typeWithName:@"double" andRepresentationClass:@"NSNumber"]];
	[w3wsdl addObject:[USSimpleType typeWithName:@"short" andRepresentationClass:@"NSNumber"]];
	[w3wsdl addObject:[USSimpleType typeWithName:@"int" andRepresentationClass:@"NSNumber"]];
	[w3wsdl addObject:[USSimpleType typeWithName:@"long" andRepresentationClass:@"NSNumber"]];
	[w3wsdl addObject:[USSimpleType typeWithName:@"anyType" andRepresentationClass:@"NSObject"]];
	[w3wsdl addObject:[USSimpleType typeWithName:@"byte" andRepresentationClass:@"NSNumber"]];
	[w3wsdl addObject:[USSimpleType typeWithName:@"float" andRepresentationClass:@"NSNumber"]];
	[w3wsdl addObject:[USSimpleType typeWithName:@"string" andRepresentationClass:@"NSString"]];
	[w3wsdl addObject:[USSimpleType typeWithName:@"unsignedShort" andRepresentationClass:@"NSNumber"]];
	[w3wsdl addObject:[USSimpleType typeWithName:@"unsignedInt" andRepresentationClass:@"NSNumber"]];
	[w3wsdl addObject:[USSimpleType typeWithName:@"unsignedLong" andRepresentationClass:@"NSNumber"]];
	//[w3wsdl addObject:[USSimpleType typeWithName:@"guid" andRepresentationClass:@"USGuid"]];
	
	return [NSArray arrayWithObjects:[USOrderedPair orderPairWithFirstObject: @"http://microsoft.com/wsdl/types/" andSecondObject:microsoft], 
			[USOrderedPair orderPairWithFirstObject: @"http://www.w3.org/2001/XMLSchema" andSecondObject:w3wsdl],
			nil];
	
}

@end
