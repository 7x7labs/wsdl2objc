
#import <Cocoa/Cocoa.h>
#import "USMessage.h"

@interface USOperation : NSObject {
	NSString *name;
	USMessage *input;
	USMessage *output;
}

@property (copy) NSString* name;
@property (retain) USMessage* input;
@property (retain) USMessage* output;
@end

