#import "CVContactPickerImageCollectionCell.h"

@implementation CVContactPickerImageCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.collectionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        
        CALayer * l = [self.collectionImageView layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:5.0];
        [self.contentView addSubview:self.collectionImageView];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
}