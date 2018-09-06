//
//  PersonalizeNewsTableViewController.m
//  SnipNews
//
//  Created by NETBIZ on 23/02/17.
//  Copyright © 2017 NetBiz. All rights reserved.
//

#import "PersonalizeNewsTableViewController.h"

@interface PersonalizeNewsTableViewController ()

@end

@implementation PersonalizeNewsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    appSettings = [NSUserDefaults standardUserDefaults];
    self.title = @"Select News Categories";
    _selectedCategoriesArray = [[NSMutableArray alloc] init];
    [self initNewsCategories];
    [self loadNewsSelectedCategories];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_newsCategoriesArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellNewsCategory" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[_newsCategoriesArray objectAtIndex:indexPath.row]];
    NSString * cellText = [[cell textLabel] text];
    /* Code crashes
    //cell.textLabel.textColor = appOrangeColor;
    //--compare _selectedNewsCategories object with _newsCategoriesArray object--//
    if ([[_selectedNewsCategories objectAtIndex:indexPath.row] isEqualToString:cell.textLabel.text])
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else
    {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
     */
    /* Code works but selects only last one
    for (NSString * lblCategory in _selectedNewsCategories) {
        if ([cell.textLabel.text isEqualToString:lblCategory])
        {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        else
        {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
     */
    for (NSString * lbl in _selectedNewsCategories)
    {
        if ([cellText isEqualToString:lbl])
        {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            break;
        }
        else
        {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
    }
    return cell;
}

#pragma mark UITableViewDelegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell * selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    NSString * selectedCategory = [[selectedCell textLabel] text];
    // _selectedCategoriesArray = _selectedNewsCategories;
    
    if ([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryNone)
    {
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        NSLog(@"%@", selectedCategory);
        [_selectedCategoriesArray addObjectsFromArray:_selectedNewsCategories];
        [_selectedCategoriesArray addObject:selectedCategory];
        //NSLog(@"+selectedCategoriesArray:%@", _selectedCategoriesArray);
        //[appSettings setObject:_selectedCategoriesArray forKey:@"selectedNewsCategories"];
        
        NSArray * categories = [[NSOrderedSet orderedSetWithArray:_selectedCategoriesArray] array];
        NSLog(@"+categories:\n %@",categories);
        [appSettings setObject:categories forKey:@"selectedNewsCategories"];
        
        
    }
    else if ([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark)
    {
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
        NSLog(@"%@", selectedCategory);
        [self loadNewsSelectedCategories];
        [_selectedCategoriesArray addObjectsFromArray:_selectedNewsCategories];
        [_selectedCategoriesArray removeObject:selectedCategory];
        //NSLog(@"-selectedCategoriesArray:%@", _selectedCategoriesArray);
        //[appSettings setObject:_selectedCategoriesArray forKey:@"selectedNewsCategories"];
        
        NSArray * categories = [[NSOrderedSet orderedSetWithArray:_selectedCategoriesArray] array];
        NSLog(@"-categories:\n %@",categories);
        [appSettings setObject:categories forKey:@"selectedNewsCategories"];
        
    }
    else
    {
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
    }
    [appSettings synchronize];
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
#pragma mark Helper methods
-(void) initNewsCategories
{
    _newsCategoriesArray = [NSArray arrayWithObjects:@"Arts",@"Business",@"Company",
                            @"Entertainment",@"Environment",@"Health",@"Lifestyle",
                            @"Money",@"Oddly Enough",@"People",@"Politics",@"Science",
                            @"Sports",@"Technology",@"Trending",@"World",nil];
}
-(void) loadNewsSelectedCategories
{
    _selectedNewsCategories = [[NSMutableArray alloc] init];
    _selectedNewsCategories = [appSettings objectForKey:@"selectedNewsCategories"];
    
}

@end
