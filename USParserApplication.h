
#import <Cocoa/Cocoa.h>
#import "USUtilities.h"
#import "USComplexType.h"
#import "USSequenceElement.h"
#import "USSimpleType.h"
#import "USOrderedPair.h"
#import "USAttribute.h"
#import "USParser.h"
#import "USWSDL.h"
#import "USSchema.h"

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



-(void)magic;

-(NSXMLDocument*)getXML;

-(void)writeDebugInfoForWSDL: (USWSDL*)wsdl;
@end
