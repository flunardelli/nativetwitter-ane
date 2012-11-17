#import "FlashRuntimeExtensions.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

// C interface

DEFINE_ANE_FUNCTION(IsTwitterAvailable);
DEFINE_ANE_FUNCTION(IsTwitterSetup);
DEFINE_ANE_FUNCTION(ComposeTweet);
DEFINE_ANE_FUNCTION(GetHomeTimeline);
DEFINE_ANE_FUNCTION(GetTwitterUsernames);
DEFINE_ANE_FUNCTION(GetMentions);
DEFINE_ANE_FUNCTION(GetTWRequest);

void CreateAndCallTWRequest(FREContext context, NSString *resourceName, NSString *reqMethod, NSString *paramsJSON, int32_t accountId, uint8_t *succesCallback, uint8_t *errorCallback, uint8_t *requestingMethod);

// ANE setup

/* NativeTwitterExtInitializer()
 * The extension initializer is called the first time the ActionScript side of the extension
 * calls ExtensionContext.createExtensionContext() for any context.
 *
 * Please note: this should be same as the <initializer> specified in the extension.xml 
*/
void NativeTwitterExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);

/* NativeTwitterExtFinalizer()
 * The extension finalizer is called when the runtime unloads the extension. However, it may not always called.
 *
 * Please note: this should be same as the <finalizer> specified in the extension.xml 
*/
void NativeTwitterExtFinalizer(void* extData);

/* ContextInitializer()
 * The context initializer is called when the runtime creates the extension context instance.
*/
void ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);

/* ContextFinalizer()
 * The context finalizer is called when the extension's ActionScript code
 * calls the ExtensionContext instance's dispose() method.
 * If the AIR runtime garbage collector disposes of the ExtensionContext instance, the runtime also calls ContextFinalizer().
*/
void ContextFinalizer(FREContext ctx);


