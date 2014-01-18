//
//  IPhoneTaskDetailPageInfoCell.m
//  Vmoso
//
//  Created by Daniel Kong on 11/22/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "IPhoneTaskDetailPageInfoCell.h"
#import "CVSparcCountItem.h"

#define ICON_WIDTH          30
#define ICON_HEIGHT         30
#define FONT_SIZE           12
#define TITLE_TEXTCOLOR [UIColor colorWithRed:41/255.0f green:111/255.0f blue:187/255.0f alpha:1]
#define DEFAULT_insets UIEdgeInsetsMake(5, 10, 5, 10)
#define TITLE_VIEW_HEIGHT   40

@interface IPhoneTaskDetailPageInfoCell ()

@property(nonatomic, assign) BOOL priority;
@property(nonatomic, assign) BOOL isRestrictedTask;
@property (nonatomic, retain) UIImageView* restrictedView;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, retain) UILabel* typeTitle;
@property (nonatomic, retain) UILabel* statusTitle;
@property (nonatomic, retain) UILabel* myStatusTitle;
@property (nonatomic, retain) UILabel* statusLabel;
@property (nonatomic, retain) UILabel* myStatusLabel;
@property (nonatomic, retain) UILabel* typeLabel;
@property (nonatomic, retain) UILabel* userDisplayNameLabel;
@property (nonatomic, retain) UILabel* updatedDisplayNameLabel;
@property (nonatomic, retain) UILabel* timeStampLabel;
@property (nonatomic, retain) UILabel* updatedTimeStampLabel;
@property (nonatomic, retain) UILabel* acceptLabel;
@property (nonatomic, retain) UILabel* addPeopleLabel;
@property (nonatomic, retain) UILabel* allowResueLabel;
@property (nonatomic, retain) UILabel* allowEditCommentLabel;
@property (nonatomic, retain) CVUserIconView* userIconView;
@property (nonatomic, retain) CVUserIconView* updaterIconView;

@end

@implementation IPhoneTaskDetailPageInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _expanded = NO;
        _insets = DEFAULT_insets;
        
        _restrictedView = [[UIImageView alloc] init];
        [self.contentView addSubview:_restrictedView];

        _titleView = [[CVTileTitleView alloc] initWithFrame:CGRectMake(_insets.left, _insets.top, self.contentView.width - _insets.left - _insets.right, TITLE_VIEW_HEIGHT)];
        _titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_titleView];
        
        _typeTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, TITLE_VIEW_HEIGHT + 5, 60, 30)];
        _typeTitle.font = [UIFont systemFontOfSize:FONT_SIZE];
        _typeTitle.textColor = [UIColor grayColor];
        _typeTitle.textAlignment = NSTextAlignmentRight;
        _typeTitle.text = LS(@"Type", @"");
        [self.contentView addSubview:_typeTitle];
        
        _statusTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, TITLE_VIEW_HEIGHT + 5 + 20, 60, 30)];
        _statusTitle.font = [UIFont systemFontOfSize:FONT_SIZE];
        _statusTitle.textColor = [UIColor grayColor];
        _statusTitle.textAlignment = NSTextAlignmentRight;
        _statusTitle.text = LS(@"Status", @"");
        [self.contentView addSubview:_statusTitle];
        
        _myStatusTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, TITLE_VIEW_HEIGHT + 45, 60, 30)];
        _myStatusTitle.font = [UIFont systemFontOfSize:FONT_SIZE];
        _myStatusTitle.textColor = [UIColor grayColor];
        _myStatusTitle.textAlignment = NSTextAlignmentRight;
        _myStatusTitle.text = LS(@"My Status", @"");
        [self.contentView addSubview:_myStatusTitle];
        
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, TITLE_VIEW_HEIGHT+5, 180, 30)];
        _typeLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        _typeLabel.textColor = [UIColor grayColor];
        _typeLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_typeLabel];
        
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, TITLE_VIEW_HEIGHT+ 5 + 20, 180, 30)];
        _statusLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        _statusLabel.textColor = [UIColor grayColor];
        _statusLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_statusLabel];
        
        _myStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, TITLE_VIEW_HEIGHT + 45, 130, 30)];
        _myStatusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _myStatusLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        _myStatusLabel.textColor = [UIColor grayColor];
        _myStatusLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_myStatusLabel];
        
        _userDisplayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, TITLE_VIEW_HEIGHT+ (TITLE_VIEW_HEIGHT)*2 -10, 220, 30)];
//        _userDisplayNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _userDisplayNameLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        _userDisplayNameLabel.textColor = TITLE_TEXTCOLOR;
        _userDisplayNameLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_userDisplayNameLabel];
        
        _updatedDisplayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, TITLE_VIEW_HEIGHT+TITLE_VIEW_HEIGHT*3 - 10, 220, 30)];
//        _updatedDisplayNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _updatedDisplayNameLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        _updatedDisplayNameLabel.textColor = TITLE_TEXTCOLOR;
        _updatedDisplayNameLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_updatedDisplayNameLabel];
        
        _timeStampLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, TITLE_VIEW_HEIGHT+5 + (TITLE_VIEW_HEIGHT)*2, 160, 30)];
        _timeStampLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _timeStampLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        _timeStampLabel.textColor = [UIColor grayColor];
        _timeStampLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_timeStampLabel];
        
        _updatedTimeStampLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, TITLE_VIEW_HEIGHT+5 + (TITLE_VIEW_HEIGHT)*3, 160, 30)];
        _updatedTimeStampLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _updatedTimeStampLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        _updatedTimeStampLabel.textColor = [UIColor grayColor];
        _updatedTimeStampLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_updatedTimeStampLabel];

        
        _userIconView = [[CVUserIconView alloc] initWithFrame:CGRectMake(45, (TITLE_VIEW_HEIGHT)*3, ICON_WIDTH, ICON_HEIGHT)];
        [self.contentView addSubview:_userIconView];
        
        _updaterIconView = [[CVUserIconView alloc] initWithFrame:CGRectMake(45  , (TITLE_VIEW_HEIGHT)*4, ICON_WIDTH, ICON_HEIGHT)];
        [self.contentView addSubview:_updaterIconView];
        
        _tabControl = [[CVTabControl alloc] initWithItems:[NSArray arrayWithObjects:LS(@"Summary", @""), LS(@"Participants", @""), LS(@"Associations", @""), LS(@"References", @""), LS(@"Content", @""), nil]];
        [_tabControl addTarget:self action:@selector(tabControlSelected:) forControlEvents:UIControlEventValueChanged];
        _tabControl.selectedTabIndex = 0;
        _tabControl.height = TOOLBAR_HEIGHT - 10;
        _tabControl.textColor = [UIColor darkGrayColor];
        _tabControl.fontSize = 10;
        _tabControl.bottomLineColor = [[CVStyleController sharedInstance] colorForTheme:THEME_FOR_TASK];
        
//        [self.contentView addSubview:_tabControl];
        _moreButton= [UIButton buttonWithType:UIButtonTypeCustom];
        _moreButton.frame = CGRectMake(self.width - 65 , _updaterIconView.bottom, 50, 40);
        [_moreButton setTitle:LS(@"More", @"") forState:UIControlStateNormal];
        _moreButton.titleLabel.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
        [_moreButton setTitleColor:TITLE_TEXTCOLOR forState:UIControlStateNormal];
        [self.contentView addSubview:_moreButton];
        
        _acceptLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, _moreButton.bottom, 300, 30)];
        _acceptLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _acceptLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        _acceptLabel.textColor = [UIColor grayColor];
        _acceptLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_acceptLabel];
        
        _addPeopleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, _acceptLabel.bottom, 300, 30)];
        _addPeopleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _addPeopleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        _addPeopleLabel.textColor = [UIColor grayColor];
        _addPeopleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_addPeopleLabel];
        
        _allowResueLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, _addPeopleLabel.bottom, 300, 30)];
        _allowResueLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _allowResueLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        _allowResueLabel.textColor = [UIColor grayColor];
        _allowResueLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_allowResueLabel];
        
        _allowEditCommentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, _allowResueLabel.bottom, 300, 30)];
        _allowEditCommentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _allowEditCommentLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        _allowEditCommentLabel.textColor = [UIColor grayColor];
        _allowEditCommentLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_allowEditCommentLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_updaterIconView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    _userIconView.frame = CGRectMake(45 , TITLE_VIEW_HEIGHT*3, ICON_WIDTH, ICON_HEIGHT);
    _updaterIconView.frame = CGRectMake(45, TITLE_VIEW_HEIGHT*4, ICON_WIDTH, ICON_HEIGHT);
    
    if (_expanded)
        self.height = _allowEditCommentLabel.bottom + 10;
    else
        self.height = _moreButton.bottom;
}

- (void)setTask:(CVTaskSvcItem *)task {
    _task = task;
    _titleView.tileTitleInfo = (id<CVTileTitleInfo>)task;
    
    NSString* imageName;
    NSString* restrictString;
    if (task.restrictedFlag){
        restrictString = LS(@"Restricted",@"");
        imageName = @"group-red-s.png";
    } else {
        restrictString = LS(@"Unrestricted",@"");
        imageName = @"group-green-s.png";
    }

    _restrictedView.frame = CGRectMake(_typeLabel.right - 60, _titleView.bottom + 5, 20, 14);

    _restrictedView.image = [UIImage imageNamed:imageName];

    _typeLabel.text = [NSString stringWithFormat:@"%@ | %@", LS([task.taskType capitalizedString], @""), restrictString];
    
    _statusLabel.text = [NSString stringWithFormat:@"%@ | %@: %@", LS([task.status capitalizedString], @""), LS(@"Due", @""), (task.dueTime)?[NSDate ConvertToRelativeTimestamp: [[NSNumber numberWithDouble:task.dueTime] integerValue]]: LS(@"None", @"")];
    _myStatusLabel.text = [NSString stringWithFormat:@"%@ | %@", [task.actorStatus isEqualToString:@"cc-assigned"] ? @"None" : LS(task.actorStatus, @""), LS(@"On Time", @"")];
    _userDisplayNameLabel.text = [NSString stringWithFormat:@"%@ %@", LS(@"Created by", @""), task.creator.displayName];
    _updatedDisplayNameLabel.text = [NSString stringWithFormat:@"%@ %@", LS(@"Updated by", @""), task.updater.displayName];
    _timeStampLabel.text = [CVAPIUtil dateStr:[[NSNumber numberWithDouble:task.timeCreated] doubleValue]];
    _updatedTimeStampLabel.text = [NSString stringWithFormat:@"%@ %@", [NSDate ConvertToRelativeTimestamp: [[NSNumber numberWithDouble:task.timeUpdated] integerValue]], LS(@"ago", @"")];
    [_userIconView setIconWithUser:task.creator];
    [_updaterIconView setIconWithUser:task.updater];
    
    _acceptLabel.text = [NSString stringWithFormat:@"Accept Required: %@", (_task.acceptFlag ? @"yes":@"no")];
    _addPeopleLabel.text = [NSString stringWithFormat:@"Can Add Participants:  To: %@    CC: %@", (_task.canAddByTo ? @"yes":@"no"), (_task.canAddByCc ? @"yes":@"no")];
    _allowResueLabel.text = [NSString stringWithFormat:@"Allow Task Reuse: %@", (_task.reuseFlag ? @"yes":@"no")];
    _allowEditCommentLabel.text = [NSString stringWithFormat:@"Allow Editing of Comments: %@", (_task.editCommentFlag ? @"yes":@"no")];
    // Adjust cell frame size
    _tabControl.top = _updaterIconView.bottom;
    if (_expanded)
        self.height = _allowEditCommentLabel.bottom + 10;
    else
        self.height = _moreButton.bottom;
    
    [_tabControl setBadgeCounts:@[[NSNumber numberWithInt:task.sparcCountItem.summary], [NSNumber numberWithInt:task.sparcCountItem.participants], [NSNumber numberWithInt:task.sparcCountItem.associations], [NSNumber numberWithInt:task.sparcCountItem.references], [NSNumber numberWithInt:task.sparcCountItem.content]]];
}

#pragma mark -
#pragma mark CVTaskDetailPageTabControlDelegate

- (void)tabControlSelected:(CVTabControl*)control {
    if (_tabControldelegate)
        [_tabControldelegate didSelectTabControlAtIndex:control.selectedTabIndex];
}

@end
