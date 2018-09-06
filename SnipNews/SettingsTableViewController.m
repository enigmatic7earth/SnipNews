//
//  SettingsTableViewController.m
//  FlipNews
//
//  Created by NETBIZ on 22/02/17.
//  Copyright © 2017 Netbiz.in. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "SWRevealViewController.h"
#import "UIView+Toast.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setSelectedAppLanguage];
    [self initMenu];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self setSelectedAppLanguage];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableViewDelegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSNumber *i = [NSNumber numberWithInteger:indexPath.row];
    int index = [i intValue];
    
    switch (index) {
        case 0:
            NSLog(@"Notification:%d",index);
            break;
        case 1:
            NSLog(@"Language:%d",index);
            break;
        case 2:
            NSLog(@"Personalize:%d",index);
            break;
        case 3:
            NSLog(@"Invite:%d",index);
            break;
        case 5:
            NSLog(@"Feedback:%d",index);
            break;
        case 6:
            NSLog(@"TnC%d",index);
            break;
        case 7:
            NSLog(@"Privacy:%d",index);
            break;
        default:
            NSLog(@"index not found");
            break;
        case 4:
            NSLog(@"Rate:%d",index);
            //-- Open App in AppStore in iOS--//
            NSString *appName = [NSString stringWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
            NSURL *appStoreURL = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.com/app/%@",[appName stringByReplacingOccurrencesOfString:@" " withString:@""]]];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
            {
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Rate App" message:@"Would you like to proceed and rate the app on the AppStore?" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:appStoreURL options:[NSDictionary dictionary] completionHandler:nil];
                }];
                UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:ok];
                [alert addAction:cancel];
                [self presentViewController:alert animated:YES completion:nil];
                
            }
            else
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Rate App" message:@"Would you like to proceed and rate the app on the AppStore?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Ok", nil];
                [alert show];
            }
            break;
    }
}
#pragma mark TableViewDatasource methods

#pragma mark Helper methods
-(void) initMenu
{
    SWRevealViewController * revealViewController = (SWRevealViewController *) self.revealViewController;
    
    if (revealViewController) {
        [_menuButton setTarget:self.revealViewController];
        [_menuButton setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}
-(void) setSelectedAppLanguage
{
    appSettings = [NSUserDefaults standardUserDefaults];
    selectedLanguage = [appSettings valueForKey:@"appLanguage"];
    [_appLanguage setText:selectedLanguage];
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 1) {
        // do something here...
        //-- Open App in AppStore in iOS--//
        NSString *appName = [NSString stringWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
        NSURL *appStoreURL = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.com/app/%@",[appName stringByReplacingOccurrencesOfString:@" " withString:@""]]];
        [[UIApplication sharedApplication] openURL:appStoreURL];
    }
}
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}
*/
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

#pragma mark IBActions

- (IBAction)toggleNotifications:(UISwitch *) notificationSwitch
{
    if ([notificationSwitch isOn])
    {
        //[[UIApplication sharedApplication] registerForRemoteNotifications];
        [self.view makeToast:@"Notifications ON" duration:1.0 position:CSToastPositionCenter];;
    }
    else
    {
        //[[UIApplication sharedApplication] unregisterForRemoteNotifications];
        [self.view makeToast:@"Notifications OFF" duration:1.0 position:CSToastPositionCenter];
    }
    
}
@end
