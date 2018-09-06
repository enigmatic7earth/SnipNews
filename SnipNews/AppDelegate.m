//
//  AppDelegate.m
//  SnipNews
//
//  Created by NETBIZ on 18/01/17.
//  Copyright © 2017 Netbiz.in. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSLog(@"%@",NSHomeDirectory());
    //--Set background fetch--//
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    //-+--//
    //--Push Notification Code--//
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10)
    {
        UNUserNotificationCenter * notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        notificationCenter.delegate = self;
        [notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert+UNAuthorizationOptionBadge+UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * error)
         {
             [[UIApplication sharedApplication] registerForRemoteNotifications];
             if (error)
             {
                 NSLog(@"Auth. error:%@",[error localizedDescription]);
             }
         }];
        [notificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * settings) {
            
        }];
        
    }
    // For iOS < 10
    else
    {
        UIUserNotificationType type = UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound;
        UIUserNotificationSettings * settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        
    }
    //--+--//
    //--Intro View--// // Somehow UIPageControl doesn't show up in vertical view.
//    UIPageControl *pageControl = [UIPageControl appearance];
//    pageControl.pageIndicatorTintColor = [UIColor grayColor];
//    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
//    pageControl.backgroundColor = [UIColor whiteColor];
    //--+--//
    
    //--Check if the intro screens have been shown earlier--//
    // If yes, show the main app screen.
    // else show the intro screen.
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    NSUserDefaults * appSettings = [NSUserDefaults standardUserDefaults];
    NSString * introDone = [appSettings valueForKey:@"IntroductionDone"];
    
    
    
    if ([introDone isEqualToString:@"YES"])
    {
        viewController = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
    }
    else
    {
        viewController = [storyboard instantiateViewControllerWithIdentifier:@"IntroViewController"];
    }
    
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    //--+--//
    //--Set Google Ads--//
    [GADMobileAds configureWithApplicationID:GoogleMobileAdsApplicationID];
    [self initialNewsFetch]; // _PS 08-06-2017, 23-06-2017
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
-(void) initialNewsFetch //08-06-2017, 23-06-2017
{
    //1. Main view|Home:- Most Read
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RootViewController * homeViewController = [storyboard instantiateViewControllerWithIdentifier:@"RootViewController"];
//    RootViewController * homeViewController = [[RootViewController alloc] init];
    [homeViewController refreshData];
    
    //2.Arts
    ArtsViewController * artsViewController = [storyboard instantiateViewControllerWithIdentifier:@"ArtsViewController"];
    [artsViewController refreshData];
    
    //3.Business
    BusinessViewController * businessViewController = [storyboard instantiateViewControllerWithIdentifier:@"BusinessViewController"];
    [businessViewController refreshData];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"ArtsNewsAvailable" object:nil];
    
}
#pragma mark Background data fetch methods
// -- Fetching news when app is in background.
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    NSUserDefaults * appSettings = [NSUserDefaults standardUserDefaults];
    NSString * selectedViewController = [appSettings valueForKey:@"currentViewController"];
    
    NSDate *fetchStart = [NSDate date];
    
    if ([selectedViewController isEqualToString:@"Arts"]) {
        ArtsViewController *artsViewController = (ArtsViewController *)self.window.rootViewController;
        
        [artsViewController fetchNewDataWithCompletionHandler:^(UIBackgroundFetchResult result) {
            completionHandler(result);
            
            NSDate *fetchEnd = [NSDate date];
            NSTimeInterval timeElapsed = [fetchEnd timeIntervalSinceDate:fetchStart];
            NSLog(@"Background Fetch Duration: %f seconds", timeElapsed);
            
        }];
    }
    else if ([selectedViewController isEqualToString:@"Main"]){
        RootViewController * mainViewController = (RootViewController *)self.window.rootViewController;
        
        [mainViewController fetchNewDataWithCompletionHandler:^(UIBackgroundFetchResult result) {
            completionHandler(result);
            
            NSDate *fetchEnd = [NSDate date];
            NSTimeInterval timeElapsed = [fetchEnd timeIntervalSinceDate:fetchStart];
            NSLog(@"Background Fetch Duration: %f seconds", timeElapsed);
            
        }];
        
    }
    else if ([selectedViewController isEqualToString:@"Personalize"]){
        PersonalizedViewController * mainViewController = (PersonalizedViewController *)self.window.rootViewController;
        
        [mainViewController fetchNewDataWithCompletionHandler:^(UIBackgroundFetchResult result) {
            completionHandler(result);
            
            NSDate *fetchEnd = [NSDate date];
            NSTimeInterval timeElapsed = [fetchEnd timeIntervalSinceDate:fetchStart];
            NSLog(@"Background Fetch Duration: %f seconds", timeElapsed);
            
        }];
        
    }
        
    
}

#pragma mark Push Notification methods
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSString * message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    
    if (application.applicationState == UIApplicationStateInactive)
    {
        NSLog(@"Application inactive");
        [[NSUserDefaults standardUserDefaults] setValue:message forKey:@"Push_Message"];
    }
    else if (application.applicationState == UIApplicationStateBackground)
    {
        NSLog(@"Application in background");
    }
    else
    {
        NSLog(@"Application active");
    }
}
#pragma mark Notification Registration methods
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString* token = [[[[deviceToken description]
                         stringByReplacingOccurrencesOfString: @"<" withString: @""]
                        stringByReplacingOccurrencesOfString: @">" withString: @""]
                       stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken:\n%@",token);
    
}
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError:");
    NSLog(@"Error:%@",[error localizedDescription]);
    NSLog(@"Suggest:%@",[error localizedRecoverySuggestion]);
}
#pragma mark App Push notification methods

-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UNNotificationSettings *)notificationSettings
// Change: UIUserNotificationSettings>>UNNotificationSettings
{
    NSLog(@"didRegisterUserNotificationSettings");
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"UserInfo: %@",userInfo);
    NSString * messageString = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    NSLog(@"Message:%@",messageString);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PushMessage" object:self userInfo:@{@"alertString":messageString}];
}
#pragma mark UNUserNotificationCenterDelegate methods

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler
{
    NSLog(@"didReceiveNotificationResponse");
    completionHandler(UNNotificationPresentationOptionAlert);
}
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    NSLog(@"willPresentNotification");
    completionHandler(UNNotificationPresentationOptionAlert);
}

@end
