//
//  IPhoneHouseViewController.m
//  RentalHouse
//
//  Created by Daniel Kong on 6/30/14.
//  Copyright (c) 2014 CV Developer. All rights reserved.
//

#import "IPhoneHouseViewController.h"

@interface IPhoneHouseViewController () <UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, retain) UISearchDisplayController* searchController;
@property(nonatomic, assign) BOOL searchResultsAvailable;
@property(nonatomic, assign) int currentActivityType;

@end

@implementation IPhoneHouseViewController

- (id)initWithStyle:(UITableViewStyle)style
{
//    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // create tableView
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //    if (getOSf() >= 7.0)
    //        _tableView.separatorInset = UIEdgeInsetsZero;
    
    UIView* topView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    topView.backgroundColor = [UIColor blueColor];
    
    UILabel* testlabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, 44)];
    testlabel2.backgroundColor = [UIColor yellowColor];
    testlabel2.text = @"I am testing2!";
    
    [self.view addSubview:topView];
    [self.view insertSubview:_tableView belowSubview:topView];
//    [self.view insertSubview:_topBar belowSubview:testlabel2];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellReuseIdentifier = @"cellReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    
    UISwitch *theSwitch = nil;
    // 10 instance UISwitch, only create one switch, so put it into cell==nil
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
        theSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        CGRect frame = theSwitch.frame;
        frame.origin.x = 230;
        frame.origin.y = 9;
        theSwitch.frame = frame;
        theSwitch.tag = 100;
        [theSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:theSwitch];
    } else {
        theSwitch = [cell.contentView viewWithTag:100];
    }
//    // remember the switch on/off
//    if([[switchStatus objectAtIndex:indexPath.row] isEqualToString:@"ON"]){
//        theSwitch.on = YES;
//    } else {
//        theSwitch.on = NO;
//    }
    
    //    cell.textLabel.text = [NSString stringWithFormat:@"Cell %d", indexPath.row];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
