//
//  ExampleViewController.m
//
//  Created by mcf on 12/05/2009.
//  Copyright 2009 Micropraxis Ltd. All rights reserved.
//

#import "ExampleViewController.h"
#import "frameworkService.h"

@interface ExampleViewController ()

- (BOOL) handleAuthenticateUserResult: (id) result;

@end

@implementation ExampleViewController

// When view is about to appear, contact web server to authenticate our user
- (void) viewWillAppear: (BOOL) animated
{
  WebService *webService = [WebService webService];
  NSString *selector;
  
  selector = NSStringFromSelector( @selector(handleAuthenticateUserResult:) );
  if ([_pendingCalls objectForKey: selector] == nil)
    [_pendingCalls setObject: selector forKey: [webService AuthenticateUser: @"fred" password: @"password" delegate: self]];

  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

// If the view is disappearing, cancel the network activity indicator
- (void) viewWillDisappear: (BOOL) animated
{
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

// Called when a web service call returns a value
- (void) operation: (id) operation hasResult: (id) result withError: (NSError *) error
{
  NSString *errorMessage;
  SEL selector = NSSelectorFromString( [_pendingCalls objectForKey: operation] );
  
  if (error != nil)
  {
    // Local error, e.g. failed to contact server, timed out etc.
    errorMessage = [error localizedDescription];
  }
  else if ([self performSelector: selector withObject: result])
  {
    // We got the result we were expecting
    errorMessage = nil;
  }
  else if (result != nil && [result isKindOfClass: [SOAPFault class]])
  {
    // Remote server-side error, expressed as a SOAP fault
    errorMessage = [(SOAPFault *) result simpleFaultString];
  }
  else
  {
    // No idea what went wrong!
    errorMessage = NSLocalizedString( @"Sorry, but an unexpected error has occurred - please try again",
                                     @"Message to show when a call fails for any other reason" );
  }

  [_pendingCalls removeObjectForKey: operation];

  [UIApplication sharedApplication].networkActivityIndicatorVisible = ([_pendingCalls count] > 0);
  
  if (errorMessage != nil)
  {
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle: NSLocalizedString( @"Problem", @"Title of alert to indicate a problem" )
                          message: errorMessage delegate: nil
                          cancelButtonTitle: NSLocalizedString( @"OK", @"Title of button to dismiss problem alert" )
                          otherButtonTitles: nil];
    
    [alert show];
    [alert release];
  }
}

- (BOOL) handleAuthenticateUserResult: (id) result
{
  BOOL handled = (result != nil && [result isKindOfClass: [USBoolean class]]);
  
  if (handled)
  {
    if (((USBoolean *) result).boolValue)
    {
      // Do stuff when user is authenticated
    }
    else
    {
      // Do stuff when user is not authenticated
    }
  }
  
  return handled;
}

- (void) dealloc
{
  [_pendingCalls release];
  [super dealloc];
}

@end
