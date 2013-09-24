//
//  ViewController.h
//  UISearchBar
//
//  Created by developer on 9/24/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *mySearchBar;

@property (weak, nonatomic) IBOutlet UITableView *myTableview;
@property (strong, nonatomic) NSMutableArray * initialCities;
@property (strong, nonatomic) NSMutableArray * filteredCities;
@property BOOL isFiltered;

@end
