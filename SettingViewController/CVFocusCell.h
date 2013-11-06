//
//  CVFocusCell.h
//  Vmoso
//
//  Created by Daniel Kong on 10/17/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CVTableViewCell.h"

@class CVRoundCornersImageView;

#define LABELFIELD_WIDTH 140
#define LABELFIELD_HEIGHT  20
#define TEXTFIELD_WIDTH  220
#define TEXTVIEW_HEIGHT  50
#define ROW_HEIGHT  40
#define SPACER 10
#define PADDING 10

@interface CVFocusCell : CVTableViewCell <UITextFieldDelegate>

@property(nonatomic, retain) UILabel* labelField;
@property(nonatomic, retain) UILabel* textField;
@property(nonatomic, retain) NSString* labelFieldKey;

- (id) initWithTitle:(NSString*)title andTextField:(BOOL)isTextField;

@end

