//
//  IPhoneMVChatEditViewController.m
//  Vmoso
//
//  Created by Daniel Kong on 1/16/14.
//  Copyright (c) 2014 Broadvision. All rights reserved.
//

#import "IPhoneMVChatEditViewController.h"
#import "CVTaskEditViewController.h"
#import "CVContactPickerViewController.h"
#import "CVRTEViewController.h"
#import "TaskFormDatePickerViewController.h"
#import "NSArray+DragonAPIUserList.h"
#import "NSDictionary+DragonAPI.h"
#import "NSDictionary+DragonAPIUser.h"
#import "NSDictionary+DragonAPITask.h"
#import "CVTaskNameCell.h"
#import "CVStampsTableViewCell.h"
#import "CVContactStampCell.h"
#import "CVAttributedTextCell.h"
#import "CVOptionCell.h"
#import "NSDictionary+DragonAPIUser.h"
#import "NSDictionary+DragonAPIFile.h"
#import "CVFilePickerViewController.h"
#import "CVTaskViewController.h"
#import "CVCommentsViewController.h"
#import "CVTaskModel.h"
#import "CVTaskDetailViewController.h"
#import "CVChatViewController.h"
#import "CVPageSectionHeaderView.h"
#import "CVNamedIcon.h"

#import "IPhoneMVRTEViewController.h"
#import "IPhoneMVContactPickerViewController.h"

#define PAGE_WIDTH  500
#define OPTIONS_FONT      [UIFont fontWithName:@"Helvetica-Bold" size:17]
#define OPTIONS_COLOR   [UIColor colorWithRed:0.298039 green:0.337255 blue:0.423529 alpha:1.0]

#define SAVE_TYPE_TASK          @"task"

#define TASK_VIEW_BUTTON_WIDTH  200
#define TASK_VIEW_BUTTON_HEIGHT 40
#define BG_COLOR            RGBCOLOR(233,233,233)


static UIPopoverController* _popover = nil;             // main popover
static NSMutableDictionary* cachedTaskData = nil;

@interface IPhoneMVChatEditViewController () <CVAPIModelDelegate, UIActionSheetDelegate, CVDescViewDelegate, ContactPickerDelegate, UIAlertViewDelegate, CVStampsTableViewCellDelegate>

@property(nonatomic, retain) CVTaskModel* taskModel;
@property(nonatomic, assign) BOOL addPeople;
@property(nonatomic, assign) BOOL toEdit;
@property(nonatomic, assign) UITableViewCell* selectedCell;
@property(nonatomic, retain) NSArray* fields;
@property(nonatomic, retain) NSArray* fieldTitles;
@property(nonatomic, retain) UIBarButtonItem* cancelItem;
@property(nonatomic, retain) UIBarButtonItem* saveItemForAddPeople;
@property(nonatomic, retain) UIBarButtonItem* saveItem;
@property(nonatomic, assign) BOOL isDetailPage;
//@property(nonatomic, retain) UITableView* tableView;
@property(nonatomic, retain) NSMutableDictionary* taskData;
@property(nonatomic, retain) CVTaskNameCell* titleCell;
@property(nonatomic, retain) CVStampsTableViewCell* assigneesCell;
@property(nonatomic, retain) CVUserListItem* collectionContactItemForAssignees;
@property(nonatomic, retain) NSMutableArray* collectionContactArrayForAssignees;
@property(nonatomic, retain) CVAttributedTextCell* descCell;
@property(nonatomic, retain) UIActionSheet* sheetForType;
@property(nonatomic, retain) UIActionSheet* sheetForSaveAs;

@property(nonatomic, retain) NSArray* typeOptions;
@property(nonatomic, retain) NSString* updatedDesc;
@property(nonatomic, retain) NSArray* updatedAssignees;
@property(nonatomic, retain) NSArray* updatedAssigneesInitial;
@property(nonatomic, retain) NSMutableArray* addedAssignees;
@property(nonatomic, retain) UIActivityIndicatorView* activityIndicator;

@property(nonatomic, retain) NSMutableArray* optionsCell;
@property(nonatomic, retain) NSString* action;

@property(nonatomic, retain) UIButton* taskViewButton;

@end

@implementation IPhoneMVChatEditViewController

- (id) initWithData:(NSDictionary*)data forAddPeople:(BOOL)addPeople {

    if (self) {
        
        _addPeople = addPeople;
        _toEdit = (data != nil);
        if (!_toEdit) {
            _taskData = (cachedTaskData != nil) ? [NSMutableDictionary dictionaryWithDictionary:cachedTaskData] : [NSMutableDictionary dictionary];
            cachedTaskData = [NSMutableDictionary dictionary];
        }
        else
            _taskData = [NSMutableDictionary dictionaryWithDictionary:data];
        _taskModel = [[CVTaskModel alloc] initWithKey:[_taskData objectForKey:@"key"]];
        _taskModel.delegate = self;
        self.isDetailPage = NO;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = RGBCOLOR(233, 233, 233);
        
        //self.tableView.allowsSelection = NO;
        
        self.title = _toEdit ? LS(@"Quick Edit", @"") : LS(@"Create Chat", @"");
        
        self.contentSizeForViewInPopover = CGSizeMake(PAGE_WIDTH, 1000);
        self.modalInPopover = YES;
        
        // Cancel button item on the left
        _cancelItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Cancel", @"")
                                                       style:UIBarButtonSystemItemCancel
                                                      target:self
                                                      action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = _cancelItem;
        
        // post button item to be used later
        _saveItemForAddPeople = [[UIBarButtonItem alloc] initWithTitle:LS(@"Save", @"")
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self
                                                                action:@selector(saveWithOption:)];
        
        _saveItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Save", @"")
                                                     style:UIBarButtonSystemItemSave
                                                    target:self
                                                    action:@selector(saveItemTouched)];
        if (_addPeople && [[_taskData objectForKey:@"canAddByTo"] intValue] ==1)
            self.navigationItem.rightBarButtonItem = _saveItemForAddPeople;
        else if (!_addPeople)
            self.navigationItem.rightBarButtonItem = _saveItem;
        
        // add margin at the top
        //self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 30)];
        
        // place the task view button in the footer view of tableView
        
        //        UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, TASK_VIEW_BUTTON_HEIGHT + 20)];
        //        footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //
        //        _taskViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [_taskViewButton setTitle:LS(@"Full Task", @"") forState:UIControlStateNormal];
        //        [_taskViewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //        [_taskViewButton setBackgroundImage:[UIImage imageNamed:@"button_grad.png"] forState:UIControlStateNormal];
        //        [_taskViewButton setBackgroundColor:[UIColor whiteColor]];
        //        _taskViewButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        //        _taskViewButton.frame = CGRectMake((footerView.width - TASK_VIEW_BUTTON_WIDTH)/2, 20, TASK_VIEW_BUTTON_WIDTH, TASK_VIEW_BUTTON_HEIGHT);
        //        [_taskViewButton addTarget:self action:@selector(taskViewButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        //        _taskViewButton.layer.cornerRadius = 3;
        //        _taskViewButton.layer.masksToBounds = YES;
        //
        //        [footerView addSubview:_taskViewButton];

        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 1)];
    
    }
    
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topBar.hidden = NO;

    NSString* titleValue = [_taskData taskName];
    
    _updatedDesc = [_taskData taskDescription];
    _updatedAssignees = [_taskData taskAssignees];
    _updatedAssigneesInitial = [_taskData taskAssignees];
    _addedAssignees = [NSMutableArray array];
    
    if (!_addPeople) {
        _titleCell = [[CVTaskNameCell alloc] init];
        _titleCell.backgroundColor = BG_COLOR;
        [_titleCell setValue:titleValue];
    }
    
    CGSize stampSize = isIPAD() ? CGSizeMake(70, 105) : CGSizeMake(40, 40);
    _collectionContactItemForAssignees = [[CVUserListItem alloc] init];
    _collectionContactArrayForAssignees = [NSMutableArray array];
    [_collectionContactArrayForAssignees addObject:@"Add For Assignees"];
    for (NSDictionary* temp in _updatedAssignees){
        _collectionContactItemForAssignees = [CVUserListItem userListItemWithDictionary:temp];
        [_collectionContactArrayForAssignees addObject:_collectionContactItemForAssignees];
    }
    _assigneesCell = [[CVStampsTableViewCell alloc] init];
    CGRect defaultRect = CGRectMake(0, 0, self.view.width, 0);
    _assigneesCell = [[CVStampsTableViewCell alloc] initWithFrame:defaultRect];
    _assigneesCell.frame = isIPAD()? CGRectMake(0, 0, 6 * 75 + 30, stampSize.height + 10*2): CGRectMake(0, 0, self.tableView.frame.size.width - 10, stampSize.height + 10*2);
    
    _assigneesCell.insects = UIEdgeInsetsMake(10,10, 10, 0);
    _assigneesCell.items = _collectionContactArrayForAssignees;
    _assigneesCell.stampSize = stampSize;
    _assigneesCell.stampSpacing = 10;
    _assigneesCell.delegate = self;
    _assigneesCell.backgroundColor = BG_COLOR;
    [_assigneesCell registerStampClass:[CVContactStampCell class] forCellWithReuseIdentifier:@"contact"];
    
    if (!_addPeople) {
        
        _descCell = [[CVAttributedTextCell alloc] init];
        _descCell.backgroundColor = BG_COLOR;
        [_descCell setValue:_updatedDesc];
        
    }
    _optionsCell = [NSMutableArray array];
    [self loadFormCells];
    
    CVPageSectionHeaderView* header = [[CVPageSectionHeaderView alloc] initWithFrame:defaultRect];
    header.title = LS(@"Title", @"");
    NSMutableArray* sections = [NSMutableArray arrayWithObject:header];
    
    CVPageSectionHeaderView* descSection = [[CVPageSectionHeaderView alloc] initWithFrame:defaultRect];
    descSection.title = LS(@"Chat With", @"");
    [sections addObject:descSection];

    CVPageSectionHeaderView* participantHeader = [[CVPageSectionHeaderView alloc] initWithFrame:defaultRect];
    participantHeader.title = LS(@"Description", @"");
    [sections addObject:participantHeader];
    
    CVPageSectionHeaderView* optionsHeader = [[CVPageSectionHeaderView alloc] initWithFrame:defaultRect];
    optionsHeader.hidden = YES;
    optionsHeader.title = LS(@"Options", @"");
    [sections addObject:optionsHeader];
    
    self.sectionHeaders = sections;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.title = _toEdit ? LS(@"Quick Edit", @"") : LS(@"Create Chat", @"");
    
    if (_addPeople && [[_taskData objectForKey:@"canAddByTo"] intValue] ==1) {
        [self.topBar.rightButton setTitle:@"Save" forState: UIControlStateNormal];
        self.topBar.rightButton.frame = CGRectMake(266, self.topBar.rightButton.top, self.topBar.rightButton.width, self.topBar.rightButton.height);
        self.topBar.rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.topBar.rightButton addTarget:self action:@selector(saveWithOption:) forControlEvents:UIControlEventTouchUpInside];
    } else if (!_addPeople) {
        [self.topBar.rightButton setTitle:@"Save" forState: UIControlStateNormal];
        self.topBar.rightButton.frame = CGRectMake(266, self.topBar.rightButton.top, self.topBar.rightButton.width, self.topBar.rightButton.height);
        self.topBar.rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.topBar.rightButton addTarget:self action:@selector(saveItemTouched) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (cachedTaskData)
        [cachedTaskData setObject:[_titleCell getValue] forKey:@"name"];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_fields count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == [_fields count] -1 && !_addPeople)
        return [[_fields objectAtIndex:section] count];
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == [_fields count] -1 && !_addPeople)
        return [[_fields objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    return [_fields objectAtIndex:indexPath.section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_fieldTitles objectAtIndex:section];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CVBaseFieldCell* cell = [_fields objectAtIndex:indexPath.section];
    if ([cell isKindOfClass:[CVBaseFieldCell class]]) {
        return [cell fieldHeightInTableView:tableView]; }
    if ([cell isKindOfClass:[CVStampsTableViewCell class]]) {
        if ([((CVStampsTableViewCell*)cell).items count] > 0) {
            return isIPAD() ? 130: 60;
        }
    }
    return 90;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if "Save" has started, do nothing
    if (_activityIndicator != nil)
        return;
    
    _selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    UIViewController* controller = nil;
    
    if (_selectedCell == _descCell) {
        
        controller = [[IPhoneMVRTEViewController alloc] initWithText:_updatedDesc];
        ((IPhoneMVRTEViewController*)controller).delegate = self;
        [controller pushToStack];
        
    } else if ([_selectedCell isKindOfClass:[CVOptionCell class]]) {
        [(CVOptionCell*)_selectedCell toggleButtonText];
    }
    
    if (controller)
        [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark -
#pragma mark CVDescViewDelegate

-(void) descTextChanged:(NSString*)text {
    _updatedDesc = text;
    [_descCell setValue:text];
    [self.tableView reloadData];
    
    [cachedTaskData setObject:_updatedDesc forKey:@"description"];
}

#pragma mark -
#pragma mark IPadPickerDelegate

-(void)recipientsChanged:(NSArray*)recipients {
    
    if (_selectedCell == _assigneesCell && !_addPeople) {
        _updatedAssignees = recipients;
        [_collectionContactArrayForAssignees removeAllObjects];
        [_collectionContactArrayForAssignees addObject:@"Add For Assignees"];
        for (NSDictionary* temp in _updatedAssignees){
            _collectionContactItemForAssignees = [CVUserListItem userListItemWithDictionary:temp];
            [_collectionContactArrayForAssignees addObject:_collectionContactItemForAssignees];
        }
        _assigneesCell.items = _collectionContactArrayForAssignees;
        [_assigneesCell.stampsView reloadData];
    } else if (_selectedCell == _assigneesCell && _addPeople && _addedAssignees) {
        _addedAssignees = (NSMutableArray*)recipients;
        for (NSDictionary* tempDictForNewRecipient in recipients){
            for (NSDictionary* tempDictForNewUpdateAssignes in _updatedAssigneesInitial){
                if ([[tempDictForNewRecipient objectForKey:@"key"] isEqualToString:[tempDictForNewUpdateAssignes objectForKey:@"key"]])
                    [_addedAssignees removeObject:tempDictForNewRecipient];
            }
        }
        NSMutableArray* combined = [NSMutableArray arrayWithArray:_updatedAssigneesInitial];
        [combined addObjectsFromArray:_addedAssignees];
        _updatedAssignees = combined;
        [_collectionContactArrayForAssignees removeAllObjects];
        [_collectionContactArrayForAssignees addObject:@"Add For Assignees"];
        for (NSDictionary* temp in combined){
            _collectionContactItemForAssignees = [CVUserListItem userListItemWithDictionary:temp];
            [_collectionContactArrayForAssignees addObject:_collectionContactItemForAssignees];
        }
        _assigneesCell.items = _collectionContactArrayForAssignees;
        [_assigneesCell.stampsView reloadData];
    } else
        ;
    [self.tableView reloadData];
    
    [cachedTaskData setObject:_updatedAssignees forKey:@"assignees"];
    
}

- (void)pickerWillBeCanceled {
    
}

#pragma mark - CVStampsTableViewCellDelegate

- (void)stampsTableViewCell:(CVStampsTableViewCell*)cell didSelectAt:(NSInteger)index {
    
    [_titleCell.nameField resignFirstResponder];
    
    id object = [cell.items objectAtIndex:index];
    NSArray* initialAssignees = [NSArray array];
    if ([object isKindOfClass:[NSString class]]) {
        if ([((NSString*)object) isEqualToString:@"Add For Assignees"]){
            _selectedCell = _assigneesCell;
            initialAssignees = _addPeople ? _addedAssignees : _updatedAssignees;
        }
        
        IPhoneMVContactPickerViewController* controller = [[IPhoneMVContactPickerViewController alloc] initWithRecipients:initialAssignees forAddPeople:NO withOptions:@[TYPE_OPTION_ALL, TYPE_OPTION_TRUSTED, TYPE_OPTION_CONNECTED, TYPE_OPTION_ENGAGED, TYPE_OPTION_ACQUAINTANCE, TYPE_OPTION_GROUP, TYPE_OPTION_ADDBOOK]];
        ((IPhoneMVContactPickerViewController*)controller).delegate = self;
        ((IPhoneMVContactPickerViewController*)controller).placeHolder = LS(@"Member:", @"");

        if (controller)
            [controller pushToStack];
    }
    return;
}


#pragma mark - CVAPIModelDelegate

- (void)modelDidSucceedWithResult:(NSDictionary *)result model:(CVAPIRequestModel *)model action:(NSString *)action {
    [CVAPIUtil alertMessage:@"Added people successfully!"];
    [self cancel:NO];
}

- (void)modelDidFailWithError:(NSError *)error model:(CVAPIRequestModel *)model action:(NSString *)action {
    [CVAPIUtil alertMessage:@"Task action failed!"];
}

#pragma mark -
#pragma mark private

- (void)loadFormCells {
    
    [_optionsCell removeAllObjects];
    
    //    NSArray* optionArrayToUse = @[LS(@"High Priority", @""), LS(@"Can Add Participants",@""), LS(@"Allow Task Reuse",@""), LS(@"Allow Editing of Comments",@"")];
    //    NSString* taskKey = [_taskData objectForKey:@"taskKey"];
    //    if (!taskKey) {
    //        for (NSString* string in optionArrayToUse) {
    //            CVOptionCell* cell = [[CVOptionCell alloc] initWithTitle:string];
    //            if ([string isEqualToString:LS(@"High Priority", @"")] || [string isEqualToString:LS(@"Allow Task Reuse", @"")])
    //                cell.statusLable.text = LS(@"No", @"");
    //            else
    //                cell.statusLable.text = LS(@"Yes", @"");
    //            [_optionsCell addObject:cell];
    //        }
    //    }
    //    else {
    //        Task* task = [Task taskWithUniqueId:taskKey inManagedObjectContext:[[DataStore sharedDataStore] managedObjectContext]];
    //        NSArray* valueArrayToUse = [NSArray arrayWithObjects:([task.flag isEqualToString:@"important"]?@"Yes":@"No"), (task.canAddTo?@"Yes":@"No"), (task.taskReuse?@"Yes":@"No"), (task.editComment?@"Yes":@"No"), nil];
    //        for (NSUInteger index = 0; index < [optionArrayToUse count]; index++) {
    //            NSString* string = [optionArrayToUse objectAtIndex:index];
    //            NSString* value = [valueArrayToUse objectAtIndex:index];
    //            CVOptionCell* cell = [[CVOptionCell alloc] initWithTitle:string];
    //            cell.statusLable.text = LS(value, @"");
    //            [_optionsCell addObject:cell];
    //        }
    //    }
    
    if (_addPeople && [[_taskData objectForKey:@"canAddByTo"] intValue] ==1) {
        _fields = [NSArray arrayWithObjects:_assigneesCell, nil];
        _fieldTitles = [NSArray arrayWithObjects:LS(@"Chat with", @""), nil];
    } else {
        _fields = [NSArray arrayWithObjects: _titleCell, _assigneesCell, _descCell, _optionsCell, nil];
        _fieldTitles = [NSArray arrayWithObjects:LS(@"Title", @""), LS(@"Chat with", @""), LS(@"Description", @""), LS(@"",@""), nil];
    }
    
}

- (void)cancel {
    [self cancel:NO];
}

- (void)cancel:(BOOL)confirmIfNecessary {
    
    if (confirmIfNecessary) {
        [self confirmCancellation];
        
    } else {
#ifdef CV_TARGET_IPAD
        
        [self.navigationController popViewControllerAnimated:YES];
#else
        [self popFromStack];
#endif
    }
}

-(BOOL)validateTaskData {
    
    NSString* msg;
    BOOL isValidate = NO;
    
    if (!_addPeople) {
        
        if ([_updatedAssignees count] == 0)
            msg = LS(@"Participants are required.", @"");
        else
            isValidate = YES;
    } else {
        //        if ([_addedAssignees count] == 0 && [_addedCCers count] == 0)
        //            msg = LS(@"Assignee or Ccer is required.", @"");
        //        else
        isValidate = YES;
    }
    
    if (!isValidate)
        [self alertMessage:msg];
    
    return isValidate;
}

- (void)convertSelections:(NSArray*)users toKeys:(NSMutableArray*)keys andEmails:(NSMutableArray*)emails {
    
    for (id userInfo in users) {
        
        //        if ([userInfo isKindOfClass:[User class]]) {
        //
        //            // picked from contacts
        //            [keys addObject:[(User*)userInfo key]];
        //
        //        } else
        
        if ([userInfo isKindOfClass:[NSDictionary class]]) {
            
            NSString* key = [(NSDictionary*)userInfo objectForKey:@"key"];
            NSString* email = [(NSDictionary*)userInfo objectForKey:@"email"];
            NSString* displayName = [(NSDictionary*)userInfo objectForKey:@"displayName"];
            
            if (key != nil)
                // existing assignee/ccer
                [keys addObject:key];
            else if (displayName)
                // manually entered email address
                [emails addObject:displayName];
            else if (email != nil)
                // picked from address book
                [emails addObject:email];
            
        } else
            continue;
    }
}

- (void)saveWithOption:(NSString*)option {
    if (![self validateTaskData])
        return;
    
    // display activity indicator
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:_activityIndicator];
    [self navigationItem].rightBarButtonItems = @[barButton];
    [_activityIndicator startAnimating];
    
    // stop all controlls
    
    [self navigationItem].leftBarButtonItem.enabled = NO;
    //_titleCell.titleValueField.enabled = NO;
    // stop taking input in title field
    
    
    if (_addPeople) {
        [self addTo];
        return;
    }
    
    // prepare data
    
    NSMutableArray* assigneeKeys = [NSMutableArray array];
    NSMutableArray* emailNames = [NSMutableArray array];
    
    [self convertSelections:_updatedAssignees toKeys:assigneeKeys andEmails:emailNames];
    
    NSMutableDictionary* taskRecord = [NSMutableDictionary dictionary];
    [taskRecord setObject:@{@"assignee" : assigneeKeys, @"cc" : @[]} forKey:@"users"];
    [taskRecord setObject:@{@"assignee" : emailNames, @"cc" : @[]} forKey:@"userEmails"];
    if (_toEdit)
        [taskRecord setObject:[_taskData objectForKey:@"key"] forKey:@"key"];
    
    // make sure these fields are set (fixed values per Petrus' suggestion)
    [taskRecord setObject:@"task" forKey:@"type"];
    [taskRecord setObject:@"task" forKey:@"subtype"];
    [taskRecord setObject:@"" forKey:@"dueDate"];
    [taskRecord setObject:@"" forKey:@"dueTime"];
    [taskRecord setObject:@"" forKey:@"tplName"];
    [taskRecord setObject:@"1" forKey:@"canAddByTo"];
    [taskRecord setObject:@"" forKey:@"msgId"];
    [taskRecord setObject:@"yes" forKey:@"enable"];// new required field after 4/1/2013
    [taskRecord setObject:TASK_TYPE_CHAT forKey:@"taskType"];
    
    // update the values with the form data
    if([_titleCell getValue] != nil)
        [taskRecord setObject:[_titleCell getValue] forKey:@"name"];
    if (_updatedDesc != nil) {
        [taskRecord setObject:_updatedDesc forKey:@"description"];
    }
    
    NSDictionary* userInfo = [CVAPIUtil getUserInfo];
    NSTimeZone* timezoneoffset = [CVAPIUtil getCachedTimeZone:[userInfo objectForKey:USER_TIMEZONE] useDefaultTimeZone:[[userInfo objectForKey:USER_DEFAULT_TIMEZONE] isEqualToString:@"1"]];
    NSString* timezone = [NSString stringWithFormat:@"%0.01f", [timezoneoffset secondsFromGMT] / 3600.0];
    
    NSMutableDictionary* param = [NSMutableDictionary dictionaryWithObjectsAndKeys:taskRecord, @"taskrecord", nil];
    [param setObject:[NSDictionary dictionaryWithObjectsAndKeys:timezone, @"tz", nil] forKey:@"_ctx"];
    
    NSString* apiPath;
    CVAPIRequest* request;
    if (_toEdit) {
        apiPath = [NSString stringWithFormat:@"/svc/tasks/%@", [_taskData objectForKey:@"key"]];
        [param setObject:[taskRecord objectForKey:@"key"] forKey:@"key"];
        
        request = [[CVAPIRequest alloc] initWithAPIPath:apiPath];
        [request setPUTParamString:[param jsonValue] isJsonFormat:YES];
        
        CVAPIListModel* model = [[CVAPIListModel alloc] init];
        [model sendRequest:request completion:^(NSDictionary* apiResult, NSError* error) {
            [self cancel:NO];
            [self stopActivityIndicator];
        }];
    }
    else {
        apiPath = @"/svc/tasks";
        request = [[CVAPIRequest alloc] initWithAPIPath:apiPath];
        [request setParamString:[param jsonValue]];
        
        CVAPIListModel* model = [[CVAPIListModel alloc] init];
        [model sendRequest:request completion:^(NSDictionary* apiResult, NSError* error) {
            
            if ([[[apiResult objectForKey:@"_hdr"] objectForKey:@"rc"] integerValue] >= 0) {
                [self cancel:NO];
                [self stopActivityIndicator];
                NSString* taskKey = [[apiResult objectForKey:@"task"] objectForKey:@"key"];
                CVChatViewController* vc = [[CVChatViewController alloc] initWithKey:taskKey];
                [vc pushToStack];
                vc.title = [[apiResult objectForKey:@"task"] objectForKey:@"name"];
                
                cachedTaskData = nil;
            }
            else {
                [CVAPIUtil alertMessage:LS(@"Chat failed to start!", @"")];
            }
            
        }];
    }
    
    
}

- (void)addTo {
    
    if ([_addedAssignees count] > 0) {
        NSMutableArray* userKeys = [NSMutableArray array];
        for (NSDictionary* user in _updatedAssignees) {
            [userKeys addObject:[user objectForKey:@"key"]];
        }
        [_taskModel addParticipants:userKeys forType:@"assignee"];
    }
    
}

- (void)confirmCancellation {
    UIActionSheet* actionSheet = [[UIActionSheet alloc]init];
    actionSheet.delegate = self;
    actionSheet.title = LS(@"Are you sure you want to cancel?", @"");
    [actionSheet addButtonWithTitle:LS(@"Yes", @"")];
    [actionSheet addButtonWithTitle:LS(@"No", @"")];
    actionSheet.destructiveButtonIndex = 1;
    
    [actionSheet showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
}

- (void)saveItemTouched {
    
    //    _sheetForSaveAs = [[UIActionSheet alloc] init];
    //    _sheetForSaveAs.delegate = self;
    //
    //    [_sheetForSaveAs addButtonWithTitle:LS(@"Save", @"")];
    //    _sheetForSaveAs.destructiveButtonIndex = 1;
    //    [_sheetForSaveAs addButtonWithTitle:LS(@"Cancel", @"")];
    //    [_sheetForSaveAs showFromBarButtonItem:_saveItem animated:YES];
    [self saveWithOption:SAVE_TYPE_TASK];
    
}

- (void)taskViewButtonTouched:(id)sender {
#ifdef CV_TARGET_IPAD
    
    [self.navigationController popViewControllerAnimated:YES];
    [[StackScrollViewAppDelegate instance].rootViewController toggleChatView];
    
#else
    // find the chat page (last but one)
    NSArray* VCs = [self.navigationController viewControllers];
    UIViewController* nextTopVC = [VCs objectAtIndex:[VCs count] - 2];
    
    // pop up the chat edit page
    [self.navigationController popViewControllerAnimated:NO];
    
    // dismiss chat navigation stack
    [nextTopVC dismissModalViewControllerAnimated:NO];
#endif
    
    // go to task detail page
    
    NSString* taskKey = [_taskData objectForKey:@"key"];
    
#ifdef CV_TARGET_IPAD
    
    CVTaskDetailViewController* tVC = [[CVTaskDetailViewController alloc] initWithKey:taskKey];
    [tVC pushToStackFromViewController:self];
    
    CVCommentsViewController* cVC = [[CVCommentsViewController alloc] initWithKey:taskKey];
    [cVC pushToStack];
    
#else
    
    IPhoneAppDelegate* appDelegate = (IPhoneAppDelegate*)[UIApplication sharedApplication];
    [appDelegate openTaskPage:taskKey];
    
#endif
}

- (void)stopActivityIndicator {
    [_activityIndicator stopAnimating];
    _activityIndicator = nil;
    [self navigationItem].leftBarButtonItem = _cancelItem;
    if (_addPeople)
        self.navigationItem.rightBarButtonItem = _saveItemForAddPeople;
    else
        self.navigationItem.rightBarButtonItem = _saveItem;
}

- (void)alertMessage:(NSString*)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:LS(message,@"")
                                                   delegate:nil
                                          cancelButtonTitle:LS(@"OK",@"")
                                          otherButtonTitles: nil];
    [alert show];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet == _sheetForSaveAs) {
        
        if (buttonIndex == 0) {
            [self saveWithOption:SAVE_TYPE_TASK];
        } else {
            [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
        }
        
        return;
        
    } else {
        if (buttonIndex == actionSheet.cancelButtonIndex || buttonIndex == actionSheet.destructiveButtonIndex)
            [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
        else {
            [self cancel:NO];
        }
    }
    
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        [_sheetForSaveAs dismissWithClickedButtonIndex:2 animated:NO];
    }
    if (buttonIndex == 1)
        [_sheetForSaveAs dismissWithClickedButtonIndex:2 animated:NO];
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    NSString *inputText = [[alertView textFieldAtIndex:0] text];
    if([inputText length] > 0)
        return YES;
    else
        return NO;
}

@end
