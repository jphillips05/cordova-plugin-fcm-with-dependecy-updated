#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>
#import <PushKit/PushKit.h>

@interface FCMPlugin : CDVPlugin<PKPushRegistryDelegate>
@property (nonatomic, copy) NSString *VoIPPushCallbackId;

+ (FCMPlugin *) fcmPlugin;
- (void)initVoip:(CDVInvokedUrlCommand*)command;
- (void)ready:(CDVInvokedUrlCommand*)command;
- (void)getToken:(CDVInvokedUrlCommand*)command;
- (void)removeToken:(CDVInvokedUrlCommand*)command;
- (void)subscribeToTopic:(CDVInvokedUrlCommand*)command;
- (void)unsubscribeFromTopic:(CDVInvokedUrlCommand*)command;
- (void)registerNotification:(CDVInvokedUrlCommand*)command;
- (void)notifyOfMessage:(NSData*) payload;
- (void)notifyOfTokenRefresh:(NSString*) token;
- (void)appEnterBackground;
- (void)appEnterForeground;


@end
