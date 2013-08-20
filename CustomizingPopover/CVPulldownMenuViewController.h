//
//  CVPulldownMenuViewController.h
//  
//
//  Created by daniel kong on 8/12/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CVBaseMenuTreeTableViewCell.h"

@protocol CVPulldownMenuDelegate <NSObject>

- (void)didSelectMenuItem:(CVBaseMenuTreeItem*) menuItem;
@end

@interface CVPulldownMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CVBaseMenuTreeTableViewCellDelegate>

@property (nonatomic, strong) UITableView *treeTableView;
@property (nonatomic, strong) NSMutableArray *treeItems;
@property (nonatomic, strong) NSMutableArray *selectedTreeItems;
@property (nonatomic, strong) NSMutableArray *treeArray;    
@property (nonatomic, strong) CVBaseMenuTreeItem *tmptreeItem;      
@property (nonatomic, unsafe_unretained) id<CVPulldownMenuDelegate> delegate;

- (id)initWithDelegate:(id<CVPulldownMenuDelegate>)delegate forMenuFilter:(NSArray*)MenuArray;

@end
