
#import <Cocoa/Cocoa.h>

#import "USComplexType.h"
#import "USSequenceElement.h"
#import "USSimpleType.h"
#import "USOrderedPair.h"
#import "USAttribute.h"
#import "USMessage.h"
#import "USSchema.h"

@interface USWSDL : NSObject {
	NSArray *messages;
	NSArray *schemas;
}
@property (retain) NSArray *messages;
@property (retain) NSArray *schemas;

-(id)init;
-(void)dealloc;
@end
