
#import "USWSDL.h"


@implementation USWSDL
@synthesize messages;
@synthesize schemas;

-(id)init
{
	if((self = [super init]))
	{
		self.messages = [NSArray array];
		self.schemas = [NSArray array];
	}
	return self;
}

-(void)dealloc
{
//	[messages release];
//	[schemas release];
	[super dealloc];
}

@end
