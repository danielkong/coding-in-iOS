//
//  IPhoneMVTopBar.h
//  Vmoso
//
//  Created by Bin Zhou on 2/14/14.
//  Copyright (c) 2014 Broadvision. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPhoneMVTopBar : UIView <UIAppearance>

@property(nonatomic, retain) NSString* title;
@property(nonatomic, retain) UILabel* titleLabel;
@property(nonatomic, retain) UIButton* backButton;
@property(nonatomic, retain) UIButton* rightButton;
@property(nonatomic, retain) UIButton* titleButton;
@property(nonatomic, assign) NSUInteger badgeCount;
@property(nonatomic, retain) UIImage* typeIcon;
@property(nonatomic, retain) UIColor* styleColor UI_APPEARANCE_SELECTOR;

- (NSString*)getTitle;

- (void)showUpdating:(BOOL)isUpdating;
- (void)showLoading:(BOOL)isLoading;
- (void)showUpdatingWithMessage:(NSString*)message;
- (void)showLoadingWithMessage:(NSString*)message;
- (void)showLoadingIndicator:(BOOL)isLoading;
- (void)beginAnimateTitleThemeBar;
- (void)endAnimateTitleThemeBar;

@end
