
#import <Cocoa/Cocoa.h>
#import "USSequenceElement.h"
#import "USType.h"
#import "USAttribute.h"

@interface USComplexType : NSObject <USType> {
	NSString *typeName;
	USComplexType *superClass;
	NSArray *sequenceElements;
	NSArray *attributes;
	
	BOOL hasBeenParsed;
}

@property (copy) NSString *typeName;
@property (retain) USComplexType *superClass;
@property (retain) NSArray *sequenceElements;
@property (retain) NSArray *attributes;

-(BOOL)isSimpleType;
-(BOOL)isComplexType;

-(void)setHasBeenParsed: (BOOL)v;
-(BOOL)hasBeenParsed;
@end
