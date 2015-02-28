//
//  imageCollectionViewCell.m
//  collectionView
//
//  Created by daniel on 2/26/15.
//  Copyright (c) 2015 DK. All rights reserved.
//

#import "imageCollectionViewCell.h"

@implementation imageCollectionViewCell

- (id)init {
    self = [super init];
    if (self) {
        _imageView = [[UIImage alloc] init];
    }
    
    return self;
}

@end
