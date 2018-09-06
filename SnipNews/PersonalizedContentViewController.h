//
//  PersonalizedContentViewController.h
//  SnipNews
//
//  Created by NETBIZ on 07/02/17.
//  Copyright © 2017 NetBiz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

@import GoogleMobileAds;
@interface PersonalizedContentViewController : UIViewController<GADBannerViewDelegate>
// GADBannerViewDelegate -  is the protocol to confirm, inorder to show Google Ads

// Properties

@property NSUInteger newsIndex;
@property (strong, nonatomic) NSString * newsArticleImage;
@property (strong, nonatomic) NSString * newsArticleHeading;
@property (strong, nonatomic) NSString * newsArticlePublishedDate;
@property (strong, nonatomic) NSString * newsArticleContent;
@property (strong, nonatomic) NSString * newsArticleMoreLink;

// IBOutlets
@property (strong, nonatomic) IBOutlet UIImageView *newsImageView;
@property (strong, nonatomic) IBOutlet UILabel *newsHeadingLabel;
@property (strong, nonatomic) IBOutlet UILabel *newsPublishedDate;
@property (strong, nonatomic) IBOutlet UITextView *newsContentTextView;
@property (strong, nonatomic) IBOutlet GADBannerView *adBanner;


// IBActions

- (IBAction)readMoreOnWeb:(id)sender;
- (IBAction)shareOnFacebook:(id)sender;
- (IBAction)shareOnTwitter:(id)sender;
- (IBAction)shareOnLinkedIn:(id)sender;
- (IBAction)shareOnGooglePlus:(id)sender;
- (IBAction)saveAsBookmark:(id)sender;
- (IBAction)shareMore:(UIButton *)sender;
@end
