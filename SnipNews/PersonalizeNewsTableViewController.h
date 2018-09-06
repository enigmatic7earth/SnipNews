//
//  PersonalizeNewsTableViewController.h
//  SnipNews
//
//  Created by NETBIZ on 23/02/17.
//  Copyright © 2017 NetBiz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface PersonalizeNewsTableViewController : UITableViewController
{
    NSUserDefaults * appSettings;
}

@property (strong, nonatomic) NSArray * newsCategoriesArray;
@property (strong, nonatomic) NSMutableArray * selectedNewsCategories;
@property (strong, nonatomic) NSMutableArray * selectedCategoriesArray;

@end
