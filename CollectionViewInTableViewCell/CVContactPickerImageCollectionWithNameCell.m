//
//  CVContactPickerImageCollectionWithNameCell.m
//  Vmoso
//
//  Created by Daniel Kong on 11/5/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVContactPickerImageCollectionWithNameCell.h"

@implementation CVContactPickerImageCollectionWithNameCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _collectionImageView = [[CVUserImageView alloc] initWithFrame:CGRectMake(15,0,45,45)];
        [self.contentView addSubview:_collectionImageView];
        
        _displayName = [[UILabel alloc] initWithFrame:CGRectMake(5,45,60,30)];
        _displayName.font = [UIFont systemFontOfSize:12];
        _displayName.textAlignment = NSTextAlignmentCenter;
        _displayName.lineBreakMode = NSLineBreakByWordWrapping;
        _displayName.numberOfLines = 2;
        [self.contentView addSubview:_displayName];
    }
    return self;
}

@end

