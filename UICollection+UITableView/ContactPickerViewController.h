#import "CVBaseListViewController.h"
#import "IPadPickerTextField.h"

@protocol ContactPickerDelegate <NSObject>

-(void) recipientsChanged:(NSArray*)recipients;

@end

@interface CVContactPickerViewController : CVBaseListViewController<UITableViewDataSource,UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic, unsafe_unretained) id<ContactPickerDelegate> delegate;
@property(nonatomic, retain) NSString* placeHolder;
@property(nonatomic, retain) NSMutableArray* selectedResults;
@property(nonatomic, retain) NSString* taskKeyForPingPicker;
@property(nonatomic, retain) NSString* listType;

@property(nonatomic, assign) BOOL isRestrictedTask;
@property(nonatomic, assign) BOOL isFiltered;
@property(nonatomic, assign) BOOL allowNoSelectedContact;

- (id)initPingPickerWithTaskKey:(NSString*)taskKey;
- (id)initWithRecipients:(NSArray*)initialRecipients forAddPeople:(BOOL)addPeople withOptions:(NSArray*)options;
- (void) doneWithPicker;
- (void) handleResults;
- (void)cancel:(BOOL)confirmIfNecessary;
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
+ (void)presentPickerInPopoverFromBarButtonItem:(UIBarButtonItem *)item withTaskKey:(NSString*)key;
+ (void)presentPickerInPopoverFromRect:(CGRect)rect inView:(UIView*)view withTaskKey:(NSString*)key;

@end
