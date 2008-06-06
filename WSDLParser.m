#import <Foundation/Foundation.h>
#import "USParserApplication.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	USParserApplication *app = [[USParserApplication alloc] initWithArgs:argv andArgCount:argc];
	
	if([app passesSanityCheck])
	{
		[app magic];
	}
	
	[app release];
    [pool drain];
    return 0;
}
