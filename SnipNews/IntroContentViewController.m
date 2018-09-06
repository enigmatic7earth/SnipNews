//
//  IntroContentViewController.m
//  SnipNews
//
//  Created by NETBIZ on 02/02/17.
//  Copyright © 2017 NetBiz. All rights reserved.
//

#import "IntroContentViewController.h"

@interface IntroContentViewController ()

@end

@implementation IntroContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.backgroundImageView.image = [UIImage imageNamed:self.imageFile];
    [appSettings setBool:YES forKey:@"IntroductionDone"];
    [appSettings synchronize];
    
    //--Blinking swipe image--//
    self.swipeUpImage.alpha = 0;
    [UIView animateWithDuration:1.5 delay:0.5 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        self.swipeUpImage.alpha = 1;
    } completion:nil];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark custom methods

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
