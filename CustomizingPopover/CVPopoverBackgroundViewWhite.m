//
//  CVPopoverBackgroundViewWhite.m
//  
//
//  Created by daniel kong on 8/14/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVPopoverBackgroundViewWhite.h"
#define kArrowBase 30.0f
#define kArrowHeight 15.0f
#define kBorderInset 0.0f

@interface CVPopoverBackgroundViewWhite()
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UIImageView *borderImageView;

- (UIImage *)drawArrowImage:(CGSize)size;
@end

@implementation CVPopoverBackgroundViewWhite

@synthesize arrowDirection  = _arrowDirection;
@synthesize arrowOffset     = _arrowOffset;

#pragma mark - Graphics Methods
- (UIImage *)drawArrowImage:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor clearColor] setFill];
    CGContextFillRect(ctx, CGRectMake(0.0f, 0.0f, size.width, size.height));
    
    CGMutablePathRef arrowPath = CGPathCreateMutable();
    CGPathMoveToPoint(arrowPath, NULL, (size.width/2.0f), 0.0f); //Top Center
    CGPathAddLineToPoint(arrowPath, NULL, size.width, size.height); //Bottom Right
    CGPathAddLineToPoint(arrowPath, NULL, 0.0f, size.height); //Bottom Right
    CGPathCloseSubpath(arrowPath);
    CGContextAddPath(ctx, arrowPath);
    CGPathRelease(arrowPath);
    
    UIColor *fillColor = [UIColor whiteColor];
    CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
    CGContextDrawPath(ctx, kCGPathFill);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    
}


#pragma mark - UIPopoverBackgroundView Overrides
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        //TODO: update with border image view
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.arrowImageView = arrowImageView;
        [self addSubview:self.arrowImageView];
        
        //TODO: update with border color
        UIImageView *borderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, kArrowHeight, frame.size.width, frame.size.height-kArrowHeight)];
        borderImageView.backgroundColor = [UIColor darkGrayColor];
        [self addSubview:borderImageView];
        
    }
    return self;
}

+ (CGFloat)arrowBase
{
    return kArrowBase;
}

+ (CGFloat)arrowHeight
{
    return kArrowHeight;
}

+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(kBorderInset, kBorderInset, kBorderInset, kBorderInset);
}

+ (BOOL)wantsDefaultContentAppearance
{
    return NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //TODO: test for arrow UIPopoverArrowDirection
    CGSize arrowSize = CGSizeMake([[self class] arrowBase], [[self class] arrowHeight]);
    self.arrowImageView.image = [self drawArrowImage:arrowSize];

    self.arrowImageView.frame = CGRectMake(((self.bounds.size.width - arrowSize.width)- kBorderInset - 90.0f), 0.0f, arrowSize.width, arrowSize.height);
  
}



@end
