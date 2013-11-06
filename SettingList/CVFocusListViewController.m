//
//  CVFocusListViewController.m
//  Vmoso
//
//  Created by Daniel Kong on 10/23/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVFocusListViewController.h"

#import "CVFocusViewController.h"
#import "CVFocusListCell.h"
#import "CVFocusListItem.h"
#import "CVFocusListModel.h"
#import "CVAPIRequest.h"
#import "CVAPIRequestModel.h"
#import "CVNamedIcon.h"

@interface CVFocusListViewController ()<CVAPIModelDelegate>

@property(nonatomic, retain) UIBarButtonItem *addNewFocusItem;
@property(nonatomic, retain) CVFocusListModel* model;

@end

@implementation CVFocusListViewController

- (id)initWithSize:(CVPageSize)sizeMode {

    self = [super initWithSize:sizeMode];
    
    UIButton*  newFocusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [newFocusButton setImage:[CVNamedIcon iconNamed:@"Add Focus" inSprite:@"24x24_Sprite_White100.png"] forState:UIControlStateNormal];
    [newFocusButton setFrame:CGRectMake(0, 0, 20, 20)];
    [newFocusButton addTarget:self action:@selector(addNewFocusItem:) forControlEvents:UIControlEventTouchUpInside];
    _addNewFocusItem = [[UIBarButtonItem alloc] initWithCustomView:newFocusButton];
    
    self.navigationItem.rightBarButtonItem =_addNewFocusItem;

    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    self.tableView.backgroundColor = RGBCOLOR(233, 233, 233);
    
    if (getOSf() >= 7.0)
        self.tableView.separatorInset = UIEdgeInsetsZero;
    
    return self;
    
}

- (void)viewDidLoad {

    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
//    [navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    CGRect frame = [navigationBar frame];
    frame =  CGRectMake(navigationBar.frame.origin.x, navigationBar.frame.origin.y, navigationBar.frame.size.width, 32.0f);
    [navigationBar setFrame:frame];
    self.title = LS(@"Focuses", @"");
    self.titleLabel.textColor = [UIColor whiteColor];

}

- (void)viewDidAppear:(BOOL)animated {

    self.topBar.hidden = YES;

    [super viewDidAppear:animated];
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    //    [navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    CGRect frame = [navigationBar frame];
    frame =  CGRectMake(navigationBar.frame.origin.x, navigationBar.frame.origin.y, navigationBar.frame.size.width, 32.0f);
    [navigationBar setFrame:frame];
    self.tableView.top = self.tableView.top - 12;

    if ( nil == _model ) {
        _model = [[CVFocusListModel alloc] init];
        _model.subType = _subType;
        _model.spaceType = _spaceType;
        _model.delegate = self;
    }
    
    if (_model && !self.noReload) {
        // load comments
        _model.delegate = self;
        [_model loadMore:NO];
    }
    
    [[StackScrollViewAppDelegate instance].rootViewController.stackScrollViewController.view removeGestureRecognizer:    [StackScrollViewAppDelegate instance].rootViewController.stackScrollViewController.panRecognizer];

}

- (void)dealloc {
    [_model cancel];
    _model.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark CVAPIRequestModel

- (void)modelDidFinishLoad:(CVAPIRequestModel*)model action:(NSString *)action {
    
    if ([_model hasMore]) {
        self.tableView.tableFooterView = self.loadMoreBoxView;
        [self showLoadMoreButtonLoading:NO];
        DLog(@"activityIndicator stopAnimating");
        
    } else
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 10)];
    
    [self showFocusList];
}

#pragma mark -
#pragma mark CVBaseListViewController

- (void)handlePullToRefresh:(SVPullToRefreshView *)refreshView {
    [_model loadMore:NO];
}

- (Class)cellClassForObject:(id)object {
    
    if ([object isKindOfClass:[CVFocusListItem class]])
        return [CVFocusListCell class];

    return [super cellClassForObject:object];
}

#pragma mark - private

- (void)addNewFocusItem:(id)sender {
    CVFocusViewController* controller = [[CVFocusViewController alloc] initWithType:self.subType];

    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showFocusList {
    NSMutableArray* sections = [NSMutableArray array];
    NSMutableArray* rows = [NSMutableArray array];
    NSMutableArray* rowsInSection = [NSMutableArray array];
    NSDate* sectionDate = nil;
    
    if ([rowsInSection count] > 0) {
        [sections addObject:[CVAPIUtil formatDateTime:sectionDate withFormat:[CVAPIUtil getDateFormat]]];
        [rows addObject:rowsInSection];
    }
    
    self.sections = sections;
    self.rows = [NSArray arrayWithObject:_model.items];
    
    self.tableView.height = self.view.height - self.tableView.top - self.bottomBar.height;
    self.tableView.tableHeaderView = nil;
    self.tableView.allowsSelection = YES;
    [self.tableView reloadData];
    [self.pullToRefreshView stopAnimating];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    CVFocusListItem *focusListItem = [[self.rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = focusListItem.focusTitle;

    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return 48.0;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Do focus filter.
    NSString* focusKey = ((CVFocusListItem*)[_model.items objectAtIndex:indexPath.row]).focusKey;
    if (_focusApplyDelegate)
       [_focusApplyDelegate didApplyFocus:focusKey];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        CVFocusListItem *deletedItem = [[self.rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        NSMutableArray* arrayForDelete = [self.rows objectAtIndex:indexPath.section];
        [arrayForDelete removeObject:deletedItem];
        [_model.items removeObject:deletedItem];

        NSString* apiPath = [NSString stringWithFormat:@"/svc/focuses/%@",deletedItem.focusKey];
        CVAPIRequest* request = [[CVAPIRequest alloc] initWithAPIPath:apiPath];
        [request setHTTPMethod:@"DELETE"];
        CVAPIRequestModel* model = [[CVAPIRequestModel alloc] init];
        model.delegate = self;
        [model sendRequest:request completion:^(NSDictionary* apiResult, NSError* error){
            [model dispatchWithResult:apiResult error:error action:@"delete"];
        }];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
    [tableView reloadData];
}

@end
