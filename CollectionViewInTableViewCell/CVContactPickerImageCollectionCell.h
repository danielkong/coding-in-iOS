//
//  CVContactPickerImageCollectionCell.h
//  Vmoso
//
//  Created by Daniel Kong on 11/5/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CVUserImageView.h"

@class CVContactPickerImageCollectionWithNameCell;
@class CVMenuItem;


@protocol CVContactPickerImageSelectionWithNameDelegate  <NSObject>

- (void)ContactPickerImageDidSelect:(CVMenuItem *)treeItem;

@end

@interface CVContactPickerImageCollectionWithNameCell : UICollectionViewCell

@property (nonatomic, assign) id <CVContactPickerImageSelectionWithNameDelegate> delegate;
@property (nonatomic, retain) CVUserImageView *collectionImageView;
@property (nonatomic, retain) UILabel *displayName;

@end
