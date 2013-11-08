//
//  CVStampsTableViewCell.m
//  Vmoso
//
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVStampsTableViewCell.h"
#import "CVStampCell.h"

#define CELL_HEIGHT     60

@interface CVStampsTableViewCell () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, retain) UICollectionViewFlowLayout* layout;
@property (nonatomic, retain) NSString* identifier;

@end

@implementation CVStampsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // initialize properties
        
        _items = [NSArray array];
        _insects = UIEdgeInsetsZero;
        _stampSize = CGSizeMake(90, 60);    // default
        
        // initialize stampsView
                
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.itemSize = CGSizeMake(90, 60);
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _stampsView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:_layout];
        _stampsView.dataSource = self;
        _stampsView.delegate = self;
        _stampsView.backgroundColor = [UIColor clearColor];
        _stampsView.showsHorizontalScrollIndicator = NO;
        
        [self.contentView addSubview:_stampsView];      
        
    }
    return self;
}

- (void)registerStampClass:(Class)cellClass forCellWithReuseIdentifier:(NSString*)identifier {
    _identifier = identifier;
    [_stampsView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}


- (void)setItems:(NSArray *)items {
    _items = items;
    [_stampsView reloadData];
}

- (void)setInsects:(UIEdgeInsets)insects {
    _insects = insects;
    _stampsView.frame = CGRectMake(insects.left,
                                   insects.top,
                                   self.width - insects.left - insects.right,
                                   self.height - insects.top - insects.bottom);
}

- (void)setStampSpacing:(CGFloat)stampSpacing {
    _stampSpacing = stampSpacing;
    _layout.minimumLineSpacing = stampSpacing;
    [_layout invalidateLayout];
}

- (void)setStampSize:(CGSize)stampSize {
    _layout.itemSize = stampSize;
    [_layout invalidateLayout];
}

- (void)prepareForReuse {
    _items = [NSArray array];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_items count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CVStampCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:_identifier forIndexPath:indexPath];
    [cell setObject:[_items objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_delegate && [_delegate respondsToSelector:@selector(stampsTableViewCell:didSelectAt:)]) {
        [_delegate stampsTableViewCell:self didSelectAt:indexPath.row];
    }
}

@end
