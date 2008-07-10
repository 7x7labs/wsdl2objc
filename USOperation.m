//
//  USOperation.m
//  WSDLParser
//
//  Created by James Williams on 7/9/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "USOperation.h"


@implementation USOperation
@synthesize name;
@synthesize input;
@synthesize output;

-(id) init
{
	if((self = [super init]))
	{
		self.name = @"";
		self.input = nil;
		self.output = nil;
	}
	
	return self;
}
@end
