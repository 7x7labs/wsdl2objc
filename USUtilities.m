
#import "USUtilities.h"


@implementation USUtilities

+(NSString*)allKeysInDictionary: (NSDictionary*)dict
{
	if(!dict || [[dict allKeys] count] == 0)
		return @"No keys";
	
	NSMutableString *r = [NSMutableString stringWithString:@""];
	for(NSString *key in [dict allKeys])
		[r appendFormat:@", %@", key];
	
	return r;
}

+(NSXMLNode*)firstXMLNodeWithLocalName: (NSString*)name andParent: (NSXMLNode*)parent
{
	NSArray *nodes = [USUtilities allXMLNodesWithLocalName:name andParent:parent];
	if(nodes && [nodes count] > 0)
		return [nodes objectAtIndex:0];
	
	return nil;
}

+(NSXMLNode*)firstXMLNodeWithName: (NSString*)name andParent: (NSXMLNode*)parent
{
 	NSArray *nodes = [USUtilities allXMLNodesWithName:name andParent:parent];
	if(nodes && [nodes count] > 0)
		return [nodes objectAtIndex:0];
	
	return nil;	
}

+(NSArray*)allXMLNodesWithLocalName: (NSString*)name andParent: (NSXMLNode*)parent
{
	NSMutableArray *r = [NSMutableArray array];
	
	if(parent)
	{
		for(NSXMLNode *child in [parent children])
		{	
			if([[child localName] compare:name options:NSLiteralSearch] == NSOrderedSame)
				[r addObject:child];
		}
	}
	
	//It's handy if this returns null for "No results"
	if([r count] > 0)
		return r;

	return nil;
}

+(NSArray*)allXMLNodesWithName: (NSString*)name andParent: (NSXMLNode*)parent
{
	NSMutableArray *r = [NSMutableArray array];
	
	if(parent)
	{
		for(NSXMLNode *child in [parent children])
		{	
			if([[child name] compare:name options:NSLiteralSearch] == NSOrderedSame)
				[r addObject:child];
		}
	}

	//It's handy if this returns null for "No results"
	if([r count] > 0)
		return r;
	
	return nil;
}

+(NSString*)valueForAttributeNamed:(NSString*)name onNode: (NSXMLNode*)parent
{
	if(!parent || ![parent isKindOfClass:[NSXMLElement class]] ) return nil;

	NSXMLNode *att = [(NSXMLElement*)parent attributeForName:name];
	if(!att) return nil;
	
	return [att stringValue];
}

+(NSInteger)findLastOccurrenceOfString:(NSString*)needle inString:(NSString*)haystack withOptions:(NSStringCompareOptions)mask
{
	if(!haystack || !needle)
		return -1;
	
	if([haystack length] < [needle length])
		return -1;
	
	NSRange searchRange = NSMakeRange(0, [haystack length]);
	NSRange foundRange = NSMakeRange(NSIntegerMax, 0);
	NSRange lastFound = NSMakeRange(NSIntegerMax, 0);
	
	foundRange = [haystack rangeOfString:needle options:mask range:searchRange];
	while(foundRange.location != NSIntegerMax)
	{
		lastFound = foundRange;
		searchRange = NSMakeRange(foundRange.location + foundRange.length , [haystack length] - (foundRange.location + foundRange.length));
		foundRange = [haystack rangeOfString:needle options:mask range:searchRange];
	}
	
	if(lastFound.location != NSIntegerMax)
		return lastFound.location;
	return -1;
}
@end
