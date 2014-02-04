#import <Foundation/Foundation.h>

@interface CVContactPickerItem : NSObject

@property (nonatomic, retain) NSString* key;
@property (nonatomic, retain) NSString* icon;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, assign) BOOL checked;
@property (nonatomic, assign) BOOL forbiddenSelecting;
@property (nonatomic, retain) id contact;

#ifdef CV_TARGET_IPAD

@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* company;
@property (nonatomic, retain) NSString* timestamp;
@property (nonatomic, retain) NSNumber* sharedTasks;
@property (nonatomic, retain) NSNumber* mutualContacts;

#endif

@end
