//
//  IntroContentViewController.h
//  SnipNews
//
//  Created by NETBIZ on 02/02/17.
//  Copyright © 2017 NetBiz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroContentViewController : UIViewController

{
    NSUserDefaults * appSettings;
    BOOL blinkStatus;
}
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property NSUInteger pageIndex;
@property NSString * imageFile;
@property (strong, nonatomic) IBOutlet UIImageView *swipeUpImage;

@end
