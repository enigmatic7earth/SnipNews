//
//  ArtsViewController.h
//  SnipNews
//
//  Created by NETBIZ on 07/02/17.
//  Copyright © 2017 NetBiz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArtsNewsContentViewController.h"
#import "Constants.h"

@interface ArtsViewController : UIViewController <UIPageViewControllerDataSource>
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
