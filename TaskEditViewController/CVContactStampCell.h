//
//  CVContactStampCell.h
//  Vmoso
//
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVStampCell.h"

#define NAME_LABEL_HEIGHT   12
#define PADDING             5

@interface CVContactStampCell : CVStampCell

@property(nonatomic, retain) CVUserIconView* iconView;
@property(nonatomic, retain) UILabel* nameLabel;
@property(nonatomic, retain) UILabel* payloadCountLabel;
@property (nonatomic, retain) NSString* taskStatus;
@property (nonatomic, assign) BOOL isMyself;

@end