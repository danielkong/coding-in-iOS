//  CVContactPickerImageCollectionCell.h


#import <UIKit/UIKit.h>
@class CVContactPickerImageCollectionCell;
@class CVMenuItem;

@protocol CVContactPickerImageSelectionDelegate  <NSObject>

- (void)ContactPickerImageDidSelect:(CVMenuItem *)treeItem;

@end

@interface CVContactPickerImageCollectionCell : UICollectionViewCell


@property (nonatomic, assign) id <CVContactPickerImageSelectionDelegate> delegate;

@property (strong, nonatomic) UILabel* label;
@property (nonatomic, strong) UIImageView *collectionImageView;
@property(nonatomic, retain) CVUserIconView* iconView;


@end
