#import "CVBaseViewController.h"
#import "CVTopBar.h"
#import "SVPullToRefresh.h"


#define PAGESIZE_FULL   @"fullsize"
#define PAGESIZE_HALF   @"halfsize"

typedef enum {
    CVListDisplayModeTabular = 0,
    CVListDisplayModeTile,
} CVListDisplayMode;

/*
 *  This class manages the followings:
 *      - tableView,
 *      - sections,
 *      - rows,
 *      - selectedKey
 *      - indexOfSelected
 *      - loadMore button
 */

@interface CVBaseListViewController : CVBaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UITableView* tableView;
@property (nonatomic, retain) NSArray* sections;
@property (nonatomic, retain) NSArray* rows;
@property (nonatomic, retain) NSString* selectedKey;
@property (nonatomic, retain) NSIndexPath* indexPathOfSelected;
@property (nonatomic, assign) BOOL isTaskPageDisplayed;
@property (nonatomic, assign) CVListDisplayMode displayMode;

@property (nonatomic, retain) UIButton* loadMoreButton;
@property (nonatomic, retain) UIView* loadMoreBoxView;
@property (nonatomic, retain) UIActivityIndicatorView* activityView;
@property (nonatomic, readonly) SVPullToRefreshView* pullToRefreshView;

- (void)handlePullToRefresh:(SVPullToRefreshView*)refreshView;
- (Class)cellClassForObject:(id)object;
- (void)showDetailPageOfSelectedItem;

- (void)displayModeWillChange:(CVListDisplayMode)displayMode;
- (void)displayModeDidChange:(CVListDisplayMode)displayMode;

- (void)resize;

- (void)showLoadMoreButtonLoading:(BOOL)show;

@end
