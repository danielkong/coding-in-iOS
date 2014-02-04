#import "IPhoneMVContactPickerViewController.h"
#import "CVRowItemCell.h"
#import "NSDictionary+DragonAPI.h"
#import "CVContactPickerItem.h"
#import "CVContactPickerCell.h"
#import "CVContactPickerImageCollectionCell.h"
#import "CVContactPickerLiteralCollectionCell.h"
#import "NSString+EMail.h"

//data source
#import "CVContactListModel.h"
#import "CVContactListSvcModel.h"
#import "CVContactItem.h"
#import "CVContactGroupItem.h"
#import "CVContactItem+Bizlogic.h"
#import "CVUserListItem.h"
#import "CVTaskSvcItem.h"

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
#define FIELD_FONT      [UIFont systemFontOfSize:14]
#define FIELD_LINES     3   // maximum lines displayed
#define SEGMENT_WIDTH   440
#define SEGMENT_HEIGHT  35

#define BG_COLOR_TABULAR     [UIColor whiteColor]

#define TILE_PAGE_SECTION_INDEX_COLOR   [UIColor grayColor]
#define TABULAR_PAGE_SECTION_INDEX_COLOR    [UIColor grayColor]

#define LOADMORE_BUTTON_WIDTH  240
#define COLLECTION_CELL_WIDTH  40
#define COLLECTION_CELL_HEIGHT 40
#define BOTTOM_TOOLBAR_HEIGHT 44

#define SEARCH_TIMER_USERINFO_SEARCHTEXT_KEY    @"searchText"
#define SEARCH_TIMER_TIMEINTERVAL               1.5

@interface IPhoneMVContactPickerViewController () <CVAPIModelDelegate, UISearchBarDelegate, UIActionSheetDelegate>
{
    NSMutableDictionary*        _recipients;
    NSArray*                    _initialRecipients;
    NSMutableArray *            _arrayCollectionPickerUsers;
}

@property (nonatomic, assign) BOOL addPeople;
@property (nonatomic, assign) BOOL isModified;
@property (nonatomic, assign) BOOL addFolder;

@property (nonatomic, retain) UISegmentedControl* segmentedControl;
@property (nonatomic, retain) NSArray* segmentOptions;
@property (nonatomic, retain) CVContactListModel* model;
@property (nonatomic, retain) CVContactListSvcModel* groupModel;
@property (nonatomic, retain) NSArray* letters;
@property (nonatomic, retain) NSMutableDictionary* letterToSectionMapping;
@property (nonatomic, retain) NSArray* typeOptions;
@property (nonatomic, retain) NSString* filter;

//filter related button
@property (nonatomic, retain) UIActionSheet* sheetForFilter;
@property (nonatomic, retain) UIActionSheet* sheetForCancel;
@property (nonatomic, retain) UIBarButtonItem* filterItem;
@property (nonatomic, retain) UIButton* confirmItem;
@property (nonatomic, retain) NSArray* filterOptions;

@property (nonatomic, retain) UISearchBar* searchBarButton;
@property (nonatomic, retain) UIView* imageCollectionViewContainer;
@property (nonatomic, retain) UICollectionView* imageCollectionView;

@property (nonatomic, strong) NSMutableArray* searchResults;
@property (nonatomic, retain) NSString* searchText;

@property (nonatomic, retain) UIButton* addEmailButton;

@property (nonatomic, retain) NSTimer* searchTimer;

@end

@implementation IPhoneMVContactPickerViewController

- (void)dealloc {
    _model.delegate = nil;
    _model = nil;
    
    _groupModel.delegate = nil;
    _groupModel = nil;
    
    [_searchTimer invalidate];
    _searchTimer = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _recipients = [NSMutableDictionary dictionary];
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

- (id)initWithOptions:(NSArray*)options forAddFolder:(BOOL)addFolder {
	self = [self initWithNibName:nil bundle:nil];
    if (self) {
        _addFolder = addFolder;
        _filterOptions = options;
    }
    
    return self;
}

- (id)initPingPickerWithTask:(CVTaskSvcItem*)taskItem {
	self = [self initWithNibName:nil bundle:nil];
    if (self) {
        _taskItemForPingPicker = taskItem;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _filter = CONTACT_TYPE_ALL;
    _listType = (_listType != nil) ? _listType : CONTACT_LIST_TYPE_CONTACT;
    _searchText = @"";
    
    //popup size
    self.contentSizeForViewInPopover = CGSizeMake(PAGE_WIDTH, 10000);
    
    // filter
    
    _filterItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"All", @"") style:UIBarButtonItemStylePlain target:self action:@selector(filterButtonTouched:)];
    _filterItem.enabled = YES;
    
    //search Bar
    _searchBarButton = [self searchBarButton];
    _searchBarButton.delegate = self;
    _searchBarButton.placeholder = LS(@"Search People", @"");
    self.topBar.hidden = NO;
    self.topBar.height = _searchBarButton.height;
    [self.view addSubview:_searchBarButton];
    
    // ok item
    NSString* confirmTitle = _addPeople ? LS(@"Add", @"") : LS(@"Select", @"");
    _confirmItem = [UIButton buttonWithType:UIButtonTypeCustom];
    _confirmItem.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    _confirmItem.frame = CGRectMake(10, 0, 80, self.bottomBar.height);
    [_confirmItem setTitle:confirmTitle forState:UIControlStateNormal];
    [_confirmItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_confirmItem addTarget:self action:@selector(doneWithPicker) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:_confirmItem];
    
    // Image picker collection view
    
    _imageCollectionViewContainer = [[UIView alloc] initWithFrame:CGRectMake(_confirmItem.width + 10, 0, self.bottomBar.width - _confirmItem.width - 10, self.bottomBar.height)];
    _imageCollectionViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.bottomBar.hidden = NO;
    [self.bottomBar addSubview:_imageCollectionViewContainer];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    //    [flowLayout setItemSize:CGSizeMake(30, 30)];
    [flowLayout setMinimumInteritemSpacing:10.f];
    [flowLayout setMinimumLineSpacing:10.f];
    
    _imageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(15, 7, _imageCollectionViewContainer.width - 30,  _imageCollectionViewContainer.height - 7*2) collectionViewLayout:flowLayout];
    _imageCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _imageCollectionView.delegate = self;
    _imageCollectionView.dataSource = self;
    _imageCollectionView.backgroundColor = [UIColor clearColor];
    _imageCollectionView.showsHorizontalScrollIndicator = NO;
    [_imageCollectionViewContainer addSubview:_imageCollectionView];
    
    
    self.searchResults = [NSMutableArray arrayWithCapacity:[self.rows count]];
    // set image picker collection view
    _arrayCollectionPickerUsers = [[NSMutableArray alloc] init];
    
    [_imageCollectionView registerClass:[CVContactPickerImageCollectionCell class] forCellWithReuseIdentifier:@"selectingCollectionViewCell"];
    [_imageCollectionView registerClass:[CVContactPickerLiteralCollectionCell class] forCellWithReuseIdentifier:CONTACT_TYPE_INPUTEMAIL];
    
    self.title = LS(@"Select Contacts", @"");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle: LS(@"Cancel", @"")
                                             style: UIBarButtonItemStyleBordered
                                             target: self
                                             action: @selector(cancel)];
    
    //    self.navigationItem.rightBarButtonItem = _filterItem;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self showBottomBar:YES animated:NO];
    
    if (!_model || !_groupModel) {
        
        if (_taskItemForPingPicker) {//task participants picker,only for ping now
            _filterItem.enabled = NO;
            if (_model == nil)
                _model = [[CVContactListModel alloc] init];
            _model.delegate = self;
            [self loadDataWithTaskParticipants];
            return;
        }
        
        [self getCachedModel];
        
        if ([_initialRecipients count] > 0) {
            
            for (NSDictionary* recipient in _initialRecipients) {
                if ([recipient objectForKey:@"key"] != nil) {
                    [_model.selectedKeys addObject:[recipient objectForKey:@"key"]];
                    if(![_recipients objectForKey:[recipient objectForKey:@"key"]])
                        [_recipients setObject:recipient forKey:[recipient objectForKey:@"key"]];
                    
                    CVContactItem* contactItem = [CVContactItem contactItemWithDictionary:recipient];
                    contactItem.isAlien = NO;
                    
                    NSDictionary* userInfo = [CVAPIUtil getUserInfo];

                    if ([[userInfo objectForKey:@"key"] isEqualToString:_creatorKey])
                        [_arrayCollectionPickerUsers addObject:contactItem];
                }
            }
            
            //update setatus button
            [self updateStatusOfButtons];
        }
        
        [self showContactsByNameInTabularMode];
    }
    if ([_filter isEqualToString:CONTACT_TYPE_GROUP]) {
        [_groupModel updateWithFilter:CONTACT_TYPE_GROUP];
    } else {
        if ([_listType isEqualToString:CONTACT_LIST_TYPE_RESTRICTED_TASK]) {
            _model.listType = _listType;
            [_model.companyNames removeAllObjects];
            NSString* email = [((NSDictionary*)[CVAPIUtil getUserInfo]) objectForKey:@"email"];
            NSString* company = [email substringFromIndex:([email rangeOfString:@"@"].location + 1)];
            [_model.companyNames addObject:company];
        }
        _model.delegate = self;
        [_model updateWithType:_filter withSortBy:STREAM_LIST_SORT_OBJECT_LANG_SORT_KEY withOrder:STREAM_LIST_ORDER_ASC withSearchText:_searchText];
        [_searchTimer invalidate];
        
        NSDictionary* userInfo = @{SEARCH_TIMER_USERINFO_SEARCHTEXT_KEY: [_searchText copy]};
        _searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(tiggerSearchTimer:) userInfo:userInfo repeats:NO];
    }
}


- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    if (_model)
        [_model cancel];
    
}

- (void)handlePullToRefresh:(SVPullToRefreshView *)refreshView {
    [_model loadMore:NO];
}

- (void)loadMoreButtonTouched {
    [self showLoadMoreButtonLoading:YES];
    [_model loadMore:YES];
}


- (Class)cellClassForObject:(id)object {
    
    if ([object isKindOfClass:[CVContactPickerItem class]])
        return [CVContactPickerCell class];             // tabular mode row cell
    else if ([object isKindOfClass:[CVRowItem class]])
        return [CVRowItemCell class];         // tile mode row cell
    
    return [super cellClassForObject:object];
}


#pragma mark -
#pragma mark CVAPIModelDelegate

- (void)modelDidFinishLoad:(CVAPIRequestModel*)model action:(NSString*)action {
    
    if (model == _groupModel) {
        if (_groupModel.pageIdx == 0 && [_searchText isEqualToString:@""]) {
            [CVContactListSvcModel persistModel:_groupModel withId:[CVContactListSvcModel getCachedModelIdWithFilter:CONTACT_TYPE_GROUP withType:nil withSort:nil withContactKey:nil]];
        }
        if ([_groupModel hasMore]) {
            self.tableView.tableFooterView = self.loadMoreBoxView;
            self.loadMoreButton.left = (self.view.width - LOADMORE_BUTTON_WIDTH)/2;
            self.loadMoreButton.width = LOADMORE_BUTTON_WIDTH;
            
            [self showLoadMoreButtonLoading:NO];
            DLog(@"activityIndicator stopAnimating");
            
            
        } else {
            self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 10)];
        }
    } else {
        // cache the first page of _model
        if (_model.pageIdx == 0 && [_searchText isEqualToString:@""]) {
            if (!_taskItemForPingPicker)
                [CVContactListModel persistModel:_model withId:[CVContactListModel getCachedModelIdWithType:_filter withSort:STREAM_LIST_SORT_OBJECT_LANG_SORT_KEY withContactKey:nil withListType:nil]];
        }
        if ([_model hasMore]) {
            self.tableView.tableFooterView = self.loadMoreBoxView;
            self.loadMoreButton.left = (self.view.width - LOADMORE_BUTTON_WIDTH)/2;
            self.loadMoreButton.width = LOADMORE_BUTTON_WIDTH;
            
            [self showLoadMoreButtonLoading:NO];
            DLog(@"activityIndicator stopAnimating");
            
            
        } else {
            self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 10)];
        }
    }
    
    [self showContactsByNameInTabularMode];
}


#pragma mark -
#pragma mark private

- (void)loadDataWithTaskParticipants {
    NSMutableArray* userKeys = [NSMutableArray array];
    
    for (CVUserListItem* userItem in _taskItemForPingPicker.assignees) {
        if (userItem.isRegistered) {
            [userKeys addObject:userItem.key];
            
            //tmp fix
            CVContactItem* contactItem = [self toContactItemWithUserItem:userItem];
            [_model.items addObject:contactItem];
        }
    }
    
    for (CVUserListItem* userItem in _taskItemForPingPicker.ccers) {
        if (![userKeys containsObject:userItem.key] && userItem.isRegistered) {
            //tmp fix
            CVContactItem* contactItem = [self toContactItemWithUserItem:userItem];
            [_model.items addObject:contactItem];
        }
    }
    
    [self showContactsByNameInTabularMode];
}

//tmp fix
- (CVContactItem*)toContactItemWithUserItem:(CVUserListItem*)userItem {
    CVContactItem* contact = [[CVContactItem alloc] init];
    contact.key = userItem.key;
    contact.firstName = userItem.firstName;
    contact.lastName = userItem.lastName;
    contact.firstNameInEnglish = userItem.firstNameInEnglish;
    contact.lastNameInEnglish = userItem.lastNameInEnglish;
    contact.firstNamePronunciation = userItem.firstNamePronunciation;
    contact.lastNamePronunciation = userItem.lastNamePronunciation;
    contact.language = userItem.language;
    contact.isAlien = userItem.isAlien;
    contact.displayName = userItem.displayName;
    contact.key = userItem.key;
    contact.iconSmall = userItem.iconSmall;
    contact.iconMedium = userItem.iconMedium;
    contact.iconLarge = userItem.iconLarge;
    contact.iconTiny = userItem.iconTiny;
    contact.jobTitle = userItem.jobTitle;
    contact.company = userItem.company;
    contact.sharedTaskCount = userItem.sharedTaskCount;
    contact.mutualContactCount = userItem.mutualContactCount;
    contact.isRegistered = userItem.isRegistered;
    
    return contact;
}

- (NSMutableSet*)selectedKeys {
    return _model.selectedKeys;
}

- (void)cancel:(BOOL)confirmIfNecessary {
    if (confirmIfNecessary && _isModified) {
        [self confirmCancellation];
    } else {
        if (_addFolder) {
            [_popover dismissPopoverAnimated:YES];
        } else {
            if([_delegate respondsToSelector:@selector(pickerWillBeCanceled)] && ![_model.selectedKeys count]){
                [_delegate pickerWillBeCanceled];
            }
            if (_popover)
                [_popover dismissPopoverAnimated:YES];
            if ([self.navigationController.viewControllers count] > 1)
                [self.navigationController popViewControllerAnimated:YES];
            else
                [self popFromStack];
        }
    }
}

- (void)cancel {
    [self cancel:YES];
}

- (void) doneWithPicker {
    
    if (_addFolder) {
        _isModified = YES;
        [self cancel:YES];
    } else {
        if (_arrayCollectionPickerUsers.count > 0){
            [self handleResults];
            [self cancel:NO];
        } else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:LS(@"Select Contacts",@"") message:LS(@"Please select at least one participant.", @"") delegate:self cancelButtonTitle:LS(@"OK", @"") otherButtonTitles: nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            
            [alert show];
        }
    }
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


- (void)confirmCancellation {
    
    if (_sheetForCancel == nil) {
        
        _sheetForCancel = [[UIActionSheet alloc]init];
        _sheetForCancel.delegate = self;
        if (_addFolder) {
            _sheetForCancel.title = LS(@"Are you sure to add selected folders to engaged folder?", @"");
            
        } else {
            _sheetForCancel.title = LS(@"Are you sure you want to cancel?", @"");
        }
        [_sheetForCancel addButtonWithTitle:LS(@"Yes", @"")];
        [_sheetForCancel addButtonWithTitle:LS(@"No", @"")];
        _sheetForCancel.destructiveButtonIndex = 1;
    }
    
    [_sheetForCancel showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
}


-(void) showCachedContacts {
    
    [self getCachedModel];
    
    [self showContactsByNameInTabularMode];
}

-(void)getCachedModel{
    if (_taskItemForPingPicker){
        //[self loadDataWithTaskParticipants];//TODO: need to convert to use new api
    } else {
        NSMutableSet* tempSelectedKeys = _model.selectedKeys;
        _model = (CVContactListModel*)[CVContactListModel cachedModelWithId:[CVContactListModel getCachedModelIdWithType:_filter withSort:STREAM_LIST_SORT_OBJECT_LANG_SORT_KEY withContactKey:nil withListType:nil]];
        if (_model == nil)
            _model = [[CVContactListModel alloc] init];
        
        _model.delegate = self;
        
        _model.filter = _filter;
        _model.sortBy = STREAM_LIST_SORT_OBJECT_LANG_SORT_KEY;
        _model.order = STREAM_LIST_ORDER_ASC;
        _model.type = _listType;
        _model.selectedKeys = tempSelectedKeys;
        if ([_listType isEqualToString:CONTACT_LIST_TYPE_RESTRICTED_TASK]) {
            _model.listType = _listType;
        }
        
        _groupModel = (CVContactListSvcModel*)[CVContactListSvcModel cachedModelWithId:[CVContactListSvcModel getCachedModelIdWithFilter:CONTACT_TYPE_GROUP withType:nil withSort:nil withContactKey:nil]];
        if (_groupModel == nil)
            _groupModel = [[CVContactListSvcModel alloc] init];
        
        _groupModel.delegate = self;
    }
    
    if(_model.selectedKeys == nil)
        _model.selectedKeys = [NSMutableSet set];
}

- (void)showContactsByNameInTabularMode {
    
    NSMutableArray* sections = [NSMutableArray array];
    NSMutableArray* rows = [NSMutableArray array];
    
    NSMutableDictionary* groups = [NSMutableDictionary dictionary];
    NSMutableArray* items = [NSMutableArray array];
    if ([_filter isEqualToString:CONTACT_TYPE_GROUP])
        [items addObjectsFromArray:_groupModel.items];
    else
        [items addObjectsFromArray:_model.items];
    
    for (id object in items) {
        
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
                if (![_filter isEqualToString:CONTACT_TYPE_ADDRESSBOOK])
                    contact.icon = [user iconUrlOfSize:@"medium"];
                if (![[user getDisplayedName] isEqualToString:@"(null) (null)"])
                    contact.name = [user getDisplayedName];
                else
                    contact.name = user.displayName;
                contact.key = user.key;
                contact.contact = user;
                
#ifdef CV_TARGET_IPAD
                contact.title = user.jobTitle;
                contact.company = user.company;
                contact.sharedTasks = user.sharedTaskCount;
                contact.mutualContacts = user.mutualContactCount;
#endif
                if ([contact.key isEqualToString:self.selectedKey])
                    self.indexPathOfSelected = [NSIndexPath indexPathForRow:[rowsInSection count] inSection:[sections count]];
                
                //turn on checked mark
                if ([_model.selectedKeys containsObject:contact.key]) {
                    contact.checked = YES;
                    contact.forbiddenSelecting = YES;
                    //[_recipients addObject:user];
                }
                
                [rowsInSection addObject:contact];
            }
            else {
                CVContactGroupItem* user = (CVContactGroupItem*)obj;
                
                CVContactPickerItem* contact = [[CVContactPickerItem alloc] init];
                if (![_filter isEqualToString:CONTACT_TYPE_ADDRESSBOOK])
                    contact.icon = @"sm-group.png";
                contact.name = user.name;
                contact.key = user.key;
                contact.contact = user;
                if ([contact.key isEqualToString:self.selectedKey])
                    self.indexPathOfSelected = [NSIndexPath indexPathForRow:[rowsInSection count] inSection:[sections count]];
                
                //turn on checked mark
                if ([_model.selectedKeys containsObject:contact.key]) {
                    contact.checked = YES;
                    //[_recipients addObject:user];
                    contact.forbiddenSelecting = YES;
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
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.allowsSelection = YES;
    self.tableView.frame = CGRectMake(0, self.searchBarButton.bottom, self.tableView.width, self.view.height - 135);
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [self.pullToRefreshView performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
    
    [_imageCollectionView reloadData];
    if (_arrayCollectionPickerUsers.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_arrayCollectionPickerUsers.count-1 inSection:0];
        [_imageCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
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
    NSString* confirmTitle = _addPeople ? LS(@"Add", @"") : LS(@"Select", @"");
    NSString* confirmTitleWithCount = [NSString stringWithFormat:@"%@ (%d)", confirmTitle, [_model.selectedKeys count]];
    [_confirmItem setTitle:confirmTitleWithCount forState:UIControlStateNormal];
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
        else if ([selectedOption isEqualToString:TYPE_OPTION_ADDBOOK])
            filter = CONTACT_TYPE_ADDRESSBOOK;
        else
            filter = CONTACT_TYPE_ALL;
        
        if ([_filter isEqualToString:filter])
            return;
        
        _filterItem.title = LS([filter capitalizedString], @"");
        _filter = filter;
        self.selectedKey = @"";
        [self popTopViewControllers];
        [self showCachedContacts];
        if ([_filter isEqualToString:CONTACT_TYPE_GROUP]) {
            [_groupModel updateWithFilter:CONTACT_TYPE_GROUP];
        } else {
            [_searchTimer invalidate];
            
            NSDictionary* userInfo = @{SEARCH_TIMER_USERINFO_SEARCHTEXT_KEY: [_searchText copy]};
            _searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(tiggerSearchTimer:) userInfo:userInfo repeats:NO];
        }
        return;
    } else if ( actionSheet == _sheetForCancel) {
        
        if (buttonIndex == actionSheet.cancelButtonIndex || buttonIndex == actionSheet.destructiveButtonIndex)
            [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
        else {
            if (_addFolder) {
                [self handleResults];
#ifdef CV_TARGET_IPAD
                [_popover dismissPopoverAnimated:YES];
#else
                [self popFromStack];
#endif
            } else {
                [_delegate pickerWillBeCanceled];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
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
    NSDictionary* userInfo = [CVAPIUtil getUserInfo];

    if (!item.forbiddenSelecting || [[userInfo objectForKey:@"key"] isEqualToString:_creatorKey]){
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
                
                int pickerCountBeforeAddSelected = [_arrayCollectionPickerUsers count];
                [_arrayCollectionPickerUsers addObject:userInfo];
                
                NSMutableArray *arrayWithIndexPathsAfterAdded = [NSMutableArray array];
                for (int i = pickerCountBeforeAddSelected; i < pickerCountBeforeAddSelected + 1; i++)
                    [arrayWithIndexPathsAfterAdded addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                
                // asyn update collection view
                [_imageCollectionView insertItemsAtIndexPaths:arrayWithIndexPathsAfterAdded];
            }
            else {
                // if checked is nil, we still need compare with key
                NSMutableArray *arrayWithIndexPathsOfDeletingItem = [NSMutableArray array];
                
                for (int i=0; i < [_arrayCollectionPickerUsers count]; i++){
                    NSString* key = [self keyOfUserInfo:[_arrayCollectionPickerUsers objectAtIndex:i]];
                    if ([item.key isEqualToString:key]){
                        [_arrayCollectionPickerUsers removeObjectAtIndex:i];
                        [arrayWithIndexPathsOfDeletingItem addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                }
                // asyn update collection view
                [_imageCollectionView deleteItemsAtIndexPaths:arrayWithIndexPathsOfDeletingItem];
                
                [_recipients removeObjectForKey:item.key];
            }
        }
        
        // scroll to the position of collection view
        if (_arrayCollectionPickerUsers.count > 0) {
            NSIndexPath *indexPathForCollection = [NSIndexPath indexPathForRow:_arrayCollectionPickerUsers.count-1 inSection:0];
            [_imageCollectionView scrollToItemAtIndexPath:indexPathForCollection atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        }

    }
    
}


#pragma mark - private

- (NSString*)keyOfUserInfo:(id)userInfo {
    
    NSString* key = nil;
    if ([userInfo isKindOfClass:[CVContactItem class]])
        key = [(CVContactItem*)userInfo key];
    else if ([userInfo isKindOfClass:[CVContactGroupItem class]])
        key = [(CVContactGroupItem*)userInfo key];
    return key;
}

- (UISearchBar*) searchBarButton{
    if (!_searchBarButton) {
        _searchBarButton = [[UISearchBar alloc] initWithFrame:CGRectMake(0, self.topBar.bottom, self.view.width , 44)];
        _searchBarButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _searchBarButton;
}

- (UIButton *)addEmailButton {
    if (nil == _addEmailButton) {
        _addEmailButton = [[UIButton alloc] init];
        [_addEmailButton setTitle:LS(@"Add", @"") forState:UIControlStateNormal];
        
        [_addEmailButton addTarget:self action:@selector(addToSelectedButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _addEmailButton;
}

- (void)makeSearchBar:(UISearchBar *)searchBar showAddButtonAtRightSide:(BOOL)show {
    [searchBar setShowsCancelButton:show animated:YES];
    
    if (show) {
        if (getOSf() >= 7.f) {
            [searchBar.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger index, BOOL *stop) {
                [subview.subviews enumerateObjectsUsingBlock:^(UIView *sub, NSUInteger idx, BOOL *stp) {
                    if ([sub isKindOfClass:[UIButton class]] && ![sub isEqual:_addEmailButton]) {
                        UIButton *cancelButton = (UIButton *)(sub);
                        
                        [self.addEmailButton setFrame:cancelButton.frame];
                        [subview addSubview:_addEmailButton];
                        
                        [cancelButton removeFromSuperview];
                        
                        (*stop) = (*stp) = YES;
                    }
                }];
            }];
        } else {
            [searchBar.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger index, BOOL *stop) {
                if ([subview isKindOfClass:[UIButton class]] && ![subview isEqual:_addEmailButton]) {
                    UIButton *cancelButton = (UIButton *)(subview);
                    
                    [self.addEmailButton setFrame:cancelButton.frame];
                    
                    [cancelButton removeFromSuperview];
                    [cancelButton setTitle:@"" forState:UIControlStateNormal];
                    cancelButton.userInteractionEnabled = NO;
                    [cancelButton setFrame:CGRectZero];
                    
                    [searchBar addSubview:_addEmailButton];
                    
                    (*stop) = YES;
                }
            }];
        }
    }
    
    _addEmailButton.hidden = !show;
}

- (void)addToSelectedButtonTouched:(UIButton *)button {
    //NSLog(@"Search input : ^%@$", _searchText);
    
    ////_searchText should be inputted email string
    NSString *email = [_searchText copy];
    if (![email isValidEmail]) {
        return;
    }
    
    NSString *displayName = [email substringToIndex:[email rangeOfString:@"@"].location];
    NSString *key = email;
    
    CVContactItem *contactItem = [[CVContactItem alloc] init];
    contactItem.key = [CVAPIUtil getValidString:key];
    contactItem.firstName = @"";
    contactItem.lastName = @"";
    contactItem.firstNameInEnglish = @"";
    contactItem.lastNameInEnglish = @"";
    contactItem.displayName = [CVAPIUtil getValidString:displayName];
    contactItem.contactType = CONTACT_TYPE_INPUTEMAIL;
    contactItem.email = email;
    
    CVContactPickerItem *contact = [[CVContactPickerItem alloc] init];
    contact.icon = [contactItem iconUrlOfSize:@"medium"];
    contact.name = displayName;
    contact.key = key;
    contact.contact = contactItem;
    
    //turn on checked mark
    if ([_model.selectedKeys containsObject:contact.key]) {
        contact.checked = YES;
        //[_recipients addObject:user];
    } else {
        [_model.selectedKeys addObject:contactItem.key];
        
        if (nil == [_recipients objectForKey:contactItem.key]) {
            [_recipients setObject:contactItem forKey:contactItem.key];
            
            int pickerCountBeforeAddSelected = [_arrayCollectionPickerUsers count];
            [_arrayCollectionPickerUsers addObject:contactItem];
            
            NSArray *insertedIndexPaths = @[[NSIndexPath indexPathForRow:pickerCountBeforeAddSelected inSection:0]];
            
            // asyn update collection view
            [_imageCollectionView insertItemsAtIndexPaths:insertedIndexPaths];
        }
    }
    
    //update _statusButton
    [self updateStatusOfButtons];
    
    _searchBarButton.text = @"";
    [self makeSearchBar:_searchBarButton showAddButtonAtRightSide:NO];
    
    _searchText = @"";
    [_searchTimer invalidate];
    _searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.f target:self selector:@selector(tiggerSearchTimer:) userInfo:@{SEARCH_TIMER_USERINFO_SEARCHTEXT_KEY: @""} repeats:NO];
}

#pragma mark -
#pragma mark Public
static UIPopoverController* _popover = nil;
+ (void)presentPickerInPopoverFromBarButtonItem:(UIBarButtonItem *)item withTaskItem:(CVTaskSvcItem*)taskItem withDelegate:(id<ContactPickerDelegate>)fvc {
    
    IPhoneMVContactPickerViewController* vc = [[IPhoneMVContactPickerViewController alloc] initPingPickerWithTask:taskItem];
    vc.delegate = fvc;
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    if (_popover) {
        [_popover dismissPopoverAnimated:NO];
    }
    
    _popover = [[UIPopoverController alloc] initWithContentViewController:nav];
    [_popover presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

+ (void)presentPickerInPopoverFromRect:(CGRect)rect inView:(UIView*)view withTaskItem:(CVTaskSvcItem*)taskItem withDelegate:(id<ContactPickerDelegate>)fvc{
    
    IPhoneMVContactPickerViewController* vc = [[IPhoneMVContactPickerViewController alloc] initPingPickerWithTask:taskItem];
    vc.delegate = fvc;
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    if (_popover) {
        [_popover dismissPopoverAnimated:NO];
    }
    
    _popover = [[UIPopoverController alloc] initWithContentViewController:nav];
    [_popover presentPopoverFromRect:rect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

+ (void)presentPickerInPopoverFromRect:(CGRect)rect inView:(UIView*)view withOptions:(NSArray*)options forAndFolder:(BOOL)addFolder withDelegate:(id<ContactPickerDelegate>)fvc {
    
    IPhoneMVContactPickerViewController* vc = [[IPhoneMVContactPickerViewController alloc] initWithOptions:options forAddFolder:YES];
    vc.delegate = fvc;
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    if (_popover) {
        [_popover dismissPopoverAnimated:NO];
    }
    
    _popover = [[UIPopoverController alloc] initWithContentViewController:nav];
    [_popover presentPopoverFromRect:rect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

+ (void)presentPickerInPopoverFromRect:(CGRect)rect inView:(UIView*)view withOptions:(NSArray*)options withRecipients:(NSArray*)initialRecipients withDelegate:(id<ContactPickerDelegate>)fvc {
    IPhoneMVContactPickerViewController* vc = [[IPhoneMVContactPickerViewController alloc] initWithRecipients:initialRecipients forAddPeople:YES withOptions:options];
    vc.delegate = fvc;
    //    vc.addFolder = YES;
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


#pragma mark -
#pragma mark NSTimer

- (void)tiggerSearchTimer:(NSTimer *)timer {
    if ([_searchTimer isEqual:timer]) {
        [_model cancel];
        _model.delegate = self;
        NSString* searchText = [timer.userInfo objectForKey:SEARCH_TIMER_USERINFO_SEARCHTEXT_KEY];
        [_model updateWithType:_filter withSortBy:STREAM_LIST_SORT_OBJECT_LANG_SORT_KEY withOrder:STREAM_LIST_ORDER_ASC withSearchText:searchText];
        
        [_searchTimer invalidate];
        _searchTimer = nil;
    }
}


# pragma mark -
# pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString* text = searchBar.text;
    
    NSTimeInterval timerInterval = SEARCH_TIMER_TIMEINTERVAL;
    
    if (0 == text.length) {     // if text is nil or @"", hide "add" button
        [self makeSearchBar:searchBar showAddButtonAtRightSide:NO];
        timerInterval = 0.0;    // if text is nil or @"", load model immediately
    } else {
        [self makeSearchBar:searchBar showAddButtonAtRightSide:[text isValidEmail]];
    }
    
    _searchText = text;
    
    NSDictionary* userInfo = @{SEARCH_TIMER_USERINFO_SEARCHTEXT_KEY: text};
    
    if (nil != _searchTimer) {
        if ([_searchTimer isValid]) {
            [_searchTimer invalidate];
            _searchTimer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(tiggerSearchTimer:) userInfo:userInfo repeats:NO];
        }
    } else {
        _searchTimer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(tiggerSearchTimer:) userInfo:userInfo repeats:NO];
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [_searchBarButton resignFirstResponder];
    _searchBarButton.text = nil;
    [self searchBar:_searchBarButton textDidChange:_searchBarButton.text];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_searchBarButton resignFirstResponder];
    
    [self makeSearchBar:searchBar showAddButtonAtRightSide:[searchBar.text isValidEmail]];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
#ifdef CV_TARGET_IPHONE
    _searchBarButton.showsCancelButton = YES;
#else
    //reload table view
    [_imageCollectionView reloadData];
#endif
}


# pragma mark -
# pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* key = [self keyOfUserInfo:[_arrayCollectionPickerUsers objectAtIndex:indexPath.row]];
    
    BOOL didFindTheItemInTable = NO;
    for (int i = 0; i < self.rows.count; i++) {
        for (int j = 0; j < [[self.rows objectAtIndex:i] count]; j++) {
            CVContactPickerItem* item = [[self.rows objectAtIndex:i] objectAtIndex:j];
            if ([item.key isEqualToString:key]) {
                didFindTheItemInTable = YES;
                
                item.checked = !item.checked;
                if ([_model.selectedKeys containsObject:item.key]){
                    [_model.selectedKeys removeObject:item.key];
                }
                [_recipients removeObjectForKey:item.key];
            }
            
        }
    }
    
    if (!didFindTheItemInTable) {
        if ([_model.selectedKeys containsObject:key]) {
            [_model.selectedKeys removeObject:key];
        }
        
        [_recipients removeObjectForKey:key];
    }
    
    [_arrayCollectionPickerUsers removeObjectAtIndex:indexPath.row];
    
    // update the selected cell
    [self.tableView reloadData];
    
    // asyn update collection view
    NSMutableArray *arrayWithIndexPathsOfDeletingItem = [NSMutableArray array];
    [arrayWithIndexPathsOfDeletingItem addObject:indexPath];
    [_imageCollectionView deleteItemsAtIndexPaths:arrayWithIndexPathsOfDeletingItem];
    
    //update _statusButton
    [self updateStatusOfButtons];
}

#pragma mark -
#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(30.f, 30.f);
    
    if (collectionView == _imageCollectionView) {
        id item = [_arrayCollectionPickerUsers objectAtIndex:indexPath.item];
        
        if ([item respondsToSelector:@selector(contactType)]) {
            NSString *contactType = [item contactType];
            
            if ([contactType isEqualToString:CONTACT_TYPE_INPUTEMAIL]) {
                size.width = [CVContactPickerLiteralCollectionCell sizeForObject:item].width + 10.f;
            }
        }
    }
    
    return size;
}


# pragma mark -
# pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_arrayCollectionPickerUsers count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id item = [_arrayCollectionPickerUsers objectAtIndex:indexPath.item];
    
    if ([item respondsToSelector:@selector(contactType)]) {
        NSString *contactType = [item contactType];
        
        if ([contactType isEqualToString:CONTACT_TYPE_INPUTEMAIL]) {
            CVContactPickerLiteralCollectionCell *literalCell = [collectionView dequeueReusableCellWithReuseIdentifier:CONTACT_TYPE_INPUTEMAIL forIndexPath:indexPath];
            if (nil == literalCell) {
                literalCell = [[CVContactPickerLiteralCollectionCell alloc] init];
            }
            
            [literalCell setObject:(CVContactItem *)(item)];
            
            return literalCell;
        }
    }
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"selectingCollectionViewCell" forIndexPath:indexPath];
    if (nil == cell) {
		cell = [[CVContactPickerImageCollectionCell alloc] init];
    }
    
    [self.tableView reloadData];
    
    if ([item isKindOfClass:[CVContactGroupItem class]]) {
        CVContactGroupItem *groupItem = (CVContactGroupItem *)(item);
        ((CVContactPickerImageCollectionCell *)cell).collectionImageView.letterView.text = groupItem.name;
    } else {
        if (![_filter isEqualToString:CONTACT_TYPE_ADDRESSBOOK]) {
            [((CVContactPickerImageCollectionCell *)cell).collectionImageView setIconWithUser:(CVContactItem*)item];
        } else {
            [((CVContactPickerImageCollectionCell *)cell).collectionImageView setIconWithUrlPath:nil displayName:[(CVContactItem*)item displayName]];
        }
    }
    
    return cell;
}

@end
