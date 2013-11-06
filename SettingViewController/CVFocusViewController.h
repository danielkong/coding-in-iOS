//
//  CVFocusViewController.h
//  Vmoso
//
//  Created by Daniel Kong on 10/16/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVBaseListViewController.h"
#import "IPadTextPickerViewController.h"

#define SETTING_FOCUS_TASK          @"Task"
#define SETTING_FOCUS_FILE          @"File"

@interface CVFocusViewController : CVBaseListViewController

@property(nonatomic, retain) UIBarButtonItem *cancelItem;
@property(nonatomic, retain) UIBarButtonItem *updateItem;

- (id)initWithType:(NSString *)type;
- (void)updateMultipleSelection:(id)sender;

@end
