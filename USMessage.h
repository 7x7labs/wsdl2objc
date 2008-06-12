
#import <Cocoa/Cocoa.h>
#import "USType.h"

@interface USMessage : NSObject {
	NSString *messageName;
	NSString *partName;
	id<USType> partType;
}

@property (copy) NSString *messageName;
@property (copy) NSString *partName;
@property (retain) id<USType> partType;

@end
