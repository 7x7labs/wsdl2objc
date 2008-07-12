
#import "USWSDL.h"


@implementation USWSDL
@synthesize schemas;

-(id)init
{
	if((self = [super init]))
	{
		self.schemas = [NSArray array];
	}
	return self;
}

-(void)dealloc
{
//	[schemas release];
	[super dealloc];
}

@end
