//
//  PersonalizedViewController.m
//  SnipNews
//
//  Created by NETBIZ on 07/02/17.
//  Copyright © 2017 NetBiz. All rights reserved.
//

#import "PersonalizedViewController.h"

@interface PersonalizedViewController ()
@property (nonatomic, strong) NSArray *arrNewsData;

@property (nonatomic) Reachability *internetReachability;

-(void)refreshData;
-(void)performNewFetchedDataActionsWithDataArray:(NSArray *)dataArray;
@end

@implementation PersonalizedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = appBackgroundColor;
    [self allocInits];
    [self initMenuBar];
    
    //--Set NSUserDefaults--//
    appSettings = [NSUserDefaults standardUserDefaults];
    [appSettings setValue:@"YES" forKey:@"IntroductionDone"];
    [appSettings setValue:@"Personalize" forKey:@"currentViewController"]; //05-06-2017_PS addition for checking which fetch method to call in Appdelegate
    [appSettings synchronize];
    //--+--//
    _selectedNewsCategories = [appSettings objectForKey:@"selectedNewsCategories"];
    NSLog(@"News:%@",_selectedNewsCategories);
    
    
    //--Load the file that saves news--//
    [self loadNews];
    if (_newsAvailable == YES)
    {
        
        [self setupPageViewController];
    }
    else
    {
        [self showNoNewsMessage];
        //        [self performSegueWithIdentifier:@"navHome" sender:self];// Discouraged, but works. Find alternative
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"SnipNews" message:@"No new news available." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        
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
-(void)viewWillAppear:(BOOL)animated
{
    [self loadNews];
    [self showNoNewsMessage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PersonalizedContentViewController*) viewController).newsIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PersonalizedContentViewController*) viewController).newsIndex;
    
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
#pragma mark IBActions
- (IBAction)reloadNews:(UIBarButtonItem *)sender
{
    //Added  MBProcessHUD 29-05-2017_PS
    if (isInternetConnectionAvailable) {
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                
            });
        });
        double delayInSeconds = 1.0;
        
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

#pragma mark Helper methods
-(void) allocInits
{
    newsArray = [[NSMutableArray alloc] init];
    _pageTitles = [[NSMutableArray alloc] init];
    _pagePublishDate = [[NSMutableArray alloc] init];
    _pageImage = [[NSMutableArray alloc] init];
    _pageMoreLink = [[NSMutableArray alloc] init];
    
    _personalisedNewsArray = [[NSMutableArray alloc] init];
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
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * docDirectory = [paths objectAtIndex:0];
    NSString * newsFilePath = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:@"personalize"]]; // NewsFile
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:newsFilePath])
    {
        _newsAvailable = YES;
        newsArray = [[NSMutableArray alloc] initWithContentsOfFile:newsFilePath];
        NSLog(@"newsArray available");
        /*
        for (int i = 0; i < [newsArray count]; i++) {
            NSDictionary * tempDict = [NSDictionary dictionaryWithDictionary:[newsArray objectAtIndex:i]];
            //NSLog(@"tempDict%d = %@",i,tempDict);
            [_pageTitles addObject:[tempDict valueForKey:@"title"]];
            [_pagePublishDate addObject:[tempDict valueForKey:@"pubDate"]];
            [_pageMoreLink addObject:[tempDict valueForKey:@"link"]];
            
        }
         */
        for (NSDictionary * tempDict in newsArray) {
            [_pageTitles addObject:[tempDict valueForKey:@"title"]];
            [_pagePublishDate addObject:[tempDict valueForKey:@"pubDate"]];
            [_pageMoreLink addObject:[tempDict valueForKey:@"link"]];
        }
    }
    else
    {
        _newsAvailable = NO;
    }
    
}
-(void) setupPageViewController
{
    //--Creating the PageViewController--//
    _pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalizedPageViewController"];
    _pageViewController.dataSource = self;
    
    PersonalizedContentViewController *startingViewController = [self viewControllerAtIndex:0];
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


- (PersonalizedContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PersonalizedContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalizedNewsContentController"];
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
#pragma mark Data Fetch methods

-(void)refreshData{
    // Determine which URLs to call
#warning implementation pending.
    NSString * newsURL;
    
    for (NSString * temp in _selectedNewsCategories) {
        if ([temp isEqualToString:@"Arts"]) {
            newsURL = ArtsNewsFeed;
            _newsCategory = @"arts";
        }
        else if ([temp isEqualToString:@"Business"]){
            newsURL = BusinessNewsFeed;
            _newsCategory = @"business";
        }
        else if ([temp isEqualToString:@"Company"]){
            newsURL = CompanyNewsFeed;
            _newsCategory = @"company";
        }
        else if ([temp isEqualToString:@"Entertainment"]){
            newsURL = EntertainmentNewsFeed;
            _newsCategory = @"entertainment";
        }
        else if ([temp isEqualToString:@"Environment"]){
            newsURL = EnvironmentNewsFeed;
            _newsCategory = @"environment";
        }
        else if ([temp isEqualToString:@"Health"]){
            newsURL = HealthNewsFeed;
            _newsCategory = @"health";
        }
        else if ([temp isEqualToString:@"Lifestyle"]){
            newsURL = LifestyleNewsFeed;
            _newsCategory = @"lifestyle";
        }
        else if ([temp isEqualToString:@"Money"]){
            newsURL = MoneyNewsFeed;
            _newsCategory = @"money";
        }
        else if ([temp isEqualToString:@"Oddly Enough"]){
            newsURL = OddlyEnoughNewsFeed;
            _newsCategory = @"oddlyenough";
        }
        else if ([temp isEqualToString:@"People"]){
            newsURL = PeopleNewsFeed;
            _newsCategory = @"people";
        }
        else if ([temp isEqualToString:@"Politics"]){
            newsURL = PoliticsNewsFeed;
            _newsCategory = @"politics";
        }
        else if ([temp isEqualToString:@"Science"]){
            newsURL = ScienceNewsFeed;
            _newsCategory = @"science";
        }
        else if ([temp isEqualToString:@"Sports"]){
            newsURL = SportsNewsFeed;
            _newsCategory = @"sports";
        }
        else if ([temp isEqualToString:@"Technology"]){
            newsURL = TechnologyNewsFeed;
            _newsCategory = @"technology";
        }
        else if ([temp isEqualToString:@"Trending"]){
            newsURL = TopNewsFeed;
            _newsCategory = @"top";
        }
        else if ([temp isEqualToString:@"World"]){
            newsURL = WorldNewsFeed;
            _newsCategory = @"world";
        }
        XMLParser *xmlParser = [[XMLParser alloc] initWithXMLURLString:newsURL];
        [xmlParser startParsingWithCompletionHandler:^(BOOL success, NSArray *dataArray, NSError *error) {
            
            if (success) {
#warning Try implementing this section in a method, with the category name passed.
                [self performNewFetchedDataActionsWithDataArray:dataArray];
            }
            else{
                NSLog(@"%@", [error localizedDescription]);
            }
        }];
    }

    
}

-(void)performNewFetchedDataActionsWithDataArray:(NSArray *)dataArray{
    // 1. Initialize the arrNewsData array with the parsed data array.
    if (self.arrNewsData != nil) {
        self.arrNewsData = nil;
    }
    self.arrNewsData = [[NSArray alloc] initWithArray:dataArray];
    //[_personalisedNewsArray addObject:_arrNewsData];
    
    
    // 2. Write the file and reload the view.
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * docDirectory = [paths objectAtIndex:0];
    NSString * newsFilePath = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:@"personalize"]]; // NewsFile
    NSString * tempFilePath = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:_newsCategory]]; // Temp file to store fetched news
    if ([_arrNewsData writeToFile:tempFilePath atomically:YES]) {
        NSLog(@"%@ file saved",_newsCategory);
    }
    
    //Check if file exists, if yes-> append, else create and append.
    if ([[NSFileManager defaultManager] fileExistsAtPath:newsFilePath]) {
        /*
        _personalisedNewsArray = [[NSArray arrayWithContentsOfFile:newsFilePath] mutableCopy];
        [_personalisedNewsArray addObject:_arrNewsData];
        
        //-- If file exists, append the content to it--//
        _personalisedNewsArray = [[NSArray arrayWithContentsOfFile:newsFilePath] mutableCopy]; //overwriting the file
        */
        //Checking which categories are selected, then appending the respective files
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * docDirectory = [paths objectAtIndex:0];

        for (NSString * temp in _selectedNewsCategories) {
            if ([temp isEqualToString:@"Arts"]) {
                _fileToAppend = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:@"arts"]];
            }
            else if ([temp isEqualToString:@"Business"]){
                _fileToAppend = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:@"business"]];
            }
            else if ([temp isEqualToString:@"Company"]){
                _fileToAppend = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:@"company"]];
            }
            else if ([temp isEqualToString:@"Entertainment"]){
                _fileToAppend = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:@"entertainment"]];
            }
            else if ([temp isEqualToString:@"Environment"]){
                _fileToAppend = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:@"environment"]];
            }
            else if ([temp isEqualToString:@"Health"]){
                _fileToAppend = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:@"health"]];
            }
            else if ([temp isEqualToString:@"Lifestyle"]){
                _fileToAppend = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:@"lifestyle"]];
            }
            else if ([temp isEqualToString:@"Money"]){
                _fileToAppend = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:@"money"]];
            }
            else if ([temp isEqualToString:@"Oddly Enough"]){
                _fileToAppend = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:@"oddlyenough"]];
            }
            else if ([temp isEqualToString:@"People"]){
                _fileToAppend = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:@"people"]];
            }
            else if ([temp isEqualToString:@"Politics"]){
                _fileToAppend = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:@"politics"]];
            }
            else if ([temp isEqualToString:@"Science"]){
                _fileToAppend = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:@"science"]];
            }
            else if ([temp isEqualToString:@"Sports"]){
                _fileToAppend = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:@"sports"]];
            }
            else if ([temp isEqualToString:@"Technology"]){
                _fileToAppend = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:@"technology"]];
            }
            else if ([temp isEqualToString:@"Trending"]){
                _fileToAppend = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:@"top"]];
            }
            else if ([temp isEqualToString:@"World"]){
                _fileToAppend = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:@"world"]];
            }
        }
        
        NSArray * tempArray = [NSArray arrayWithContentsOfFile:_fileToAppend];
        for (NSDictionary * tempDict in tempArray) {
            [_personalisedNewsArray addObject:tempDict];
        }
    }
    else
    {
        _personalisedNewsArray = [_arrNewsData mutableCopy];
    }
    
    //--Write out the array
    if (![_personalisedNewsArray writeToFile:newsFilePath atomically:YES]) {
        NSLog(@"Couldn't save data.");
        _newsAvailable = NO;
        
    }
    else
    {
        _newsAvailable = YES;
        NSLog(@"Saved data.");
        [self viewDidLoad]; //--//
    }
}
-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
#warning To be implemented.
    
    NSString * newsURL;
    
    for (NSString * temp in _selectedNewsCategories) {
        if ([temp isEqualToString:@"Arts"]) {
            newsURL = ArtsNewsFeed;
        }
        else if ([temp isEqualToString:@"Business"]){
            newsURL = BusinessNewsFeed;
        }
        else if ([temp isEqualToString:@"Company"]){
            newsURL = CompanyNewsFeed;
        }
        else if ([temp isEqualToString:@"Entertainment"]){
            newsURL = EntertainmentNewsFeed;
        }
        else if ([temp isEqualToString:@"Environment"]){
            newsURL = EnvironmentNewsFeed;
        }
        else if ([temp isEqualToString:@"Health"]){
            newsURL = HealthNewsFeed;
        }
        else if ([temp isEqualToString:@"Lifestyle"]){
            newsURL = LifestyleNewsFeed;
        }
        else if ([temp isEqualToString:@"Money"]){
            newsURL = MoneyNewsFeed;
        }
        else if ([temp isEqualToString:@"Oddly Enough"]){
            newsURL = OddlyEnoughNewsFeed;
        }
        else if ([temp isEqualToString:@"People"]){
            newsURL = PeopleNewsFeed;
        }
        else if ([temp isEqualToString:@"Politics"]){
            newsURL = PoliticsNewsFeed;
        }
        else if ([temp isEqualToString:@"Science"]){
            newsURL = ScienceNewsFeed;
        }
        else if ([temp isEqualToString:@"Sports"]){
            newsURL = SportsNewsFeed;
        }
        else if ([temp isEqualToString:@"Technology"]){
            newsURL = TechnologyNewsFeed;
        }
        else if ([temp isEqualToString:@"Trending"]){
            newsURL = TopNewsFeed;
        }
        else if ([temp isEqualToString:@"World"]){
            newsURL = WorldNewsFeed;
        }
        XMLParser *xmlParser = [[XMLParser alloc] initWithXMLURLString:newsURL];
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
