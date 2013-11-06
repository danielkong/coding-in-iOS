//
//  CVFocusListCell.m
//  Vmoso
//
//  Created by Daniel Kong on 10/23/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVFocusListCell.h"
#import "CVFocusListItem.h"

@interface CVFocusListCell ()

@property(nonatomic, retain) CVFocusListItem* item;

@end

@implementation CVFocusListCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark -
#pragma mark TTTableViewCell

- (void)setObject:(id)object {
    
    if (object == nil)
        return;
    
    _item = object;
    
    self.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16];;
#ifdef CV_TARGET_IPHONE
    _timeLabelField = [[UILabel alloc] initWithFrame: CGRectMake(_titleLabelField.right, _titleLabelField.top, self.contentView.width - labelWidth - 60, LABELFIELD_HEIGHT)];
    _timeLabelField.textAlignment = NSTextAlignmentRight;
#else
    _timeLabelField = [[UILabel alloc] initWithFrame: CGRectMake(self.textLabel.right, self.textLabel.top-30, TEXTFIELD_WIDTH, LABELFIELD_HEIGHT)];
    
#endif
    _timeLabelField.textColor = [UIColor grayColor];
    _timeLabelField.font = [UIFont systemFontOfSize:12];
    _timeLabelField.textAlignment = NSTextAlignmentRight;
    _timeLabelField.text = _item.timeupdated? [CVAPIUtil formatDateTimeWithTimestamp:_item.timeupdated withIntervalStyle:CVDateTimeIntervalOneBlank]:[CVAPIUtil formatDateTimeWithTimestamp:_item.timecreated withIntervalStyle:CVDateTimeIntervalOneBlank];

    [self.contentView addSubview:_timeLabelField];

}

#pragma mark -
#pragma mark UIView

-(void) prepareForReuse {
    [super prepareForReuse];
    
    _timeLabelField.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(10, 10, 160, 30);
    _timeLabelField.frame = CGRectMake(175, 10, 130, 30);
}

- (void)didMoveToSuperview {
	[super didMoveToSuperview];
    
}


@end
