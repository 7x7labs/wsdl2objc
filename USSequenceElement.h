
#import <Cocoa/Cocoa.h>
#import "UStype.h"

@interface USSequenceElement : NSObject {
	NSInteger minOccurs;
	NSInteger maxOccurs;
	NSString *name;
	id<USType> type;
}

@property (assign) NSInteger minOccurs;
@property (assign) NSInteger maxOccurs;
@property (copy) NSString *name;
@property (retain) id<USType> type;
@end
