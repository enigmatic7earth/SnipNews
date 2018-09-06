//
//  RootViewController.h
//  SnipNews
//
//  Created by NETBIZ on 18/01/17.
//  Copyright © 2017 Netbiz.in. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "NewsContentViewController.h"
#import "Constants.h"


@interface RootViewController : UIViewController <UIPageViewControllerDataSource>
{
    NSUserDefaults * appSettings;
    NSArray * newsArray;
    NSString * dataFilePath;
    NSDictionary * displayDictionary;
    BOOL isInternetConnectionAvailable;
    
}
@property (strong, nonatomic) UIPageViewController *pageViewController;

@property BOOL newsAvailable;
@property (strong, nonatomic) NSMutableArray *pageImage;
@property (strong, nonatomic) NSMutableArray *pageTitles;
@property (strong, nonatomic) NSMutableArray *pagePublishDate;
@property (strong, nonatomic) NSMutableArray *pageMoreLink;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuButton;
- (IBAction)reloadNews:(UIBarButtonItem *)sender;

-(void)refreshData;
-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end
