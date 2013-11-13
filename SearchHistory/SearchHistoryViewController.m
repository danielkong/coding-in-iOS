//
//  CVSearchHistoryViewController.m
//  Vmoso
//
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVSearchHistoryViewController.h"
#import "ClearvaleUtility.h"
#import "CVSearchViewController.h"

@interface CVSearchHistoryViewController () <UIActionSheetDelegate, UIPopoverControllerDelegate, UISearchBarDelegate>

@property (nonatomic, retain) NSArray* searchHistory;
@property (nonatomic, retain) UISearchBar* searchBarButton;
@property (nonatomic, retain) UIBarButtonItem* clearItem;
@property (nonatomic, retain) UIBarButtonItem* cancelItem;

@end

@implementation CVSearchHistoryViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = LS(@"Recent Search", @"");
    _clearItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Clear", @"") style:UIBarButtonItemStylePlain target:self action:@selector(clearItemTouched)];
    self.navigationItem.rightBarButtonItem = _clearItem;
#ifdef CV_TARGET_IPHONE
    _cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelItemTouched)];
    self.navigationItem.leftBarButtonItem = _cancelItem;
    
    _searchBarButton = [self searchBarButton];
    _searchBarButton.delegate = self;
    _searchBarButton.placeholder = LS(@"Search", @"");
    [_searchBarButton becomeFirstResponder];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    [self.tableView.tableHeaderView addSubview:_searchBarButton];

    if (!_searchStats)
        _searchStats = [self getSearchStatsFromPlist];
#endif
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchBarTextDidChange:) name:SEARCHBAR_TEXT_CHANGED object:nil];
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SEARCHBAR_TEXT_CHANGED object:nil];
}

#pragma mark - private

- (NSMutableDictionary*)getSearchStatsFromPlist {
    
    ClearvaleUtility* cu = [[ClearvaleUtility alloc] init];
    NSString* plistPath = [cu getPListFilePath:SEARCHSTATS_LIST_FILE];
    return [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
}

- (void)updateSearchStatsWithKeyword:(NSString*)keyword {
    
    NSDictionary* item = [_searchStats objectForKey:keyword];
    if (!item) {
        NSDictionary* record = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"count", [NSDate date], @"lastSearchTime", nil];
        [_searchStats setObject:record forKey:keyword];
    }
    else {
        NSNumber* count = [item objectForKey:@"count"];
        NSDictionary* record = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:count.intValue+1], @"count", [NSDate date], @"lastSearchTime", nil];
        [_searchStats setObject:record forKey:keyword];
    }
}

- (void)getSortedSearchHistoryWithKeyword:(NSString*)keyword {
    
    NSMutableArray* result = [NSMutableArray array];
    [_searchStats enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key rangeOfString:keyword].location != NSNotFound || keyword.length == 0) {
            [result addObject:[NSDictionary dictionaryWithObject:obj forKey:key]];
        }
    }];
    
    NSArray* sortedArray = [result sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber* count1 = [[[obj1 allValues] objectAtIndex:0] objectForKey:@"count"];
        NSNumber* count2 = [[[obj2 allValues] objectAtIndex:0] objectForKey:@"count"];
        
        if (count1.intValue >= count2.intValue)
            return NSOrderedAscending;
        else
            return NSOrderedDescending;
    }];
    
    _searchHistory = sortedArray;
}

- (void)searchBarTextDidChange:(NSNotification*)notif {
    [self getSortedSearchHistoryWithKeyword:[notif.userInfo objectForKey:@"keyword"]];
    [self.tableView reloadData];
}

- (UISearchBar*) searchBarButton{
    if (!_searchBarButton) {
        _searchBarButton = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width , 44)];
        _searchBarButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _searchBarButton;
}

- (void)clearItemTouched {
    UIActionSheet* sheet = [[UIActionSheet alloc] init];
    sheet.delegate = self;
    [sheet addButtonWithTitle:LS(@"Clear All History", @"")];
    [sheet addButtonWithTitle:LS(@"Cancel", @"")];
    sheet.destructiveButtonIndex = 1;
    [sheet showFromBarButtonItem:_clearItem animated:YES];
}

#ifdef CV_TARGET_IPHONE
- (void)cancelItemTouched {
    [self popFromStack];
}

- (void)pop {
    UINavigationController* nc;
    if ([self isOnRootStack])
        nc = (UINavigationController*)((IPhoneAppDelegate*)[IPhoneAppDelegate sharedApplication].delegate).window.rootViewController;
    else
        nc = self.navigationController;
    
    [nc popViewControllerAnimated:NO];
}
#endif

#pragma mark - Class Method

static CVSearchHistoryViewController* _instance;

+ (CVSearchHistoryViewController*) sharedInstance {
	
    if (_instance == nil) {
		_instance = [[CVSearchHistoryViewController alloc] initWithStyle:UITableViewStylePlain];
	}
    
	return _instance;
}

static UIPopoverController* _popover = nil;

- (void)presentInPopoverFromBarButtonItem:(UIBarButtonItem *)item {
    
    CVSearchHistoryViewController* vc = [CVSearchHistoryViewController sharedInstance];
    if (!_searchStats)
        _searchStats = [self getSearchStatsFromPlist];
    
    if (_popover) {
        [_popover dismissPopoverAnimated:NO];
    }
    
    _popover = [[UIPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:vc]];
    _popover.delegate = self;
    [_popover presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)dismissPopover:(BOOL)animated {
    if (_popover) {
        [_popover dismissPopoverAnimated:animated];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_searchHistory count];;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SearchHistoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    NSString* historyItem = [[[_searchHistory objectAtIndex:indexPath.row] allKeys] lastObject];
    cell.textLabel.text = historyItem;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
#ifdef CV_TARGET_IPAD
    [_popover dismissPopoverAnimated:YES];
    [[StackScrollViewAppDelegate instance].rootViewController.searchBar resignFirstResponder];
    NSString* text = [[[_searchHistory objectAtIndex:indexPath.row] allKeys] lastObject];
    
    UIViewController* viewController = [[CVSearchViewController alloc] initWithQueue:text];
    viewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [[StackScrollViewAppDelegate instance].rootViewController presentViewController:viewController animated:YES completion:nil];
#else
    [self pop];
    NSString* text = [[[_searchHistory objectAtIndex:indexPath.row] allKeys] lastObject];
    
    UIViewController* viewController = [[CVSearchViewController alloc] initWithQueue:text];
    
    [viewController pushToStack];
#endif
    [self updateSearchStatsWithKeyword:text];

}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
#ifdef CV_TARGET_IPAD
    [[StackScrollViewAppDelegate instance].rootViewController.searchBar resignFirstResponder];
#endif
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex < 0)
        return;
    if (buttonIndex == actionSheet.cancelButtonIndex || buttonIndex == actionSheet.destructiveButtonIndex)
        [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
    else {
        [_searchStats removeAllObjects];
        _searchHistory = nil;
        [self.tableView reloadData];
    }
}
#ifdef CV_TARGET_IPHONE

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString* text = searchBar.text;
    // post notification for search history vc to update history items
    [[NSNotificationCenter defaultCenter] postNotificationName:SEARCHBAR_TEXT_CHANGED object:self userInfo:[NSDictionary dictionaryWithObject:text forKey:@"keyword"]];
    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    return;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    
    NSString* text = searchBar.text;
    
    [self updateSearchStatsWithKeyword:text];
    [self pop];
    
    UIViewController* viewController = [[CVSearchViewController alloc] initWithQueue:text];
    [viewController pushToStack];
    
    return;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    CVSearchHistoryViewController* svc = [CVSearchHistoryViewController sharedInstance];
    [svc getSortedSearchHistoryWithKeyword:searchBar.text];
}

#endif
@end
