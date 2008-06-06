
#import <Cocoa/Cocoa.h>

@protocol USType
-(NSString*) typeName;
-(BOOL)isSimpleType;
-(BOOL)isComplexType;

-(void)setHasBeenParsed: (BOOL)v;
-(BOOL)hasBeenParsed;
@end