//
//  BookmarksViewController.m
//  SnipNews
//
//  Created by NETBIZ on 09/02/17.
//  Copyright © 2017 NetBiz. All rights reserved.
//

#import "BookmarksViewController.h"
#import "RootViewController.h"

@interface BookmarksViewController ()

@end

@implementation BookmarksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self allocInits];
    [self initMenuBar];
    self.view.backgroundColor = appBackgroundColor;
    //--Set NSUserDefaults--//
    appSettings = [NSUserDefaults standardUserDefaults];
    [appSettings setValue:@"YES" forKey:@"IntroductionDone"];
    [appSettings synchronize];
    //--+--//
        //--Load the file that saves bookmarks--//
    [self loadBookmarks];
    
    if (_bookmarksAvailable == YES)
    {
        [self setupPageViewController];
    }
    else
    {
        [self showNoNewsMessage];
//        [self performSegueWithIdentifier:@"navHome" sender:self];// Discouraged, but works. Find alternative.
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"SnipNews" message:@"You haven't bookmarked any article yet.\nPlease bookmark articles." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        }];
        
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [self loadBookmarks];
    [self showNoNewsMessage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((BookmarksContentViewController*) viewController).newsIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((BookmarksContentViewController *) viewController).newsIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

#pragma mark Helper methods
-(void) allocInits
{
    bookmarksArray = [[NSMutableArray alloc] init];
    _pageTitles = [[NSMutableArray alloc] init];
    _pagePublishDate = [[NSMutableArray alloc] init];
    _pageImage = [[NSMutableArray alloc] init];
    _pageMoreLink = [[NSMutableArray alloc] init];
}
-(void) initMenuBar
{
    SWRevealViewController * revealViewController = self.revealViewController;
    
    if (revealViewController) {
        [_menuButton setTarget:self.revealViewController];
        [_menuButton setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

-(void) loadBookmarks
{
    [self allocInits];
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * docDirectory = [paths objectAtIndex:0];
    NSString * bookmarksFilePath = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:@"bookmarks"]]; // BookmarksFile
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:bookmarksFilePath])
    {
        bookmarksArray = [[NSMutableArray alloc] initWithContentsOfFile:bookmarksFilePath];
        NSLog(@"bookmarksArray:\n%@", bookmarksArray);
        
        
        for (int i = 0; i < [bookmarksArray count]; i++) {
            NSDictionary * tempDict = [NSDictionary dictionaryWithDictionary:[bookmarksArray objectAtIndex:i]];
            NSLog(@"tempDict%d = %@",i,tempDict);
            //Static//
            /*
            [_pageImage addObject:[tempDict valueForKey:@"articleImage"]];
            [_pageTitles addObject:[tempDict valueForKey:@"articleHeading"]];
            [_pagePublishDate addObject:[tempDict valueForKey:@"articlePublishDate"]];
            [_pageMoreLink addObject:[tempDict valueForKey:@"articleMoreLink"]];
             */
            //Live
            [_pageTitles addObject:[tempDict valueForKey:@"title"]];
            [_pagePublishDate addObject:[tempDict valueForKey:@"pubDate"]];
            [_pageMoreLink addObject:[tempDict valueForKey:@"link"]];
        }
        _bookmarksAvailable = YES;
    }
    else
    {
        _bookmarksAvailable = NO;
    }

}


- (BookmarksContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        
//        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    BookmarksContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BookmarksNewsContentController"];
    
    //pageContentViewController.newsArticleImage = [NSString stringWithFormat:@"%@",self.pageImage[index]];
    pageContentViewController.newsArticleHeading = self.pageTitles[index];
    pageContentViewController.newsArticlePublishedDate = self.pagePublishDate[index];
    pageContentViewController.newsArticleMoreLink = self.pageMoreLink[index];
    pageContentViewController.newsIndex = index;
    //NSLog(@"Details:\n%@\n%@\n%@\n%@",pageContentViewController.newsArticleImage,pageContentViewController.newsArticleHeading,pageContentViewController.newsArticlePublishedDate,pageContentViewController.newsArticleMoreLink);
   
    return pageContentViewController;
}
-(void) setupPageViewController
{
    //--Creating the PageViewController--//
    _pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BookmarksPageViewController"];
    _pageViewController.dataSource = self;
    
    BookmarksContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    _pageViewController.view.frame = self.view.bounds;
    
    [self addChildViewController:_pageViewController];
    
    [self.view addSubview:_pageViewController.view];
    [_pageViewController didMoveToParentViewController:self];
    //--Adding rounded edges to the view--//
    //self.view.layer.cornerRadius = 10.0;
    //self.view.layer.masksToBounds = YES;
}
-(void) showNoNewsMessage
{
    UILabel * message = [[UILabel alloc] initWithFrame:self.view.frame];
    message.numberOfLines = 2;
    message.textColor = [UIColor darkGrayColor];
    message.textAlignment = NSTextAlignmentCenter;
    message.backgroundColor = appBackgroundColor;
    message.text = @"No articles bookmarked articles.";
    if (_bookmarksAvailable == YES) {
        message.hidden = YES;
    }
    else
    {
        message.hidden = NO;
    }
    [self.view addSubview:message];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
