//
//  PulldownMenuViewController.h
//  
//
//  Created by daniel kong on 8/12/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseMenuTreeTableViewCell.h"

@protocol PulldownMenuDelegate <NSObject>

- (void)didSelectMenuItem:(BaseMenuTreeItem*) menuItem;
@end

@interface CVPulldownMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CVBaseMenuTreeTableViewCellDelegate>

@property (nonatomic, strong) UITableView *treeTableView;
@property (nonatomic, strong) NSMutableArray *treeItems;
@property (nonatomic, strong) NSMutableArray *selectedTreeItems;
@property (nonatomic, strong) NSMutableArray *treeArray;    
@property (nonatomic, strong) BaseMenuTreeItem *tmptreeItem;      
@property (nonatomic, unsafe_unretained) id<PulldownMenuDelegate> delegate;

- (id)initWithDelegate:(id<PulldownMenuDelegate>)delegate forMenuFilter:(NSArray*)MenuArray;

@end
