
#import "USAttribute.h"


@implementation USAttribute
@synthesize attributeName;
@synthesize attributeDefault;
@synthesize type;

-(id)init
{
	if((self = [super init]))
	{
		attributeName = @"";
		attributeDefault = @"";
		type = nil;
	}
	return self;
}

-(void)dealloc
{
	[attributeName release];
	[attributeDefault release];
	[(id)type release];
	[super dealloc];
}

@end
