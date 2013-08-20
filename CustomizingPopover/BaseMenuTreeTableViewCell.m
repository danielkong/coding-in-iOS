//
//  BaseMenuTreeTableViewCell.m
//  
//
//  Created by daniel kong on 8/13/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "BaseMenuTreeTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

#define KOCOLOR_FILES_TITLE [UIColor colorWithRed:0.4 green:0.357 blue:0.325 alpha:1] /*#665b53*/
#define KOCOLOR_FILES_TITLE_SHADOW [UIColor colorWithRed:1 green:1 blue:1 alpha:1] /*#ffffff*/
#define KOCOLOR_FILES_COUNTER [UIColor colorWithRed:0.608 green:0.376 blue:0.251 alpha:1] /*#9b6040*/
#define KOCOLOR_FILES_COUNTER_SHADOW [UIColor colorWithRed:1 green:1 blue:1 alpha:0.35] /*#ffffff*/
#define KOFONT_FILES_TITLE [UIFont fontWithName:@"HelveticaNeue" size:20.0f]
#define KOFONT_FILES_COUNTER [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f]

@implementation BaseMenuTreeTableViewCell

@synthesize backgroundImageView;
@synthesize iconButton;
@synthesize titleTextField;
@synthesize delegate;
@synthesize treeItem;
@synthesize downArrowImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		
		backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"copymove-cell-bg"]];
		[backgroundImageView setContentMode:UIViewContentModeTopRight];
		
		[self setBackgroundView:backgroundImageView];
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];

		iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[iconButton setFrame:CGRectMake(0, 20, 100, 180)];
		[iconButton setAdjustsImageWhenHighlighted:NO];
		[iconButton addTarget:self action:@selector(iconButtonAction:) forControlEvents:UIControlEventTouchUpInside];

		
		[self.contentView addSubview:iconButton];

		titleTextField = [[UITextField alloc] init];
		[titleTextField setFont:KOFONT_FILES_TITLE];
		[titleTextField setTextColor:KOCOLOR_FILES_TITLE];
		[titleTextField.layer setShadowColor:KOCOLOR_FILES_TITLE_SHADOW.CGColor];
		[titleTextField.layer setShadowOffset:CGSizeMake(0, 1)];
		[titleTextField.layer setShadowOpacity:1.0f];
		[titleTextField.layer setShadowRadius:0.0f];
		
		[titleTextField setUserInteractionEnabled:NO];
		[titleTextField setBackgroundColor:[UIColor clearColor]];
		[titleTextField sizeToFit];
		[titleTextField setFrame:CGRectMake(108, 10, titleTextField.frame.size.width, titleTextField.frame.size.height)];
        [titleTextField addTarget:self action:@selector(titleTextFieldfilterAction:) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:titleTextField];
		
		[self.layer setMasksToBounds:YES];
		
        downArrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(686, 38, 25, 20)];
		
		[self setAccessoryView:downArrowImage];
		[self.accessoryView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin];
        //[self.contentView addSubview:downArrowImage];

    }
    return self;
}
- (void) layoutSubviews {
    [super subviews];
    [iconButton setFrame:CGRectMake(170, 10, 24, 24)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

- (void)setLevel:(NSInteger)level {
	CGRect rect;
	
	rect = iconButton.frame;
	rect.origin.x = 25 * level+1;
	iconButton.frame = rect;
	
	rect = titleTextField.frame;
	rect.origin.x = 20 + 25 * level;
	titleTextField.frame = rect;
    
    titleTextField.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0-level*3 ];
}

- (void)iconButtonAction:(id)sender {
	NSLog(@"iconButtonAction:");
	
	if (delegate && [delegate respondsToSelector:@selector(treeTableViewCell:didTapIconWithTreeItem:)]) {
		[delegate treeTableViewCell:(CVBaseMenuTreeTableViewCell *)self didTapIconWithTreeItem:(CVBaseMenuTreeItem *)treeItem];
	}
}

- (void)titleTextFieldFilterAction:(id)sender {
	NSLog(@"titleTextFieldFilterAction:");
	
	if (delegate && [delegate respondsToSelector:@selector(treeTableViewCell:didTapIconWithTreeItem:)]) {
		[delegate treeTableViewCell:(CVBaseMenuTreeTableViewCell *)self didTapIconWithTreeItem:(CVBaseMenuTreeItem *)treeItem];
	}
}
@end
