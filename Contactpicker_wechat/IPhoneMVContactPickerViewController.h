
#import <UIKit/UIKit.h>
#import "CVContactPickerCell.h"
#import "CVContactPickerItem.h"
#import "CVContactItem+Bizlogic.h"
#import "CVNamedIcon.h"
#import "CVContactGroupItem.h"

#define ICON_WIDTH          40
#define ICON_HEIGHT         40
#define NAME_HEIGHT         15
#define TITLE_HEIGHT        15
#define MESSAGE_HEIGHT      15
#define TS_WIDTH            60
#define TS_HEIGHT           10
#define TS_PADDING          3
#define LR_PADDING          20
#define TB_PADDING          10

#define CHECKMARK_WIDTH     22
#define CHECKMARK_HEIGHT    22

#define MSG_ICON_WIDTH      12
#define MSG_ICON_HEIGHT     10
#define COUNT_LABEL_WIDTH   20
#define ICON_LABEL_SPACE    5


@interface CVContactPickerCell()

@property(nonatomic, retain) CVUserIconView* iconView;
@property(nonatomic, retain) UILabel* nameLabel;
@property(nonatomic, retain) UIImageView* checkmarkImgView;

#ifdef CV_TARGET_IPAD

@property(nonatomic, retain) UILabel* titleLabel;
@property(nonatomic, retain) UILabel* companyLabel;
@property(nonatomic, retain) UILabel* messageLabel;
@property(nonatomic, retain) UILabel* tsLabel;
@property(nonatomic, retain) UIImageView* peopleImgView;
@property(nonatomic, retain) UIImageView* payloadImgView;
@property(nonatomic, retain) UILabel* peopleCountLabel;
@property(nonatomic, retain) UILabel* payloadCountLabel;

#endif

@end

@implementation CVContactPickerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]) {
        
        _iconView = [[CVUserIconView alloc] init];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.numberOfLines = 2;
        _nameLabel.font = [UIFont boldSystemFontOfSize:14];
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.highlightedTextColor = [UIColor whiteColor];
       
        _checkmarkImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15.f, ICON_HEIGHT/2, CHECKMARK_WIDTH, CHECKMARK_HEIGHT)];
        
#ifdef CV_TARGET_IPAD
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont italicSystemFontOfSize:11];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor darkGrayColor];
        _titleLabel.highlightedTextColor = [UIColor whiteColor];
        
        
        _companyLabel = [[UILabel alloc] init];
        _companyLabel.font = [UIFont italicSystemFontOfSize:11];
        _companyLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _companyLabel.textAlignment = NSTextAlignmentLeft;
        _companyLabel.backgroundColor = [UIColor clearColor];
        _companyLabel.textColor = [UIColor darkGrayColor];
        _companyLabel.highlightedTextColor = [UIColor whiteColor];
        
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:12];
        _messageLabel.textColor = [UIColor darkGrayColor];
        _messageLabel.textAlignment = NSTextAlignmentRight;
        _messageLabel.backgroundColor = [UIColor clearColor];
        
        _tsLabel = [[UILabel alloc] init];
        _tsLabel.font = [UIFont systemFontOfSize:12];
        _tsLabel.textAlignment = NSTextAlignmentRight;
        _tsLabel.backgroundColor = [UIColor clearColor];
        
        _peopleImgView = [[UIImageView alloc] initWithImage:[CVNamedIcon iconNamed:@"People" inSprite:@"24x24_Sprite_Black100.png"]];
        _peopleImgView.tag = 1;

        _payloadImgView = [[UIImageView alloc] initWithImage:[CVNamedIcon iconNamed:@"Share" inSprite:@"24x24_Sprite_Black100.png"]];
        _payloadImgView.tag = 2;
        
        _peopleCountLabel = [[UILabel alloc] init];
        _peopleCountLabel.font = [UIFont systemFontOfSize:10];
        _peopleCountLabel.textAlignment = NSTextAlignmentLeft;
        _peopleCountLabel.backgroundColor = [UIColor clearColor];
        _peopleCountLabel.textColor = [UIColor blackColor];
        _peopleCountLabel.tag = 3;
        
        _payloadCountLabel = [[UILabel alloc] init];
        _payloadCountLabel.font = [UIFont systemFontOfSize:10];
        _payloadCountLabel.textAlignment = NSTextAlignmentLeft;
        _payloadCountLabel.backgroundColor = [UIColor clearColor];
        _payloadCountLabel.textColor = [UIColor blackColor];
        _payloadCountLabel.tag = 4;
#endif
        
        [self.contentView addSubview:_iconView];
        [self.contentView addSubview:_nameLabel];
        [self.contentView addSubview:_checkmarkImgView];
        
#ifdef CV_TARGET_IPAD
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_companyLabel];
        [self.contentView addSubview:_messageLabel];
        [self.contentView addSubview:_tsLabel];
        [self.contentView addSubview:_peopleImgView];
        [self.contentView addSubview:_payloadImgView];
        [self.contentView addSubview:_peopleCountLabel];
        [self.contentView addSubview:_payloadCountLabel];
#endif
	}
	return self;
}

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
    return TB_PADDING*2 + ICON_HEIGHT;
}

- (void)prepareForReuse {
    [_iconView unsetImage];
}

-(void)setObject:(id)object {
    
    [super setObject:object];
    
    CVContactPickerItem* item = (CVContactPickerItem*)object;
    if ([item.contact isKindOfClass:[CVContactGroupItem class]]) {
        _iconView.letterView.hidden = YES;
        _iconView.imageView.image = [UIImage imageNamed:item.icon];
    } else {
        [_iconView setIconWithUser:item.contact];
    }
    _nameLabel.text = item.name;
    
//    self.accessoryType = item.checked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    if (item.checked) {
        [_checkmarkImgView setImage:[UIImage imageNamed:@"checkbox_checked1.png"]];
    } else {
        [_checkmarkImgView setImage:[UIImage imageNamed:@"checkbox_unchecked1.png"]];
    };
    
    if (item.forbiddenSelecting) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView* defaultSelectionBackGround = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height+15)];
        [defaultSelectionBackGround setBackgroundColor:[UIColor whiteColor]];
        [defaultSelectionBackGround setAlpha:0.5];
        [self.contentView addSubview:defaultSelectionBackGround];
    }

#ifdef CV_TARGET_IPAD
    _titleLabel.text = LS(item.title, @"");
    _companyLabel.text = LS(item.company, @"");
    _messageLabel.text = @"";
    _tsLabel.text = @"";
    _payloadCountLabel.text = [item.sharedTasks stringValue];
    _peopleCountLabel.text = [item.mutualContacts stringValue];
#endif
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    _iconView.frame = CGRectMake(LR_PADDING + CHECKMARK_HEIGHT, TB_PADDING, ICON_WIDTH, ICON_HEIGHT);
    CGFloat left = LR_PADDING + ICON_WIDTH + 10 + CHECKMARK_HEIGHT;
    CGFloat width = self.frame.size.width - left - LR_PADDING;
    _nameLabel.frame = CGRectMake(left, _iconView.frame.origin.y, width, NAME_HEIGHT);
  
#ifdef CV_TARGET_IPAD
    
    _tsLabel.frame = CGRectMake(self.frame.size.width - LR_PADDING*3 - 100, _iconView.top, 100, TITLE_HEIGHT);
    
    CGFloat nameLabelBottom = _nameLabel.frame.origin.y + _nameLabel.frame.size.height;
    _titleLabel.frame = CGRectMake(left, nameLabelBottom, width, TITLE_HEIGHT);
    _companyLabel.frame = CGRectMake(left, _titleLabel.bottom, width, TITLE_HEIGHT);
    _messageLabel.frame = CGRectMake(self.frame.size.width - LR_PADDING*3 - 100, nameLabelBottom, 100, TITLE_HEIGHT);
    
    CGFloat top = _messageLabel.bottom;
    left = _messageLabel.right - MSG_ICON_WIDTH * 2 - ICON_LABEL_SPACE * 2 - COUNT_LABEL_WIDTH * 2;
    
    _peopleImgView.frame = CGRectMake(left, top, MSG_ICON_WIDTH, MSG_ICON_HEIGHT);
    left += MSG_ICON_WIDTH + ICON_LABEL_SPACE;
    
    _peopleCountLabel.frame = CGRectMake(left, top, COUNT_LABEL_WIDTH, MSG_ICON_HEIGHT);
    left += COUNT_LABEL_WIDTH;
    
    _payloadImgView.frame = CGRectMake(left, top, MSG_ICON_WIDTH, MSG_ICON_HEIGHT);
    left += MSG_ICON_WIDTH + ICON_LABEL_SPACE;
    
    _payloadCountLabel.frame = CGRectMake(left, top, COUNT_LABEL_WIDTH, MSG_ICON_HEIGHT);

#endif
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
#ifdef CV_TARGET_IPAD
    _tsLabel.textColor = selected ? [UIColor whiteColor] : [UIColor blackColor];
    _messageLabel.textColor = selected ? [UIColor whiteColor] : [UIColor blackColor];
#endif
    return;
}

@end
