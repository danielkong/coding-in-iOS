#import <UIKit/UIKit.h>
#import "MenuItemCell.h"

@protocol PulldownMenuDelegate <NSObject>

- (void)pulldownMenu:self didSelectMenuItem:(NSString*) menuItem didSelectMenuIndex:(NSInteger) selectedIndex;

@end

@interface PulldownMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MenuItemSelectionDelegate>
  
@property (nonatomic, unsafe_unretained) id<PulldownMenuDelegate> delegate;
@property (nonatomic, assign) BOOL *showExtensionButton;
@property (nonatomic, retain) UIFont *titleFont;

- (id)initWithMenuItems:(NSArray*)menuArray selectedIndex:(NSInteger)selectedIndex;
- (NSArray*)currentMenuItems;

@end
