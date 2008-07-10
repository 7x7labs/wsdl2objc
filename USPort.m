
#import "USPort.h"


@implementation USPort
@synthesize name;
@synthesize operations;

-(id)init
{
	if((self = [super init]))
	{
		self.name = @"";
		self.operations = [NSArray array];
	}
	
	return self;
}

@end
