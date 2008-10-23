//
//  USAdditions.m
//  WSDLParser
//
//  Created by John Ogle on 9/5/08.
//  Copyright 2008 LightSPEED Technologies. All rights reserved.
//
//
//  NSData (MBBase64) category taken from "MiloBird" at http://www.cocoadev.com/index.pl?BaseSixtyFour
//

#import "USAdditions.h"
#import "NSCalendarDate+ISO8601Parsing.h"
#import "NSCalendarDate+ISO8601Unparsing.h"

@implementation NSString (USAdditions)

- (NSString *)serializedFormUsingElementName:(NSString *)elName
{
	return [NSString stringWithFormat:@"<%@>%@</%@>", elName, self, elName];
}

+ (NSString *)deserializeNode:(xmlNodePtr)cur
{
	xmlChar *elementText = xmlNodeListGetString(cur->doc, cur->children, 1);
	NSString *elementString = nil;
	
	if(elementText != NULL) {
		elementString = [NSString stringWithCString:(char*)elementText encoding:NSUTF8StringEncoding];
		xmlFree(elementText);
	}
	
	return elementString;
}

@end

@implementation NSNumber (USAdditions)

- (NSString *)serializedFormUsingElementName:(NSString *)elName
{
	return [NSString stringWithFormat:@"<%@>%@</%@>", elName, [self stringValue], elName];
}

+ (NSNumber *)deserializeNode:(xmlNodePtr)cur
{
	NSString *stringValue = [NSString deserializeNode:cur];
	return [NSNumber numberWithDouble:[stringValue doubleValue]];
}

@end

@implementation NSCalendarDate (USAdditions)

- (NSString *)serializedFormUsingElementName:(NSString *)elName
{
	return [NSString stringWithFormat:@"<%@>%@</%@>", elName, [self ISO8601DateString], elName];
}

+ (NSCalendarDate *)deserializeNode:(xmlNodePtr)cur
{
	return [NSCalendarDate calendarDateWithString:[NSString deserializeNode:cur]];
}

@end

@implementation NSData (USAdditions)

- (NSString *)serializedFormUsingElementName:(NSString *)elName
{
	return [NSString stringWithFormat:@"<%@>%@</%@>", elName, [self base64Encoding], elName];
}

+ (NSData *)deserializeNode:(xmlNodePtr)cur
{
	return [NSData dataWithBase64EncodedString:[NSString deserializeNode:cur]];
}

@end


static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


@implementation NSData (MBBase64)

+ (id)dataWithBase64EncodedString:(NSString *)string;
{
	if (string == nil)
		[NSException raise:NSInvalidArgumentException format:nil];
	if ([string length] == 0)
		return [NSData data];
	
	static char *decodingTable = NULL;
	if (decodingTable == NULL)
	{
		decodingTable = malloc(256);
		if (decodingTable == NULL)
			return nil;
		memset(decodingTable, CHAR_MAX, 256);
		NSUInteger i;
		for (i = 0; i < 64; i++)
			decodingTable[(short)encodingTable[i]] = i;
	}
	
	const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
	if (characters == NULL)     //  Not an ASCII string!
		return nil;
	char *bytes = malloc((([string length] + 3) / 4) * 3);
	if (bytes == NULL)
		return nil;
	NSUInteger length = 0;

	NSUInteger i = 0;
	while (YES)
	{
		char buffer[4];
		short bufferLength;
		for (bufferLength = 0; bufferLength < 4; i++)
		{
			if (characters[i] == '\0')
				break;
			if (isspace(characters[i]) || characters[i] == '=')
				continue;
			buffer[bufferLength] = decodingTable[(short)characters[i]];
			if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
			{
				free(bytes);
				return nil;
			}
		}
		
		if (bufferLength == 0)
			break;
		if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
		{
			free(bytes);
			return nil;
		}
		
		//  Decode the characters in the buffer to bytes.
		bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
		if (bufferLength > 2)
			bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
		if (bufferLength > 3)
			bytes[length++] = (buffer[2] << 6) | buffer[3];
	}
	
	realloc(bytes, length);
	return [NSData dataWithBytesNoCopy:bytes length:length];
}

- (NSString *)base64Encoding;
{
	if ([self length] == 0)
		return @"";

    char *characters = malloc((([self length] + 2) / 3) * 4);
	if (characters == NULL)
		return nil;
	NSUInteger length = 0;
	
	NSUInteger i = 0;
	while (i < [self length])
	{
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < [self length])
			buffer[bufferLength++] = ((char *)[self bytes])[i++];
		
		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
		characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1)
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		if (bufferLength > 2)
			characters[length++] = encodingTable[buffer[2] & 0x3F];
		else characters[length++] = '=';	
	}
	
	return [[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES] autorelease];
}

@end

@implementation USBoolean

@synthesize boolValue=value;

- (id)initWithBool:(BOOL)aValue
{
	self = [super init];
	if(self != nil) {
		value = aValue;
	}
	
	return self;
}

- (NSString *)stringValue
{
	return value ? @"true" : @"false";
}

- (NSString *)serializedFormUsingElementName:(NSString *)elName
{
	return [NSString stringWithFormat:@"<%@>%@</%@>", elName, [self stringValue], elName];
}

+ (USBoolean *)deserializeNode:(xmlNodePtr)cur
{
	NSString *stringValue = [NSString deserializeNode:cur];
	
	if([stringValue isEqualToString:@"true"]) {
		return [[[USBoolean alloc] initWithBool:YES] autorelease];
	} else if([stringValue isEqualToString:@"false"]) {
		return [[[USBoolean alloc] initWithBool:NO] autorelease];
	}
	
	return nil;
}

@end
