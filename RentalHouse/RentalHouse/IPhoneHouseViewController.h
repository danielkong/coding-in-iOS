//
//  IPhoneHouseViewController.h
//  RentalHouse
//
//  Created by Daniel Kong on 6/30/14.
//  Copyright (c) 2014 CV Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+SVPullToRefresh.h"
#import "IPhoneMVTopBar.h"

@interface IPhoneHouseViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, retain) UITableView* tableView;
@property (nonatomic, retain) NSMutableArray* sections;
@property (nonatomic, retain) NSMutableArray* rows;
@property (nonatomic, readonly) SVPullToRefreshView* pullToRefreshView;
@property (nonatomic, readonly, retain) UISearchBar* searchBar;
@property (nonatomic, retain) IPhoneMVTopBar* topBar;


@end
