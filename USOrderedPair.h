
#import <Cocoa/Cocoa.h>


@interface USOrderedPair : NSObject {
	id firstObject;
	id secondObject;
}

@property(retain) id firstObject;
@property(retain) id secondObject;

+(USOrderedPair*)orderPairWithFirstObject: (id)obj1 andSecondObject: (id)obj2;
-(id)initWithFirstObject: (id)obj1 andSecondObject: (id)obj2;
@end
