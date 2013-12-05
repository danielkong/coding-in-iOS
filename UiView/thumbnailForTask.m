//
//  CVThumbnailForContact.m
//  Vmoso
//
//  Created by Daniel Kong on 11/27/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVThumbnailForContact.h"

#define FONT_SIZE           14
#define TITLE_TEXTCOLOR [UIColor colorWithRed:41/255.0f green:111/255.0f blue:187/255.0f alpha:1]

@interface CVThumbnailForContact ()

@property (nonatomic, retain) UIView* picView;
@property (nonatomic, retain) UILabel* contactName;
@property (nonatomic, retain) UILabel* taskType;
@property (nonatomic, retain) CVUserIconView* userIconView;
@property (nonatomic, retain) UILabel* userDisplayNameLabel;

@end

@implementation CVThumbnailForContact

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _userIconView = [[CVUserIconView alloc] initWithFrame:CGRectMake(0 , 0, self.width, self.width)];
        _userIconView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_userIconView];
        
        _userDisplayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _userIconView.bottom, self.width, self.height - self.width)];
        _userDisplayNameLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _userDisplayNameLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        _userDisplayNameLabel.textColor = TITLE_TEXTCOLOR;
        _userDisplayNameLabel.textAlignment = NSTextAlignmentLeft;
        _userDisplayNameLabel.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_userDisplayNameLabel];
        
    }
    return self;
}

- (void)prepareForReuse {
    [_userIconView unsetImage];
}

- (void)setThumbnailInfo:(id<CVContactThumbnailInfo>)contactThumbnailInfo
{
    _userDisplayNameLabel.text = [[contactThumbnailInfo contactIconInfo] displayName];
    [_userIconView setIconWithUser:[contactThumbnailInfo contactIconInfo]];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
