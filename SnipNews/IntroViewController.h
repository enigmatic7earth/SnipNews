//
//  IntroViewController.h
//  SnipNews
//
//  Created by NETBIZ on 02/02/17.
//  Copyright © 2017 NetBiz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntroContentViewController.h"

@interface IntroViewController : UIViewController<UIPageViewControllerDataSource>
{
    NSUserDefaults * appSettings;
}
@property (strong,nonatomic) UIPageViewController * pageViewController;
@property (strong, nonatomic) NSArray * introPages;
@property (strong, nonatomic) NSArray * pageImages;
- (IBAction)startIntroAgain:(id)sender;
- (IBAction)okButtonClicked:(id)sender;



@end
