//
//  AppDelegate.h
//  SnipNews
//
//  Created by NETBIZ on 18/01/17.
//  Copyright © 2017 Netbiz.in. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "Constants.h"

@import GoogleMobileAds; // Google Mobile Ads

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>  
{
    UIViewController * viewController;
}
@property (strong, nonatomic) UIWindow *window;


@end

