//
//  CVSearchHistoryViewController.h
//  Vmoso
//
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SEARCHBAR_TEXT_CHANGED @"searchbar_text_changed"

@interface CVSearchHistoryViewController : UITableViewController

@property (nonatomic, retain) NSMutableDictionary* searchStats;

+ (CVSearchHistoryViewController*) sharedInstance;
- (void)presentInPopoverFromBarButtonItem:(UIBarButtonItem *)item;
- (void)updateSearchStatsWithKeyword:(NSString*)keyword;
- (void)getSortedSearchHistoryWithKeyword:(NSString*)keyword;
- (void)dismissPopover:(BOOL)animated;

@end
