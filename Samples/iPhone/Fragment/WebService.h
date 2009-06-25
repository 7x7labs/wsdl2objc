//
//  WebService.h
//
//  Created by mcf on 12/05/2009.
//  Copyright 2009 Micropraxis Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class frameworkServiceSoap;

@protocol WebServiceResultDelegate <NSObject>

- (void) operation: (id) operation hasResult: (id) result withError: (NSError *) error;

@end

@interface WebService : NSObject
{
@private
  frameworkServiceSoap *_binding;
}

+ (WebService *) webService;

- (id) AuthenticateUser: (NSString *) username password: (NSString *) password 
                                  delegate: (id<WebServiceResultDelegate>) delegate;

@end
