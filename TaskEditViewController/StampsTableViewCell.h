//
//  CVStampsTableViewCell.h
//  Vmoso
//
//      This implements the functions of having horizontally scrollable 'stamps'
//      in a UITableViewCell.
//
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CVStampsTableViewCell;

@protocol CVStampsTableViewCellDelegate <NSObject>

@optional
- (void)stampsTableViewCell:(CVStampsTableViewCell*)cell didSelectAt:(NSInteger)index;

@end

@interface CVStampsTableViewCell : UITableViewCell

@property (nonatomic, retain) NSArray* items;
@property (nonatomic, assign) UIEdgeInsets insects;
@property (nonatomic, assign) CGFloat stampSpacing;
@property (nonatomic, assign) CGSize stampSize;
@property (nonatomic, retain) UICollectionView* stampsView;

@property (nonatomic, unsafe_unretained) id<CVStampsTableViewCellDelegate> delegate;

- (void)registerStampClass:(Class)cellClass forCellWithReuseIdentifier:(NSString*)identifier;

@end
