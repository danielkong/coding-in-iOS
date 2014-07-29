//
//  IPhoneMVTopBar.m
//  Vmoso
//
//  Created by Bin Zhou on 2/14/14.
//  Copyright (c) 2014 Broadvision. All rights reserved.
//

#import "IPhoneMVTopBar.h"
#import "UIView+RoundCorners.h"
//#import "CVColoredImageUtil.h"
//#import "CVNewStreamViewController.h"
//#import "CVNamedIcon.h"
//#import "IPhoneMVStyleController.h"
//#import "CVCustomBadge.h"

#define TITLE_LABEL_HEIGHT      44
#define BUTTON_WIDTH            60
#define BUTTON_HEIGHT           44
#define THEMEBAR_HEIGHT         4
#define BUTTON_IMG_WIDTH        24
#define BUTTON_IMG_HEIGHT       24

#define TYPEICON_WIDTH          16
#define TYPEICON_HEIGHT         16

#define BADGE_BG_COLOR          RGBCOLOR(66, 150, 205)


@interface IPhoneMVTopBar ()

@property(nonatomic, retain) UIView* titleBar;
@property(nonatomic, retain) UIView* titleThemeBar;
@property(nonatomic, retain) UIView* animatedView;
//@property(nonatomic, retain) CVCustomBadge* badgeView;
@property(nonatomic, retain) UIImageView* typeIconView;

@end

@implementation IPhoneMVTopBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, TITLE_LABEL_HEIGHT + THEMEBAR_HEIGHT)];
        _titleBar.backgroundColor = [UIColor yellowColor];
//        _titleBar.backgroundColor = [[IPhoneMVStyleController sharedInstance] colorForTheme:THEME_FOR_BASE];
//        
        _titleThemeBar = [[UIView alloc] initWithFrame:CGRectMake(0, TITLE_LABEL_HEIGHT, _titleBar.frame.size.width, THEMEBAR_HEIGHT)];
//        _titleThemeBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        _animatedView = [[UIView alloc] initWithFrame:CGRectMake(_titleThemeBar.width/2, 0, 0, _titleThemeBar.height)];
//        _animatedView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
//        
//        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _backButton.titleLabel.font = [UIFont systemFontOfSize:14];
//        _backButton.titleLabel.adjustsFontSizeToFitWidth = YES;
//        _backButton.showsTouchWhenHighlighted = YES;
//        [_backButton setImage:[CVNamedIcon iconNamed:@"Element Nav Previous"] forState:UIControlStateNormal];
//        _backButton.imageEdgeInsets = UIEdgeInsetsMake((BUTTON_HEIGHT - BUTTON_IMG_HEIGHT)/2,
//                                                       10,
//                                                       (BUTTON_HEIGHT - BUTTON_IMG_HEIGHT)/2,
//                                                       BUTTON_WIDTH - BUTTON_IMG_WIDTH - 10);
//        _backButton.frame = CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
        
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _rightButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _rightButton.showsTouchWhenHighlighted = YES;
        _rightButton.imageEdgeInsets = UIEdgeInsetsMake((BUTTON_HEIGHT - BUTTON_IMG_HEIGHT)/2,
                                                        BUTTON_WIDTH - BUTTON_IMG_WIDTH - 10,
                                                        (BUTTON_HEIGHT - BUTTON_IMG_HEIGHT)/2,
                                                        10);
        _rightButton.frame = CGRectMake(frame.size.width - BUTTON_WIDTH, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
        _rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(BUTTON_WIDTH, 0, frame.size.width - BUTTON_WIDTH*2, TITLE_LABEL_HEIGHT)];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 2;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.textColor = [UIColor whiteColor];
        //        _titleLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"top_nav_grad.png"]];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.minimumScaleFactor= 14.f;
        _titleLabel.backgroundColor = [UIColor clearColor];
        
//        _badgeView = [CVCustomBadge customBadgeWithString:@""
//                                          withStringColor:[UIColor whiteColor]
//                                           withInsetColor:BADGE_BG_COLOR
//                                           withBadgeFrame:NO
//                                      withBadgeFrameColor:[UIColor whiteColor]
//                                                withScale:1.1
//                                              withShining:NO];
        
        _typeIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TYPEICON_WIDTH, TYPEICON_HEIGHT)];

        _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _titleButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleButton.showsTouchWhenHighlighted = YES;
        _titleButton.frame = _titleLabel.frame;
        
//        [_titleBar addSubview:_titleThemeBar];
//        [_titleBar addSubview:_backButton];
        [_titleBar addSubview:_titleLabel];
//        [_titleBar addSubview:_badgeView];
        [_titleBar addSubview:_typeIconView];
        [_titleBar addSubview:_titleButton];
        [_titleBar addSubview:_rightButton];
        
        [self addSubview:_titleBar];
//        self.height = _titleBar.height;
        
    }
    return self;
}

//- (void)setBadgeCount:(NSUInteger)badgeCount {
//    _badgeCount = badgeCount;
//    CGSize suggestedSize = [_title sizeWithFont:_titleLabel.font constrainedToSize:_titleLabel.frame.size];
//    _badgeView.frame = CGRectMake(_titleLabel.right - (_titleLabel.width  - suggestedSize.width)/2, 5, 30, 30);
//    [_badgeView autoBadgeSizeWithString:(badgeCount > 0) ? [NSString stringWithFormat:@"%d", badgeCount] : @""];
//}
//
//- (void)setTypeIcon:(UIImage *)typeIcon {
//    _typeIconView.image = typeIcon;
//    CGSize suggestedSize = [_title sizeWithFont:_titleLabel.font constrainedToSize:_titleLabel.frame.size];
//    _typeIconView.top = (_titleLabel.height - _typeIconView.height)/2;
//    _typeIconView.left = _titleLabel.left + (_titleLabel.width  - suggestedSize.width)/2 - _typeIconView.width - 5;
//}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (NSString*)getTitle{
    return _titleLabel.text;
}

- (void)setStyleColor:(UIColor*)styleColor {
    
    if (styleColor == nil)
        return;
    
    _titleThemeBar.backgroundColor = styleColor;
}

- (void)showUpdating:(BOOL)isUpdating {
    if (isUpdating) {
        [self showUpdatingWithMessage:@"Updating ..."];
    } else {
        // stop previous animations
        [_animatedView.layer removeAllAnimations];
        [self endAnimateTitleThemeBar];
    }
}

- (void)showLoading:(BOOL)isLoading {
    if (isLoading) {
        [self showLoadingWithMessage:@"Loading ..."];
    } else {
        // stop previous animations
        [_animatedView.layer removeAllAnimations];
        [self endAnimateTitleThemeBar];
    }
}

- (void)showLoadingWithMessage:(NSString*)message {
    _titleLabel.text = message;
    [self beginAnimateTitleThemeBar];
}

- (void)showUpdatingWithMessage:(NSString*)message {
    _titleLabel.text = message;
    [self beginAnimateTitleThemeBar];
}

//- (void)beginAnimateTitleThemeBar {
//    
//    _typeIconView.hidden = YES;
//    
//    _animatedView.frame = CGRectMake(_titleThemeBar.width/2, 0, 0, _titleThemeBar.height);
//    [_titleThemeBar addSubview:_animatedView];
//    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
//        _animatedView.frame = _titleThemeBar.bounds;
//    } completion:nil];
//}
//
//- (void)endAnimateTitleThemeBar {
//    [UIView animateWithDuration:0.5f animations:^{
//        _animatedView.frame = CGRectMake(_titleThemeBar.width/2, 0, 0, _titleThemeBar.height);
//    } completion:^(BOOL finished) {
//        [_animatedView removeFromSuperview];
//        _titleLabel.text = _title;
//        _typeIconView.hidden = NO;
//    }];
//}

@end
