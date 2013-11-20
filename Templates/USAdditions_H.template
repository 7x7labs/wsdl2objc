//
//	USAdditions.h
//	WSDLParser
//
//	Created by John Ogle on 9/5/08.
//	Copyright 2008 LightSPEED Technologies. All rights reserved.
//	Modified by Matthew Faupel on 2009-05-06 to use NSDate instead of NSCalendarDate (for iPhone compatibility).
//	Modifications copyright (c) 2009 Micropraxis Ltd.
//	NSData (MBBase64) category taken from "MiloBird" at http://www.cocoadev.com/index.pl?BaseSixtyFour
//

#import <Foundation/Foundation.h>
#import <libxml/tree.h>

@interface NSString (USAdditions)
- (NSString *)stringByEscapingXML;
- (NSString *)stringByUnescapingXML;
- (const xmlChar *)xmlString;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
+ (NSString *)deserializeNode:(xmlNodePtr)cur;
+ (NSString *)stringWithXmlString:(xmlChar *)str free:(BOOL)free;
@end

@interface NSNumber (USAdditions)
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
+ (NSNumber *)deserializeNode:(xmlNodePtr)cur;
@end

@interface NSDecimalNumber (USAdditions) 
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
+ (NSDecimalNumber *)deserializeNode:(xmlNodePtr)cur;
@end

@interface NSDate (USAdditions)
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
+ (NSDate *)deserializeNode:(xmlNodePtr)cur;
@end

@interface NSData (USAdditions)
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
+ (NSData *)deserializeNode:(xmlNodePtr)cur;
@end

@interface NSData (MBBase64)
+ (id)dataWithBase64EncodedString:(const char *)string; // Padding '=' characters are optional. Whitespace is ignored.
- (NSString *)base64Encoding;
@end

@interface NSArray (USAdditions)
- (void)addToNode:(xmlNodePtr)node elementName:(NSString *)name elementNSPrefix:(NSString *)nsPrefix;
@end

@interface SOAPFault : NSObject
@property(nonatomic, strong) NSString *faultcode;
@property(nonatomic, strong) NSString *faultstring;
@property(nonatomic, strong) NSString *faultactor;
@property(nonatomic, strong) NSString *detail;
@property(nonatomic, readonly) NSString *simpleFaultString;

+ (SOAPFault *)deserializeNode:(xmlNodePtr)cur expectedExceptions:(NSDictionary *)exceptions;
@end

@protocol SOAPSignerDelegate
- (NSData *)signData:(NSData *)rawData;
- (NSData *)digestData:(NSData *)rawData;
- (NSString *)base64Encode:(NSData *)rawData;
@end

@interface SOAPSigner : NSObject
@property (nonatomic, assign) id <SOAPSignerDelegate> delegate;

- (id)initWithDelegate:(id <SOAPSignerDelegate>)del;
- (NSString *)signRequest:(NSString *)req;
@end

@protocol SSLCredentialsManaging <NSObject>
- (BOOL)canAuthenticateForAuthenticationMethod:(NSString *)authMethod;
- (BOOL)authenticateForChallenge:(NSURLAuthenticationChallenge *)challenge;
@end

@interface BasicSSLCredentialsManager : NSObject <SSLCredentialsManaging>
+ (id)managerWithUsername:(NSString *)usr andPassword:(NSString *)pwd;
- (id)initWithUsername:(NSString *)usr andPassword:(NSString *)pwd;
@end
