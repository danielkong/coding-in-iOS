//
//  BaseMenuTreeTableViewCell.h
//  
//
//  Created by daniel kong on 8/13/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BaseMenuTreeTableViewCell;
@class BaseMenuTreeItem;

@protocol BaseMenuTreeTableViewCellDelegate  <NSObject>

- (void)treeTableViewCell:(BaseMenuTreeTableViewCell *)cell didTapIconWithTreeItem:(BaseMenuTreeItem *)treeItem;

@end

@interface BaseMenuTreeTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIButton *iconButton;
@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIImageView *downArrowImage;
@property (nonatomic, assign) id <BaseMenuTreeTableViewCellDelegate> delegate;
@property (nonatomic, strong) BaseMenuTreeItem *treeItem;

- (void)setLevel:(NSInteger)pixels;


@end
