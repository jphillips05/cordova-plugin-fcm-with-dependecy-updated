//
//  AppDelegate+FCMPlugin.h
//  TestApp
//
//  Created by felipe on 12/06/16.
//
//

#import "AppDelegate.h"
#import <UIKit/UIKit.h>
#import <Cordova/CDVViewController.h>
#import <PushKit/PushKit.h>


@interface AppDelegate (FCMPlugin)

+ (NSData*)getLastPush;
+ (PKPushPayload*)getLastVoipPush;
+ (NSString*) getLastPushType;
+ (PKPushRegistry*) getPushRegitry;


@end
