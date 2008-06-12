
#import "USMessage.h"


@implementation USMessage
@synthesize messageName;
@synthesize partName;
@synthesize partType;

-(id) init
{
	if((self = [super init]))
	{
		self.messageName = @"";
		self.partName = @"";
		self.partType = nil;
	}
	
	return self;
}

@end
