
#import "USOrderedPair.h"


@implementation USOrderedPair
@synthesize firstObject;
@synthesize secondObject;

+(USOrderedPair*)orderPairWithFirstObject: (id)obj1 andSecondObject: (id)obj2
{
	return [[[USOrderedPair alloc] initWithFirstObject:obj1 andSecondObject:obj2] autorelease];
}

-(id)initWithFirstObject: (id)obj1 andSecondObject: (id)obj2
{
	if((self = [super init]))
	{
		self.firstObject = obj1;
		self.secondObject = obj2;
	}
	
	return self;
}

-(void)dealloc
{
	[firstObject release];
	[secondObject release];
	[super dealloc];
}
@end
