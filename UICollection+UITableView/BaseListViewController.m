#import "CVBaseListViewController.h"

#import <objc/runtime.h>
#import "CVTableViewCell.h"
#import "CVTableViewSectionHeaderView.h"

#ifdef CV_TARGET_IPAD
#define LOAD_MORE_VIEW_HEIGHT   60
#define LOAD_MORE_BUTTON_HEIGHT 40
#define LOAD_MORE_BUTTON_WIDTH  600
#define LOAD_MORE_BUTTON_FONT [UIFont systemFontOfSize:20]
#define ACTIVITY_ICON_HEIGHT    30
#define ACTIVITY_ICON_WIDTH     30
#define ACTIVITY_ICON_START_X   150
#else
#define LOAD_MORE_VIEW_HEIGHT   42
#define LOAD_MORE_BUTTON_HEIGHT 32
#define LOAD_MORE_BUTTON_WIDTH  220
#define LOAD_MORE_BUTTON_FONT [UIFont systemFontOfSize:14]
#define ACTIVITY_ICON_HEIGHT    20
#define ACTIVITY_ICON_WIDTH     20
#define ACTIVITY_ICON_START_X   40
#endif

@interface CVBaseListViewController ()

@end

@implementation CVBaseListViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // create tableView
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    if (getOSf() >= 7.0)
        _tableView.separatorInset = UIEdgeInsetsZero;
    
    [self.view insertSubview:_tableView belowSubview:self.topBar];
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 10)];
    
    // setup pull-to-refresh
    
    __unsafe_unretained CVBaseListViewController* weakSelf = self;
    __unsafe_unretained UITableView* weakTableView = _tableView;
    [_tableView addPullToRefreshWithActionHandler:^{
        [weakSelf handlePullToRefresh:weakTableView.pullToRefreshView];
    }];
    [_tableView.pullToRefreshView setTitle:nil forState:SVPullToRefreshStateAll];
    
    _selectedKey = @"";
    _indexPathOfSelected = [NSIndexPath indexPathForRow:0 inSection:0];
    _isTaskPageDisplayed = NO;
    
#ifdef CV_TARGET_IPHONE
    // As requested by SuperPM, for iPhone, default to tile mode
    // Reason: Not much info can be shown in tabular mode 
    _displayMode = CVListDisplayModeTile;
#endif
    
    // create a footer view for drawing a loadmore box
    
    _loadMoreBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, LOAD_MORE_VIEW_HEIGHT)];
    _loadMoreBoxView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _loadMoreBoxView.autoresizesSubviews = YES;
    _loadMoreBoxView.backgroundColor = [UIColor clearColor];
    
    // Add loadMoreButton and place inside loadMoreBox
    _loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _loadMoreButton.backgroundColor = [UIColor clearColor];
    _loadMoreButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    CGFloat left = (self.view.width - LOAD_MORE_BUTTON_WIDTH)/2;
    _loadMoreButton.frame = CGRectMake(left, (LOAD_MORE_VIEW_HEIGHT - LOAD_MORE_BUTTON_HEIGHT)/2, LOAD_MORE_BUTTON_WIDTH, LOAD_MORE_BUTTON_HEIGHT);
    // button label
    [_loadMoreButton setTitle:LS(@"Load More", @"") forState:UIControlStateNormal];
    [_loadMoreButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    _loadMoreButton.titleLabel.font = LOAD_MORE_BUTTON_FONT;
    _loadMoreButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    // button border
    _loadMoreButton.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
    _loadMoreButton.layer.borderWidth = 1;
    _loadMoreButton.layer.cornerRadius = 5;
    // button action
    [_loadMoreButton addTarget:self action:@selector(loadMoreButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    // put together subviews of the footer view
    [_loadMoreBoxView addSubview:_loadMoreButton];
    
    // Create activity spinning icon
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
    _activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    _activityView.frame = CGRectMake(_loadMoreButton.width - ACTIVITY_ICON_WIDTH - 20, (LOAD_MORE_BUTTON_HEIGHT - ACTIVITY_ICON_HEIGHT)/2, ACTIVITY_ICON_WIDTH, ACTIVITY_ICON_HEIGHT);
    _activityView.backgroundColor = [UIColor clearColor];
    
    [_loadMoreButton addSubview:_activityView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"notif_tile_selection" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    // position tableView
    _tableView.top = self.topBar.hidden ? 0 : self.topBar.bottom;
    _tableView.height = self.view.height
                        - (self.topBar.hidden ? 0 : self.topBar.height)
                        - (self.bottomBar.hidden ? 0 : self.bottomBar.height);

    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:@"notif_tile_selection" object:nil];
    [nc addObserver:self selector:@selector(processTileSelectionNotif:) name:@"notif_tile_selection" object:nil];
    
}

- (void)setSelectedKey:(NSString *)selectedKey {
    if ([selectedKey isEqualToString:@""]) {
        _indexPathOfSelected = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    _selectedKey = selectedKey;
}

- (void)resize {
        
    // adjust tableView size
    
    _tableView.height = self.view.height
    - (self.topBar.hidden ? 0 : self.topBar.height)
    - (self.bottomBar.hidden ? 0 : self.bottomBar.height);

}

- (void)showLoadMoreButtonLoading:(BOOL)show {
    
    if (show) {
        [_activityView startAnimating];
        [_loadMoreButton setTitle:LS(@"Loading...", @"") forState:UIControlStateNormal];
        _loadMoreButton.enabled = NO;

    } else {
        [_activityView stopAnimating];
        [_loadMoreButton setTitle:LS(@"Load More", @"") forState:UIControlStateNormal];
        _loadMoreButton.enabled = YES;
    }
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_rows objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id object = [[_rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    Class cellClass = [self cellClassForObject:object];
    const char* className = class_getName(cellClass);
    NSString* identifier = [[NSString alloc] initWithBytesNoCopy:(char*)className
                                                          length:strlen(className)
                                                        encoding:NSASCIIStringEncoding
                                                    freeWhenDone:NO];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (nil == cell) {
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if ([cell isKindOfClass:[CVTableViewCell class]]) {
        [(CVTableViewCell*)cell setObject:object];
    }
    
    return cell;
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _sections;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (_sections == nil)
        return nil;
    
    CVTableViewSectionHeaderView* headerView = [[CVTableViewSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 0)];
    headerView.title = [_sections objectAtIndex:section];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id object = [[_rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    Class cls = [self cellClassForObject:object];
    return [cls tableView:tableView rowHeightForObject:object];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (_sections == nil)
        return 0.0;
    
    if ([_sections count] == 0)
        return 0.0;
    
    if ([[_sections objectAtIndex:section] isEqualToString:@""])
        return 0.0;
    
    return HEADERVIEW_HEIGHT;
}


#pragma mark -
#pragma mark public

// this method must be overriden
- (Class)cellClassForObject:(id)object {
    return [NSObject class];
}

- (SVPullToRefreshView*)pullToRefreshView {
    return _tableView.pullToRefreshView;
}

- (void)handlePullToRefresh:(SVPullToRefreshView*)refreshView {
    [refreshView stopAnimating];
}

- (void)showDetailPageOfSelectedItem{
    
    if ([_selectedKey isEqualToString:@""]) {
        [self tableView:self.tableView didSelectRowAtIndexPath:_indexPathOfSelected];
        [self.tableView selectRowAtIndexPath:_indexPathOfSelected animated:NO scrollPosition:UITableViewScrollPositionNone];
        
    } else {
        // reserve the previous selection after a refresh/update
        [self.tableView selectRowAtIndexPath:_indexPathOfSelected animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    _isTaskPageDisplayed = YES;
}

- (void)setDisplayMode:(CVListDisplayMode)displayMode {
    if (_displayMode != displayMode) {
        _displayMode = displayMode;
        [self displayModeDidChange:displayMode];
    }
}

- (void)displayModeWillChange:(CVListDisplayMode)displayMode {
    // to be overriden
}

- (void)displayModeDidChange:(CVListDisplayMode)displayMode {
    // to be overriden
}

#pragma mark -
#pragma mark CVBaseViewController

- (void)topBarDidShow:(BOOL)show {
    
    [super topBarDidShow:show];
    
    // adjust tableView size
    
    _tableView.top = self.topBar.hidden ? 0 : self.topBar.bottom;
    _tableView.height = self.view.height
                            - (self.topBar.hidden ? 0 : self.topBar.height)
                            - (self.bottomBar.hidden ? 0 : self.bottomBar.height);
}

- (void)bottomBarDidShow:(BOOL)show {
    
    [super bottomBarDidShow:show];
    
    // adjust tableView size
    
    _tableView.height = self.view.height
                            - (self.topBar.hidden ? 0 : self.topBar.height)
                            - (self.bottomBar.hidden ? 0 : self.bottomBar.height);
}

#ifdef CV_TARGET_IPAD

- (void)pageDidResize:(CVPageSize)sizeMode {
    
    [super pageDidResize:sizeMode];
    
    // pop the pages on top
    self.selectedKey = @"";
    [self popFromStack];
}


#endif

- (void) processTileSelectionNotif:(NSNotification*)notif {
    
    if (notif.userInfo != nil)
        return;
    
    // reset selectedKey when a tile is deselected from close button
    _selectedKey = @"";
}


@end
