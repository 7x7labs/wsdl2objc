
#import "USComplexType.h"


@implementation USComplexType
@synthesize typeName;
@synthesize superClass;
@synthesize sequenceElements;
@synthesize attributes;

-(id)init
{
	if((self == [super init]))
	{
		self.typeName = @"";
		self.superClass = nil;
		self.sequenceElements = nil;
		self.attributes = nil;
		hasBeenParsed = NO;
	}
	return self;
}

-(BOOL)isSimpleType
{
	return NO;
}
-(BOOL)isComplexType
{
	return YES;
}

-(void)setHasBeenParsed: (BOOL)v
{
	hasBeenParsed = v;
}

-(BOOL)hasBeenParsed
{
	return hasBeenParsed;
}
@end
