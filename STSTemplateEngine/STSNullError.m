//
//	STSNullError.m
//	STS Null Error Library ver 1.00
//
//	Extends NSError with a null-error object to represent "No errors".
//
//	Created by benjk on 7/19/05.
//
//	This software is released as open source under the terms of the new BSD
//	License obtained from http://www.opensource.org/licenses/bsd-license.php
//	on Tuesday, July 19, 2005.  The full license text follows below.
//
//	Copyright 2005 Sunrise Telephone Systems Ltd. All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modi-
//	fication, are permitted provided that the following conditions are met:
//
//	Redistributions of source code must retain the above copyright notice,
//	this list of conditions and the following disclaimer.  Redistributions in
//	binary form must reproduce the above copyright notice, this list of
//	conditions and the following disclaimer in the documentation and/or other
//	materials provided with the distribution.  Neither the name of Sunrise
//	Telephone Systems Ltd. nor the names of its contributors may be used to
//	endorse or promote products derived from this software without specific
//	prior written permission.
//
//	THIS  SOFTWARE  IS  PROVIDED  BY  THE  COPYRIGHT HOLDERS  AND CONTRIBUTORS
//	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,  INCLUDING, BUT NOT LIMITED
//	TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//	PURPOSE  ARE  DISCLAIMED.  IN  NO  EVENT  SHALL  THE  COPYRIGHT  OWNER  OR
//	CONTRIBUTORS  BE  LIABLE  FOR  ANY  DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//	EXEMPLARY,  OR  CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT LIMITED  TO,
//	PROCUREMENT  OF SUBSTITUTE  GOODS  OR  SERVICES;  LOSS  OF  USE,  DATA, OR
//	PROFITS;  OR  BUSINESS  INTERRUPTION)  HOWEVER CAUSED AND ON ANY THEORY OF
//	LIABILITY,  WHETHER  IN  CONTRACT,  STRICT LIABILITY,  OR TORT  (INCLUDING
//	NEGLIGENCE OR OTHERWISE)  ARISING  IN  ANY  WAY  OUT  OF  THE  USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "STSNullError.h"

#define kEmptyString @""

@implementation NSError (STSNullErrorCategory)

- (id)initWithNullError;
{
	return [self initWithDomain:kEmptyString code:0 userInfo:nil];
} // end method

- (BOOL)isNullError;
{
	return ([[self domain] length] == 0) && ([self code] == 0);
} // end method

@end // STSNullError
