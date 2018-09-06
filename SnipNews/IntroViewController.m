//
//  IntroViewController.m
//  SnipNews
//
//  Created by NETBIZ on 02/02/17.
//  Copyright © 2017 NetBiz. All rights reserved.
//

#import "IntroViewController.h"
#import "RootViewController.h"

@interface IntroViewController ()

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _introPages = [NSArray arrayWithObjects:@"1",@"2",@"3", nil];
    _pageImages = @[@"page1.png", @"page2.png", @"page3.png",];
    
    //Instantiate a page view controller
    
    _pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"IntroPageViewController"];
    _pageViewController.dataSource = self;
    
    // Create page view controller
    IntroContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray * viewControllers = @[startingViewController];
    [_pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    //Changing the size of Page View Controller
    _pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 40);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [_pageViewController didMoveToParentViewController:self];
    
    appSettings = [NSUserDefaults standardUserDefaults];
    [appSettings setValue:@"YES" forKey:@"IntroductionDone"];
    [appSettings synchronize];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)startIntroAgain:(id)sender
{
    IntroContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [_pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
}

- (IBAction)okButtonClicked:(id)sender
{
}
#pragma mark UIPageViewControllerDataSource methods
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    // We have to verify if we have reached the boundaries of the pages and return nil in that case.
    NSUInteger index = ((IntroContentViewController *) viewController).pageIndex;
    if ((index == 0)||(index == NSNotFound))
    {
        return nil;
    }
    index-- ;
    
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    // We have to verify if we have reached the boundaries of the pages and return nil in that case.
    NSUInteger index = ((IntroContentViewController *) viewController).pageIndex;
    if (index == NSNotFound)
    {
        return nil;
    }
    index++ ;
    // Last page reached.
    if (index == [self.introPages count]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}
-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [_introPages count];
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}
#pragma mark Helper methods
- (IntroContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.introPages count] == 0) || (index >= [self.introPages count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    IntroContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"IntroContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}
@end
