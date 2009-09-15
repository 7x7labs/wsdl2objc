//
//  WebService.m
//
//  Created by mcf on 12/05/2009.
//  Copyright 2009 Micropraxis Ltd. All rights reserved.
//

#import "WebService.h"
#import "frameworkService.h"

static WebService *commonService = nil;

@interface ResponseHandler : NSObject <NSCopying, frameworkServiceSoapResponseDelegate>
{
@private
  Class _resultClass;
  SEL _resultValueSelector;
  id<WebServiceResultDelegate> _delegate;
}

- (id) initWithResultClass: (Class) resultClass resultValueSelector: (SEL) resultValueSelector
                  delegate: (id<WebServiceResultDelegate>) delegate;

@end

@implementation ResponseHandler

- (id) initWithResultClass: (Class) resultClass resultValueSelector: (SEL) resultValueSelector
                  delegate: (id<WebServiceResultDelegate>) delegate
{
  if (self = [super init])
  {
    _resultClass = resultClass;
    _resultValueSelector = resultValueSelector;
    _delegate = [delegate retain];
  }

  return self;
}

- (void) dealloc
{
  [_delegate release];
  [super dealloc];
}

- (id) copyWithZone: (NSZone *) zone
{
  return [self retain];
}

- (void) operation: (frameworkServiceSoapOperation *) operation completedWithResponse: (frameworkServiceSoapResponse *) response
{
  NSArray *responseBodyParts = response.bodyParts;
  id result = nil;

  for (id bodyPart in responseBodyParts) 
  {
    if ([bodyPart isKindOfClass: _resultClass])
    {
      result = [bodyPart performSelector: _resultValueSelector];
      break;
    }
  }
  
  if (result == nil)
  {
    for (id bodyPart in responseBodyParts)
    {
      if ([bodyPart isKindOfClass: [SOAPFault class]])
      {
        result = bodyPart;
        break;
      }
    }
  }
  
  [_delegate operation: self hasResult: result withError: response.error];
  [self autorelease];
}

@end

@implementation WebService

- (id) init
{
  if (self = [super init])
  {
    _binding = [[frameworkServiceSoap alloc] initWithAddress: [CommonConstants webServiceURL]];
    _binding.defaultTimeout = 20; // seconds
  }
  
  return self;
}

- (void) dealloc
{
  [_binding release];
  [super dealloc];
}

+ (WebService *) webService
{
  if (commonService == nil)
  {
    [frameworkService initialize];
    commonService = [WebService new];
  }
  
  return commonService;
}

- (id) AuthenticateUser: (NSString *) username password: (NSString *) password 
                                  delegate: (id<WebServiceResultDelegate>) delegate
{
  frameworkService_AuthenticateUser *request = [frameworkService_AuthenticateUser new];
  ResponseHandler *responseHandler = [[ResponseHandler alloc] initWithResultClass: [frameworkService_AuthenticateUserResponse class]
                                                              resultValueSelector: @selector(AuthenticateUserResult)
                                                                         delegate: delegate];
  
  request.userUsername = username;
  request.userPassword = password;
  
  [_binding AuthenticateUserAsyncUsingParameters: request delegate: responseHandler];
  [request release];
  
  return responseHandler;
}

@end
