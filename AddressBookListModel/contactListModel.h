//
//  CVContactListSvcModel.h
//  Vmoso
//
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVAPIListModel.h"

#define CONTACT_LIST_MODEL_ID               @"CVContactListSvcModel"

#define CONTACT_LIST_TYPE_CONTACT           @"contact"
#define CONTACT_LIST_TYPE_TASK              @"task"
#define CONTACT_LIST_TYPE_RESTRICTED_TASK   @"restricted_task"

#define CONTACT_LIST_SORT_NAME              @"name"

#define CONTACT_LIST_ORDER_ASC              @"asc"
#define CONTACT_LIST_ORDER_DESC             @"desc"

@interface CVContactListSvcModel : CVAPIListModel

@property (nonatomic, retain) NSString* contactKey;

+ (NSString*)getCachedModelIdWithFilter:(NSString*)filter withType:(NSString*)type withSort: (NSString*)sortBy withContactKey: (NSString*)contactKey;

- (void)deleteContact:(BOOL)isGroup;

@end
