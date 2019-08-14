#include <sys/types.h>
#include <sys/sysctl.h>

#import "AppDelegate+FCMPlugin.h"

#import <Cordova/CDV.h>
#import "FCMPlugin.h"
#import "Firebase.h"
#import <PushKit/PushKit.h>

@import UserNotifications;

@interface FCMPlugin () {}
@end

@implementation FCMPlugin
@synthesize VoIPPushCallbackId;

static BOOL notificatorReceptorReady = NO;
static BOOL appInForeground = YES;

static NSString *notificationCallback = @"FCMPlugin.onNotificationReceived";
static NSString *tokenRefreshCallback = @"FCMPlugin.onTokenRefreshReceived";
static FCMPlugin *fcmPluginInstance;
static NSString *voipToken = @"";

+ (FCMPlugin *) fcmPlugin {
    
    return fcmPluginInstance;
}

- (void)initVoip:(CDVInvokedUrlCommand*)command
{
  //http://stackoverflow.com/questions/27245808/implement-pushkit-and-test-in-development-behavior/28562124#28562124
  PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
  pushRegistry.delegate = self;
  pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}

- (void) ready:(CDVInvokedUrlCommand *)command
{
    NSLog(@"Cordova view ready");
    fcmPluginInstance = self;
    [self.commandDelegate runInBackground:^{
        
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
    
}

// GET TOKEN //
- (void) getToken:(CDVInvokedUrlCommand *)command 
{
    NSLog(@"get Token");
    CDVPluginResult* pluginResult = nil;
    [FCMPlugin.fcmPlugin notifyOfTokenRefresh:voipToken];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:voipToken];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// REMOVE TOKEN //
- (void) removeToken:(CDVInvokedUrlCommand *)command
{
    NSLog(@"remove Token");
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// UN/SUBSCRIBE TOPIC //
- (void) subscribeToTopic:(CDVInvokedUrlCommand *)command 
{
    NSString* topic = [command.arguments objectAtIndex:0];
    NSLog(@"subscribe To Topic %@", topic);
    [self.commandDelegate runInBackground:^{
        if(topic != nil)[[FIRMessaging messaging] subscribeToTopic:[NSString stringWithFormat:@"/topics/%@", topic]];
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:topic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) unsubscribeFromTopic:(CDVInvokedUrlCommand *)command 
{
    NSString* topic = [command.arguments objectAtIndex:0];
    NSLog(@"unsubscribe From Topic %@", topic);
    [self.commandDelegate runInBackground:^{
        if(topic != nil)[[FIRMessaging messaging] unsubscribeFromTopic:[NSString stringWithFormat:@"/topics/%@", topic]];
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:topic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) registerNotification:(CDVInvokedUrlCommand *)command
{
    NSLog(@"view registered for notifications");
    
    notificatorReceptorReady = YES;
    NSData* lastPush = [AppDelegate getLastPush];
    if (lastPush != nil) {
        [FCMPlugin.fcmPlugin notifyOfMessage:lastPush];
    }
    
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void) notifyOfMessage:(NSData *)payload
{
    NSString *JSONString = [[NSString alloc] initWithBytes:[payload bytes] length:[payload length] encoding:NSUTF8StringEncoding];
    NSString * notifyJS = [NSString stringWithFormat:@"%@(%@);", notificationCallback, JSONString];
    NSLog(@"stringByEvaluatingJavaScriptFromString %@", notifyJS);
    
    if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
        [(UIWebView *)self.webView stringByEvaluatingJavaScriptFromString:notifyJS];
    } else {
        [self.webViewEngine evaluateJavaScript:notifyJS completionHandler:nil];
    }
}


-(void) notifyOfTokenRefresh:(NSString *)token
{
    voipToken = token;
    
    NSString * notifyJS = [NSString stringWithFormat:@"%@('%@');", tokenRefreshCallback, token];
    NSLog(@"stringByEvaluatingJavaScriptFromString %@", notifyJS);
    
    if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
        [(UIWebView *)self.webView stringByEvaluatingJavaScriptFromString:notifyJS];
    } else {
        [self.webViewEngine evaluateJavaScript:notifyJS completionHandler:nil];
    }
}

-(void) appEnterBackground
{
    NSLog(@"FCM: Set state background");
    appInForeground = NO;
}

-(void) appEnterForeground
{
    NSLog(@"FCM: Set state foreground");
    NSData* lastPush = [AppDelegate getLastPush];
    if (lastPush != nil) {
        [FCMPlugin.fcmPlugin notifyOfMessage:lastPush];
    }
    appInForeground = YES;

}

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type{
    if([credentials.token length] == 0) {
        NSLog(@"FCM: No device token!");
        return;
    }

    NSLog(@"FCM: Device token: %@", credentials.token);
    const unsigned *tokenBytes = [credentials.token bytes];
    NSString *sToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                         ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                         ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                         ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];

    NSMutableDictionary* results = [NSMutableDictionary dictionaryWithCapacity:2];
    [results setObject:sToken forKey:@"deviceToken"];
    [results setObject:@"true" forKey:@"registration"];
    
    [FCMPlugin.fcmPlugin notifyOfTokenRefresh:sToken];
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type
{
//    NSDictionary *payloadDict = payload.dictionaryPayload[@"notification"];
//    NSLog(@"FCM: didReceiveIncomingPushWithPayload: %@", payloadDict);

    NSString *message = payload.dictionaryPayload[@"notification"];
    NSLog(@"FCM: received VoIP msg: %@", message);

    NSMutableDictionary* results = [NSMutableDictionary dictionaryWithCapacity:2];
    [results setObject:message forKey:@"function"];
    [results setObject:@"someOtherDataForField" forKey:@"someOtherField"];
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload.dictionaryPayload[@"data"]
                                                       options:0
                                                         error:&error];
    
    // Video / request should always open if closed and send json
    // Video / missed should send json if app is open and send notificaiton if app is not
    // all other when app is open send json
    //   else send to notification center
    
    NSDictionary *dict = payload.dictionaryPayload[@"data"];
    if([dict[@"Type"] isEqualToString:@"Video"] && [dict[@"Action"] isEqualToString:@"Request"]) {
        NSLog(@"FCM: Video Request, Sending json data");
        [FCMPlugin.fcmPlugin notifyOfMessage:jsonData];
    } else {

        if([dict[@"Type"] isEqualToString:@"Video"] && [dict[@"Action"] isEqualToString:@"Cancel"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CancelCall" object:nil];
        }

        NSLog(@"FCM: Not a Video Request");
        if(appInForeground == NO) {
            NSLog(@"FCM: App not in the foreground sending notification");
            //if app is in background send notification to system
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            UNMutableNotificationContent *content = [UNMutableNotificationContent new];
            
            content.title = [message valueForKey:@"title"];
            content.body = [message valueForKey: @"body"];
            content.sound = [UNNotificationSound defaultSound];
            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1
                                                                                                                repeats:NO];
            NSString *identifier = @"VhApp";
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                                  content:content trigger:trigger];
            
            [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                if (error != nil) {
                    NSLog(@"FCM: Something went wrong: %@",error);
                } else {
                    NSLog(@"FCM: scheduled notification");
                }
            }];
        } else {
            NSLog(@"FCM: App in foregground, sending json");
            [FCMPlugin.fcmPlugin notifyOfMessage:jsonData];
        }
    }
    
}


@end
