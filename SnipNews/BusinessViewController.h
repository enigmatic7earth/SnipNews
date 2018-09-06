//
//  BusinessViewController.h
//  SnipNews
//
//  Created by NETBIZ on 07/06/17.
//  Copyright © 2017 NetBiz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "BusinessNewsContentViewController.h"

@interface BusinessViewController : UIViewController<UIPageViewControllerDataSource>
{
    NSUserDefaults * appSettings;
    NSArray * newsArray;
    NSString * dataFilePath;
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
