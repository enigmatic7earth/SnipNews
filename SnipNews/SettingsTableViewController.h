//
//  SettingsTableViewController.h
//  FlipNews
//
//  Created by NETBIZ on 22/02/17.
//  Copyright © 2017 Netbiz.in. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface SettingsTableViewController : UITableViewController
{
    NSUserDefaults * appSettings;
    NSString * selectedLanguage;
}
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (strong, nonatomic) IBOutlet UILabel *appLanguage;
- (IBAction)toggleNotifications:(id)sender;

@end
