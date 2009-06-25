//
//  ExampleViewController.h
//
//  Created by mcf on 12/05/2009.
//  Copyright 2009 Micropraxis Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebService.h"

@interface ExampleViewController : UIViewController <WebServiceResultDelegate>
{
@private
  NSMutableDictionary *_pendingCalls;
}

@end
