
#import <Cocoa/Cocoa.h>
#import "USType.h"

@interface USSimpleType : NSObject <USType> {
	NSString *typeName;
	NSString *representationClass;
	
	NSArray *enumerationValues;
	BOOL hasBeenParsed;
}

@property (copy) NSString *typeName;
@property (copy) NSString *representationClass;
@property (retain) NSArray *enumerationValues;

+(USSimpleType*)typeWithName: (NSString*)t andRepresentationClass: (NSString*)r;
-(id)initWithTypeName: (NSString*)t andRepresentationClass: (NSString*)r;

-(BOOL)isSimpleType;
-(BOOL)isComplexType;

-(void)setHasBeenParsed: (BOOL)v;
-(BOOL)hasBeenParsed;
@end
