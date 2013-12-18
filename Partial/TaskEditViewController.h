//
//  TaskEditViewController.h
//
//  Created by Daniel Kong on 12/18/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "TaskFormDatePickerViewController.h"
#import "CVTaskSvcItem.h"

#define NOTIF_TASK_UPDATE   @"taskUpdate"

#define TYPE_OPTION_MESSAGE     @"Message"
#define TYPE_OPTION_MAIL        @"Mail"
#define TYPE_OPTION_DISCUSSION  @"Discussion"
#define TYPE_OPTION_FYI         @"FYI"
#define TYPE_OPTION_TODO        @"TODO"
#define TYPE_OPTION_ACTION      @"Action"
#define TYPE_OPTION_APPROVAL    @"Approval"
#define TYPE_OPTION_CHAT        @"Chat"

#define RELATED_TYPE_REFERENCE  @"reference"
#define RELATED_TYPE_TEMPLATE   @"template"
#define RELATED_TYPE_SNAPSHOT   @"snapshot"

@interface CVTaskEditViewController : UITableViewController

@property(nonatomic, retain) CVTaskSvcItem* oldTaskItem;

- (id) initWithData:(NSDictionary*)data forAddPeople:(BOOL)addPeople;
+ (void) presentTaskFormInPopoverFromBarButtonItem:(UIBarButtonItem *)item withData:(NSDictionary*) data forAddPeople:(BOOL)addPeople;
+ (void) presentTaskFromViewController:(UIViewController*)viewController taskKey:(NSString*) key  taskType:(NSString*)type;
+ (void) presentDraftFormInPopoverFromRect:(CGRect)rect inView:(UIView*)view withData:(NSDictionary*) data;
+ (void) presentTaskForRelatedTaskFromViewController:(UIViewController*)viewController taskKey:(NSString*) key type:(NSString*)relatedType;
+ (void) presentTaskForRelatedTaskWithTaskItemFromViewController:(UIViewController*)viewController taskKey:(NSString*)key taskItem:(CVTaskSvcItem*)taskItem type:(NSString*)relatedType;
+ (UIPopoverController*) getPopover;

@end
