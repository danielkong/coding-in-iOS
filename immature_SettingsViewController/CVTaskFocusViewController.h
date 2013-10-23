//
//  CVTaskFocusViewController.h
//  Vmoso
//
//  Created by Daniel Kong on 10/16/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVBaseListViewController.h"
#import "IPadTextPickerViewController.h"

#define SETTING_ITEM_PROFILE           @"profile"
#define SETTING_ITEM_ACCOUNT           @"account"
#define SETTING_ITEM_LANGUAGE          @"language"
#define SETTING_ITEM_DATETIME          @"datetime"
#define SETTING_ITEM_NOTIFICATION      @"notification"

@interface CVTaskFocusViewController : CVBaseListViewController {
    NSMutableArray* switchStatus;
}
@property(nonatomic, retain) UIBarButtonItem *cancelItem;
@property(nonatomic, retain) UIBarButtonItem *updateItem;

- (void)updateMultipleSelection:(id)sender;

@end
