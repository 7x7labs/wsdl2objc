#import "USGlobals.h"

@implementation USGlobals
+ (USGlobals *)sharedInstance {
    static USGlobals *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ sharedInstance = [USGlobals new]; });
    return sharedInstance;
}

- (id)init {
    if ((self = [super init]))
        _wsdlStandardNamespaces = [[NSMutableDictionary alloc] init];

    return self;
}
@end
