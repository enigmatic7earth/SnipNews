//
//  LanguagesTableViewController.h
//  FlipNews
//
//  Created by NETBIZ on 23/02/17.
//  Copyright © 2017 Netbiz.in. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface LanguagesTableViewController : UITableViewController
{
    NSUserDefaults * appSettings;
    NSString * appLanguage;
}
@property (strong, nonatomic) NSArray * languageArray;
@end
