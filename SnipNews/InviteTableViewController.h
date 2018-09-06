//
//  InviteTableViewController.h
//  SnipNews
//
//  Created by NETBIZ on 02/03/17.
//  Copyright © 2017 NetBiz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ContactsUI/ContactsUI.h>
#import <MessageUI/MessageUI.h>


@interface InviteTableViewController : UITableViewController <MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate>
{
    
    NSString * firstName;
    NSString * lastName;
    NSString * fullName;
    NSString * phone;
    NSString * email;
    UIImage  * profileImage;
}
@property (strong, nonatomic) NSMutableArray * contactsArray;

@end
