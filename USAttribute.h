
#import <Cocoa/Cocoa.h>
#import "USType.h"

@interface USAttribute : NSObject {
	NSString *attributeName;
	NSString *attributeDefault;
	id<USType> type;
}

@property (copy) NSString *attributeName;
@property (copy) NSString *attributeDefault;
@property (retain) id<USType> type;

-(id)init;
-(void)dealloc;

@end
