//
//  UIView+RoundCorners.m
//  CV
//
//  Created by Bin Zhou on 8/16/12.
//  Copyright (c) 2012 Broadvision. All rights reserved.
//

#import "UIView+RoundCorners.h"

@implementation UIView (RoundCorners)

-(void)enableRoundCorners:(BOOL)enable {
   
    if (enable) {
        // Create the path (with only the top-left corner rounded)
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                       byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight
                                                             cornerRadii:CGSizeMake(10.0, 10.0)];
        
        // Create the shape layer and set its path
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        
        // Set the newly created shape layer as the mask for the image view's layer
        self.layer.mask = maskLayer;
        
    } else {
        self.layer.mask = nil;
    }
}

-(void)roundCorners:(CGFloat)radius {
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight|UIRectCornerTopLeft|UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(radius, radius)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    // Set the newly created shape layer as the mask for the image view's layer
    self.layer.mask = maskLayer;
}

-(void)roundCorners:(UIRectCorner)corners withRadius:(CGFloat)radius {
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(radius, radius)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    // Set the newly created shape layer as the mask for the image view's layer
    self.layer.mask = maskLayer;
}

@end
