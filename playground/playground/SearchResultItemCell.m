//
//  SearchResultItemCell.m
//  playground
//
//  Created by daniel on 4/4/15.
//  Copyright (c) 2015 DK. All rights reserved.
//

#import "SearchResultItemCell.h"

@interface SearchResultItemCell()
@end


@implementation SearchResultItemCell

// Designated initializer.

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)setup {
    
    _image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    _image.image = [UIImage imageNamed: @"default.jpg"];
//    CGSize imgSize = _image.image.size;
//    [_image sizeToFit]; // if imageView larger than icon then fit to icon size. // if use default.jpg then too large for the cell, then the cell could not see anything.
    [_image setContentMode:UIViewContentModeScaleAspectFit];    // if imageView larger than icon, then fit to imageView size.
//    typedef NS_ENUM(NSInteger, UIViewContentMode) {
//        UIViewContentModeScaleToFill,
//        UIViewContentModeScaleAspectFit,      // contents scaled to fit with fixed aspect. remainder is transparent
//        UIViewContentModeScaleAspectFill,     // contents scaled to fill with fixed aspect. some portion of content may be clipped.
//        UIViewContentModeRedraw,              // redraw on bounds change (calls -setNeedsDisplay)
//        UIViewContentModeCenter,              // contents remain same size. positioned adjusted.
//        UIViewContentModeTop,
//        UIViewContentModeBottom,
//        UIViewContentModeLeft,
//        UIViewContentModeRight,
//        UIViewContentModeTopLeft,
//        UIViewContentModeTopRight,
//        UIViewContentModeBottomLeft,
//        UIViewContentModeBottomRight,
//    };

//    [self addSubview:_image];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
