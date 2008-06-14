
#import "USSchema.h"


@implementation USSchema
@synthesize fullName;
@synthesize types;

-(id)init
{
	if((self = [super init]))
	{
		fullName = @"";
		types = [[NSArray array] retain];
	}
	return self;
}


-(void)dealloc
{
	[fullName release];
	[types release];
	[super dealloc];
}
@end
