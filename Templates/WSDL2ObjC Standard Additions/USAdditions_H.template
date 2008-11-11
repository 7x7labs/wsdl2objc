//
//  USAdditions.h
//  WSDLParser
//
//  Created by John Ogle on 9/5/08.
//  Copyright 2008 LightSPEED Technologies. All rights reserved.
//
//  NSData (MBBase64) category taken from "MiloBird" at http://www.cocoadev.com/index.pl?BaseSixtyFour
//

#import <Foundation/Foundation.h>
#import <libxml/tree.h>

@interface NSString (USAdditions)

- (NSString *)serializedFormUsingElementName:(NSString *)elName;
+ (NSString *)deserializeNode:(xmlNodePtr)cur;

@end

@interface NSNumber (USAdditions)

- (NSString *)serializedFormUsingElementName:(NSString *)elName;
+ (NSNumber *)deserializeNode:(xmlNodePtr)cur;

@end

@interface NSCalendarDate (USAdditions)

- (NSString *)serializedFormUsingElementName:(NSString *)elName;
+ (NSCalendarDate *)deserializeNode:(xmlNodePtr)cur;

@end

@interface NSData (USAdditions)

- (NSString *)serializedFormUsingElementName:(NSString *)elName;
+ (NSData *)deserializeNode:(xmlNodePtr)cur;

@end

@interface NSData (MBBase64)

+ (id)dataWithBase64EncodedString:(NSString *)string;     //  Padding '=' characters are optional. Whitespace is ignored.
- (NSString *)base64Encoding;
@end

@interface USBoolean : NSObject {
	BOOL value;
}

@property (assign) BOOL boolValue;

- (id)initWithBool:(BOOL)aValue;
- (NSString *)stringValue;

- (NSString *)serializedFormUsingElementName:(NSString *)elName;
+ (USBoolean *)deserializeNode:(xmlNodePtr)cur;

@end
