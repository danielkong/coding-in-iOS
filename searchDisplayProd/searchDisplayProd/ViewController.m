//
//  ViewController.m
//  searchDisplayProd
//
//  Created by developer on 9/27/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    //instance variables
    NSMutableArray *totalStrings;
    NSMutableArray *filteredStrings;
    BOOL isFiltered;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.mySearchBar.delegate = self;
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    
    totalStrings = [[NSMutableArray alloc]initWithObjects:@"one", @"two", @"three", @"four", @"five", @"six", @"seven", nil];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        isFiltered = NO;
    } else {
        isFiltered = YES;
        filteredStrings = [[NSMutableArray alloc] init];
        for (NSString *str in totalStrings) {
            NSRange stringRange = [str rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if (stringRange.location != NSNotFound) {
                [filteredStrings addObject:str];
            }
        }
    }
    [self.myTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isFiltered) {
        return [filteredStrings count];
    } else {
        return [totalStrings count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (!isFiltered) {
        cell.textLabel.text = [totalStrings objectAtIndex:indexPath.row];
    } else {
        cell.textLabel.text = [filteredStrings objectAtIndex:indexPath.row];
    }
    return cell;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.myTableView resignFirstResponder];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if(self.searchDisplayController.searchBar.text.length>0){
        isFiltered = YES;
        NSString * strSearchText = self.searchDisplayController.searchBar.text;
        filteredStrings = [NSMutableArray array];
        for (NSString *s in totalStrings){
            if ([s rangeOfString:strSearchText].length>0){
                [filteredStrings addObject:s];
            }
        }
    } else {
        isFiltered = NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
