//
//  CVContactPickerViewController.m
//  Vmoso
//
//  Created by Vincent Leung on 5/1/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVContactPickerViewController.h"
#import "CVContactListModel.h"
#import "CVRowItemCell.h"
#import "User.h"
#import "User+Bizlogic.h"
#import "NSDictionary+DragonAPI.h"
#import "DataStore.h"
#import "CVContactPickerItem.h"
#import "CVContactPickerCell.h"
#import "CVContactPickerImageCollectionCell.h"
#import <objc/runtime.h>

//data source
#import "IPadContactPickerDataSource.h"
#import "IPadContactPickerSearchDatasource.h"
#import "CVAddressBookDataSource.h"
#import "CVAddressBookSearchDataSource.h"
#import "CVContactListSvcModel.h"
#import "CVContactItem.h"
#import "CVContactGroupItem.h"
#import "CVContactItem+Bizlogic.h"
#import "CVUserListItem.h"

#define BG_COLOR            [UIColor whiteColor]
#define BUTTON_TINTCOLOR    RGBCOLOR(90, 90, 90)
#define CANCEL_BUTTON_COLOR RGBCOLOR(60, 136, 230)

#ifdef CV_TARGET_IPAD
#define PAGE_WIDTH      500
#else 
#define PAGE_WIDTH      320
#endif

#define TOP_MARGIN      20
#define BOTTOM_MARGIN   20
#define LEFT_MARGIN     5
#define RIGHT_MARGIN    20
#define FIELD_SPACER    3
#define FIELD_FONT      [UIFont fontWithName:@"Helvetica" size:14]
#define FIELD_LINES     3   // maximum lines displayed
#define SEGMENT_WIDTH   440
#define SEGMENT_HEIGHT  35

#define BG_COLOR_TABULAR     [UIColor whiteColor]


#define TILE_PAGE_SECTION_INDEX_COLOR   [UIColor grayColor]
#define TABULAR_PAGE_SECTION_INDEX_COLOR    [UIColor grayColor]

#define LOADMORE_BUTTON_WIDTH  240
#define BOTTOM_TOOLBAR_HEIGHT 44
#define COLLECTION_CELL_WIDTH  40
#define COLLECTION_CELL_HEIGHT 40

@interface CVContactPickerViewController () <CVAPIListModelDelegate, UISearchBarDelegate, UIActionSheetDelegate, TTPickerTextFieldDelegate>
{
    IPadPickerTextField*        _pickerField;
    UIScrollView*               _pickerFieldContainer;
    NSMutableDictionary*        _recipients;
    NSArray*                    _initialRecipients;
    NSMutableArray *            _arrayCollectionPickerUsers;
    
}

@property (nonatomic, assign) BOOL addPeople;
@property (nonatomic, assign) BOOL isModified;

@property (nonatomic, retain) UISegmentedControl* segmentedControl;
@property (nonatomic, retain) NSArray* segmentOptions;
@property (nonatomic, retain) CVContactListSvcModel* model;
@property (nonatomic, retain) NSArray* letters;
@property (nonatomic, retain) NSMutableDictionary* letterToSectionMapping;
@property (nonatomic, retain) NSArray* typeOptions;
@property (nonatomic, retain) NSString* filter;

//filter related button
@property(nonatomic, retain) UIActionSheet* sheetForFilter;
@property(nonatomic, retain) UIActionSheet* sheetForCancel;
@property(nonatomic, retain) UIButton* filterButton;
@property(nonatomic, retain) UIBarButtonItem* filterItem;
@property(nonatomic, retain) UIButton*  statusButton;
@property(nonatomic, retain) NSArray* filterOptions;
//@property (nonatomic, retain) NSArray* sections;
//@property (nonatomic, retain) NSArray* rows;


@property (nonatomic, retain) UISearchBar* searchBarButton;
@property (nonatomic, retain) UICollectionView* collectionView;
@property(nonatomic, retain) UIToolbar* imageCollectionToolbar;
@property (nonatomic, retain) UIView* imageCollectionViewContainer;
@property (nonatomic, retain) UICollectionView* imageCollectionView;

@property (nonatomic, strong) NSMutableArray *searchResults;


@end

@implementation CVContactPickerViewController

- (void)dealloc {
    _model = nil;
    _model.delegate = nil;
    
    self.tableView.delegate = nil;
    self.tableView = nil;
    self.collectionView.delegate = nil;
    self.collectionView = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _recipients = [NSMutableDictionary dictionary];
        
        self.navigationItem.title = LS(@"Select Contacts", @"");
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                 initWithTitle: LS(@"Cancel", @"")
                                                 style: UIBarButtonItemStyleBordered
                                                 target: self
                                                 action: @selector(cancel)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithTitle: LS(@"Done", @"")
                                                  style: UIBarButtonItemStyleDone
                                                  target: self
                                                  action: @selector(doneWithPicker)];

        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    return self;
}


- (id)initWithRecipients:(NSArray*)initialRecipients forAddPeople:(BOOL)addPeople withOptions:(NSArray*)options {
	self = [self initWithNibName:nil bundle:nil];
    if (self) {
        _addPeople = addPeople;
        _initialRecipients = initialRecipients;
        _filterOptions = options;
    }
    
    return self;
}

- (id)initPingPickerWithTaskKey:(NSString*)taskKey {
	self = [self initWithNibName:nil bundle:nil];
    if (self) {
        _taskKeyForPingPicker = taskKey;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    _tableView.delegate = self;
    
    _filter = CONTACT_TYPE_ALL;
    _listType = (_listType != nil) ? _listType : CONTACT_LIST_TYPE_CONTACT;
    
    //popup size
    self.contentSizeForViewInPopover = CGSizeMake(PAGE_WIDTH, 10000);
    
    //original filter control
    /*
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:_filterOptions];
    _segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    _segmentedControl.selectedSegmentIndex =
    _segmentedControl.tintColor = BUTTON_TINTCOLOR;
    [_segmentedControl addTarget:self action:@selector(segmentedControlSelected:) forControlEvents:UIControlEventValueChanged];

    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PAGE_WIDTH, SEGMENT_HEIGHT + FIELD_SPACER)];
    view.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    [view addSubview:_segmentedControl];
    [self.view addSubview:view];
    */
    
    //new filter
#ifdef CV_TARGET_IPAD
    UIView* filterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PAGE_WIDTH, SEGMENT_HEIGHT + FIELD_SPACER)];
#else
    CGRect frm = [self view].frame;
    UIView* filterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frm.size.width, SEGMENT_HEIGHT + FIELD_SPACER)];
#endif
    filterView.backgroundColor = [UIColor blackColor];
    [filterView  setUserInteractionEnabled:YES];
    
    _filterButton = [self filterButton];
    _filterItem = [[UIBarButtonItem alloc] initWithCustomView:_filterButton];
    
    _statusButton = [self statusButton];
    
    [filterView addSubview:_filterButton];
    [filterView addSubview:_statusButton];

    [self.view addSubview:filterView];
    
    
    //picker field container
    _pickerFieldContainer = [[[UIScrollView class] alloc] initWithFrame:self.view.bounds];
    _pickerFieldContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _pickerFieldContainer.canCancelContentTouches = NO;
    _pickerFieldContainer.showsVerticalScrollIndicator = YES;
    _pickerFieldContainer.showsHorizontalScrollIndicator = NO;
    //[self.view addSubview:_pickerFieldContainer];
    
    //picker field
    _pickerField = [[IPadPickerTextField alloc] init];
    _pickerField.autocorrectionType = UITextAutocorrectionTypeNo;
    _pickerField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _pickerField.rightViewMode = UITextFieldViewModeAlways;
    _pickerField.delegate = self;
    _pickerField.font = FIELD_FONT;
    _pickerField.returnKeyType = UIReturnKeyDone;
    _pickerField.keyboardType = UIKeyboardTypeEmailAddress;
    _pickerField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _pickerField.placeholder = (_placeHolder != nil) ? _placeHolder : LS(@"Search People", @"");
    _pickerField.backgroundColor = [UIColor whiteColor];
    _pickerField.text = @"";
    
    //[_pickerFieldContainer addSubview:_pickerField];
    
    //search Bar
    _searchBarButton = [self searchBarButton];
    _searchBarButton.delegate = self;
    _searchBarButton.placeholder = LS(@"Search People", @"");
    [self.view addSubview:_searchBarButton];

    // Image picker collection view
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setItemSize:CGSizeMake(COLLECTION_CELL_WIDTH, COLLECTION_CELL_HEIGHT)];
    [flowLayout setMinimumInteritemSpacing:0.f];
#ifdef CV_TARGET_IPAD
    [flowLayout setMinimumLineSpacing:20.f];
    _imageCollectionViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, SEGMENT_HEIGHT - 5)];
#else
    [flowLayout setMinimumLineSpacing:8.f];
    _imageCollectionViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width,  BOTTOM_TOOLBAR_HEIGHT - 5)];

#endif
    _imageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width,  BOTTOM_TOOLBAR_HEIGHT - 5) collectionViewLayout:flowLayout];
    _imageCollectionView.delegate = self;
    _imageCollectionView.dataSource = self;
    _imageCollectionView.backgroundColor = [UIColor clearColor];
    
    [_imageCollectionViewContainer addSubview:_imageCollectionView];
    
    _imageCollectionToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - BOTTOM_TOOLBAR_HEIGHT, self.view.width,  BOTTOM_TOOLBAR_HEIGHT - 5)];

    self.bottomBar = _imageCollectionToolbar;
    [self.bottomBar addSubview:_imageCollectionViewContainer];
    [self.bottomBar addSubview:_imageCollectionView];
    self.bottomBar.hidden = NO;
    [self.view addSubview:self.bottomBar];

    [self layoutViews];
    
//    _tableView.delegate = self;
//    _tableView.dataSource = self;
//    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _model.delegate = self;

    self.searchResults = [NSMutableArray arrayWithCapacity:[self.rows count]];
    // set image picker collection view
    _arrayCollectionPickerUsers = [[NSMutableArray alloc] init];
    for (NSString* selectedKey in _model.selectedKeys) {
        User* userInfo = [User userWithUniqueUserId:selectedKey inManagedObjectContext:[[DataStore sharedDataStore] managedObjectContext]];
        [_arrayCollectionPickerUsers addObject:userInfo];
    }
    
    self.collectionView = _imageCollectionView;
    [self.collectionView registerClass:[CVContactPickerImageCollectionCell class] forCellWithReuseIdentifier:@"selectingCollectionViewCell"];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    if (!_model) {
        [self.topBar removeFromSuperview];

        if (_taskKeyForPingPicker) {//task participants picker,only for ping now
            [_filterButton setEnabled:NO];
        }
        
        [self getCachedModel];
        
        if ([_initialRecipients count] > 0) {
            
            for (NSDictionary* recipient in _initialRecipients) {
                if ([recipient objectForKey:@"key"] != nil) {
                    [_model.selectedKeys addObject:[recipient objectForKey:@"key"]];
                    if(![_recipients objectForKey:[recipient objectForKey:@"key"]])
                        [_recipients setObject:recipient forKey:[recipient objectForKey:@"key"]];
                }
            }
            
            //update setatus button
            [self updateStatusOfButtons];
        }
        
        [self showContactsByNameInTabularMode];
    }
    
    [_model loadMore:NO];
    
    [self.collectionView reloadData];
    
    if (_arrayCollectionPickerUsers.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_arrayCollectionPickerUsers.count-1 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _pickerField.text = nil;
    
    // adjust _scrollView frame and contentSize
    [self layoutViews];
    
    self.tableView.delegate = self;
    
}

- (void)viewDidDisappear:(BOOL)animated{
 
    [super viewDidDisappear:animated];
    
    if (_model)
        [_model cancel];
    
}

- (void)handlePullToRefresh:(SVPullToRefreshView *)refreshView {
    [_model loadMore:NO];
    [self layoutViews];
}

- (void)modelDidFinishLoad:(CVAPIListModel*)model {
    
    // cache the first page of _model
    if (_model.pageIdx == 0) {
        if (!_taskKeyForPingPicker)
            [CVContactListSvcModel persistModel:_model withId:[CVContactListSvcModel getCachedModelIdWithFilter:_filter withType:_listType withSort:CONTACT_LIST_SORT_NAME]];
    }
    
    
    if ([_model hasMore]) {
        self.tableView.tableFooterView = self.loadMoreBoxView;
        self.loadMoreButton.left = (self.view.width - LOADMORE_BUTTON_WIDTH)/2;
        self.loadMoreButton.width = LOADMORE_BUTTON_WIDTH;
        
        [self showLoadMoreButtonLoading:NO];
        DLog(@"activityIndicator stopAnimating");
        
        
    } else
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 10)];
    
    [self showContactsByNameInTabularMode];
}

- (Class)cellClassForObject:(id)object {
    
    if ([object isKindOfClass:[CVContactPickerItem class]])
        return [CVContactPickerCell class];             // tabular mode row cell
    else if ([object isKindOfClass:[CVRowItem class]])
        return [CVRowItemCell class];         // tile mode row cell
    
    return [super cellClassForObject:object];
}



#pragma mark -
#pragma mark private

- (void)loadDataWithTaskParticipants {
//    Task* task = [Task taskWithUniqueId:_taskKeyForPingPicker inManagedObjectContext:[[DataStore sharedDataStore] managedObjectContext]];
//    for (User* user in task.assignedTo) {
//        NSDictionary* obj = [NSDictionary dictionaryWithObject:user forKey:ITEM_OBJECT];
//        [_model.allItems addObject:obj];
//        [_model.resultItems addObject:obj];
//    }
//    for (User* user in task.ccedTo) {
//        NSDictionary* obj = [NSDictionary dictionaryWithObject:user forKey:ITEM_OBJECT];
//        [_model.allItems addObject:obj];
//        [_model.resultItems addObject:obj];
//
//    }
//    [self showContactsByNameInTabularMode];
}

- (NSMutableSet*)selectedKeys {
    return _model.selectedKeys;
}

- (void)addRecipient:(id)recipient {
    [self view];
    
    [_pickerField addCellWithObject:recipient];
    
}

- (void)cancel:(BOOL)confirmIfNecessary {
    if (confirmIfNecessary && _isModified) {
        [self confirmCancellation];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)cancel {
    [self cancel:YES];
}

- (void) doneWithPicker {
    
    [self handleResults];
    
    [self cancel:NO];
}

- (void) handleResults {
    if (_delegate) {
        
        __block NSMutableArray* results = [NSMutableArray array];
        __block NSMutableSet* helper = [NSMutableSet set];
        
        [[_recipients allValues] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
            if ([obj isKindOfClass:[CVContactItem class]]) {
                if (![helper containsObject:[(CVContactItem*)obj key]]) {
                    [results addObject:[(CVContactItem*)obj toDictionary]];
                    [helper addObject:[(CVContactItem*)obj key]];
                }
                
            } else if ([obj isKindOfClass:[CVContactGroupItem class]]) {
                for (CVUserListItem* user in ((CVContactGroupItem*)obj).members) {
                    if (![helper containsObject:user.key]) {
                        [results addObject:[user toDictionary]];
                        [helper addObject:user.key];
                    }
                }
            }
            else if ([obj isKindOfClass:[NSDictionary class]]) {
                if (![helper containsObject:[(NSDictionary*)obj objectForKey:@"key"]]) {
                    [results addObject:obj];
                    [helper addObject:[(NSDictionary*)obj objectForKey:@"key"]];
                }
            }
        }];
        _selectedResults = results;
        [_delegate recipientsChanged:results];
        
    }
}


- (void)layoutViews {
    
    //use for pickerField    
    //_segmentedControl.frame = CGRectMake(LEFT_MARGIN, 5, PAGE_WIDTH - 2 * LEFT_MARGIN, 30);
   /*
    CGRect frm = [self view].frame;
    int width = frm.size.width/2;
    _filterButton.frame = CGRectMake(width, 0,  width, SEGMENT_HEIGHT);
    _statusButton.frame = CGRectMake(0, 0, width, SEGMENT_HEIGHT);

    _pickerField.frame = CGRectMake(0, _segmentedControl.bottom, self.view.width, 0);
    */
    
    [_pickerField sizeToFit];
    if (_pickerField.lineCount <= FIELD_LINES)
        _pickerFieldContainer.frame = _pickerField.frame;
    else
        _pickerFieldContainer.frame = CGRectMake(0, _segmentedControl.bottom + 5, _pickerField.frame.size.width, [_pickerField heightWithLines:FIELD_LINES]);
    _pickerFieldContainer.contentSize = _pickerField.frame.size;
    [_pickerFieldContainer setContentOffset:CGPointMake(0,40) animated:NO];

    //adding space
#ifdef CV_TARGET_IPAD
    [self.tableView setContentInset:UIEdgeInsetsMake(FIELD_SPACER + _searchBarButton.size.height,0,0,0)];
#else
    [self.tableView setContentInset:UIEdgeInsetsMake(SEGMENT_HEIGHT + FIELD_SPACER + _searchBarButton.size.height,0,0,0)];
#endif
    
    self.tableView.top = _filterButton.bottom + _searchBarButton.size.height;
    self.tableView.height = self.view.height - self.tableView.top - BOTTOM_TOOLBAR_HEIGHT;
    [_searchBarButton sizeToFit];

    _imageCollectionViewContainer.frame = CGRectMake(0.0f, 0.0f, self.view.width, BOTTOM_TOOLBAR_HEIGHT);
//    _imageCollectionViewContainer.backgroundColor = [UIColor clearColor];
//    _imageCollectionViewContainer.backgroundColor = [UIColor blueColor];
    _imageCollectionToolbar.frame = CGRectMake(0.0f, self.view.height - BOTTOM_TOOLBAR_HEIGHT, self.view.width, BOTTOM_TOOLBAR_HEIGHT);
    _imageCollectionToolbar.backgroundColor = [UIColor redColor];
    _imageCollectionView.frame = CGRectMake(15.0f, 0.0f, self.view.width - COLLECTION_CELL_WIDTH,  BOTTOM_TOOLBAR_HEIGHT);

}

- (void)confirmCancellation {
    
    if (_sheetForCancel == nil) {

        _sheetForCancel = [[UIActionSheet alloc]init];
        _sheetForCancel.delegate = self;
        _sheetForCancel.title = LS(@"Are you sure you want to cancel?", @"");
        [_sheetForCancel addButtonWithTitle:LS(@"Yes", @"")];
        [_sheetForCancel addButtonWithTitle:LS(@"No", @"")];
        _sheetForCancel.destructiveButtonIndex = 1;    
    }
    
    [_sheetForCancel showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
}

//- (void)segmentedControlSelected:(UISegmentedControl*)segmentControl {
//    
//    
//    NSString* selectedSegmentTitle = [_segmentedControl titleForSegmentAtIndex:_segmentedControl.selectedSegmentIndex];
//
//    [_model.query setObject:[selectedSegmentTitle lowercaseString] forKey:@"filter"];
//    
//    [self showLoading:YES];
//    [_model loadMore:NO];
//    
//    [_pickerField shouldUpdate:YES];
//    [_pickerField setSelectedCell:nil];
//    
//    /*
//    NSString* selectedSegmentTitle = [_segmentedControl titleForSegmentAtIndex:_segmentedControl.selectedSegmentIndex];
//    if ([selectedSegmentTitle isEqualToString:TYPE_OPTION_ADDBOOK]) {
//        //self.dataSource = self.addressBookDS;
//        _pickerField.dataSource = _addressBookSearchDS;
//        _pickerField.tableView.dataSource = _addressBookSearchDS;
//    }
//    else {
//        //self.dataSource = self.contactsDS;
//        _pickerField.dataSource = _contactsSearchDS;
//        _pickerField.tableView.dataSource = _contactsSearchDS;
//    }
//    
//    _pickerField.text = @"";
//    [_pickerField shouldUpdate:YES];
//    [_pickerField setSelectedCell:nil];
//    */
//    
//}

-(void) showCachedContacts {

    [self getCachedModel];
    
    [self showContactsByNameInTabularMode];
}

-(void)getCachedModel{
    if (_taskKeyForPingPicker){
        //[self loadDataWithTaskParticipants];//TODO: need to convert to use new api
    } else {
        _model = (CVContactListSvcModel*)[CVContactListSvcModel cachedModelWithId:[CVContactListSvcModel getCachedModelIdWithFilter:_filter withType:_listType
                                                                                                                           withSort:CONTACT_LIST_SORT_NAME]];
        if (_model == nil)
            _model = [[CVContactListSvcModel alloc] init];
        
        _model.delegate = self;
        
        _model.filter = _filter;
        _model.sortBy = CONTACT_LIST_SORT_NAME;
        _model.order = CONTACT_LIST_ORDER_ASC;
        _model.type = _listType;
    }
    
    if(_model.selectedKeys == nil)
        _model.selectedKeys = [NSMutableSet set];
}

- (void)showContactsByNameInTabularMode {
    
    NSMutableArray* sections = [NSMutableArray array];
    NSMutableArray* rows = [NSMutableArray array];
    
    NSMutableDictionary* groups = [NSMutableDictionary dictionary];
    for (id object in _model.items) {
        NSString* lastName = nil;
        if ([object isKindOfClass:[CVContactItem class]])
            lastName = [object getSortLastName];
        else
            lastName = [object name];
        NSString* letter = [CVAPIUtil firstLetterOfString:lastName];
        
        NSMutableArray* section = [groups objectForKey:letter];
        if (!section) {
            section = [NSMutableArray array];
            [groups setObject:section forKey:letter];
        }
        
        [section addObject:object];
    }
    
    _letters = [CVAPIUtil sortLetterByArray:groups];
    for (NSString* letter in _letters) {
        
        NSMutableArray* itemsWithLetter = [groups objectForKey:letter];
        
        // sort the items by last/first names
        NSArray* sortedItemsWithLetter = [itemsWithLetter sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            
            if ([a isKindOfClass:[CVContactItem class]]) {
                CVContactItem* aUser = (CVContactItem*)a;
                CVContactItem* bUser = (CVContactItem*)b;
                
                NSInteger result = [[aUser getSortLastName] localizedCaseInsensitiveCompare:[bUser getSortLastName]];
                if (result != NSOrderedSame)
                    return result;
                return [[aUser getSortFirstName] localizedCaseInsensitiveCompare:[bUser getSortFirstName]];
            }
            else {
                CVContactGroupItem* aUser = (CVContactGroupItem*)a;
                CVContactGroupItem* bUser = (CVContactGroupItem*)b;
                return [aUser.name localizedCaseInsensitiveCompare:bUser.name];
            }
            
        }];
        
        NSMutableArray* rowsInSection = [NSMutableArray array];
        for (id obj in sortedItemsWithLetter) {
            
            if ([obj isKindOfClass:[CVContactItem class]]) {
                
                CVContactItem* user = (CVContactItem*)obj;
                
                CVContactPickerItem* contact = [[CVContactPickerItem alloc] init];
                contact.icon = [user iconUrlOfSize:@"medium"];
                contact.name = [user getDisplayedName];
                contact.key = user.key;
                contact.contact = user;
                
#ifdef CV_TARGET_IPAD
                contact.title = user.jobTitle;
                contact.company = user.company;
                contact.sharedTasks = user.sharedTasks;
                contact.mutualContacts = user.mutualContacts;
#endif
                if ([contact.key isEqualToString:self.selectedKey])
                    self.indexPathOfSelected = [NSIndexPath indexPathForRow:[rowsInSection count] inSection:[sections count]];
                
                //turn on checked mark
                if ([_model.selectedKeys containsObject:contact.key]) {
                    contact.checked = YES;
                    //[_recipients addObject:user];
                }
                
                [rowsInSection addObject:contact];
            }
            else {
                CVContactGroupItem* user = (CVContactGroupItem*)obj;
                
                CVContactPickerItem* contact = [[CVContactPickerItem alloc] init];
                contact.icon = @"bundle://sm-group.png";
                contact.name = user.name;
                contact.key = user.key;
                contact.contact = user;
                if ([contact.key isEqualToString:self.selectedKey])
                    self.indexPathOfSelected = [NSIndexPath indexPathForRow:[rowsInSection count] inSection:[sections count]];
                
                //turn on checked mark
                if ([_model.selectedKeys containsObject:contact.key]) {
                    contact.checked = YES;
                    //[_recipients addObject:user];
                }
                
                [rowsInSection addObject:contact];
            }
            
        }
        
        [sections addObject:letter];
        [rows addObject:rowsInSection];
    }
    
    self.sections = sections;
    self.rows = rows;
    
    self.view.backgroundColor = BG_COLOR_TABULAR;
    
    if ([self.tableView respondsToSelector:@selector(setSectionIndexColor:)])
        self.tableView.sectionIndexColor = TABULAR_PAGE_SECTION_INDEX_COLOR;
    
    self.tableView.tableHeaderView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.allowsSelection = YES;
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [self.pullToRefreshView performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
}

- (void)filterButtonTouched:(id)sender {
    
    if (_sheetForFilter == nil) {
        _sheetForFilter = [[UIActionSheet alloc]init];
        _sheetForFilter.delegate = self;
        _sheetForFilter.title = nil;
        for (NSString* option in _filterOptions)
            [_sheetForFilter addButtonWithTitle:option];
    }
    
    [_sheetForFilter showInView:[self view]];
}

-(void) updateStatusOfButtons {
    
    NSString *selectedCount = [NSString stringWithFormat:@"%d %@", [_model.selectedKeys count], LS((@"Selected"),@"") ];
    [_statusButton setTitle:LS(selectedCount, @"0 Selected") forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet == _sheetForFilter) {
        if (buttonIndex < 0)
            return;
        NSString* filter = nil;
        NSString* selectedOption = [_sheetForFilter buttonTitleAtIndex:buttonIndex];
        if ([selectedOption isEqualToString:TYPE_OPTION_TRUSTED])
            filter = CONTACT_TYPE_TRUSTED;
        else if ([selectedOption isEqualToString:TYPE_OPTION_CONNECTED])
            filter = CONTACT_TYPE_CONNECTED;
        else if ([selectedOption isEqualToString:TYPE_OPTION_ENGAGED])
            filter = CONTACT_TYPE_ENGAGED;
        else if ([selectedOption isEqualToString:TYPE_OPTION_ACQUAINTANCE])
            filter = CONTACT_TYPE_ACQUAINTANCE;
        else if ([selectedOption isEqualToString:TYPE_OPTION_PENDING])
            filter = CONTACT_TYPE_PENDING;
        else if ([selectedOption isEqualToString:TYPE_OPTION_COMPANY])
            filter = CONTACT_TYPE_COMPANY;
        else if ([selectedOption isEqualToString:TYPE_OPTION_GROUP])
            filter = CONTACT_TYPE_GROUP;
        else if ([selectedOption isEqualToString:TYPE_OPTION_ALL])
            filter = CONTACT_TYPE_ALL;
        else
            filter = CONTACT_TYPE_ALL;
        
        if ([_filter isEqualToString:filter])
            return;
        
        [_filterButton setTitle:LS([filter capitalizedString], @"") forState:UIControlStateNormal];
        _filter = filter;
        self.selectedKey = @"";
        [self popTopViewControllers];
        [self showCachedContacts];
        [_model updateWithFilter:filter];
        return;
    } else if ( actionSheet == _sheetForCancel) {
    
       if (buttonIndex == actionSheet.cancelButtonIndex || buttonIndex == actionSheet.destructiveButtonIndex)
           [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
       else
           [self.navigationController popViewControllerAnimated:YES];
   }
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    
    return 58.0;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    
#ifdef CV_TARGET_IPAD
    if (_isFiltered)
        return 0.0;
    else
        return 25.0;
#else 
    return 0.0;
#endif
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CVContactPickerItem* item = [[CVContactPickerItem alloc] init];
    
    if (!_isFiltered){
        item = [[self.rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    } else {
        item = [[self.searchResults objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    // update selectedContacts in model and IPadContactItem with selection
    item.checked = !item.checked;
    
    if ([_model.selectedKeys containsObject:item.key])
        [_model.selectedKeys removeObject:item.key];
    else if(item.key != nil)
        [_model.selectedKeys addObject:item.key];
    
    //update _statusButton
    [self updateStatusOfButtons];
    
    // update the selected cell
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    id userInfo = item.contact;

    if(userInfo != nil) {
        if (item.checked) {
            if(![_recipients objectForKey:item.key])
                [_recipients setObject:userInfo forKey:item.key];
            [_arrayCollectionPickerUsers addObject:userInfo];

        }
        else {
            [_recipients removeObjectForKey:item.key];
            [_arrayCollectionPickerUsers removeObject:userInfo];
        }
        
        //[_pickerField addCellWithObject:userInfo];
        //[_pickerField scrollToEditingLine:YES];
    }
    
    // asyn update collection view
    [self.collectionView reloadData];
    
    // cursor the position of collection view
    if (_arrayCollectionPickerUsers.count > 0) {
        NSIndexPath *indexPathForCollection = [NSIndexPath indexPathForRow:_arrayCollectionPickerUsers.count-1 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPathForCollection atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }

    if ([[self selectedKeys] count])
        self.navigationItem.rightBarButtonItem.enabled = YES;
    else
        self.navigationItem.rightBarButtonItem.enabled = NO;
    /* pickerField
    NSSet* selectedKeys = [self selectedKeys];
    if (![selectedKeys containsObject:userKey]) {
        // select a contact
        [_pickerField addCellWithObject:userInfo];
        [_pickerField scrollToEditingLine:YES];
        
    } else {
        
        // make selected cell non-selected
        _pickerField.selectedCell = nil;
        
        // deselect a contact
        [_pickerField removeCellWithObject:userInfo];
        
        _pickerField.text = @"";
        
    } */


}


#pragma mark -
#pragma mark TTPickerTextFieldDelegate

- (void)textField:(TTPickerTextField*)textField didAddCellAtIndex:(NSInteger)cellIndex {
        
    id object = ((TTPickerViewCell*)[_pickerField.cellViews objectAtIndex:cellIndex]);
    
    id userInfo = object;
    if ([object isKindOfClass:[TTTableImageItem class]]) {
        userInfo = ((TTTableImageItem*)object).userInfo;
    }
    
    //[_recipients addObject:userInfo];
    
    NSString* userKey = nil;
    if ([userInfo isKindOfClass:[User class]])
        userKey = [(User*)userInfo key];
    else if ([userInfo isKindOfClass:[Group class]])
        userKey = ((Group*)userInfo).key;

    if (userKey!= nil) {
        [[self selectedKeys] addObject:userKey];
    }
    
    [self.tableView reloadData];
    
}

- (void)textFieldDidResize:(TTPickerTextField*)textField {
    
    // when the picker view grows to two lines, we need to adjust the
    // the sizes of scrollView, and searchResults tableView
    if (textField.lineCount <= FIELD_LINES) {
        _pickerFieldContainer.frame = CGRectMake(0, 40, textField.frame.size.width, textField.size.height);
        _pickerFieldContainer.contentSize = _pickerFieldContainer.size;
        [_pickerFieldContainer setContentOffset:CGPointMake(0,40) animated:NO];
        CGRect frame = textField.tableView.frame;
        frame.origin.y = _pickerFieldContainer.bottom;
        frame.size.height = self.view.height - _pickerFieldContainer.bottom;
        textField.tableView.frame = frame;
        
        frame = textField.shadowView.frame;
        frame.origin.y = _pickerFieldContainer.bottom;
        textField.shadowView.frame = frame;
    }
    
    [self layoutViews];
}


#pragma mark -
#pragma mark TTURLRequestDelegate

- (void)requestDidFinishLoad:(TTURLRequest*)request {
    
	TTURLJSONResponse* response = request.response;
    NSDictionary* data = response.rootObject;
    
	if (data != nil && [data isDragonAPIResultOK]) {
        
        if ([[data dragonAPICommand] isEqualToString:@"contact.remove"]) {
            User* user = [User userWithUniqueUserId:[CVAPIUtil getUserKey] inManagedObjectContext:[[DataStore sharedDataStore] managedObjectContext]];
            for (NSString* contactKey in _model.selectedKeys) {
                User* contact = [User userWithUniqueUserId:contactKey inManagedObjectContext:[[DataStore sharedDataStore] managedObjectContext]];
                if ([_filter isEqualToString:CONTACT_TYPE_TRUSTED])
                    [user removeTrustedContactObject:contact];
                else if ([_filter isEqualToString:CONTACT_TYPE_CONNECTED])
                    [user removeConnectedContactObject:contact];
                else if ([_filter isEqualToString:CONTACT_TYPE_ENGAGED])
                    [user removeEngagedContactObject:contact];
                else if ([_filter isEqualToString:CONTACT_TYPE_ACQUAINTANCE])
                    [user removeAcquaintanceContactObject:contact];
                else if ([_filter isEqualToString:CONTACT_TYPE_PENDING])
                    [user removePendingContactObject:contact];
                else if ([_filter isEqualToString:CONTACT_TYPE_COMPANY])
                    [user removeCompanyContactObject:contact];
                else if ([_filter isEqualToString:CONTACT_TYPE_ALL])
                    [user removeAllContactObject:contact];
            }
            [self alertMessage:@"Contact removed successfully!"];
        }
        if ([[data dragonAPICommand] isEqualToString:@"contact.groupremove"]) {
            User* user = [User userWithUniqueUserId:[CVAPIUtil getUserKey] inManagedObjectContext:[[DataStore sharedDataStore] managedObjectContext]];
            for (NSString* groupKey in _model.selectedKeys) {
                Group* group = [Group groupWithUniqueId:groupKey inManagedObjectContext:[[DataStore sharedDataStore] managedObjectContext]];
                [user removeHasGroupObject:group];
            }
            
            [self alertMessage:@"Group removed successfully!"];
        }
        [_model.selectedKeys removeAllObjects];
        //[self updateStatusOfButtons];
        [_model loadMore:NO];
        
    }
	
}


- (UIButton*)  filterButton {
    
    if (!_filterButton)
    {
        _filterButton = [UIButton buttonWithType:UIButtonTypeCustom];

        [_filterButton setTitle:TYPE_OPTION_ALL forState:UIControlStateNormal];
#ifdef CV_TARGET_IPAD
        [_filterButton setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
        _filterButton.frame = CGRectMake(PAGE_WIDTH/2, 0, PAGE_WIDTH/2, SEGMENT_HEIGHT);
#else
        [_filterButton setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
        CGRect frm = [self view].frame;
        int width = frm.size.width/2;
        _filterButton.frame = CGRectMake(width, 0,  width, SEGMENT_HEIGHT);
#endif
        _filterButton.backgroundColor = [UIColor darkGrayColor];
        _filterButton.layer.borderColor = [UIColor blackColor].CGColor;
        _filterButton.layer.borderWidth = 2.1f;
        _filterButton.layer.cornerRadius = 5.0f;

        _filterButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [_filterButton addTarget:self action:@selector(filterButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _filterButton;
}

- (UISearchBar*) searchBarButton{
    if (!_searchBarButton) {
        _searchBarButton = [[UISearchBar alloc] initWithFrame:CGRectMake(0, SEGMENT_HEIGHT + 2, PAGE_WIDTH , SEGMENT_HEIGHT)];
    }
    return _searchBarButton;
}

- (UIButton*) statusButton {
    
    if (!_statusButton)
    {
        _statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_statusButton setTitle:LS(@"0 Selected", @"") forState:UIControlStateNormal];
#ifdef CV_TARGET_IPAD
        [_statusButton setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
        _statusButton.frame = CGRectMake(0, 0, PAGE_WIDTH/2, SEGMENT_HEIGHT);

#else
        [_statusButton setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
        CGRect frm = [self view].frame;
        int width = frm.size.width/2;
        _statusButton.frame = CGRectMake(0, 0, width, SEGMENT_HEIGHT);
#endif
        _statusButton.backgroundColor = [UIColor blackColor];
        _statusButton.layer.borderColor = [UIColor blackColor].CGColor;
        _statusButton.layer.borderWidth = 2.1f;
        _statusButton.layer.cornerRadius = 0.0f;
        
        _statusButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    }
    return _statusButton;
}


- (void)alertMessage:(NSString*)message {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:LS(message, @"") delegate:self cancelButtonTitle:LS(@"OK", @"") otherButtonTitles:nil];
    
    [alert show];
}

#pragma mark -
#pragma mark Public
static UIPopoverController* _popover = nil;
+ (void)presentPickerInPopoverFromBarButtonItem:(UIBarButtonItem *)item withTaskKey:(NSString*)key {
    
    CVContactPickerViewController* vc = [[CVContactPickerViewController alloc] initPingPickerWithTaskKey:key];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    if (_popover) {
        [_popover dismissPopoverAnimated:NO];
    }
    
    _popover = [[UIPopoverController alloc] initWithContentViewController:nav];
    [_popover presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

+ (void)presentPickerInPopoverFromRect:(CGRect)rect inView:(UIView*)view withTaskKey:(NSString*)key {
    
    CVContactPickerViewController* vc = [[CVContactPickerViewController alloc] initPingPickerWithTaskKey:key];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    if (_popover) {
        [_popover dismissPopoverAnimated:NO];
    }
    
    _popover = [[UIPopoverController alloc] initWithContentViewController:nav];
    [_popover presentPopoverFromRect:rect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark -
#pragma mark TableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (_isFiltered){
        return [self.searchResults count];
    } else {
        return [super numberOfSectionsInTableView:tableView];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isFiltered == YES) {
        return [[self.searchResults objectAtIndex:section] count];
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    id object;
    
    if (_isFiltered == YES) {
        object = [[self.searchResults objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    } else {
        object = [[self.rows objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    }
    
    Class cellClass = [self cellClassForObject:object];
    const char* className = class_getName(cellClass);
    NSString* identifier = [[NSString alloc] initWithBytesNoCopy:(char*)className
                                                          length:strlen(className)
                                                        encoding:NSASCIIStringEncoding
                                                    freeWhenDone:NO];
    if (nil == cell) {
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if ([cell isKindOfClass:[CVTableViewCell class]]) {
        [(CVTableViewCell*)cell setObject:object];
    }
    
    for (UIView * subview in [cell.contentView subviews]) {
        if (subview.tag == 1 || subview.tag == 2 || subview.tag == 3 || subview.tag == 4)
            [subview removeFromSuperview];
    }
    
    return cell;
}

# pragma mark -
# pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        //set our boolean flag
        _isFiltered = NO;
    } else {
        //set our boolean flag
        _isFiltered =YES;
        
        // filtered array
        self.searchResults = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < self.rows.count; i++){
            NSMutableArray *searchResultInEachSection=[NSMutableArray arrayWithObjects: nil];
            for (int j = 0; j < [[self.rows objectAtIndex:i] count]; j++){
                NSString *nameEachRow = [[[self.rows objectAtIndex:i] objectAtIndex:j] name];
                NSRange filterNameRange = [nameEachRow rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (filterNameRange.location != NSNotFound){
                    id object = [[self.rows objectAtIndex:i] objectAtIndex:j];
                    [searchResultInEachSection addObject:object];
//                    [self.searchResults addObject:object];
                }
            }
            [self.searchResults addObject:searchResultInEachSection];
        }
    }
    
    //reload table view
    [self.tableView reloadData];
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [_searchBarButton resignFirstResponder];
    _searchBarButton.text = nil;
    [self searchBar:_searchBarButton textDidChange:_searchBarButton.text];
    _searchBarButton.showsCancelButton = NO;
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_searchBarButton resignFirstResponder];
    _searchBarButton.showsCancelButton = NO;
#ifdef CV_TARGET_IPAD
    self.bottomBar.frame = CGRectMake(0, self.view.height + 352 - BOTTOM_TOOLBAR_HEIGHT, self.view.width, BOTTOM_TOOLBAR_HEIGHT);
#endif
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
#ifdef CV_TARGET_IPHONE
    _searchBarButton.showsCancelButton = YES;
#else
    //reload table view
    self.bottomBar.frame = CGRectMake(0, self.view.height- 352 - BOTTOM_TOOLBAR_HEIGHT, self.view.width, BOTTOM_TOOLBAR_HEIGHT);
    [self.collectionView reloadData];
#endif
  
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
#ifdef CV_TARGET_IPAD
    self.bottomBar.frame = CGRectMake(0, self.view.height + 352 - 44, self.view.width, 44);
#endif
}

# pragma mark -
# pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    User* userInfo = [_arrayCollectionPickerUsers objectAtIndex:indexPath.row];
    for (int i = 0; i < self.rows.count; i++) {
        for (int j = 0; j < [[self.rows objectAtIndex:i] count]; j++) {
            CVContactPickerItem* item = [[self.rows objectAtIndex:i] objectAtIndex:j];
            if (userInfo.key == item.key) {
                item.checked = !item.checked;
                if ([_model.selectedKeys containsObject:item.key]){
                    [_model.selectedKeys removeObject:item.key];
                }
                [_arrayCollectionPickerUsers removeObject:userInfo];
            }
            
            // update the selected cell
            [self.tableView reloadData];
            
            // asyn update collection view
            [self.collectionView reloadData];
            
            // scroll to the position of collection view and animation
            if (indexPath.row > 0) {
                NSIndexPath *indexPathForCollection = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:0];
                [self.collectionView scrollToItemAtIndexPath:indexPathForCollection atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            }
        }
    }
    
    //update _statusButton
    [self updateStatusOfButtons];

    //
    if ([[self selectedKeys] count])
        self.navigationItem.rightBarButtonItem.enabled = YES;
    else
        self.navigationItem.rightBarButtonItem.enabled = NO;
}

# pragma mark -
# pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_arrayCollectionPickerUsers count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CVContactPickerImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"selectingCollectionViewCell" forIndexPath:indexPath];
 	
    if (!cell)
		cell = [[CVContactPickerImageCollectionCell alloc] init];
    
    [self.tableView reloadData];
    
    UIImage* image = [[TTURLCache sharedCache] imageForURL:[[_arrayCollectionPickerUsers objectAtIndex:indexPath.item] iconUrlOfSize:@"medium"] fromDisk:YES];
    
    if (!image) {
        CVUserIconView* userIconView = [[CVUserIconView alloc] init];
        userIconView.urlPath = [[_arrayCollectionPickerUsers objectAtIndex:indexPath.item] iconUrlOfSize:@"medium"];
        userIconView.hidden = NO;
        image = userIconView.image;
    }
    
    [[cell collectionImageView]setImage:image];

    return cell;
}



@end
