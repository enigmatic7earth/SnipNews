//
//  BookmarksViewController.h
//  SnipNews
//
//  Created by NETBIZ on 09/02/17.
//  Copyright © 2017 NetBiz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "BookmarksContentViewController.h"
#import "Constants.h"

@interface BookmarksViewController : UIViewController<UIPageViewControllerDataSource>
{
    NSUserDefaults * appSettings;
    NSArray * bookmarksArray;
    NSString * dataFilePath;
    NSDictionary * displayDictionary;
    
}
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property BOOL bookmarksAvailable;
@property (strong, nonatomic) NSMutableArray *pageImage;
@property (strong, nonatomic) NSMutableArray *pageTitles;
@property (strong, nonatomic) NSMutableArray *pagePublishDate;
@property (strong, nonatomic) NSMutableArray *pageMoreLink;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuButton;



@end
