//
//  FeedbackViewController.m
//  SnipNews
//
//  Created by NETBIZ on 02/03/17.
//  Copyright © 2017 NetBiz. All rights reserved.
//

#import "FeedbackViewController.h"

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Feedback";
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
- (IBAction)submitFeedback:(id)sender {
    
    if ([self checkFeedbackForm])
    {
        name = [_nameField text];
        email = [_emailField text];
        feedbackMessage = [_feedbackTextView text];
        
        UIAlertController * feedbackAlert = [UIAlertController alertControllerWithTitle:@"Thank you" message:@"The feedback you provide is valuable to us, as it helps us improve the app. Submit the feedback?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self sendFeedbackEmail];
            
        }];
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self resetFields];
            [_nameField becomeFirstResponder];
        }];
        [feedbackAlert addAction:ok];
        [feedbackAlert addAction:cancel];
        [self presentViewController:feedbackAlert animated:YES completion:nil];
    }
    
}

#pragma mark MFMailComposeViewControllerDelegate methods
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark Helper methods
-(BOOL) checkFeedbackForm
{
    if ([[_nameField text] isEqualToString:@""])
    {
        UIAlertController * warn = [UIAlertController alertControllerWithTitle:@"Name required" message:@"Please provide your name." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [_nameField becomeFirstResponder];
        }];
        [warn addAction:ok];
        [self presentViewController:warn animated:YES completion:nil];
        
        return NO;
    }
    else if ([[_emailField text] isEqualToString:@""])
    {
        
        UIAlertController * warn = [UIAlertController alertControllerWithTitle:@"Email required" message:@"Please provide your email." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [_emailField becomeFirstResponder];
        }];
        [warn addAction:ok];
        [self presentViewController:warn animated:YES completion:nil];
        return NO;
    }
    else if ([[_feedbackTextView text] isEqualToString:@""])
    {
        UIAlertController * warn = [UIAlertController alertControllerWithTitle:@"Feedback required" message:@"Please provide your feedback." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [_feedbackTextView becomeFirstResponder];
        }];
        [warn addAction:ok];
        [self presentViewController:warn animated:YES completion:nil];
        return NO;
    }
    else
    {
        return YES;
    }
    
}
-(void) resetFields
{
    [_nameField setText:@""];
    [_emailField setText:@""];
    [_feedbackTextView setText:@""];
}

-(void) sendFeedbackEmail
{
    // get app name and url
    NSString *appName = [NSString stringWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
    NSURL *appStoreURL = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.com/app/%@",[appName stringByReplacingOccurrencesOfString:@" " withString:@""]]];
    
    if(![MFMailComposeViewController canSendMail]) {
        
        UIAlertController * warning = [UIAlertController alertControllerWithTitle:@"Error" message:@"Your device doesn't support Email!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [warning addAction:ok];
        [self presentViewController:warning animated:YES completion:^{
            [self resetFields];
        }];
        
        /*UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support Email!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [warningAlert show];
         */
        return;
    }
    
    // Email Subject
    NSString *emailTitle = [NSString stringWithFormat:@"Feedback about the %@ app.",appName];
    // Email Content
    NSString *messageBody = [NSString stringWithFormat:@"%@ sent from %@",feedbackMessage,email];
    // To address
    NSString * toRecipentEmail = @"prashant.s@netbiz.in";
    NSArray *toRecipents = [NSArray arrayWithObject:toRecipentEmail];
    //From address
    
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}
@end
