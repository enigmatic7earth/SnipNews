//
//  InviteTableViewController.m
//  SnipNews
//
//  Created by NETBIZ on 02/03/17.
//  Copyright © 2017 NetBiz. All rights reserved.
//

#import "InviteTableViewController.h"

@interface InviteTableViewController ()

@end

@implementation InviteTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = @"Select Contacts";
    _contactsArray = [[NSMutableArray alloc] init];
    [self authorizeAndFetchContacts];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_contactsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellContact" forIndexPath:indexPath];
    
    // Configure the cell...
    //cell.textLabel.text = [NSString stringWithFormat:@"%@",[_contactsArray objectAtIndex:indexPath.row]];
    NSDictionary * person = [_contactsArray objectAtIndex:indexPath.row];
    fullName = [person valueForKey:@"fullName"];
    profileImage = [person valueForKey:@"userImage"];
    phone = [person valueForKey:@"phone"];
    email = [person valueForKey:@"email"];
    if ([email isEqualToString:@""]) {
        email = @"";
    }
    if ([phone isEqualToString:@""]) {
        phone = @"";
    }
    
    cell.textLabel.text = fullName;
    cell.imageView.image = profileImage;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Phone:%@ Email:%@",phone,email];
    
    return cell;
}
#pragma mark UITableViewDelegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * person = [_contactsArray objectAtIndex:indexPath.row];
    fullName = [person valueForKey:@"fullName"];
    profileImage = [person valueForKey:@"userImage"];
    phone = [person valueForKey:@"phone"];
    email = [person valueForKey:@"email"];
/*
    UIAlertController * inviteAlert = [UIAlertController alertControllerWithTitle:@"Invite Contact" message:[NSString stringWithFormat:@"Invite %@ to try the app?", contactName] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // invite contact, send sms or email.
    }];
    UIAlertAction * no = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
    [inviteAlert addAction:ok];
    [inviteAlert addAction:no];
    [self presentViewController:inviteAlert animated:YES completion:nil];
*/
    UIAlertController * inviteContact = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Invite %@",fullName] message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * smsAction = [UIAlertAction actionWithTitle:@"SMS" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // code to invite via sms
        [self sendSMSTo:phone];
    }];
    UIAlertAction * emailAction = [UIAlertAction actionWithTitle:@"Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //code to  invite via email
        [self sendEmailTo:email];
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [inviteContact addAction:smsAction];
    [inviteContact addAction:emailAction];
    [inviteContact addAction:cancel];
    [self presentViewController:inviteContact animated:YES completion:nil];
}
#pragma mark MFMessageComposeViewControllerDelegate methods
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertController * warningAlert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to send SMS!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
            [warningAlert addAction:ok];
            [self presentViewController:warningAlert animated:YES completion:nil];
            
            /* ios<10
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
             */
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
#pragma mark helper methods
-(void) authorizeAndFetchContacts
{
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted == YES) {
            //keys with fetching properties
            NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey, CNContactEmailAddressesKey];
            CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
            NSError *error;
            BOOL success = [store enumerateContactsWithFetchRequest:request error:&error usingBlock:^(CNContact * __nonnull contact, BOOL * __nonnull stop)
            {
                if (error)
                {
                    NSLog(@"error fetching contacts %@", error);
                } else
                {
                    
                    firstName = contact.givenName;
                    lastName = contact.familyName;
                    NSMutableArray *contactNumbersArray = [[NSMutableArray alloc]init];
                    NSMutableArray *emailArray = [[NSMutableArray alloc]init];
                    // construct full name
                    if (lastName == nil) {
                        fullName = [NSString stringWithFormat:@"%@",firstName];
                    }else if (firstName == nil){
                        fullName = [NSString stringWithFormat:@"%@",lastName];
                    }
                    else{
                        fullName=[NSString stringWithFormat:@"%@ %@",firstName,lastName];
                    }
                    // profile image
                    UIImage *image = [UIImage imageWithData:contact.imageData];
                    if (image != nil) {
                        profileImage = image;
                    }else{
                        profileImage = [UIImage imageNamed:@"user-blue.png"];
                    }
                    // phone numbers
                    for (CNLabeledValue *label in contact.phoneNumbers) {
                        phone = [label.value stringValue];
                        if ([phone length] > 0) {
                            [contactNumbersArray addObject:phone];
                        }
                    }
                    // email
                        for (CNLabeledValue *label in contact.emailAddresses) {
                            email = label.value;
                            if ([email length] > 0) {
                                [emailArray addObject:email];
                            }
                        }
                    NSDictionary* personDict = [[NSDictionary alloc] initWithObjectsAndKeys: fullName,@"fullName",profileImage,@"userImage",[contactNumbersArray firstObject],@"phone",[emailArray firstObject],@"email", nil];
                    [_contactsArray addObject:personDict];
                    //[_contactsArray addObject:[personDict objectForKey:@"fullName"]];
                    //NSLog(@"contactsArray:%@", _contactsArray);
                }
            }];
            [self.tableView reloadData];
        }        
    }];
}
-(void) sendSMSTo:(NSString *) phoneNumber
{
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertController * warning = [UIAlertController alertControllerWithTitle:@"Error" message:@"Your device doesn't support SMS!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [warning addAction:ok];
        [self presentViewController:warning animated:YES completion:nil];
        /* ios <10
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
         */
        return;
    }
    // get app name and url
    NSString *appName = [NSString stringWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
    NSURL *appStoreURL = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.com/app/%@",[appName stringByReplacingOccurrencesOfString:@" " withString:@""]]];
    
    NSArray *recipents = @[phoneNumber];
    NSString *message = [NSString stringWithFormat:@"I'd like to invite you to try %@ app.\nYou can get it from the app store, here's the link: %@\n I liked it, hope you like it too.",appName,appStoreURL];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}
-(void) sendEmailTo:(NSString *) emailAddress
{
    // get app name and url
    NSString *appName = [NSString stringWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
    NSURL *appStoreURL = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.com/app/%@",[appName stringByReplacingOccurrencesOfString:@" " withString:@""]]];
    
    if(![MFMailComposeViewController canSendMail]) {
        
        UIAlertController * warning = [UIAlertController alertControllerWithTitle:@"Error" message:@"Your device doesn't support Email!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [warning addAction:ok];
        [self presentViewController:warning animated:YES completion:nil];
        
        /*UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support Email!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        */
        return;
    }
    
    // Email Subject
    NSString *emailTitle = [NSString stringWithFormat:@"Invite to try the %@ app",appName];
    // Email Content
    NSString *messageBody = [NSString stringWithFormat:@"I'd like to invite you to try %@ app.\nYou can get it from the app store, here's the link: %@\n I liked it, hope you like it too.",appName,appStoreURL];
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:emailAddress];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
