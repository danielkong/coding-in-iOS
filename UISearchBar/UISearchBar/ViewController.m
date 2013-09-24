//
//  ViewController.m
//  UISearchBar
//
//  Created by developer on 9/24/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Alloc and init our data
    _initialCities = [[NSMutableArray alloc] initWithObjects:@"London", @"New York", @"Beijing", @"Sydney", @"Korean", @"Berlin", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return 6;
    if (_isFiltered == YES) {
        return _filteredCities.count;
    } else {
        return _initialCities.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell ==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (_isFiltered == YES) {
        cell.textLabel.text = [_filteredCities objectAtIndex:indexPath.row];
    } else {
        cell.textLabel.text = [_initialCities objectAtIndex:indexPath.row];
    }
//    cell.textLabel.text = [NSString stringWithFormat:@"Cell %d", indexPath.row];
    return cell;
}

#pragma UITableView Delegate method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

# pragma mark - UISearchBar Delegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        //set our boolean flag
        _isFiltered = NO;
    } else {
        //set our boolean flag
        _isFiltered =YES;
        
        // filtered array
        _filteredCities = [[NSMutableArray alloc] init];
        
        // fast enumeration
        for (NSString * cityName in _initialCities){
            NSRange cityNameRange = [cityName rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if (cityNameRange.location != NSNotFound){
                [_filteredCities addObject:cityName];
            }
        }
    }
    
    //reload table view
    [_myTableview reloadData];
}

@end
