//
//  NewsContentViewController.m
//  SnipNews
//
//  Created by NETBIZ on 19/01/17.
//  Copyright © 2017 Netbiz.in. All rights reserved.
//

#import "NewsContentViewController.h"
#import "Constants.h"
#import "UIView+Toast.h"

@interface NewsContentViewController ()

@end

@implementation NewsContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUIAttributes];
    [self setUIContent];
    [self initGAdBanner];
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



- (IBAction)readMoreOnWeb:(id)sender
{
    NSURL * urlReadMoreLink = [NSURL URLWithString:_newsArticleMoreLink];
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Opening full article" message:[NSString stringWithFormat:@"App will open the article in a webpage:\n %@",_newsArticleMoreLink] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // iOS > = 10
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
        {
            [[UIApplication sharedApplication] openURL:urlReadMoreLink options:[NSDictionary dictionary] completionHandler:nil];
        }
        // iOS < 10
        else
        {
            [[UIApplication sharedApplication] openURL:urlReadMoreLink];
        }

    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)shareOnFacebook:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController * fbPostController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        NSMutableString * fbPost = [NSMutableString stringWithFormat:@"%@\n\n%@\nRead more at:%@",_newsArticleHeading,_newsArticleContent,_newsArticleMoreLink];
        [fbPostController setInitialText:fbPost];
        [self presentViewController:fbPostController animated:YES completion:nil];
    }
    else
    {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Facebook" message:@"Sorry, you cannot make this post now." preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)shareOnTwitter:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController * twPostController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSMutableString * twTweet = [NSMutableString stringWithFormat:@"%@\n\nRead more at:%@",_newsArticleHeading,_newsArticleMoreLink];
        [twPostController setInitialText:twTweet];
        [self presentViewController:twPostController animated:YES completion:nil];
    }
    else
    {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Twitter" message:@"Sorry, you cannot make this tweet now." preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }

}

- (IBAction)shareOnLinkedIn:(id)sender
{
    
}

- (IBAction)shareOnGooglePlus:(id)sender
{
    
}

- (IBAction)saveAsBookmark:(id)sender
{
    //--Capture the article details in a dictionary--//
    //Static
//    NSDictionary * bookmarkArticle = [NSDictionary dictionaryWithObjects:@[_newsArticleImage,_newsArticleHeading,_newsArticlePublishedDate,_newsArticleMoreLink]
//                                                    forKeys:@[@"articleImage",@"articleHeading",@"articlePublishDate",@"articleMoreLink"]];

    //Live
    NSDictionary * bookmarkArticle = [NSDictionary dictionaryWithObjects:@[_newsArticleHeading,_newsArticlePublishedDate,_newsArticleMoreLink]
                                                                 forKeys:@[@"title",@"pubDate",@"link"]];
    //--Append the object to a bookmarks file--//
    // First check if file exists, if yes append,else create a new one
    //--Load the file that saves bookmarks--//
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * docDirectory = [paths objectAtIndex:0];
    NSString * bookmarksFilePath = [NSString stringWithFormat:@"%@",[docDirectory stringByAppendingPathComponent:@"bookmarks"]]; // BookmarksFile
    bookmarksArray = [[NSMutableArray alloc] init];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:bookmarksFilePath])
    {
        bookmarksArray = [[NSMutableArray alloc] initWithContentsOfFile:bookmarksFilePath];
        [bookmarksArray addObject:bookmarkArticle];
        [bookmarksArray writeToFile:bookmarksFilePath atomically:YES];
        NSLog(@"%@", NSHomeDirectory());
        
    }
    else
    {
        bookmarksArray = [[NSMutableArray alloc] initWithObjects:bookmarkArticle, nil];
        [bookmarksArray writeToFile:bookmarksFilePath atomically:YES];
        
    }
    
    [self.view makeToast:@"Article bookmarked!"];
    NSLog(@"Bookmarked!");
}
- (IBAction)shareMore:(UIButton *)sender
{
    NSMutableString * shareText = [NSMutableString stringWithFormat:@"%@\n%@\n\nRead more:%@",_newsArticleHeading,_newsArticleContent,_newsArticleMoreLink];
    UIActivityViewController * activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[shareText] applicationActivities:nil];
    
    // check for iPad
    if ([activityViewController respondsToSelector:@selector(popoverPresentationController)])
    {
        activityViewController.popoverPresentationController.sourceView = sender.superview;
        activityViewController.popoverPresentationController.sourceRect = sender.frame;
        // Arrow direction down presents the popover upwards.
        activityViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    else
    {
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
}


#pragma mark Custom methods
-(void) initGAdBanner
{
    _adBanner.adUnitID = GoogleAdUnitID;
    _adBanner.adSize = kGADAdSizeSmartBannerPortrait;
    _adBanner.delegate = self;
    _adBanner.rootViewController = self;
    
    // Request Ads
    GADRequest * request = [GADRequest request];
    // Comment this when not testing on Simulator, or replace it with deviceIDs of the devices on which it would be tested
    request.testDevices = @[kGADSimulatorID,@"cfe9d4ff4b613d5bae6c29b5e2d7b0ee"];
    // cfe9d4ff4b613d5bae6c29b5e2d7b0ee -device ID of Netbiz iPad iOS 9.3
    
    // Load the request
    [_adBanner loadRequest:request];
    
}

-(void) setUIAttributes
{
    // Article Image
    _newsImageView.layer.cornerRadius = 5;
    _newsImageView.layer.borderWidth = 1.5;
    _newsImageView.layer.borderColor = [[UIColor grayColor] CGColor];
    
    // Article Content
    _newsContentTextView.layer.cornerRadius = 5;
    
    
}
-(void) setUIContent

{
    _newsImageView.image = [UIImage imageNamed:_newsArticleImage];
    _newsHeadingLabel.text = _newsArticleHeading;
    _newsPublishedDate.text = _newsArticlePublishedDate;
    
}
#pragma mark GADBannerViewDelegate - methods
-(void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    NSLog(@"Ad received, banner loaded");
    _adBanner.hidden = NO;
}

-(void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"Failed:%@",[error localizedDescription]);
    NSLog(@"Reason:%@",[error localizedFailureReason]);
    NSLog(@"Suggestion:%@",[error localizedRecoverySuggestion]);
    _adBanner.hidden = YES;
}

@end
