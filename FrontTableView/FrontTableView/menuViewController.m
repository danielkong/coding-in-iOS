//
//  ViewController.m
//  FrontTableView
//
//  Created by developer on 9/6/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import "menuViewController.h"

@interface menuViewController ()

@end

@implementation menuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    switchStatus = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 20; i++) {
        [switchStatus addObject:@"OFF"];
    }
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
    // remember the switch on/off
    if([[switchStatus objectAtIndex:indexPath.row] isEqualToString:@"ON"]){
        theSwitch.on = YES;
    } else {
        theSwitch.on = NO;
    }
    
//    cell.textLabel.text = [NSString stringWithFormat:@"Cell %d", indexPath.row];
    
    return cell;
}


- (void)switchChanged:(UISwitch *)sender
{
    UITableViewCell *theParentCell = [[sender superview] superview];
    NSIndexPath *indexPathOfSwitch = [mainTableView indexPathForCell:(UITableViewCell *)theParentCell];
//    NSLog(@"the index path of the switch: %d", indexPathOfSwitch.row);
    if(sender.on){
        [switchStatus replaceObjectAtIndex:indexPathOfSwitch.row withObject:@"ON"];
    } else {
        [switchStatus replaceObjectAtIndex:indexPathOfSwitch.row withObject:@"OFF"];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
