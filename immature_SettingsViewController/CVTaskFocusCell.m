//
//  CVTaskFocusCell.m
//  Vmoso
//
//  Created by Daniel Kong on 10/17/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVTaskFocusCell.h"
#import "CVTaskFocusItem.h"
#import "CVRoundCornersImageView.h"

#define SEGMENT_WIDTH 240
#define SEGMENT_HEIGHT 20
#define SEGMENT_COLOR RGBCOLOR(90, 90, 90)

#define BG_COLOR [UIColor clearColor]
#define PRIVACY_BUTTON_COLOR RGBCOLOR(60, 136, 230)
#define LINEVIEW_HEIGHT 1

#define SPEECHBUBBLE_STYLE TTSTYLEVAR(TableMessageItemSpeechBubbleStyle)
#define ICON_HEIGHT     30
#define ICON_WIDTH     30
@interface CVTaskFocusCell ()

@property(nonatomic, retain) CVTaskFocusItem* item;
@property(nonatomic, retain) UILabel* titleLabel;

@end

@implementation CVTaskFocusCell

- (id) initWithTitle:(NSString*)title andTextField:(BOOL)isTextField {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:title];
    if (self) {
        
        
        
#ifdef CV_TARGET_IPHONE
        CGSize textSize= [title sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(LABELFIELD_WIDTH, LABELFIELD_HEIGHT) lineBreakMode:UILineBreakModeTailTruncation];
        CGFloat labelWidth = textSize.width;
        
        _labelField = [[UILabel alloc] initWithFrame: CGRectMake(PADDING, PADDING, labelWidth, LABELFIELD_HEIGHT)];
        _labelField.textAlignment = NSTextAlignmentLeft;
#else
        _labelField = [[UILabel alloc] initWithFrame: CGRectMake(PADDING, PADDING, LABELFIELD_WIDTH, LABELFIELD_HEIGHT)];
        _labelField.textAlignment = NSTextAlignmentRight;
#endif
        _labelField.backgroundColor= [UIColor purpleColor]; //BG_COLOR;
        _labelField.text = title;
        _labelField.font = [UIFont boldSystemFontOfSize:14];
        _labelField.backgroundColor = [UIColor redColor];
        _labelField.hidden = NO;
        
#ifdef CV_TARGET_IPHONE
        _textField = [[UITextField alloc] initWithFrame: CGRectMake(_labelField.right + SPACER, _labelField.top, self.contentView.width - labelWidth - 60 - SPACER, LABELFIELD_HEIGHT)];
        _textField.textAlignment = NSTextAlignmentRight;
#else
//        _textField = [[UITextField alloc] initWithFrame: CGRectMake(_labelField.right + SPACER, _labelField.top, TEXTFIELD_WIDTH, LABELFIELD_HEIGHT)];
        _textField = [[UITextField alloc] initWithFrame: CGRectMake(5, 5, 25, 25)];

#endif
//        _textField.backgroundColor = [UIColor greenColor];
        _textField.hidden = NO;
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.font = [UIFont systemFontOfSize:14];
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.delegate = self;
        
#ifdef CV_TARGET_IPHONE
        _textView = [[UITextView alloc] initWithFrame: CGRectMake(_labelField.right + SPACER, _labelField.top, self.contentView.width - labelWidth - 60 - SPACER, TEXTVIEW_HEIGHT)];
#else
        _textView = [[UITextView alloc] initWithFrame: CGRectMake(_labelField.right + SPACER, _labelField.top, TEXTFIELD_WIDTH, TEXTVIEW_HEIGHT)];
#endif
        _textView.font = [UIFont systemFontOfSize:14];
        _textView.hidden = YES;
        
        
        [self.contentView addSubview:_labelField];
        [self.contentView addSubview:_textField];
        [self.contentView addSubview:_textView];
        
        if (isTextField) {
            _textView.hidden = NO;
            _textField.hidden = YES;
            self.height = 2 * SPACER + TEXTVIEW_HEIGHT;
        }
        else
            self.height = 2 * SPACER + LABELFIELD_HEIGHT;
    }
    
    return self;
    
}

//resign keyboard when hit Return.
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

/**- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 NSLog(@"tapped");
 [self.textField resignFirstResponder];
 }*/

- (void)setIconViewFromUrlPath:(NSString*)urlPath {
	if (!_iconView) {
		_iconView = [[CVRoundCornersImageView alloc] init];
		_iconView.style = SPEECHBUBBLE_STYLE;
        _iconView.backgroundColor = BG_COLOR;
        _iconView.frame = CGRectMake(self.contentView.width - 2*PADDING - 60, (self.height - ICON_HEIGHT)/2, ICON_WIDTH, ICON_HEIGHT);
        _iconView.urlPath = urlPath;
		[self.contentView addSubview:_iconView];
	}
}

#pragma mark -
#pragma mark TTTableViewCell

- (void)setObject:(id)object {
    
    if (object == nil)
        return;

    _item = object;
//    self.accessoryType = _item.checked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
//    
//    self.ownerIconView.urlPath = [((CVUserListItem*)_item.creator) iconUrlOfSize:@"small"];
//    //[self.ownerIconView setPresenceStatus:PresenceStatusOnline withLargeIcon:NO];
//    self.iconView.urlPath = [((CVUserListItem*)_item.updater) iconUrlOfSize:@"small"];
//    //[self.iconView setPresenceStatus:PresenceStatusOnline withLargeIcon:NO];
//    self.titleLabel.text = _item.lname;
    
    
#ifdef CV_TARGET_IPHONE
    CGSize textSize= [title sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(LABELFIELD_WIDTH, LABELFIELD_HEIGHT) lineBreakMode:UILineBreakModeTailTruncation];
    CGFloat labelWidth = textSize.width;
    
    _labelField = [[UILabel alloc] initWithFrame: CGRectMake(PADDING, PADDING, labelWidth, LABELFIELD_HEIGHT)];
    _labelField.textAlignment = NSTextAlignmentLeft;
#else
    _labelField = [[UILabel alloc] initWithFrame: CGRectMake(PADDING, PADDING, LABELFIELD_WIDTH, LABELFIELD_HEIGHT)];
    _labelField.textAlignment = NSTextAlignmentRight;
#endif
//    _labelField.backgroundColor= [UIColor purpleColor]; //BG_COLOR;
    _labelField.text = _item.fname;
    _labelField.font = [UIFont boldSystemFontOfSize:14];
    _labelField.backgroundColor = [UIColor redColor];
    _labelField.hidden = NO;
    
#ifdef CV_TARGET_IPHONE
    _textField = [[UITextField alloc] initWithFrame: CGRectMake(_labelField.right + SPACER, _labelField.top, self.contentView.width - labelWidth - 60 - SPACER, LABELFIELD_HEIGHT)];
    _textField.textAlignment = NSTextAlignmentRight;
#else
    _textField = [[UITextField alloc] initWithFrame: CGRectMake(_labelField.right + SPACER, _labelField.top, TEXTFIELD_WIDTH, LABELFIELD_HEIGHT)];
    
#endif
    _textField.backgroundColor = [UIColor greenColor];
    _textField.text = _item.selectedOption;
    _textField.hidden = NO;
    _textField.borderStyle = UITextBorderStyleNone;
    _textField.font = [UIFont systemFontOfSize:14];
    _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.delegate = self;
    
#ifdef CV_TARGET_IPHONE
    _textView = [[UITextView alloc] initWithFrame: CGRectMake(_labelField.right + SPACER, _labelField.top, self.contentView.width - labelWidth - 60 - SPACER, TEXTVIEW_HEIGHT)];
#else
    _textView = [[UITextView alloc] initWithFrame: CGRectMake(_labelField.right + SPACER, _labelField.top, TEXTFIELD_WIDTH, TEXTVIEW_HEIGHT)];
#endif
    _textView.font = [UIFont systemFontOfSize:14];
    _textView.hidden = NO;  //
    _textView.textColor = [UIColor blackColor];
//    _textView.backgroundColor = [UIColor redColor]; //
    
    [self.contentView addSubview:_labelField];
    [self.contentView addSubview:_textField];
    [self.contentView addSubview:_textView];
    


//    self.creatorLabel.text = [NSString stringWithFormat:@"Last Updated By %@",((CVUserListItem*)_item.updater).displayName];
//
//    if (_item.unread) {
//        self.hasReadView.urlPath = @"bundle://unreadcircle.png";
//    }
//    else
//        self.hasReadView.urlPath = nil;
//    
//    if (_item.favorite)
//        _favView.hidden = NO;
//    else
//        _favView.hidden = YES;
//    if (_item.important)
//        _impLabel.hidden = NO;
//    else
//        _impLabel.hidden = YES;
//    // Format text name based on task priority
//    _title = [CVAPIUtil capitalizeIt:_item.name];
//    _highPriority = [_item.priority isEqualToString:@"normal"] ? NO : YES;
//    // Call self.titleLabel just to initialize title label
//    self.titleLabel.text = _title;
//    UIColor* titleColor = TITLE_COLOR;
//    [CVAPIUtil formatTitleLabel:_titleLabel title:_title color:titleColor priority:_highPriority];
//    
//    self.taskStatusLabel.hidden = NO;
//    if ([_item.status isEqualToString:TASK_STATUS_COMPLETED])
//        self.taskStatusLabel.image = [UIImage imageNamed:@"task_status_completed.png"];
//    else if ([_item.status isEqualToString:TASK_STATUS_ASSIGNED])
//        self.taskStatusLabel.image = [UIImage imageNamed:@"task_status_assigned.png"];
//    else if ([_item.status isEqualToString:TASK_STATUS_DECLINED])
//        self.taskStatusLabel.image = [UIImage imageNamed:@"task_status_declined.png"];
//    else if ([_item.status isEqualToString:TASK_STATUS_CLOSED])
//        self.taskStatusLabel.image = [UIImage imageNamed:@"task_status_closed.png"];
//    else if ([_item.status isEqualToString:TASK_STATUS_ARCHIVED])
//        self.taskStatusLabel.image = [UIImage imageNamed:@"task_status_archived.png"];
//    else if ([_item.status isEqualToString:TASK_STATUS_SUSPENDED])
//        self.taskStatusLabel.image = [UIImage imageNamed:@"task_status_suspended.png"];
//    else
//        self.taskStatusLabel.hidden = YES;
//    
//    // ======   if (![_item.task isUserAssigned])
//    if (NO)
//        self.myStatusLabel.hidden = YES;
//    else {
//        self.myStatusLabel.hidden = NO;
//        if ([_item.userStatus isEqualToString:TASK_STATUS_COMPLETED])
//            self.myStatusLabel.image = [UIImage imageNamed:@"task_status_completed.png"];
//        else if ([_item.userStatus isEqualToString:TASK_STATUS_ASSIGNED])
//            self.myStatusLabel.image = [UIImage imageNamed:@"task_status_assigned.png"];
//        else if ([_item.userStatus isEqualToString:TASK_STATUS_DECLINED])
//            self.myStatusLabel.image = [UIImage imageNamed:@"task_status_declined.png"];
//        else if ([_item.userStatus isEqualToString:TASK_STATUS_DISMISSED])
//            self.myStatusLabel.image = [UIImage imageNamed:@"task_status_closed.png"];
//        else
//            self.myStatusLabel.hidden = YES;
//    }
//    
//    self.commentLabel.text = [NSString stringWithFormat:@"%d",_item.commentCount];
//    self.attachmentLabel.text = _item.attachmentsCount;
//    self.updateTimeLabel.text = [_item updatedTimeFormatted2Part:_item.timeUpdated];
//    self.creationTimeLabel.text = [_item updatedTimeFormatted2Part:_item.timeCreated];
//    self.dueDateLabel.text = [_item updatedTimeFormatted2Part:_item.dueDate];
    
}

#pragma mark -
#pragma mark UIView

-(void) prepareForReuse {
    
    
    [super prepareForReuse];
    
    _titleLabel.text = nil;
    _labelField.text = nil;
    _textField.text = nil;
    _textView.text = nil;
    
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    _titleLabel.frame = CGRectMake(10, 10, ICON_WIDTH, ICON_HEIGHT);
    _labelField.frame = CGRectMake(30, 10, 60, 60);
    _textField.frame = CGRectMake(110, 10, 220, 60);
    _textView.frame = CGRectMake(280, 10, 60, 60);
    _textView.backgroundColor = [UIColor blueColor];

 }

- (void)didMoveToSuperview {
    
	[super didMoveToSuperview];
    
	if (self.superview) {
		UIColor* baseColor = [UIColor clearColor];

        _titleLabel.backgroundColor = baseColor;
        _labelField.backgroundColor = baseColor;
        _textField.backgroundColor = baseColor;
        _textView.backgroundColor = baseColor;

	}
}


-(UILabel*) titleLabel {
    if (!_titleLabel) {
		_titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = BG_COLOR;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
		[self.contentView addSubview:_titleLabel];
	}
	return _titleLabel;
}

-(UILabel*) labelField {
    if (!_labelField) {
		_labelField = [[UILabel alloc] init];
        _labelField.backgroundColor = BG_COLOR;
        _labelField.textAlignment = NSTextAlignmentCenter;
		[self.contentView addSubview:_labelField];
	}
	return _labelField;
}

-(UITextField*) textField{
    if (!_textField) {
		_textField = [[UITextField alloc] init];
        _textField.backgroundColor = BG_COLOR;
        _textField.textAlignment = NSTextAlignmentCenter;
		[self.contentView addSubview:_textField];
	}
	return _textField;
}

-(UITextView*) textView{
    if (!_textView) {
		_textView = [[UITextView alloc] init];
        _textView.backgroundColor = BG_COLOR;
        _textView.textAlignment = NSTextAlignmentCenter;
		[self.contentView addSubview:_textView];
	}
	return _textView;
}

@end
