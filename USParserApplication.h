
#import <Cocoa/Cocoa.h>
#import "USUtilities.h"
#import "USComplexType.h"
#import "USSequenceElement.h"
#import "USSimpleType.h"
#import "USOrderedPair.h"
#import "USAttribute.h"

@interface USParserApplication : NSObject {
	NSString *fileName;
	NSString *url;	
	
	NSDictionary *namespaceAliases;
}

@property (copy) NSString *fileName;
@property (copy) NSString *url;

-(id)initWithArgs: (const char **)argv andArgCount: (int) argc;
-(BOOL)passesSanityCheck;
-(void)parseArgs:  (const char **)argv andArgCount: (int) argc;

-(BOOL)usingFile;
-(BOOL)usingURL;

-(NSString*) translateAliasInFullTypeName: (NSString*)fullName;
-(NSString*) fullNameForType:(NSString*)typeName inNamespace:(NSString*)nsName;
-(NSString*) namespaceNameFromFullName:(NSString*)fullName;
-(NSString*) typeNameFromFullName:(NSString*)fullName;

-(NSDictionary*) allTypeNodesFromXML: (NSXMLNode*) definitions;
-(NSDictionary*) allNamespacesFromXML: (NSXMLNode*) definitions;

-(BOOL) xmlNodeIsComplexType: (NSXMLNode*)node;
-(BOOL) xmlNodeIsSimpleType: (NSXMLNode*)node;

-(NSArray*)allUnparsedTypesInTypeDictionary: (NSDictionary*)types;

-(void)magic;

-(void)parseType: (USOrderedPair*)typeToParse withParsedTypes: (NSDictionary*)parsedTypes andXMLTypeNodes: (NSDictionary*)xmlTypeNodes;
-(void)parseSimpleType: (USSimpleType*)typeToParse named: (NSString*)fullName withParsedTypes: (NSDictionary*)parsedTypes andXMLNode: (NSXMLNode*)typeNode;
-(void)parseComplexType: (USComplexType*)typeToParse named: (NSString*)fullName withParsedTypes: (NSDictionary*)parsedTypes andXMLNode: (NSXMLNode*)typeNode;
-(void)parseComplexContent: (NSXMLNode*)complexContent forTypeToParse: (USComplexType*)typeToParse withParsedTypes: (NSDictionary*)parsedTypes;
-(void)parseComplexSequence: (NSXMLNode*)sequenceNode forTypeToParse: (USComplexType*)typeToParse withParsedTypes: (NSDictionary*)parsedTypes;
-(void)parseComplexAttributes: (NSArray*)attributeNodes forTypeToParse: (USComplexType*)typeToParse withParsedTypes: (NSDictionary*)parsedTypes;

-(NSArray*)builtInSchemas;
-(NSXMLDocument*)getXML;
@end
