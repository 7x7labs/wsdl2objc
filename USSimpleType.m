
#import "USSimpleType.h"


@implementation USSimpleType
@synthesize typeName;
@synthesize representationClass;
@synthesize enumerationValues;

+(USSimpleType*)typeWithName: (NSString*)t andRepresentationClass: (NSString*)r
{
	return [[[USSimpleType alloc] initWithTypeName:t andRepresentationClass:r] autorelease];
}

-(id)init
{
	return [self initWithTypeName:@"" andRepresentationClass:@""];
}

-(id)initWithTypeName: (NSString*)t andRepresentationClass: (NSString*)r
{
	if((self = [super init]))
	{
		self.typeName = t;
		self.representationClass = r;
		self.enumerationValues = [NSArray array];
		
		if([t length] == 0 && [r length] == 0)
			hasBeenParsed = NO;
		else
			hasBeenParsed = YES;
	}
	return self;
}

-(void)dealloc
{
	[typeName release];
	[representationClass release];
	[enumerationValues release];
	
	[super dealloc];
}

-(BOOL)isSimpleType
{
	return YES;
}

-(BOOL)isComplexType
{
	return NO;
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
