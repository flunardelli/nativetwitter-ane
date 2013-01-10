#import "NativeTwitter.h"

#define TWITTER_URL @"http://api.twitter.com/1.1/"

FREContext NativeTwitterCtx = nil;

#pragma mark - C interface

DEFINE_ANE_FUNCTION(IsTwitterAvailable)
{
    TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
    BOOL twitterSDKAvailable = tweetViewController != nil;
    
    // http://brianistech.wordpress.com/2011/10/13/ios-5-twitter-integration/
    if(tweetViewController != nil){
        [tweetViewController release];
    }
    
    FREObject result = nil;
    
    FRENewObjectFromBool(twitterSDKAvailable, &result);
 
    return result;
}

DEFINE_ANE_FUNCTION(IsTwitterSetup)
{
    BOOL isSetup = [TWTweetComposeViewController canSendTweet];
    FREObject result = nil;
    
    FRENewObjectFromBool(isSetup, &result);
    
    return result;
}

DEFINE_ANE_FUNCTION(ComposeTweet)
{
    uint32_t textLength;
    const uint8_t *text;
    uint32_t urlLength;
    const uint8_t *url;
    uint32_t imageLength;
    const uint8_t *image;
    
    TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
    
    uint8_t error = 0;
    
    if (FREGetObjectAsUTF8(argv[0], &textLength, &text) == FRE_OK) {
        NSString *tweetText = [NSString stringWithUTF8String:(char *)text];
        
        if (![tweetViewController setInitialText:tweetText]) {
            error = 1;
        }
    }
    
    if (FREGetObjectAsUTF8(argv[1], &imageLength, &image) == FRE_OK) {
        BOOL ok;
        
        NSString *imageAttach = [NSString stringWithUTF8String:(char *)image];
        // Note that the image is loaded syncronously
        if ([imageAttach hasPrefix:@"http://"] || [imageAttach hasPrefix:@"https://"]) {
            UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageAttach]]];
            ok = [tweetViewController addImage:img];
            [img release];
        }
        else {
            ok = [tweetViewController addImage:[UIImage imageNamed:imageAttach]];
        }
        
        if (!ok) {
            error |= 2;
        }
    }
    
	if (FREGetObjectAsUTF8(argv[2], &urlLength, &url) == FRE_OK) {
        NSString *urlAttach = [NSString stringWithUTF8String:(char *)url];
        
        if (![tweetViewController addURL:[NSURL URLWithString:urlAttach]]) {
            error |= 4;
        }
    }
    
    
    if (error > 0) {
        NSString* returnString = [NSString stringWithFormat:@"%d", error];
        FREDispatchStatusEventAsync(context, (uint8_t*)"tweetComposed", (const uint8_t*)[returnString UTF8String]);
        //[returnString release];
    }
    else{
        
        [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
            if (result == TWTweetComposeViewControllerResultDone)
                FREDispatchStatusEventAsync(context, (uint8_t*)"tweetComposed", (uint8_t*)"0");
            else
                FREDispatchStatusEventAsync(context, (uint8_t*)"tweetComposed", (uint8_t*)"8");
            
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissViewControllerAnimated:YES completion:NULL];
            
        }];
        
       [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:tweetViewController animated:YES completion:NULL];
    }
    
    [tweetViewController release];
    
    return NULL;
}

DEFINE_ANE_FUNCTION(GetTwitterUsernames)
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if (granted) {
            NSMutableString *usernames = [NSMutableString new];
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            if ([accountsArray count] > 0) {
                for (ACAccount* account in accountsArray) {
                    [usernames appendFormat:@"%@/", account.username];
                }
            }
            
            FREDispatchStatusEventAsync(context, (uint8_t*)"getTwitterUsernames", (const uint8_t*)[usernames UTF8String]);
            
            [usernames release];
        }
        else {
            FREDispatchStatusEventAsync(context, (uint8_t*)"deniedAccess", (uint8_t*)"mentionsRequest");
        }
    }];
    
    [accountStore release];
    
    return NULL;
}

DEFINE_ANE_FUNCTION(GetHomeTimeline)
{
    int32_t accountId;
    
    FREGetObjectAsInt32(argv[0], &accountId);

    CreateAndCallTWRequest(context, @"statuses/home_timeline.json", @"GET", nil, accountId, (uint8_t *)"homeTimelineRequested", (uint8_t *)"homeTimelineRequestError", (uint8_t*)"homeTimelineRequest");
    
    return NULL;
}

DEFINE_ANE_FUNCTION(GetMentions)
{
    int32_t accountId;
    
    FREGetObjectAsInt32(argv[0], &accountId);
    
    CreateAndCallTWRequest(context, @"statuses/mentions_timeline.json", @"GET", nil, accountId, (uint8_t *)"mentionsRequested", (uint8_t *)"mentionsRequestError", (uint8_t*)"mentionsRequest");
    
    return NULL;
}

DEFINE_ANE_FUNCTION(GetTWRequest)
{
 
    uint32_t urlLength;
    const uint8_t *urlSlug;
    uint32_t paramsLength;
    const uint8_t *paramsUTF8;
    uint32_t reqMethodLength;
    const uint8_t *reqMethodUTF8;
    int32_t accountId;
    
    NSString *params = nil;
    
    FREGetObjectAsUTF8(argv[0], &urlLength, &urlSlug);
    FREGetObjectAsUTF8(argv[2], &reqMethodLength, &reqMethodUTF8);
    FREGetObjectAsInt32(argv[3], &accountId);

    if (FREGetObjectAsUTF8(argv[1], &paramsLength, &paramsUTF8) == FRE_OK) {
        params = [NSString stringWithUTF8String:(char *)paramsUTF8];
    }
    
    CreateAndCallTWRequest(context, [NSString stringWithUTF8String:(char *)urlSlug], [NSString stringWithUTF8String:(char *)reqMethodUTF8], params, accountId, (uint8_t *)"twRequestResult", (uint8_t *)"twRequestError", (uint8_t*)"twRequest");
    
    return NULL;
}

void CreateAndCallTWRequest(FREContext context, NSString *resourceName, NSString *reqMethod, NSString *paramsJSON, int32_t accountId, uint8_t *succesCallback, uint8_t *errorCallback, uint8_t *requestingMethod) {

    NSString *url = [NSString stringWithFormat:@"%@%@", TWITTER_URL, resourceName];
    
    NSDictionary *params = nil;
    if (paramsJSON != nil) {
        NSError *jsonError = nil;
        params = [NSJSONSerialization JSONObjectWithData:[paramsJSON dataUsingEncoding:NSUTF8StringEncoding]
                                                 options:NSJSONReadingMutableLeaves
                                                 error:&jsonError];
        
        if (jsonError) {
            NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
            FREDispatchStatusEventAsync(context, errorCallback, (uint8_t *)"-1");
            return;
        }
    }
    
    TWRequestMethod method;
    if ([reqMethod isEqualToString:@"POST"]) {
        method = TWRequestMethodPOST;
    }
    else if ([reqMethod isEqualToString:@"DELETE"]) {
        method = TWRequestMethodDELETE;
    }
    else {
        method = TWRequestMethodGET;
    }
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
			// making assumption they only have one twitter account configured, should probably revist
            if([accountsArray count] > accountId) {
                TWRequest *request = [[TWRequest alloc] initWithURL:[NSURL URLWithString:url]
                                                         parameters:params
                                                      requestMethod:method];
                
                [request setAccount:[accountsArray objectAtIndex:accountId]];
                
                @try {
                    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        if ([urlResponse statusCode] == 200) {
                            NSString *dataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                            FREDispatchStatusEventAsync(context, succesCallback, (uint8_t *)[dataString UTF8String]);
                            [dataString release];
                        }
                        else {
                            FREDispatchStatusEventAsync(context, errorCallback, (uint8_t *)[[NSString stringWithFormat:@"%i", [urlResponse statusCode]]UTF8String]);
                        }
                    }];
                } @catch (NSException *e) {
                    FREDispatchStatusEventAsync(context, errorCallback, (uint8_t *)"-1");
                }
                [request release];
            }
            else {
                FREDispatchStatusEventAsync(context, (uint8_t*)"nonexistentAccount", (uint8_t*)[[NSString stringWithFormat:@"%d",accountId] UTF8String]);
            }
        }
        else {
            FREDispatchStatusEventAsync(context, (uint8_t*)"deniedAccess", requestingMethod);
        }
    }];
    
    [accountStore release];
}

#pragma mark - ANE setup

/* NativeTwitterExtInitializer()
 * The extension initializer is called the first time the ActionScript side of the extension
 * calls ExtensionContext.createExtensionContext() for any context.
 *
 * Please note: this should be same as the <initializer> specified in the extension.xml 
 */
void NativeTwitterExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet) 
{
    *extDataToSet = NULL;
    *ctxInitializerToSet = &NativeTwitterContextInitializer;
    *ctxFinalizerToSet = &NativeTwitterContextFinalizer;
}

/* NativeTwitterExtFinalizer()
 * The extension finalizer is called when the runtime unloads the extension. However, it may not always called.
 *
 * Please note: this should be same as the <finalizer> specified in the extension.xml 
 */
void NativeTwitterExtFinalizer(void* extData) 
{
    // Nothing to clean up.
    return;
}

/* ContextInitializer()
 * The context initializer is called when the runtime creates the extension context instance.
 */
void NativeTwitterContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    // The following code describes the functions that are exposed by this native extension to the ActionScript code.
    *numFunctionsToTest = 7;

    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * (*numFunctionsToTest));
    func[0].name = (const uint8_t*) "isTwitterAvailable";
    func[0].functionData = NULL;
    func[0].function = &IsTwitterAvailable;

    func[1].name = (const uint8_t*) "isTwitterSetup";
    func[1].functionData = NULL;
    func[1].function = &IsTwitterSetup;
    
    func[2].name = (const uint8_t*) "composeTweet";
    func[2].functionData = NULL;
    func[2].function = &ComposeTweet;
    
    func[3].name = (const uint8_t*) "getHomeTimeline";
    func[3].functionData = NULL;
    func[3].function = &GetHomeTimeline;
    
    func[4].name = (const uint8_t*) "getTwitterUsernames";
    func[4].functionData = NULL;
    func[4].function = &GetTwitterUsernames;
    
    func[5].name = (const uint8_t*) "getMentions";
    func[5].functionData = NULL;
    func[5].function = &GetMentions;
    
    func[6].name = (const uint8_t*) "getTWRequest";
    func[6].functionData = NULL;
    func[6].function = &GetTWRequest;
    
    *functionsToSet = func;

    NativeTwitterCtx = ctx;
}

/* ContextFinalizer()
 * The context finalizer is called when the extension's ActionScript code
 * calls the ExtensionContext instance's dispose() method.
 * If the AIR runtime garbage collector disposes of the ExtensionContext instance, the runtime also calls ContextFinalizer().
 */
void NativeTwitterContextFinalizer(FREContext ctx)
{
    // Nothing to clean up.
    return;
}


