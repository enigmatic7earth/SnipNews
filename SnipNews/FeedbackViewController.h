//
//  FeedbackViewController.h
//  SnipNews
//
//  Created by NETBIZ on 02/03/17.
//  Copyright © 2017 NetBiz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface FeedbackViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
    NSString * name;
    NSString * email;
    NSString * feedbackMessage;
}
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextView *feedbackTextView;

- (IBAction)submitFeedback:(id)sender;

@end
