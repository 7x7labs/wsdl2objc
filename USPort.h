
#import <Cocoa/Cocoa.h>


@interface USPort : NSObject {
	NSString *name;
	NSArray *operations;
}

@property (copy) NSString* name;
@property (retain) NSArray* operations;

@end

