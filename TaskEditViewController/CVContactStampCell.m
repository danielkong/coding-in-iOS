//
//  CVContactStampCell.m
//  Vmoso
//
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVContactStampCell.h"
#import "CVUserListItem.h"
#import "CVContactItem+Bizlogic.h"
#import "CVNamedIcon.h"

#define MSG_ICON_WIDTH      12
#define MSG_ICON_HEIGHT     12
#define COUNT_LABEL_WIDTH   20
#define ICON_LABEL_SPACE    5
#define ICON_PADDING        5


@interface CVContactStampCell ()

@property (nonatomic, retain) UIImageView* payloadImgView;
@property (nonatomic, retain) UIImageView* statusImgView;

@end

@implementation CVContactStampCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
                        
        self.contentView.backgroundColor = [RGBCOLOR(92,91,91) colorWithAlphaComponent:0.25];
        
        self.iconView = [[CVUserIconView alloc] init];
        [self.contentView addSubview:_iconView];
        
        self.nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:11];
        _nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _nameLabel.textAlignment = UITextAlignmentCenter;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_nameLabel];
        
        _statusImgView = [[UIImageView alloc] initWithImage:[CVNamedIcon iconNamed:@"Task Assigned" inSprite:@"24x24_Sprite_Black100.png"]];
        _payloadImgView = [[UIImageView alloc] initWithImage:[CVNamedIcon iconNamed:@"Share" inSprite:@"24x24_Sprite_Black100.png"]];
        
        _payloadCountLabel = [[UILabel alloc] init];
        _payloadCountLabel.font = [UIFont systemFontOfSize:10];
        _payloadCountLabel.textAlignment = UITextAlignmentLeft;
        _payloadCountLabel.backgroundColor = [UIColor clearColor];
        _payloadCountLabel.textColor = [UIColor blackColor];
        
        [self.contentView addSubview:_payloadImgView];
        [self.contentView addSubview:_payloadCountLabel];
        [self.contentView addSubview:_statusImgView];
        
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    _iconView.frame = CGRectMake(ICON_PADDING, ICON_PADDING, self.width - ICON_PADDING*2, self.width - ICON_PADDING*2);
    CGFloat top = _iconView.bottom + ICON_PADDING;
    
    _nameLabel.frame = CGRectMake(ICON_PADDING, top, self.contentView.width - ICON_PADDING*2, NAME_LABEL_HEIGHT);
    top += NAME_LABEL_HEIGHT + 8;
    CGFloat left = ICON_PADDING;
    
    _payloadImgView.frame = CGRectMake(left, top, MSG_ICON_WIDTH, MSG_ICON_HEIGHT);
    _payloadCountLabel.frame = CGRectMake(left + MSG_ICON_WIDTH + ICON_LABEL_SPACE, top, COUNT_LABEL_WIDTH, MSG_ICON_HEIGHT);
    
    if (_isMyself) {
        _payloadImgView.hidden = YES;
        _payloadCountLabel.hidden = YES;
    }
    _statusImgView.frame = CGRectMake(self.contentView.width - PADDING - MSG_ICON_WIDTH, top, MSG_ICON_WIDTH, MSG_ICON_HEIGHT);
    
    _statusImgView.hidden = NO;
    if (_taskStatus == nil)
        _statusImgView.hidden = YES;
    else if ([_taskStatus isEqualToString:TASK_STATUS_ASSIGNED])
        _statusImgView.image = [CVNamedIcon iconNamed:@"Task Assigned" inSprite:@"24x24_Sprite_Black100.png"];
    else if ([_taskStatus isEqualToString:TASK_STATUS_CLOSED] || [_taskStatus isEqualToString:TASK_STATUS_DISMISSED])
        _statusImgView.image = [UIImage imageNamed:@"task_closed.png"];
    else if ([_taskStatus isEqualToString:TASK_STATUS_COMPLETED])
        _statusImgView.image = [CVNamedIcon iconNamed:@"Task Complete" inSprite:@"24x24_Sprite_Black100.png"];
    else if ([_taskStatus isEqualToString:TASK_STATUS_DECLINED])
        _statusImgView.image = [UIImage imageNamed:@"task_declined.png"];
    else
        _statusImgView.hidden = YES;
}

- (void)prepareForReuse {
    [_iconView unsetImage];
}

- (void)setObject:(id)object {
    
    if (![object isKindOfClass:[CVUserListItem class]]){
        _iconView.letterView.hidden = YES;
        _iconView.image = [CVNamedIcon iconNamed:@"Add Contact"];
        _nameLabel.text = LS(@"Add People", @"");
        return;
    }
    
    CVUserListItem* user = (CVUserListItem*)object;
    [_iconView setIconWithUser:user];
    
#ifdef CV_TARGET_IPAD
    // For iPad version, setting more user information
    _nameLabel.text = user.displayName;
    
    //***_payloadCountLabel.text = [NSString stringWithFormat:@"%@",user.sharedTasks];
    if ([user.key isEqualToString:[CVAPIUtil getUserKey]])
        _isMyself = YES;
    else
        _isMyself = NO;
    
//    if (_status == nil || [_status objectForKey:user.key] == nil)
//        _taskStatus = nil;
//    else
//        _taskStatus = [_status objectForKey:user.key];
    
    if(user.isAlien) {
        _taskStatus = nil;
        _isMyself = YES;
    }
    
#endif
    
    self.contentView.backgroundColor = [CVContactItem bgColor:nil];//*** user.contactType
}

@end
