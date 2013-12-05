//
//  CVTileSummaryViewForContact.m
//  Vmoso
//
//  Created by Daniel Kong on 11/19/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVTileSummaryViewForContact.h"

#define TITLE_TEXTCOLOR [UIColor colorWithRed:41/255.0f green:111/255.0f blue:187/255.0f alpha:1]
#define ICON_WIDTH          40
#define ICON_HEIGHT         40

@interface CVTileSummaryViewForContact()

@property (nonatomic, retain) UILabel* titleLabel;
@property (nonatomic, retain) UILabel* companyLabel;
@property (nonatomic, retain) UILabel* emailLabel;
@property (nonatomic, retain) UILabel* sharedTaskAndMutualContactLabel;
@property (nonatomic, retain) CVUserIconView* userIconView;

@end

@implementation CVTileSummaryViewForContact

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _userIconView = [[CVUserIconView alloc] initWithFrame:CGRectMake(self.left, 10, ICON_WIDTH, ICON_HEIGHT)];
        [self.contentView addSubview:_userIconView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.left + ICON_WIDTH + 10, 5, 70, 30)];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = [UIColor grayColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_titleLabel];
        
        _companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.left + ICON_WIDTH + 10, 25, 100, 30)];
        _companyLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        _companyLabel.font = [UIFont systemFontOfSize:12];
        _companyLabel.textColor = [UIColor grayColor];
        _companyLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_companyLabel];
        
        _emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.left + ICON_WIDTH + 150, 5, 180, 30)];
        _emailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _emailLabel.font = [UIFont systemFontOfSize:12];
        _emailLabel.textColor = [UIColor grayColor];
        _emailLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_emailLabel];
        
        _sharedTaskAndMutualContactLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.left + ICON_WIDTH + 150, 25, 220, 30)];
        _sharedTaskAndMutualContactLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _sharedTaskAndMutualContactLabel.font = [UIFont systemFontOfSize:12];
        _sharedTaskAndMutualContactLabel.textColor = [UIColor grayColor];
        _sharedTaskAndMutualContactLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_sharedTaskAndMutualContactLabel];

    }
    return self;
}

- (void)setContactSummaryInfo:(id<CVContactTileSummaryInfo>)contactSummaryInfo
{
    [_userIconView setIconWithUser:[contactSummaryInfo ownerIconInfo]];
    _titleLabel.text = [contactSummaryInfo title];
    _companyLabel.text = [contactSummaryInfo company];
    _emailLabel.text = [contactSummaryInfo email];
    _sharedTaskAndMutualContactLabel.text = [NSString stringWithFormat:@"%@ | %@", [contactSummaryInfo sharedTasks], [contactSummaryInfo mutualContacts]];
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
