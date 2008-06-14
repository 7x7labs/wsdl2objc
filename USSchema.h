
#import <Cocoa/Cocoa.h>


@interface USSchema : NSObject {
	NSString *fullName;
	NSArray *types;
}

@property (copy) NSString *fullName;
@property (retain) NSArray *types;

-(id)init;
-(void)dealloc;
@end
