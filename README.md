# First steps

## Generating code out of the WSDL file

Once you obtain WSDL2ObjC, code generation is pretty simple.

1. Launch the app
2. Browse to a WSDL file or enter in a URL
3. Browse to an output directory
3. Click "Parse WSDL"

Source code files will be added to the output directory you've specified. There will be one pair of .h/.m files for each namespace in your WSDL.

## Including the generated source files

You can add the output files to your project or create a web service framework from them. Each project that uses the generated web service code will need to link against libxml2 by performing the following for each target in your XCode project:

1. Go to the General tab of the project target
2. Add libxml2.dylib to Linked Frameworks and Libraries
3. If building for iOS, also add CFNetworking.framework
4. Go to the Build Settings tab
5. Add $(SDKROOT)/usr/include/libxml2 to the Header Search Paths property


## Using the generated code

You can use a given web service as follows:

```objective-c
#import "MyWebService.h"

    MyWebServiceBinding *binding = [MyWebService MyWebServiceBinding];
    binding.logXMLInOut = YES;

    ns1_MyOperationRequest *request = [ns1_MyOperationRequest new];
    request.attribute = @"attributeValue";
    request.element = [ns1_MyElement new];
    request.element.value = @"elementValue"];

    MyWebServiceBindingResponse *response = [binding myOperationUsingParameters:request];

    NSArray *responseHeaders = response.headers;
    NSArray *responseBodyParts = response.bodyParts;

    for (id header in responseHeaders) {
        if ([header isKindOfClass:[ns2_MyHeaderResponse class]]) {
            ns2_MyHeaderResponse *headerResponse = (ns2_MyHeaderResponse*)header;

            // ... Handle ns2_MyHeaderResponse ...
        }
    }

    for (id bodyPart in responseBodyParts) {
        if ([bodyPart isKindOfClass:[ns2_MyBodyResponse class]]) {
            ns2_MyBodyResponse *body = (ns2_MyBodyResponse*)bodyPart;

            // ... Handle ns2_MyBodyResponse ...
        }
    }
```

### Example

Assume the following:

 * A SOAP service called "Friends"
 * A SOAP method called GetFavoriteColor that has a request attribute called Friend, and a response attribute called Color (i.e. you're asking it to return you the favorite color for a given a friend)
 * All the methods in this service ask for basic HTTP authentication, using a username and password that you acquired from the user via text fields 

```objective-c
- (IBAction)pressedRequestButton:(id)sender {
    FriendsBinding *bFriends = [FriendsService FriendsBinding];
    bFriends.logXMLInOut = YES;
    bFriends.authUsername = u.text;
    bFriends.authPassword = p.text;

    types_getFavoriteColorRequestType *cRequest = [types_getFavoriteColorRequestType new];
    cRequest.friend = @"Johnny";
    [bFriends getFavoriteColorAsyncUsingRequest:cRequest delegate:self];
}

- (void) operation:(FriendsBindingOperation *)operation completedWithResponse:(FriendsBindingResponse *)response {
    NSArray *responseHeaders = response.headers;
    NSArray *responseBodyParts = response.bodyParts;

    for (id header in responseHeaders) {
        // here do what you want with the headers, if there's anything of value in them
    }

    for (id bodyPart in responseBodyParts) {
        /****
         * SOAP Fault Error
         ****/
        if ([bodyPart isKindOfClass:[SOAPFault class]]) {
            // You can get the error like this:
            tV.text = ((SOAPFault *)bodyPart).simpleFaultString;
            continue;
        }

        /****
         * Get Favorite Color
         ****/
        if ([bodyPart isKindOfClass:[types_getFavoriteColorResponseType class]]) {
            types_getFavoriteColorResponseType *body = (types_getFavoriteColorResponseType*)bodyPart;
            // Now you can extract the color from the response
            q.text = body.color;
            continue;
        }
        // ...
    }
}
```

### NOTE

If a WSDL has defined a string type that has attributes, then wsdl2objc will map it to a generic NSObject with a property called "content" which will hold the actual string. So if you want to use the string, you have to call object.content. If you want its attributes, they're also properties of the object. The short reason for this is that Cocoa makes it very hard to subclass NSStrings.
