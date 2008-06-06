
#import <Cocoa/Cocoa.h>


@interface USUtilities : NSObject {

}

+(NSString*)allKeysInDictionary: (NSDictionary*)dict;
+(NSXMLNode*)firstXMLNodeWithLocalName: (NSString*)name andParent: (NSXMLNode*)parent;
+(NSXMLNode*)firstXMLNodeWithName: (NSString*)name andParent: (NSXMLNode*)parent;
+(NSArray*)allXMLNodesWithLocalName: (NSString*)name andParent: (NSXMLNode*)parent;
+(NSArray*)allXMLNodesWithName: (NSString*)name andParent: (NSXMLNode*)parent;
+(NSString*)valueForAttributeNamed:(NSString*)name onNode: (NSXMLNode*)parent;

+(NSInteger)findLastOccurrenceOfString:(NSString*)needle inString:(NSString*)haystack withOptions:(NSStringCompareOptions)mask;
@end
