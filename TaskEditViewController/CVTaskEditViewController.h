//
//  CVTaskEditViewController.h
//  Vmoso
//
//  Created by Daniel Kong on 11/07/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "TaskFormDatePickerViewController.h"

#define NOTIF_TASK_UPDATE   @"taskUpdate"

#define TYPE_OPTION_MESSAGE     @"Message"
#define TYPE_OPTION_MAIL        @"Mail"
#define TYPE_OPTION_DISCUSSION  @"Discussion"
#define TYPE_OPTION_FYI         @"FYI"
#define TYPE_OPTION_TODO        @"TODO"
#define TYPE_OPTION_ACTION      @"Action"
#define TYPE_OPTION_APPROVAL    @"Approval"
#define TYPE_OPTION_CHAT        @"Chat"

@interface CVTaskEditViewController : UITableViewController

@property(nonatomic, assign) BOOL changeToNewTask;

- (id) initWithData:(NSDictionary*)data forAddPeople:(BOOL)addPeople;
+ (void) presentTaskFormInPopoverFromBarButtonItem:(UIBarButtonItem *)item withData:(NSDictionary*) data forAddPeople:(BOOL)addPeople;
+ (void) presentDraftFormInPopoverFromRect:(CGRect)rect inView:(UIView*)view withData:(NSDictionary*) data;
+ (void) presentTaskForSaveAsNewTaskFromViewController:(UIViewController*)viewController taskKey:(NSString*) key;
+ (UIPopoverController*) getPopover;

@end
