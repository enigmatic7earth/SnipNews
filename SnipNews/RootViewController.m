//
//  RootViewController.m
//  SnipNews
//
//  Created by NETBIZ on 18/01/17.
//  Copyright © 2017 Netbiz.in. All rights reserved.
//

#import "RootViewController.h"
#import "Reachability.h"

@interface RootViewController ()
@property (nonatomic, strong) NSArray *arrNewsData;
@property (nonatomic) Reachability *internetReachability;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = appBackgroundColor;
    [self allocInits];
    [self initMenuBar];
    //--Set NSUserDefaults--//
    appSettings = [NSUserDefaults standardUserDefaults];
    [appSettings setValue:@"YES" forKey:@"IntroductionDone"];
    [appSettings setValue:@"Main" forKey:@"currentViewController"]; //29-May-2017_PS addition for checking which fetch method to call in Appdelegate
    [appSettings synchronize];
    //--+--//
    
    
    //--Load the file that saves news--//
    [self loadNews];
    
    if (_newsAvailable == YES)
    {
        [self setupPageViewController];
    }
    else
    {
        //23-06-2017
        [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(reloadNews) userInfo:nil repeats:NO];
    }
    //--Reachability--
    /*
     Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
    //--+--//
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((NewsContentViewController*) viewController).newsIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((NewsContentViewController*) viewController).newsIndex;
    
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
    newsArray = [[NSMutableArray alloc] init];
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
-(void) loadNews
 {
     // New approach, loads RSS feeds
     NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString * docDirectory = [paths objectAtIndex:0];
     NSString * newsFilePath = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:@"mostRead"]]; // NewsFile
     
     if ([[NSFileManager defaultManager] fileExistsAtPath:newsFilePath])
     {
         _newsAvailable = YES;
         newsArray = [[NSMutableArray alloc] initWithContentsOfFile:newsFilePath];
         NSLog(@"newsArray available");
         
         for (int i = 0; i < [newsArray count]; i++) {
             NSDictionary * tempDict = [NSDictionary dictionaryWithDictionary:[newsArray objectAtIndex:i]];
             //NSLog(@"tempDict%d = %@",i,tempDict);
             [_pageTitles addObject:[tempDict valueForKey:@"title"]];
             [_pagePublishDate addObject:[tempDict valueForKey:@"pubDate"]];
             [_pageMoreLink addObject:[tempDict valueForKey:@"link"]];
             
         }
     }
     else
     {
         _newsAvailable = NO;
         //[self showNoNewsMessage];
     }
    
}
-(void) setupPageViewController
{
    //--Creating the PageViewController--//
    _pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    _pageViewController.dataSource = self;
    
    NewsContentViewController *startingViewController = [self viewControllerAtIndex:0];
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

- (NewsContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    NewsContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NewsContentController"];
    //New
    pageContentViewController.newsArticleHeading = self.pageTitles[index];
    pageContentViewController.newsArticlePublishedDate = self.pagePublishDate[index];
    pageContentViewController.newsArticleMoreLink = self.pageMoreLink[index];
    pageContentViewController.newsIndex = index;
    
    // setting the size of pageview
    //_pageViewController.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+44, self.view.frame.size.width, self.view.frame.size.height-44) ;
    return pageContentViewController;
}
-(void) showNoNewsMessage
{
    UILabel * message = [[UILabel alloc] initWithFrame:self.view.frame];
    message.numberOfLines = 2;
    message.textColor = [UIColor darkGrayColor];
    message.textAlignment = NSTextAlignmentCenter;
    message.backgroundColor = appBackgroundColor;
    message.text = @"No news is currently available.\n Please try refershing again.";
    if (_newsAvailable == YES) {
        message.hidden = YES;
        
    }
    else
    {
        message.hidden = NO;
    }
    [self.view addSubview:message];
}
-(void)reloadNews //23-06-2017
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
        });
    });
    double delayInSeconds = 1.0;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadNews];
        [self setupPageViewController];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    });
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark IBActions
- (IBAction)reloadNews:(UIBarButtonItem *)sender
{
    // New'
    if (isInternetConnectionAvailable) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                
            });
        });
        double delayInSeconds = 0.5;
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self refreshData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
        });
        
    }
    else
    {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Internet" message:@"Kindly check your internet connection!\n If it is off,please turn it on and try again." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //Opening settings app if iOS > = 8.0
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                //Open settings app
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];//
            };
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}
#pragma mark Data Fetch methods

-(void)refreshData{

    XMLParser *xmlParser = [[XMLParser alloc] initWithXMLURLString:MostReadNewsFeed];
    [xmlParser startParsingWithCompletionHandler:^(BOOL success, NSArray *dataArray, NSError *error) {
        
        if (success) {
            [self performNewFetchedDataActionsWithDataArray:dataArray];
        }
        else{
            NSLog(@"%@", [error localizedDescription]);
        }
    }];

}

-(void)performNewFetchedDataActionsWithDataArray:(NSArray *)dataArray{
    // 1. Initialize the arrNewsData array with the parsed data array.
    if (self.arrNewsData != nil) {
        self.arrNewsData = nil;
    }
    self.arrNewsData = [[NSArray alloc] initWithArray:dataArray];
    
    
    // 2. Write the file and reload the view.
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * docDirectory = [paths objectAtIndex:0];
    NSString * newsFilePath = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:@"mostRead"]]; // NewsFile
    
    if (![self.arrNewsData writeToFile:newsFilePath atomically:YES]) {
        _newsAvailable = NO;
        NSLog(@"mostRead not saved");
    }
    else
    {
        _newsAvailable = YES;

    }
}
-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    XMLParser *xmlParser = [[XMLParser alloc] initWithXMLURLString:MostReadNewsFeed];
    [xmlParser startParsingWithCompletionHandler:^(BOOL success, NSArray *dataArray, NSError *error) {
        if (success) {
            NSDictionary *latestDataDict = [dataArray objectAtIndex:0];
            NSString *latestTitle = [latestDataDict objectForKey:@"title"];
            
            NSDictionary *existingDataDict = [self.arrNewsData objectAtIndex:0];
            NSString *existingTitle = [existingDataDict objectForKey:@"title"];
            
            if ([latestTitle isEqualToString:existingTitle]) {
                completionHandler(UIBackgroundFetchResultNoData);
                
                NSLog(@"No new data found.");
            }
            else{
                [self performNewFetchedDataActionsWithDataArray:dataArray];
                
                completionHandler(UIBackgroundFetchResultNewData);
                
                NSLog(@"New data was fetched.");
            }
        }
        else{
            completionHandler(UIBackgroundFetchResultFailed);
            
            NSLog(@"Failed to fetch new data.");
        }
    }];
}

#pragma mark Reachability
/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}


- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    
    if (reachability == self.internetReachability)
    {
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        BOOL connectionRequired = [reachability connectionRequired];
        NSString* statusString = @"";
        
        //
        UIAlertController * connectivityAlert = [UIAlertController alertControllerWithTitle:@"Connectivity" message:[NSString stringWithFormat:@"Status:%@",statusString] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [connectivityAlert addAction:ok];
        //
        
        switch (netStatus)
        {
            case NotReachable:        {
                statusString = NSLocalizedString(@"Access Not Available", @"Text field text for access is not available");
                /*
                 Minor interface detail- connectionRequired may return YES even when the host is unreachable. We cover that up here...
                 */
                connectionRequired = NO;
                // alerts added _PS
                connectivityAlert.message = [NSString stringWithFormat:@"Status:%@",statusString];
                [self presentViewController:connectivityAlert animated:YES completion:nil];
                isInternetConnectionAvailable = NO;
                break;
            }
                
            case ReachableViaWWAN:        {
                statusString = NSLocalizedString(@"Reachable WWAN", @"");
                // alerts added _PS
                connectivityAlert.message = [NSString stringWithFormat:@"Status:%@",statusString];
                //[self presentViewController:connectivityAlert animated:YES completion:nil];
                isInternetConnectionAvailable = YES;
                break;
            }
            case ReachableViaWiFi:        {
                statusString= NSLocalizedString(@"Reachable WiFi", @"");
                // alerts added _PS
                connectivityAlert.message = [NSString stringWithFormat:@"Status:%@",statusString];
                //[self presentViewController:connectivityAlert animated:YES completion:nil];
                isInternetConnectionAvailable = YES;
                break;
            }
        }
        
        if (connectionRequired)
        {
            NSString *connectionRequiredFormatString = NSLocalizedString(@"%@, Connection Required", @"Concatenation of status string with connection requirement");
            statusString= [NSString stringWithFormat:connectionRequiredFormatString, statusString];
            // alerts added _PS
            connectivityAlert.message = [NSString stringWithFormat:@"Status:%@",statusString];
            isInternetConnectionAvailable = NO;
            [self presentViewController:connectivityAlert animated:YES completion:nil];
        }
    }
    
}
@end
