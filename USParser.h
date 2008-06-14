
#import <Cocoa/Cocoa.h>
#import "USUtilities.h"
#import "USComplexType.h"
#import "USSequenceElement.h"
#import "USSimpleType.h"
#import "USOrderedPair.h"
#import "USAttribute.h"
#import "USMessage.h"
#import "USSchema.h"
#import "USWSDL.h"

@interface USParser : NSObject {
	NSXMLDocument *wsdlXML;
	NSDictionary *namespaceAliases;
}

-(id)initWithWSDL: (NSXMLDocument*)wsdl;
-(void)dealloc;
-(USWSDL*)parse;

-(NSArray*) allObjectsForSchema: (NSString*)schemaName inDictionary: (NSDictionary*)dictionary;

-(NSString*)translateAliasInFullTypeName: (NSString*)fullName;
-(NSString*)translateAliasToNamespace: (NSString*)alias;
-(NSString*)translateNamespaceToAlias: (NSString*)nsName;

-(NSString*) fullNameForType:(NSString*)typeName inNamespace:(NSString*)nsName;
-(NSString*) namespaceNameFromFullName:(NSString*)fullName;
-(NSString*) typeNameFromFullName:(NSString*)fullName;

-(NSDictionary*) allTypeNodesFromXML: (NSXMLNode*) definitions;
-(NSDictionary*) allNamespacesFromXML: (NSXMLNode*) definitions;

-(BOOL) xmlNodeIsComplexType: (NSXMLNode*)node;
-(BOOL) xmlNodeIsSimpleType: (NSXMLNode*)node;

-(NSArray*)allUnparsedTypesInTypeDictionary: (NSDictionary*)types;

-(USMessage*)parseMessage: (NSXMLNode*)messageNode withParsedTypes: (NSDictionary*)parsedTypes;
-(void)parseType: (USOrderedPair*)typeToParse withParsedTypes: (NSDictionary*)parsedTypes andXMLTypeNodes: (NSDictionary*)xmlTypeNodes;
-(void)parseSimpleType: (USSimpleType*)typeToParse named: (NSString*)fullName withParsedTypes: (NSDictionary*)parsedTypes andXMLNode: (NSXMLNode*)typeNode;
-(void)parseComplexType: (USComplexType*)typeToParse named: (NSString*)fullName withParsedTypes: (NSDictionary*)parsedTypes andXMLNode: (NSXMLNode*)typeNode;
-(void)parseComplexContent: (NSXMLNode*)complexContent forTypeToParse: (USComplexType*)typeToParse withParsedTypes: (NSDictionary*)parsedTypes;
-(void)parseComplexSequence: (NSXMLNode*)sequenceNode forTypeToParse: (USComplexType*)typeToParse withParsedTypes: (NSDictionary*)parsedTypes;
-(void)parseComplexAttributes: (NSArray*)attributeNodes forTypeToParse: (USComplexType*)typeToParse withParsedTypes: (NSDictionary*)parsedTypes;

-(NSArray*)builtInSchemas;


@end
