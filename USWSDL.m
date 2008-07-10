
#import "USWSDL.h"


@implementation USWSDL
@synthesize messages;
@synthesize schemas;
@synthesize ports;

-(id)init
{
	if((self = [super init]))
	{
		self.messages = [NSArray array];
		self.schemas = [NSArray array];
		self.ports = [NSArray array];
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
