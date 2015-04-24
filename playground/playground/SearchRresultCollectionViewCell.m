//
//  SearchRresultCollectionViewCell.m
//  playground
//
//  Created by daniel on 4/4/15.
//  Copyright (c) 2015 DK. All rights reserved.
//

#import "SearchRresultCollectionViewCell.h"

@interface SearchRresultCollectionViewCell()

@property(nonatomic, strong) UIView* container;

@end

@implementation SearchRresultCollectionViewCell

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"test-icon"]];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        _container = [[UIView alloc] initWithFrame:self.contentView.frame];
        _container.backgroundColor = [UIColor clearColor];

        [_container addSubview:_imageView];
        [_container addSubview:_textLabel];
//        _container.frame = CGRectMake(0, 0, self.contentView.width - 0*2, self.contentView.height - 0*2);

        [self.contentView addSubview:_container];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//    _container.frame = CGRectMake(0, 0, self.contentView.width - 0*2, self.contentView.height - 0*2);
}

@end
