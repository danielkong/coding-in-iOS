//
//  CVBaseMenuTreeTableViewCell.h
//  
//
//  Created by daniel kong on 8/13/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CVBaseMenuTreeTableViewCell;
@class CVBaseMenuTreeItem;

@protocol CVBaseMenuTreeTableViewCellDelegate  <NSObject>

- (void)treeTableViewCell:(CVBaseMenuTreeTableViewCell *)cell didTapIconWithTreeItem:(CVBaseMenuTreeItem *)treeItem;

@end

@interface CVBaseMenuTreeTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIButton *iconButton;
@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIImageView *downArrowImage;
@property (nonatomic, assign) id <CVBaseMenuTreeTableViewCellDelegate> delegate;
@property (nonatomic, strong) CVBaseMenuTreeItem *treeItem;

- (void)setLevel:(NSInteger)pixels;


@end
