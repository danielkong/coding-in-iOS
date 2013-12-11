//
//  CVActivityStampForContact.m
//  Vmoso
//
//  Created by Daniel Kong on 12/9/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVActivityStampForContact.h"
#import "CVNamedIcon.h"

#define FONT_SIZE           14
#define ICON_WIDTH          70
#define SMALL_ICON_WIDTH    16
#define SMALL_ICON_HEIGHT   16
#define TITLE_TEXTCOLOR [UIColor colorWithRed:41/255.0f green:111/255.0f blue:187/255.0f alpha:1]

@interface CVActivityStampForContact ()

@property (nonatomic, retain) UIView* picView;
@property (nonatomic, retain) UILabel* contactName;
@property (nonatomic, retain) UILabel* taskType;
@property (nonatomic, retain) CVUserIconView* userIconView;
@property (nonatomic, retain) UILabel* userDisplayNameLabel;
@property (nonatomic, retain) UILabel* userTitleLabel;
@property (nonatomic, retain) UILabel* userCompanyLabel;
@property (nonatomic, retain) UILabel* seperateImageLabel;
@property (nonatomic, retain) UILabel* seperateImageLabel2;
@property (nonatomic, retain) UILabel* sharedTaskLabel;
@property (nonatomic, retain) UILabel* mutualContactLabel;
@property (nonatomic, retain) UIImageView* imgOfMenu;

@end

@implementation CVActivityStampForContact

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _userIconView = [[CVUserIconView alloc] initWithFrame:CGRectMake(10 , 10, 60, 60)];
        _userIconView.backgroundColor = [UIColor grayColor];
        [self addSubview:_userIconView];
        
        _userDisplayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(ICON_WIDTH + 10, 10, self.width, 15)];
        _userDisplayNameLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _userDisplayNameLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        _userDisplayNameLabel.textColor = TITLE_TEXTCOLOR;
        _userDisplayNameLabel.textAlignment = NSTextAlignmentLeft;
        _userDisplayNameLabel.backgroundColor = [UIColor whiteColor];
        [self addSubview:_userDisplayNameLabel];
        
        _userTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(ICON_WIDTH + 10, 27, self.width, 15)];
        _userTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        _userTitleLabel.font = [UIFont systemFontOfSize:12];
        _userTitleLabel.textColor = [UIColor darkGrayColor];
        _userTitleLabel.textAlignment = NSTextAlignmentLeft;
        _userTitleLabel.backgroundColor = [UIColor whiteColor];
        [self addSubview:_userTitleLabel];

        _userCompanyLabel = [[UILabel alloc] initWithFrame:CGRectMake(ICON_WIDTH + 10, 40, self.width, 15)];
        _userCompanyLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        _userCompanyLabel.font = [UIFont systemFontOfSize:12];
        _userCompanyLabel.textColor = [UIColor darkGrayColor];
        _userCompanyLabel.textAlignment = NSTextAlignmentLeft;
        _userCompanyLabel.backgroundColor = [UIColor whiteColor];
        [self addSubview:_userCompanyLabel];
        
        _seperateImageLabel = [[UILabel alloc] initWithFrame:CGRectMake(ICON_WIDTH + 10, 55, SMALL_ICON_WIDTH, 15)];
        _seperateImageLabel.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_seperateImageLabel];
        
        _sharedTaskLabel = [[UILabel alloc] initWithFrame:CGRectMake(ICON_WIDTH + 35, 55, self.width, 15)];
        _sharedTaskLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        _sharedTaskLabel.font = [UIFont systemFontOfSize:12];
        _sharedTaskLabel.textColor = TITLE_TEXTCOLOR;
        _sharedTaskLabel.textAlignment = NSTextAlignmentLeft;
        _sharedTaskLabel.backgroundColor = [UIColor whiteColor];
        [self addSubview:_sharedTaskLabel];

        _seperateImageLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(ICON_WIDTH + 55, 55, SMALL_ICON_WIDTH, 15)];
        _seperateImageLabel2.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_seperateImageLabel2];
        
        _mutualContactLabel = [[UILabel alloc] initWithFrame:CGRectMake(ICON_WIDTH + 80, 55, self.width, 15)];
        _mutualContactLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        _mutualContactLabel.font = [UIFont systemFontOfSize:12];
        _mutualContactLabel.textColor = TITLE_TEXTCOLOR;
        _mutualContactLabel.textAlignment = NSTextAlignmentLeft;
        _mutualContactLabel.backgroundColor = [UIColor whiteColor];
        [self addSubview:_mutualContactLabel];
        
        _imgOfMenu = [[UIImageView alloc] initWithFrame:CGRectMake(ICON_WIDTH + 150, 55, SMALL_ICON_WIDTH, SMALL_ICON_WIDTH)];
        _imgOfMenu.image = [CVNamedIcon iconNamed:@"Menu" inSprite:@"24x24_Sprite_Black40.png"];
        _imgOfMenu.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_imgOfMenu];
        
    }
    return self;
}

- (void)prepareForReuse {
    [_userIconView unsetImage];
}

- (void)setThumbnailInfo:(id<CVContactStampInfo>)contactStampInfo
{
    _userDisplayNameLabel.text = contactStampInfo.displayName;
    _userTitleLabel.text = contactStampInfo.jobTitle;
    _userCompanyLabel.text = contactStampInfo.company;
    [_userIconView setIconWithUser:contactStampInfo.contactIconInfo];
    _sharedTaskLabel.text = contactStampInfo.sharedTaskCountStr;
    _mutualContactLabel.text = contactStampInfo.mutualContactCountStr;
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
