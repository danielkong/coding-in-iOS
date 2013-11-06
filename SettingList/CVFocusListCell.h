//
//  CVFocusListCell.h
//  Vmoso
//
//  Created by Daniel Kong on 10/23/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVTableViewCell.h"

#define LABELFIELD_WIDTH 140
#define LABELFIELD_HEIGHT  20
#define TEXTFIELD_WIDTH  220
#define TEXTVIEW_HEIGHT  50

@interface CVFocusListCell : CVTableViewCell

@property(nonatomic, retain) UILabel* timeLabelField;

@end
