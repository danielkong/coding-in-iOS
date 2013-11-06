//
//  CVTaskFocusCell.m
//  Vmoso
//
//  Created by Daniel Kong on 10/17/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVFocusCell.h"
#import "CVFocusItem.h"
#import "CVRoundCornersImageView.h"

#define SEGMENT_WIDTH 240
#define SEGMENT_HEIGHT 20
#define SEGMENT_COLOR RGBCOLOR(90, 90, 90)

#define BG_COLOR [UIColor clearColor]
#define PRIVACY_BUTTON_COLOR RGBCOLOR(60, 136, 230)
#define LINEVIEW_HEIGHT 1

#define ICON_HEIGHT     30
#define ICON_WIDTH     30
@interface CVFocusCell ()

@property(nonatomic, retain) CVFocusItem* item;
@property(nonatomic, retain) UILabel* titleLabel;

@end

@implementation CVFocusCell

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
#endif
        _labelField.text = title;
        _labelField.font = [UIFont boldSystemFontOfSize:14];
        _labelField.hidden = NO;
        
#ifdef CV_TARGET_IPHONE
        _textField = [[UITextField alloc] initWithFrame: CGRectMake(_labelField.right + SPACER, _labelField.top, self.contentView.width - labelWidth - 60 - SPACER, LABELFIELD_HEIGHT)];
        _textField.textAlignment = NSTextAlignmentRight;
#else
        _textField = [[UILabel alloc] initWithFrame: CGRectMake(5, 5, 25, 25)];

#endif

        _textField.hidden = NO;
        _textField.font = [UIFont systemFontOfSize:14];
        
        [self.contentView addSubview:_labelField];
        [self.contentView addSubview:_textField];
        
        if (isTextField) {
            _textField.hidden = YES;
            self.height = 2 * SPACER + TEXTVIEW_HEIGHT;
        }
        else
            self.height = 2 * SPACER + LABELFIELD_HEIGHT;
    }
    
    return self;
    
}

#pragma mark -
#pragma mark TTTableViewCell

- (void)setObject:(id)object {
    
    if (object == nil)
        return;

    _item = object;
    
#ifdef CV_TARGET_IPHONE
    CGSize textSize= [title sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(LABELFIELD_WIDTH, LABELFIELD_HEIGHT) lineBreakMode:UILineBreakModeTailTruncation];
    CGFloat labelWidth = textSize.width;
    
    _labelField = [[UILabel alloc] initWithFrame: CGRectMake(PADDING, PADDING, labelWidth, LABELFIELD_HEIGHT)];
    _labelField.textAlignment = NSTextAlignmentLeft;
#else
    _labelField = [[UILabel alloc] initWithFrame: CGRectMake(PADDING, PADDING, LABELFIELD_WIDTH, LABELFIELD_HEIGHT)];
    _labelField.textAlignment = NSTextAlignmentRight;
#endif
    _labelField.text = _item.title;
    _labelField.font = [UIFont boldSystemFontOfSize:14];
    _labelField.backgroundColor = [UIColor clearColor];
    _labelField.hidden = NO;
    
#ifdef CV_TARGET_IPHONE
    _textField = [[UILabel alloc] initWithFrame: CGRectMake(_labelField.right + SPACER, _labelField.top, self.contentView.width - labelWidth - 60 - SPACER, LABELFIELD_HEIGHT)];
    _textField.textAlignment = NSTextAlignmentRight;
#else
    _textField = [[UILabel alloc] initWithFrame: CGRectMake(_labelField.right + SPACER, _labelField.top, TEXTFIELD_WIDTH, LABELFIELD_HEIGHT)];
    
#endif
    _textField.text = _item.selectedOption;
    _textField.hidden = NO;
    _textField.font = [UIFont systemFontOfSize:14];
    
    [self.contentView addSubview:_labelField];
    [self.contentView addSubview:_textField];
}

#pragma mark -
#pragma mark UIView

-(void) prepareForReuse {
    
    
    [super prepareForReuse];
    
    _titleLabel.text = nil;
    _labelField.text = nil;
    _textField.text = nil;
    
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    _titleLabel.frame = CGRectMake(10, 10, ICON_WIDTH, ICON_HEIGHT);
    _labelField.frame = CGRectMake(10, 10, 100, 30);
    _textField.frame = CGRectMake(120, 10, 170, 30);
    _textField.textColor = [UIColor darkGrayColor];
    _textField.textAlignment = NSTextAlignmentRight;

 }

- (void)didMoveToSuperview {
    
	[super didMoveToSuperview];
    
	if (self.superview) {
		UIColor* baseColor = [UIColor clearColor];

        _titleLabel.backgroundColor = baseColor;
        _labelField.backgroundColor = baseColor;
        _textField.backgroundColor = baseColor;

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

-(UILabel*) textField {
    if (!_textField) {
		_textField = [[UILabel alloc] init];
        _textField.backgroundColor = BG_COLOR;
        _textField.textAlignment = NSTextAlignmentRight;
		[self.contentView addSubview:_textField];
	}
	return _textField;
}
@end
