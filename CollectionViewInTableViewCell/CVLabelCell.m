//
//  CVLabelCell.m
//  CV
//
//  Created by Daniel Kong on 12/17/12.
//  Copyright (c) 2012 Broadvision. All rights reserved.
//

#import "CVLabelCell.h"

@interface CVLabelCell ()

@property(nonatomic, retain) UILabel* valueLable;

@end

@implementation CVLabelCell

- (id)init {
    self = [super init];
    if (self) {
        _valueLable = [[UILabel alloc] init];
        _valueLable.font = FIELD_FONT;
        _valueLable.textColor = FIELD_TEXT_COLOR;
        _valueLable.numberOfLines = 0;
        _valueLable.backgroundColor = FIELD_BG_COLOR;
        [self.contentView addSubview:_valueLable];
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return self;
}

-(void) setValue:(NSString*)text {
    _valueLable.text = text;
}

- (NSString*)getValue {
    return _valueLable.text;
}

- (void) layoutSubviews {

    [super layoutSubviews];
    
    if (_valueLable.text != nil) {
       
        // reserve FIELD_PADDING*2 for accessory indicator
        CGSize theSize = [_valueLable.text sizeWithFont:self.valueLable.font
                                      constrainedToSize:CGSizeMake(self.contentView.width - LR_PADDING*2, 9999)];
        CGFloat textHeight = theSize.height;

        // when empty, reserve the height for 1 blank line
        if (textHeight == 0)
            textHeight = _valueLable.font.pointSize;

        _valueLable.frame = CGRectMake(LR_PADDING, TB_PADDING, self.contentView.width - LR_PADDING*2, textHeight);
    
    } else {
        // size for empty area: 1 blank line + top/bottom paddings
        _valueLable.frame = CGRectMake(0, 0, self.contentView.width, _valueLable.font.pointSize + TB_PADDING*2);
    }
}

- (CGFloat)fieldHeightInTableView:(UITableView*)tableView {
    // to be overriden in subclasses
    
    CGFloat height = 0;
    
    if (!_isAssigneeOrCc){
        if (self.valueLable.text != nil) {
            CGSize theSize = [_valueLable.text sizeWithFont:self.valueLable.font
                                          constrainedToSize:CGSizeMake(tableView.width - GROUPED_CELL_PADDING*2 - LR_PADDING*2 - TABLE_ACCESSORY_WIDTH, 9999)];
            CGFloat textHeight = theSize.height;
            
            // when empty, reserve the height for 1 blank line
            if (textHeight == 0)
                textHeight = _valueLable.font.pointSize;
            
            height = textHeight + TB_PADDING*2;
        } else
            height = _valueLable.font.pointSize + TB_PADDING*2;
        
        return height;
    } else {
        return 100;
    }

    
}


@end
