//
//  UIView+RoundCorners.h
//  CV
//
//  Created by Bin Zhou on 8/16/12.
//  Copyright (c) 2012 Broadvision. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (RoundCorners)

-(void)enableRoundCorners:(BOOL)enable;
-(void)roundCorners:(CGFloat)radius;
-(void)roundCorners:(UIRectCorner)corners withRadius:(CGFloat)radius;

@end
