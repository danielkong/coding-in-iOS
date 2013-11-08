//
//  CVTaskEditViewController.m
//  Vmoso
//
//  Created by Daniel Kong on 11/07/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVTaskEditViewController.h"
#import "CVContactPickerViewController.h"
#import "CVRTEViewController.h"
#import "TaskFormDatePickerViewController.h"
#import "NSArray+DragonAPIUserList.h"
#import "NSDictionary+DragonAPI.h"
#import "NSDictionary+DragonAPIUser.h"
#import "NSDictionary+DragonAPITask.h"
#import "CVTaskNameCell.h"
#import "CVLabelCell.h"
#import "CVAttributedTextCell.h"
#import "CVOptionCell.h"
#import "NSDictionary+DragonAPIUser.h"
#import "NSDictionary+DragonAPIFile.h"
#import "CVFilePickerViewController.h"
#import "CVAPIRequest.h"
#import "CVAPIListModel.h"
#import "CVTaskACLItem.h"
#import "CVTaskItem.h"
#import "CVFileListItem.h"
#import "CVStampsTableViewCell.h"
#import "CVContactStampCell.h"

#define PAGE_WIDTH  500
#define OPTIONS_FONT      [UIFont fontWithName:@"Helvetica-Bold" size:17]
#define OPTIONS_COLOR   [UIColor colorWithRed:0.298039 green:0.337255 blue:0.423529 alpha:1.0]

#define SAVE_TYPE_TASK          @"task"
#define SAVE_TYPE_DRAFT         @"draft"
#define SAVE_TYPE_TEMPLATE      @"template"

#define CONTACT_LIST_TYPE_TASK              @"task"
#define CONTACT_LIST_TYPE_RESTRICTED_TASK   @"restricted_task"

static UIPopoverController* _popover = nil;             // main popover
static UIPopoverController* _secondaryPopover = nil;    // popover from popover

@interface CVTaskEditViewController () <UIActionSheetDelegate, IPadDatePickerDelegate, CVDescViewDelegate, ContactPickerDelegate, CVFilePickerDelegate, UIAlertViewDelegate, CVStampsTableViewCellDelegate>

@property(nonatomic, assign) BOOL addPeople;
@property(nonatomic, assign) UITableViewCell* selectedCell;
@property(nonatomic, retain) NSArray* fields;
@property(nonatomic, retain) NSArray* fieldTitles;
@property(nonatomic, retain) UIBarButtonItem* cancelItem;
@property(nonatomic, retain) UIBarButtonItem* saveItemForAddPeople;
@property(nonatomic, retain) UIBarButtonItem* saveItem;
@property(nonatomic, assign) BOOL isDetailPage;
@property(nonatomic, assign) BOOL isRestrictedTask;
//@property(nonatomic, retain) UITableView* tableView;
@property(nonatomic, retain) NSMutableDictionary* taskData;
@property(nonatomic, retain) CVLabelCell* typeCell;
@property(nonatomic, retain) CVTaskNameCell* titleCell;
@property(nonatomic, retain) CVStampsTableViewCell* assigneesCell;
@property(nonatomic, retain) CVStampsTableViewCell* ccersCell;
@property(nonatomic, retain) CVLabelCell* dueDateCell;
@property(nonatomic, retain) CVLabelCell* dueTimeCell;
@property(nonatomic, retain) CVAttributedTextCell* descCell;
@property(nonatomic, retain) CVLabelCell* attachmentsCell;
@property(nonatomic, retain) UIActionSheet* sheetForType;
@property(nonatomic, retain) UIActionSheet* sheetForSaveAs;
@property(nonatomic, retain) UIAlertView* alertForTemplate;
@property(nonatomic, retain) NSString* templateName;
@property(nonatomic, retain) UIAlertView* alertForRestrict;

@property(nonatomic, retain) NSArray* typeOptions;
@property(nonatomic, assign) double updatedDueDate;
@property(nonatomic, retain) NSString* updatedDesc;
@property(nonatomic, retain) NSArray* updatedAssignees;
@property(nonatomic, retain) NSArray* updatedCCers;
@property(nonatomic, retain) NSArray* updatedAssigneesInitial;
@property(nonatomic, retain) NSArray* updatedCCersInitial;
@property(nonatomic, retain) NSMutableArray* addedAssignees;
@property(nonatomic, retain) NSMutableArray* addedCCers;
@property(nonatomic, retain) CVUserListItem* collectionContactItemForAssignees;
@property(nonatomic, retain) NSMutableArray* collectionContactArrayForAssignees;
@property(nonatomic, retain) CVUserListItem* collectionContactItemForCCers;
@property(nonatomic, retain) NSMutableArray* collectionContactArrayForCCers;
@property(nonatomic, retain) NSArray* updatedAttachments;
@property(nonatomic, retain) NSArray* addedAttachments;
@property(nonatomic, retain) UIActivityIndicatorView* activityIndicator;

@property(nonatomic, retain) NSArray* messageTaskOptions;
@property(nonatomic, retain) NSArray* messageTaskOptionValues;
@property(nonatomic, retain) NSArray* todoTaskOptions;
@property(nonatomic, retain) NSArray* todoTaskOptionValues;
@property(nonatomic, retain) NSMutableArray* optionsCell;
@property(nonatomic, retain) NSString* action;
@property(nonatomic, retain) NSString* oldTaskType;

@end

@implementation CVTaskEditViewController

- (id) initWithData:(NSDictionary*)data forAddPeople:(BOOL)addPeople {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {

        _addPeople = addPeople;
        
        _taskData = (data != nil) ? [NSMutableDictionary dictionaryWithDictionary:data] : [NSMutableDictionary dictionary];
        // task type key(lower), e.g. "fyi"
        _oldTaskType = [[data objectForKey:@"taskType"] lowercaseString];
        _changeToNewTask = NO;
        self.isDetailPage = NO;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = RGBCOLOR(233, 233, 233);

        //self.tableView.allowsSelection = NO;
        
        self.contentSizeForViewInPopover = CGSizeMake(PAGE_WIDTH, 1000);
        self.modalInPopover = YES;
        
        // Cancel button item on the left
        _cancelItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Cancel", @"")
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = _cancelItem;
        
        // post button item to be used later
        _saveItemForAddPeople = [[UIBarButtonItem alloc] initWithTitle:LS(@"Save", @"")
                                                        style:UIBarButtonItemStyleDone
                                                        target:self
                                                        action:@selector(saveWithOption:)];
        _saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(saveItemTouched)];
        if (_addPeople)
            self.navigationItem.rightBarButtonItem = _saveItemForAddPeople;
        else
            self.navigationItem.rightBarButtonItem = _saveItem;
    }
    
    return self;
}

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString* taskType = [CVAPIUtil getValidString:[_taskData objectForKey:@"taskType"]];
    NSString* taskKey = [_taskData objectForKey:@"key"];
    
    _messageTaskOptions = @[LS(@"Participants Restriction:My Company Only", @""), LS(@"High Priority", @""), LS(@"Can Add Participants", @""), LS(@"Allow Task Reuse", @""), LS(@"Allow Editing of Comments", @"")];
    
    _todoTaskOptions = @[LS(@"Participants Restriction:My Company Only", @""), LS(@"High Priority", @""), LS(@"Accept Required", @""), LS(@"Can Add Participants:TO", @""), LS(@"Can Add Participants:CC", @""), LS(@"Allow Task Reuse", @""), LS(@"Allow Editing of Comments", @"")];
    
    _typeOptions = @[LS(TYPE_OPTION_DISCUSSION, @""), LS(TYPE_OPTION_FYI, @""), LS(TYPE_OPTION_CHAT, @""), LS(TYPE_OPTION_ACTION, @""), LS(TYPE_OPTION_APPROVAL, @"")];
    
    _isRestrictedTask = [[_taskData objectForKey:@"restrictedFlag"] boolValue];

    if (taskKey) {
        if ([taskType isEqualToString:TASK_TYPE_FYI])
            taskType = LS(TYPE_OPTION_FYI, @"");
        else
            taskType = LS([taskType capitalizedString], @"");
        _messageTaskOptionValues = [NSArray arrayWithObjects:([[_taskData objectForKey:@"restrictedFlag"] boolValue]?@"Yes":@"No"),
                                    ([[_taskData objectForKey:@"flag"] isEqualToString:@"important"]?@"Yes":@"No"),
                                    ([[_taskData objectForKey:@"canAddByTo"] boolValue]?@"Yes":@"No"),
                                    ([[_taskData objectForKey:@"reuseFlag"] boolValue]?@"Yes":@"No"),
                                    ([[_taskData objectForKey:@"editCommentFlag"] boolValue]?@"Yes":@"No"), nil];
        _todoTaskOptionValues = [NSArray arrayWithObjects:([[_taskData objectForKey:@"restrictedFlag"] boolValue]?@"Yes":@"No"),
                                 ([[_taskData objectForKey:@"flag"] isEqualToString:@"important"]?@"Yes":@"No"),
                                 ([[_taskData objectForKey:@"acceptFlag"] boolValue]?@"Yes":@"No"),
                                 ([[_taskData objectForKey:@"canAddByTo"] boolValue]?@"Yes":@"No"),
                                 ([[_taskData objectForKey:@"canAddByCc"] boolValue]?@"Yes":@"No"),
                                 ([[_taskData objectForKey:@"reuseFlag"] boolValue]?@"Yes":@"No"),
                                 ([[_taskData objectForKey:@"editCommentFlag"] boolValue]?@"Yes":@"No"), nil];
    }
    else
        taskType = LS([CVAPIUtil getValidString:[_taskData objectForKey:@"taskType"]], @"");
    
    _updatedDueDate = [_taskData taskDueDate];
    if (_updatedDueDate == TIMESTAMP_ERROR_VALUE)
        _updatedDueDate = [[NSDate date] timeIntervalSince1970] + 24 * 60 * 60;
    _updatedDesc = [_taskData taskDescription];
    _updatedAssignees = [_taskData taskAssignees];
    _updatedAssigneesInitial = [_taskData taskAssignees];
    _updatedCCers = [_taskData taskCcers];
    _updatedCCersInitial = [_taskData taskCcers];
    _updatedAttachments = [_taskData taskAttachments];
    _addedAssignees = [NSMutableArray array];
    _addedCCers = [NSMutableArray array];
    _addedAttachments = [NSArray array];
    
    _typeCell = [[CVLabelCell alloc] init];
    [_typeCell setValue:taskType];
    _typeCell.accessoryType = UITableViewCellAccessoryNone;
    if (!_addPeople) {
        _titleCell = [[CVTaskNameCell alloc] init];
        [_titleCell setValue:[_taskData objectForKey:@"name"]];
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
    _assigneesCell.frame = CGRectMake(0, 0, 6 * 75 + 30, stampSize.height + 10*2);

    _assigneesCell.insects = UIEdgeInsetsMake(10,10, 10, 0);
    _assigneesCell.items = _collectionContactArrayForAssignees;
    _assigneesCell.stampSize = stampSize;
    _assigneesCell.stampSpacing = 10;
    _assigneesCell.delegate = self;
    [_assigneesCell registerStampClass:[CVContactStampCell class] forCellWithReuseIdentifier:@"contact"];
    
    _collectionContactItemForCCers = [[CVUserListItem alloc] init];
    _collectionContactArrayForCCers = [NSMutableArray array];
    [_collectionContactArrayForCCers addObject:@"Add For CCers"];
    for (NSDictionary* temp in _updatedCCers){
        _collectionContactItemForCCers = [CVUserListItem userListItemWithDictionary:temp];
        [_collectionContactArrayForCCers addObject:_collectionContactItemForCCers];
    }
    _ccersCell = [[CVStampsTableViewCell alloc] init];
    _ccersCell = [[CVStampsTableViewCell alloc] initWithFrame:defaultRect];
    _ccersCell.frame = CGRectMake(_ccersCell.insects.left, _ccersCell.insects.right, 6 * 75 + 30, stampSize.height + 10*2);
    _ccersCell.insects = UIEdgeInsetsMake(10, 10, 10, 0);
    _ccersCell.items = _collectionContactArrayForCCers;
    _ccersCell.stampSize = stampSize;
    _ccersCell.stampSpacing = 10;
    _ccersCell.delegate = self;

    [_ccersCell registerStampClass:[CVContactStampCell class] forCellWithReuseIdentifier:@"contact"];
    
    _attachmentsCell = [[CVLabelCell alloc] init];
    [_attachmentsCell setValue:[self toAttachmentDisplayString:_updatedAttachments]];
    
    if (!_addPeople) {
        
        _dueDateCell = [[CVLabelCell alloc] init];
        [_dueDateCell setValue:[CVAPIUtil formatDateTimeWithTimestamp:_updatedDueDate withFormat:[CVAPIUtil getDateFormat]]];
        
        _dueTimeCell = [[CVLabelCell alloc] init];
        [_dueTimeCell setValue:[CVAPIUtil formatDateTimeWithTimestamp:_updatedDueDate withFormat:[CVAPIUtil getTimeFormat]]];
        
        _descCell = [[CVAttributedTextCell alloc] init];
        [_descCell setValue:_updatedDesc];
 
    }
    _optionsCell = [NSMutableArray array];
    [self loadFormCells];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.title = _addPeople ? [NSString stringWithFormat:@"%@/%@",LS(@"Add People", @""), LS(@"File", @"")] : (([_taskData objectForKey:@"key"] && !_changeToNewTask) ? LS(@"Edit Task", @"") : LS(@"Create Task", @""));
    [self.tableView reloadData];
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
    if ([cell isKindOfClass:[CVBaseFieldCell class]])
        return [cell fieldHeightInTableView:tableView];
    if ([cell isKindOfClass:[CVStampsTableViewCell class]])
        if ([((CVStampsTableViewCell*)cell).items count] > 0)
            return 130;
    return 30;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if "Save" has started, do nothing
    if (_activityIndicator != nil)
        return;
    
    _selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString* taskType = _oldTaskType;
    NSString* subType = [_taskData objectForKey:@"subtype"];
    if (_selectedCell == _typeCell && (![_taskData objectForKey:@"key"] || [taskType isEqualToString:@"mail"] || [taskType isEqualToString:@"chat"]||[subType isEqualToString:@"draft"])) {
        if (_sheetForType == nil || [taskType isEqualToString:@"mail"]) {
            _sheetForType = [[UIActionSheet alloc] init];
            _sheetForType.delegate = self;
            if(![_taskData objectForKey:@"key"]  || [subType isEqualToString:@"draft"]) {
                for (NSString* option in _typeOptions) {
                    [_sheetForType addButtonWithTitle:option];
                }
            } else if ([taskType isEqualToString:@"mail"]) {
                if ([_updatedCCers count] == 0) {
                    [_sheetForType addButtonWithTitle:LS(TYPE_OPTION_DISCUSSION, @"")];
                    [_sheetForType addButtonWithTitle:LS(TYPE_OPTION_FYI, @"")];
                    [_sheetForType addButtonWithTitle:LS(TYPE_OPTION_CHAT, @"")];
                }
                [_sheetForType addButtonWithTitle:LS(TYPE_OPTION_ACTION, @"")];
                [_sheetForType addButtonWithTitle:LS(TYPE_OPTION_APPROVAL, @"")];
            } else if([taskType isEqualToString:@"chat"]) {
                [_sheetForType addButtonWithTitle:LS(TYPE_OPTION_DISCUSSION, @"")];
                [_sheetForType addButtonWithTitle:LS(TYPE_OPTION_FYI, @"")];
                [_sheetForType addButtonWithTitle:LS(TYPE_OPTION_CHAT, @"")];

            }
            
             _sheetForType.cancelButtonIndex = [_sheetForType addButtonWithTitle:LS(@"Cancel", @"")];
        }
        [_sheetForType showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];

        return;
    }
    
    UIViewController* controller = nil;
    
    if (_selectedCell == _dueDateCell || _selectedCell == _dueTimeCell) {

        CVLabelCell* field = (CVLabelCell*)[_fields objectAtIndex:indexPath.section];
        if (_updatedDueDate)
            controller = [[TaskFormDatePickerViewController alloc] initWithTimestamp:_updatedDueDate];
        //when create task,use default init to set picker time to current
        else
            controller = [[TaskFormDatePickerViewController alloc] init];
        
        if (_selectedCell == _dueDateCell) {
            [(TaskFormDatePickerViewController*)controller setPickerMode:UIDatePickerModeDate];
        } else {
            [(TaskFormDatePickerViewController*)controller setPickerMode:UIDatePickerModeTime];
        }
        
        ((TaskFormDatePickerViewController*) controller).delegate = self;
#ifdef CV_TARGET_IPAD
        if (_secondaryPopover)
            [_secondaryPopover dismissPopoverAnimated:NO];
        _secondaryPopover = [[UIPopoverController alloc] initWithContentViewController:controller];
        //CGRect pointToRect = [self.view convertRect:field.frame fromView:field];
        [_secondaryPopover presentPopoverFromRect:field.frame inView:self.view
                         permittedArrowDirections:UIPopoverArrowDirectionLeft /*| UIPopoverArrowDirectionRight*/
                                         animated:YES];
#else
        [controller pushToStack];
#endif
        return;
        
    } else if (_selectedCell == _attachmentsCell) {
        
        NSArray* initialAttachments = _addPeople ? _addedAttachments :_updatedAttachments;
        controller = [[CVFilePickerViewController alloc] initWithAttachments:initialAttachments];
        //        ((CVContactPickerViewController*)controller).placeHolder = LS(@"Attachment:", @"");
        ((CVFilePickerViewController*)controller).delegate = self;
        
    } else if (_selectedCell == _descCell) {
        
        controller = [[CVRTEViewController alloc] initWithText:_updatedDesc];
        ((CVRTEViewController*)controller).delegate = self;
        
    } else if ([_selectedCell isKindOfClass:[CVOptionCell class]]) {
        if ([[(CVOptionCell*)_selectedCell optionLable].text isEqualToString:LS(@"Participants Restriction:My Company Only", @"")]) {
            if ([[(CVOptionCell*)_selectedCell statusLable].text isEqualToString:LS(@"No", @"")]) {
                if (![CVAPIUtil isAllCompany:_updatedAssignees] || ![CVAPIUtil isAllCompany:_updatedCCers]) {
                    _alertForRestrict = [[UIAlertView alloc] initWithTitle:nil message:LS(@"Task participants restricted to same company only.", @"") delegate:self cancelButtonTitle:LS(@"Cancel", @"") otherButtonTitles:LS(@"Done", @""), nil];
                    [_alertForRestrict show];
                } else {
                    _isRestrictedTask = true;
                    [(CVOptionCell*)_selectedCell toggleButtonText];
                }
            } else {
                _isRestrictedTask = false;
                [(CVOptionCell*)_selectedCell toggleButtonText];
            }
        } else {
            [(CVOptionCell*)_selectedCell toggleButtonText];
        }
    }
    
    if (controller)
        [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark -
#pragma mark IPadDatePickerDelegate

-(void) dateValueChanged:(NSDate *)newDate {
    NSString* dateStr = [CVAPIUtil formatDateTime:newDate withFormat:[CVAPIUtil getDateFormat]];
    NSString* timeStr = [CVAPIUtil formatDateTime:newDate withFormat:[CVAPIUtil getTimeFormat]];
    
    [_dueDateCell setValue:dateStr];
    [_dueTimeCell setValue:timeStr];
    
    _updatedDueDate = [newDate timeIntervalSince1970];
    
}

#pragma mark -
#pragma mark CVDescViewDelegate

-(void) descTextChanged:(NSString*)text {
    _updatedDesc = text;
    [_descCell setValue:text];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark ContactPickerDelegate

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

    } else if (_selectedCell == _ccersCell && !_addPeople) {
        _updatedCCers = recipients;
        [_collectionContactArrayForCCers removeAllObjects];
        [_collectionContactArrayForCCers addObject:@"Add For CCers"];

        for (NSDictionary* temp in _updatedCCers){
            _collectionContactItemForCCers = [CVUserListItem userListItemWithDictionary:temp];
            [_collectionContactArrayForCCers addObject:_collectionContactItemForCCers];
        }

        _ccersCell.items = _collectionContactArrayForCCers;
        [_ccersCell.stampsView reloadData];
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
    } else if (_selectedCell == _ccersCell && _addPeople && _addedCCers) {
        _addedCCers = (NSMutableArray*)recipients;
        for (NSDictionary* tempDictForNewRecipient in recipients){
            for (NSDictionary* tempDictForInitialUpdateCCer in _updatedCCersInitial){
                if ([[tempDictForNewRecipient objectForKey:@"key"] isEqualToString:[tempDictForInitialUpdateCCer objectForKey:@"key"]])
                    [_addedCCers removeObject:tempDictForNewRecipient];
            }
        }
        NSMutableArray* combined = [NSMutableArray arrayWithArray:_updatedCCersInitial];
        [combined addObjectsFromArray:_addedCCers];
        _updatedCCers = combined;
        [_collectionContactArrayForCCers removeAllObjects];
        [_collectionContactArrayForCCers addObject:@"Add For CCers"];
        
        for (NSDictionary* temp in _updatedCCers){
            _collectionContactItemForCCers = [CVUserListItem userListItemWithDictionary:temp];
            [_collectionContactArrayForCCers addObject:_collectionContactItemForCCers];
        }
        
        _ccersCell.items = _collectionContactArrayForCCers;
        [_ccersCell.stampsView reloadData];
    } else
        ;
    [self.tableView reloadData];
    
}


#pragma mark -
#pragma mark IPadFilePickerDelegate

-(void)AttachmentsChanged:(NSArray *)attachments {
    
    if (!_addPeople) {
        _updatedAttachments = attachments;
        [_attachmentsCell setValue:[self toAttachmentDisplayString:_updatedAttachments]];
        
    }
    else {
        _addedAttachments = attachments;
        NSMutableArray* combined = [NSMutableArray arrayWithArray:_updatedAttachments];
        [combined addObjectsFromArray:_addedAttachments];
        [_attachmentsCell setValue:[self toAttachmentDisplayString:combined]];
        _updatedAttachments = combined;
    }
    
    [self.tableView reloadData];
    
}

#pragma mark -
#pragma mark private

- (void)loadFormCells {
    
    NSString* taskType = [_typeCell getValue];
    
    [_optionsCell removeAllObjects];
    NSMutableArray* optionArrayToUse = nil;
    NSMutableArray* valueArrayToUse = nil;
    
    if ([taskType isEqualToString:LS(TYPE_OPTION_DISCUSSION,@"")] || [taskType isEqualToString:LS(TYPE_OPTION_FYI, @"")] || [taskType isEqualToString:LS(TYPE_OPTION_CHAT,@"")]) {
        optionArrayToUse = [NSMutableArray arrayWithArray:_messageTaskOptions];
        valueArrayToUse = [NSMutableArray arrayWithArray:_messageTaskOptionValues];
        // if type is chat,don't "Allow Task Reuse"
        if([taskType isEqualToString:LS(TYPE_OPTION_CHAT,@"")]) {
            [optionArrayToUse removeObject:LS(@"Allow Task Reuse",@"")];
            if ([valueArrayToUse count] > 0) {
                [valueArrayToUse removeObject:LS(@"Allow Task Reuse", @"")];
            }
        }
    }
    else {
        optionArrayToUse = [NSMutableArray arrayWithArray:_todoTaskOptions];
        valueArrayToUse = [NSMutableArray arrayWithArray:_todoTaskOptionValues];
    }
    
    if (![_taskData objectForKey:@"key"]) {
        for (NSString* string in optionArrayToUse) {
            CVOptionCell* cell = [[CVOptionCell alloc] initWithTitle:string];
            if ([string isEqualToString:LS(@"High Priority", @"")] || [string isEqualToString:LS(@"Allow Task Reuse", @"")] || [string isEqualToString:LS(@"Participants Restriction:My Company Only", @"")])
                cell.statusLable.text = LS(@"No", @"");
            else
                cell.statusLable.text = LS(@"Yes", @"");
            [_optionsCell addObject:cell];
        }
    }
    else {
        for (NSUInteger index = 0; index < [optionArrayToUse count]; index++) {
            NSString* string = [optionArrayToUse objectAtIndex:index];
            NSString* value = [valueArrayToUse objectAtIndex:index];
            CVOptionCell* cell = [[CVOptionCell alloc] initWithTitle:string];
            cell.statusLable.text = LS(value, @"");
            [_optionsCell addObject:cell];
        }
    }
    
    if (_addPeople) {
        if ([taskType isEqualToString:LS(TYPE_OPTION_DISCUSSION, @"")] || [taskType isEqualToString:LS(TYPE_OPTION_FYI, @"")] || [taskType isEqualToString:LS(TYPE_OPTION_CHAT, @"")]) {
            if([[_taskData objectForKey:@"canAddByTo"] intValue] ==1) {
                _fields = [NSArray arrayWithObjects:_assigneesCell, _attachmentsCell, nil];
                _fieldTitles = [NSArray arrayWithObjects:LS(@"To", @""), LS(@"Attachments", @""), nil];
            } else {
                _fields = [NSArray arrayWithObjects:_attachmentsCell, nil];
                _fieldTitles = [NSArray arrayWithObjects:LS(@"Attachments", @""), nil];
            }
        }
        else {
            NSMutableArray* cells = [NSMutableArray array];
            NSMutableArray* titles = [NSMutableArray array];
            NSString* userKey = [CVAPIUtil getUserKey];
            if ([[_taskData objectForKey:@"canAddByTo"] intValue] ==1) {
                for (NSDictionary* assignee in [_taskData taskAssignees]) {
                    if([[assignee objectForKey:@"key"] isEqualToString:userKey]) {
                        [cells addObject:_assigneesCell];
                        [titles addObject:LS(@"To", @"")];
                        [cells addObject:_ccersCell];
                        [titles addObject:LS(@"Cc", @"")];
                        break;
                    }
                }
            }
            if ([[_taskData objectForKey:@"canAddByCc"] intValue] ==1) {
                for (NSDictionary* ccers in [_taskData taskCcers]) {
                    if([[ccers objectForKey:@"key"] isEqualToString:userKey]) {
                        [cells addObject:_assigneesCell];
                        [titles addObject:LS(@"To", @"")];
                        [cells addObject:_ccersCell];
                        [titles addObject:LS(@"Cc", @"")];
                        break;
                    }
                }
            }
            [cells addObject:_attachmentsCell];
            [titles addObject:LS(@"Attachments", @"")];
            _fields = cells;
            _fieldTitles = titles;
        }
    } else {
        if ([taskType isEqualToString:LS(TYPE_OPTION_DISCUSSION, @"")] || [taskType isEqualToString:LS(TYPE_OPTION_FYI, @"")] || [taskType isEqualToString:LS(TYPE_OPTION_CHAT, @"")]) {
            _fields = [NSArray arrayWithObjects:_typeCell, _titleCell, _assigneesCell, _attachmentsCell, _descCell, _optionsCell, nil];
            _fieldTitles = [NSArray arrayWithObjects:LS(@"Task Type", @""), LS(@"Title", @""), LS(@"To", @""), LS(@"Attachments", @""), LS(@"Description", @""), LS(@"",@""), nil];
        }
        else {
            _fields = [NSArray arrayWithObjects:_typeCell, _titleCell, _assigneesCell, _ccersCell, _dueDateCell, _dueTimeCell, _attachmentsCell, _descCell, _optionsCell, nil];
            _fieldTitles = [NSArray arrayWithObjects:LS(@"Task Type", @""), LS(@"Title", @""), LS(@"To", @""), LS(@"Cc", @""), LS(@"Due Date", @""), LS(@"Due Time",@""), LS(@"Attachments", @""), LS(@"Description", @""), LS(@"",@""), nil];
        }
    }
    
}

- (void)cancel {
    [self cancel:YES];
}

- (void)cancel:(BOOL)confirmIfNecessary {
    if (confirmIfNecessary) {
        [self confirmCancellation];
        
    } else {
#ifdef CV_TARGET_IPAD
        if (_popover)
            [_popover dismissPopoverAnimated:YES];
        else
            [self dismissModalViewController];
#else
        [self popFromStack];
#endif
    }
}

-(BOOL)validateTaskData {
    
    NSString* msg;
    BOOL isValidate = NO;
    
    NSString* taskType = [[_typeCell getValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* taskName = [[_titleCell getValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* taskDesc = [_updatedDesc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (!_addPeople) {
        if (taskName.length == 0 && ![taskType isEqualToString:LS(TYPE_OPTION_CHAT, @"")])
            msg = LS(@"Title of task is required.", @"");
        else if (taskType.length == 0 && ![taskType isEqualToString:LS(TYPE_OPTION_CHAT, @"")])
            msg = LS(@"Task type is required.", @"");
        else if (taskDesc.length == 0 && ![taskType isEqualToString:LS(TYPE_OPTION_CHAT, @"")])
            msg = LS(@"Description is required.", @"");
        else if ([_updatedAssignees count] == 0)
            msg = LS(@"Assignees are required.", @"");
        else
            isValidate = YES;
    } else {
        //        if ([_addedAssignees count] == 0 && [_addedCCers count] == 0)
        //            msg = LS(@"Assignee or Ccer is required.", @"");
        //        else
        isValidate = YES;
    }
    
    if (isValidate)
        return isValidate;
    
    [self alertMessage:msg];
    
    return NO;
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
            NSRange range = [key rangeOfString:@"@"];
            if (range.length > 0) {
                [emails addObject:email];
                continue;
            }
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
    
    [self navigationItem].leftBarButtonItem = nil;  // remove the "Cancel" button item
    //_titleCell.titleValueField.enabled = NO;
    // stop taking input in title field
    
    
    if (_addPeople) {
        [self addTo];
        return;
    }
    
    NSMutableArray* assigneeKeys = [NSMutableArray array];
    NSMutableArray* ccKeys = [NSMutableArray array];
    NSMutableArray* emailNames = [NSMutableArray array];
    NSMutableArray* ccEmailNames = [NSMutableArray array];
    NSMutableArray* attachmentKeys = [NSMutableArray array];
    NSString* taskType;
    CVAPIRequest* request = nil;
//    if ([subType isEqualToString:SAVE_TYPE_DRAFT]) {
//        request = [[CVAPIRequest alloc] initWithAPIPath:@"/svc/tasks/createDraft"];
//
//    } else {
//        request = [[CVAPIRequest alloc] initWithAPIPath:@"/svc/tasks"];
//    }
//    
    NSMutableDictionary* taskRecord = [NSMutableDictionary dictionary];
    
    [self convertSelections:_updatedAssignees toKeys:assigneeKeys andEmails:emailNames];
    [self convertSelections:_updatedCCers toKeys:ccKeys andEmails:ccEmailNames];
    for (NSDictionary* item in _updatedAttachments) {
        [attachmentKeys addObject:[item fileKey]];
    }

    NSMutableDictionary* users = [NSMutableDictionary dictionary];
    [users setObject:assigneeKeys forKey:@"assignee"];
    [users setObject:ccKeys forKey:@"cc"];
    
    [taskRecord setObject:users forKey:@"users"];
    [taskRecord setObject:attachmentKeys forKey:@"attachmentKeys"];
    if ([_taskData objectForKey:@"subtype"]) {
        [taskRecord setObject:[_taskData objectForKey:@"subtype"] forKey:@"subtype"];
    }
    [taskRecord setObject:@"" forKey:@"dueDate"];
    [taskRecord setObject:@"" forKey:@"dueTime"];
    [taskRecord setObject:@"yes" forKey:@"enable"];
    [taskRecord setObject:@"" forKey:@"msgId"];
    [taskRecord setObject:@"" forKey:@"tplName"];
    [taskRecord setObject:@"0" forKey:@"canAddByTo"];
    [taskRecord setObject:@"0" forKey:@"canAddByCc"];
    if ([_taskData objectForKey:@"key"]) {
        [taskRecord setObject:[_taskData objectForKey:@"key"] forKey:@"key"];
    }
    taskType = [[_taskData objectForKey:@"taskType"] lowercaseString];
    
    [taskRecord setObject:taskType forKey:@"taskType"];
    
    NSString* isRestrictedTask = [((CVOptionCell*)[_optionsCell objectAtIndex:0]).statusLable.text isEqualToString:LS(@"Yes", @"")]?@"1":@"0";
    [taskRecord setObject:isRestrictedTask forKey:@"restrictedFlag"];

    if ([taskType isEqualToString:TASK_TYPE_DISCUSSION ]|| [taskType isEqualToString:TASK_TYPE_FYI]|| [taskType isEqualToString:TASK_TYPE_CHAT]) {
        NSString* priority = [((CVOptionCell*)[_optionsCell objectAtIndex:1]).statusLable.text isEqualToString:LS(@"Yes", @"")]?@"important":@"normal";
        NSString* canAddTo = [((CVOptionCell*)[_optionsCell objectAtIndex:2]).statusLable.text isEqualToString:LS(@"Yes", @"")]?@"1":@"0";
        if([taskType isEqualToString:TASK_TYPE_CHAT]) {
            NSString* editCommentFlag = [((CVOptionCell*)[_optionsCell objectAtIndex:3]).statusLable.text isEqualToString:LS(@"Yes", @"")]?@"1":@"0";
            [taskRecord setObject:priority forKey:@"flag"];
            [taskRecord setObject:canAddTo forKey:@"canAddByTo"];
            [taskRecord setObject:@"0" forKey:@"reuseFlag"];
            [taskRecord setObject:editCommentFlag forKey:@"editCommentFlag"];

        } else {
            NSString* allowReuse = [((CVOptionCell*)[_optionsCell objectAtIndex:3]).statusLable.text isEqualToString:LS(@"Yes", @"")]?@"1":@"0";
            NSString* editCommentFlag = [((CVOptionCell*)[_optionsCell objectAtIndex:4]).statusLable.text isEqualToString:LS(@"Yes", @"")]?@"1":@"0";
            [taskRecord setObject:priority forKey:@"flag"];
            [taskRecord setObject:canAddTo forKey:@"canAddByTo"];
            [taskRecord setObject:allowReuse forKey:@"reuseFlag"];
            [taskRecord setObject:editCommentFlag forKey:@"editCommentFlag"];
        }
    }
    else if([taskType isEqualToString:TASK_TYPE_ACTION] || [taskType isEqualToString:TASK_TYPE_APPROVAL] || [taskType isEqualToString:TASK_TYPE_MAIL]){
        NSString* priority = [((CVOptionCell*)[_optionsCell objectAtIndex:1]).statusLable.text isEqualToString:LS(@"Yes", @"")]?@"important":@"normal";
        NSString* requireAccept = [((CVOptionCell*)[_optionsCell objectAtIndex:2]).statusLable.text isEqualToString:LS(@"Yes", @"")]?@"1":@"0";
        NSString* canAddTo = [((CVOptionCell*)[_optionsCell objectAtIndex:3]).statusLable.text isEqualToString:LS(@"Yes", @"")]?@"1":@"0";
        NSString* canAddCc = [((CVOptionCell*)[_optionsCell objectAtIndex:4]).statusLable.text isEqualToString:LS(@"Yes", @"")]?@"1":@"0";
        NSString* allowReuse = [((CVOptionCell*)[_optionsCell objectAtIndex:5]).statusLable.text isEqualToString:LS(@"Yes", @"")]?@"1":@"0";
        NSString* editCommentFlag = [((CVOptionCell*)[_optionsCell objectAtIndex:6]).statusLable.text isEqualToString:LS(@"Yes", @"")]?@"1":@"0";
        [taskRecord setObject:priority forKey:@"flag"];
        [taskRecord setObject:requireAccept forKey:@"acceptFlag"];
        [taskRecord setObject:canAddTo forKey:@"canAddByTo"];
        [taskRecord setObject:canAddCc forKey:@"canAddByCc"];
        [taskRecord setObject:allowReuse forKey:@"reuseFlag"];
        [taskRecord setObject:editCommentFlag forKey:@"editCommentFlag"];
    }
    // update the values with the form data
    if([_titleCell getValue] != nil)
        [taskRecord setObject:[_titleCell getValue] forKey:@"name"];
    
    if (_updatedDesc != nil) {
        [taskRecord setObject:_updatedDesc forKey:@"description"];
    }
    
    if (_updatedDueDate != TIMESTAMP_ERROR_VALUE) {//remote api require dueDate like MM/dd/yyyy,dueTime like 3:40 PM
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:_updatedDueDate];
        
        NSString* dateStr = [CVAPIUtil formatDateTime:date withFormat:@"MM/dd/yyyy"];
        NSString* timeStr = [CVAPIUtil formatDateTime:date withFormat:@"hh:mm aa"];
        [taskRecord setObject:dateStr forKey:@"dueDate"];
        [taskRecord setObject:timeStr forKey:@"dueTime"];
    }
    
    if ([option isKindOfClass:[UIBarButtonItem class]] || [option isEqualToString:SAVE_TYPE_TASK]) {
        if (!_changeToNewTask && [_taskData objectForKey:@"key"] && [[_taskData objectForKey:@"subtype"] isEqualToString:SAVE_TYPE_TASK]) {
            
            NSDictionary* userInfo = [CVAPIUtil getUserInfo];
            NSTimeZone* timezoneoffset = [CVAPIUtil getCachedTimeZone:[userInfo objectForKey:USER_TIMEZONE] useDefaultTimeZone:[[userInfo objectForKey:USER_DEFAULT_TIMEZONE] isEqualToString:@"1"]];
            NSString* timezone = [NSString stringWithFormat:@"%0.01f", [timezoneoffset secondsFromGMT] / 3600.0];
            
            request = [[CVAPIRequest alloc] initWithAPIPath:[NSString stringWithFormat:@"/svc/tasks/%@", [_taskData objectForKey:@"key"]]];
            NSMutableDictionary* param = [NSMutableDictionary dictionary];
            [param setObject:[taskRecord objectForKey:@"key"] forKey:@"key"];
            [param setObject:taskRecord forKey:@"taskrecord"];
            [param setObject:[NSDictionary dictionaryWithObjectsAndKeys:timezone, @"tz", nil] forKey:@"_ctx"];
            [request setPUTParamString:[param jsonValue] isJsonFormat:YES];
            CVAPIListModel* model = [[CVAPIListModel alloc] init];
            [model sendRequest:request completion:^(NSDictionary* apiRequest, NSError* error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TASK_UPDATE object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[taskRecord objectForKey:@"key"], @"taskKey", nil]];
                
                // fixed: blank page will present when click back button, so must cancel before alert message
                [self cancel:NO];
                [self stopActivityIndicator];
            }];

        } else {
            if (_changeToNewTask) {
                [taskRecord removeObjectForKey:@"key"];
            }
            request = [[CVAPIRequest alloc] initWithAPIPath:@"/svc/tasks"];
            NSDictionary* userInfo = [CVAPIUtil getUserInfo];
            NSTimeZone* timezoneoffset = [CVAPIUtil getCachedTimeZone:[userInfo objectForKey:USER_TIMEZONE] useDefaultTimeZone:[[userInfo objectForKey:USER_DEFAULT_TIMEZONE] isEqualToString:@"1"]];
            NSString* timezone = [NSString stringWithFormat:@"%0.01f", [timezoneoffset secondsFromGMT] / 3600.0];

            NSMutableDictionary* param = [NSMutableDictionary dictionaryWithObjectsAndKeys:taskRecord, @"taskrecord", nil];
            [param setObject:[NSDictionary dictionaryWithObjectsAndKeys:timezone, @"tz", nil] forKey:@"_ctx"];
            [request setParamString:[param jsonValue]];
            CVAPIListModel* model = [[CVAPIListModel alloc] init];
            [model sendRequest:request completion:^(NSDictionary* apiRequest, NSError* error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TASK_UPDATE object:nil userInfo:nil];
                
                // fixed: blank page will present when click back button, so must cancel before alert message
                [self cancel:NO];
                [CVAPIUtil alertMessage:LS(@"Task created successfully!", @"")];
                [self stopActivityIndicator];
            }];

        }
    }
    else if ([option isEqualToString:SAVE_TYPE_DRAFT]) {
        request = [[CVAPIRequest alloc] initWithAPIPath:@"/svc/tasks/createDraft"];
        NSMutableDictionary* param = [NSMutableDictionary dictionaryWithObjectsAndKeys:taskRecord, @"taskrecord", nil];
        
        NSDictionary* userInfo = [CVAPIUtil getUserInfo];
        NSTimeZone* timezoneoffset = [CVAPIUtil getCachedTimeZone:[userInfo objectForKey:USER_TIMEZONE] useDefaultTimeZone:[[userInfo objectForKey:USER_DEFAULT_TIMEZONE] isEqualToString:@"1"]];
        NSString* timezone = [NSString stringWithFormat:@"%0.01f", [timezoneoffset secondsFromGMT] / 3600.0];
        [param setObject:[NSDictionary dictionaryWithObjectsAndKeys:timezone, @"tz", nil] forKey:@"_ctx"];
        
        [request setParamString:[param jsonValue]];
        CVAPIListModel* model = [[CVAPIListModel alloc] init];
        [model sendRequest:request completion:^(NSDictionary* apiRequest, NSError* error) {
            [CVAPIUtil alertMessage:LS(@"Task draft saved successfully!", @"")];
            [self stopActivityIndicator];
        }];
    }
    else if ([option isEqualToString:SAVE_TYPE_TEMPLATE]) {
        [taskRecord setObject:_templateName forKey:@"tplName"];
        request = [[CVAPIRequest alloc] initWithAPIPath:@"/svc/tasks/createTemplate"];
        NSMutableDictionary* param = [NSMutableDictionary dictionaryWithObjectsAndKeys:taskRecord, @"taskrecord", nil];
        
        NSDictionary* userInfo = [CVAPIUtil getUserInfo];
        NSTimeZone* timezoneoffset = [CVAPIUtil getCachedTimeZone:[userInfo objectForKey:USER_TIMEZONE] useDefaultTimeZone:[[userInfo objectForKey:USER_DEFAULT_TIMEZONE] isEqualToString:@"1"]];
        NSString* timezone = [NSString stringWithFormat:@"%0.01f", [timezoneoffset secondsFromGMT] / 3600.0];
        [param setObject:[NSDictionary dictionaryWithObjectsAndKeys:timezone, @"tz", nil] forKey:@"_ctx"];
        
        [request setParamString:[param jsonValue]];
        CVAPIListModel* model = [[CVAPIListModel alloc] init];
        [model sendRequest:request completion:^(NSDictionary* apiRequest, NSError* error) {
            [CVAPIUtil alertMessage:LS(@"Task template saved successfully!", @"")];
            [self stopActivityIndicator];
        }];

    }
}

- (void)addTo {
    if (![_addedAssignees count]) {
        [self addCc];
    } else {
        NSMutableArray* orgUserKeys = [NSMutableArray array];
        NSMutableArray* userKeys = [NSMutableArray array];
        for (NSString* key in [_taskData objectForKey:@"assignees"]) {
            [orgUserKeys addObject:key];
        }
        for (NSDictionary* user in _updatedAssignees) {
            [userKeys addObject:[user objectForKey:@"key"]];
        }
        CVAPIRequest* request = [[CVAPIRequest alloc] initWithAPIPath:[NSString stringWithFormat:@"/svc/tasks/%@/participants/add", [_taskData objectForKey:@"key"]]];
        NSDictionary* useroption = [NSDictionary dictionaryWithObjectsAndKeys:orgUserKeys, @"orgUserKeys", userKeys, @"userKeys", @"assignee", @"userType",nil];
        NSDictionary* param = [NSDictionary dictionaryWithObjectsAndKeys:useroption, @"useroption", nil];
        [request setPUTParamString:[param jsonValue] isJsonFormat:YES];
        CVAPIRequestModel* model = [[CVAPIRequestModel alloc] init];
        [model sendRequest:request completion:^(NSDictionary *apiResult, NSError *error) {
            if (!error) {
                [self addCc];
            } else {
                [self cancel:NO];
            }
        }];

    }
    
}

- (void)addCc {
    if (![_addedCCers count]) {
        [self addAttachments];
    } else {
        NSMutableArray* orgUserKeys = [NSMutableArray array];
        NSMutableArray* userKeys = [NSMutableArray array];
        for (NSString* key in [_taskData objectForKey:@"ccers"]) {
            [orgUserKeys addObject:key];
        }
        for (NSDictionary* user in _updatedCCers) {
            [userKeys addObject:[user objectForKey:@"key"]];
        }
        CVAPIRequest* request = [[CVAPIRequest alloc] initWithAPIPath:[NSString stringWithFormat:@"/svc/tasks/%@/participants/add", [_taskData objectForKey:@"key"]]];
        NSDictionary* useroption = [NSDictionary dictionaryWithObjectsAndKeys:orgUserKeys, @"orgUserKeys", userKeys, @"userKeys", @"cc", @"userType",nil];
        NSDictionary* param = [NSDictionary dictionaryWithObjectsAndKeys:useroption, @"useroption", nil];
        [request setPUTParamString:[param jsonValue] isJsonFormat:YES];
        CVAPIRequestModel* model = [[CVAPIRequestModel alloc] init];
        [model sendRequest:request completion:^(NSDictionary *apiResult, NSError *error) {
            if (!error) {
                [self addAttachments];
            } else {
                [self cancel:NO];
            }
        }];
 
    }
}

- (void)addAttachments {
    if (![_addedAttachments count]) {
        [self cancel:NO];
    } else {
        NSMutableArray* orgKeys = [NSMutableArray array];
        NSMutableArray* selectedKeys = [NSMutableArray array];
        for (NSDictionary* attachment in [_taskData objectForKey:@"attachments"]) {
            [orgKeys addObject:[attachment objectForKey:@"key"]];
        }
        for (NSDictionary* user in _updatedAttachments) {
            [selectedKeys addObject:[user objectForKey:@"key"]];
        }
        CVAPIRequest* request = [[CVAPIRequest alloc] initWithAPIPath:[NSString stringWithFormat:@"/svc/tasks/%@/attachments/add", [_taskData objectForKey:@"key"]]];
        NSDictionary* attachmentsOpRecord = [NSDictionary dictionaryWithObjectsAndKeys:orgKeys, @"orgKeys", selectedKeys, @"selectedKeys",nil];
        NSDictionary* param = [NSDictionary dictionaryWithObjectsAndKeys:attachmentsOpRecord, @"attachmentsOpRecord", nil];
        [request setPUTParamString:[param jsonValue] isJsonFormat:YES];
        CVAPIRequestModel* model = [[CVAPIRequestModel alloc] init];
        [model sendRequest:request completion:^(NSDictionary *apiResult, NSError *error) {
            if (!error) {
                NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                [nc postNotificationName:NOTIF_TASK_UPDATE object:nil userInfo:[NSDictionary dictionaryWithObject:[_taskData objectForKey:@"key"] forKey:@"taskKey"]];
                
                // fixed: blank page will present when click back button, so must cancel before alert message
                [self cancel:NO];
                [CVAPIUtil alertMessage:@"Added TO/CC/Attachment successfully!"];
            } else {
                [CVAPIUtil alertMessage:LS(@"Task action failed!", @"")];
            }
            
        }];
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
    
    _sheetForSaveAs = [[UIActionSheet alloc] init];
    _sheetForSaveAs.delegate = self;
    NSString* subType = [_taskData objectForKey:@"subtype"];
    NSString* taskType = [_typeCell getValue];
    BOOL isChatTask = [taskType isEqualToString:LS(TYPE_OPTION_CHAT,@"")];
    if ([subType isEqualToString:@"draft"]) {
        [_sheetForSaveAs addButtonWithTitle:LS(@"Assign", @"")];
        [_sheetForSaveAs addButtonWithTitle:LS(@"Save", @"")];
        [_sheetForSaveAs addButtonWithTitle:LS(@"Save as new", @"")];
    }
    else {
        if(isChatTask) {
            [_sheetForSaveAs addButtonWithTitle:LS(@"Save", @"")];
        }
        else {
            [_sheetForSaveAs addButtonWithTitle:[_taskData objectForKey:@"key"] ? LS(@"Save", @"") : LS(@"Assign", @"")];
            [_sheetForSaveAs addButtonWithTitle:LS(@"Save as draft", @"")];
            [_sheetForSaveAs addButtonWithTitle:LS(@"Save as template", @"")];
        }
    }
    _sheetForSaveAs.destructiveButtonIndex = isChatTask ? 1 : 3;
    [_sheetForSaveAs addButtonWithTitle:LS(@"Cancel", @"")];
    
    [_sheetForSaveAs showFromBarButtonItem:_saveItem animated:YES];
    
}

- (NSString*)getTypeKey:(NSString*) TypeCellValue {
    NSArray* keys = @[TYPE_OPTION_DISCUSSION, TYPE_OPTION_FYI, TYPE_OPTION_CHAT, TYPE_OPTION_ACTION, TYPE_OPTION_APPROVAL];
    for (NSString* key in keys) {
        if([LS(key, @"") isEqualToString:TypeCellValue]) {
            return key;
        }
    }
    return @"";
}

-(NSString*) toAttachmentDisplayString:(NSArray*)updatedAttachments {
    NSMutableString* result = [NSMutableString string];
    for (id file in updatedAttachments) {
        NSString* displayName = [file isKindOfClass:[CVFileListItem class]]? [(CVFileListItem*)file name] : [(NSDictionary*)file objectForKey:@"name"];
        [result appendFormat:(result.length > 0) ? @"; %@" : @"%@", displayName];
    }
    
    return result;
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
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:message
                                                             delegate:self
                                                    cancelButtonTitle:cancelStringForActionSheet()
                                               destructiveButtonTitle:LS(@"OK", @"")
                                                    otherButtonTitles:nil, nil];
    
    [actionSheet showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == _sheetForType) {
        // if click outside of the sheet, treat as selection of the default or previous one
        if (buttonIndex < 0 || buttonIndex >= _typeOptions.count || buttonIndex == actionSheet.cancelButtonIndex)
            return;
        if ([_oldTaskType isEqualToString:@"mail"] && [_updatedCCers count] != 0) {
            [_typeCell setValue:[_typeOptions objectAtIndex:buttonIndex + 3]];
        } else {
            [_typeCell setValue:[_typeOptions objectAtIndex:buttonIndex]];
        }
        NSString* taskType = [ self getTypeKey:[actionSheet buttonTitleAtIndex:buttonIndex]];
        [_taskData setObject:[taskType lowercaseString] forKey:@"taskType"];
        
        [self loadFormCells];
        [self.tableView reloadData];
    }
    else if (actionSheet == _sheetForSaveAs) {
        
        NSString* subType = [_taskData objectForKey:@"subtype"];
        if ([subType isEqualToString:@"draft"]) {
            if (buttonIndex == 0)
                [self saveWithOption:SAVE_TYPE_TASK];
            else if (buttonIndex == 1) {
                _action = @"update";
                [self saveWithOption:SAVE_TYPE_DRAFT];
            }
            else if (buttonIndex == 2) {
                _action = @"create";
                [self saveWithOption:SAVE_TYPE_DRAFT];
            }
        }
        else {
            NSString* taskType = [_typeCell getValue];
            if ([taskType isEqualToString:LS(TYPE_OPTION_CHAT, @"")]) {
                if (buttonIndex == 0) {
                    [self saveWithOption:SAVE_TYPE_TASK];
                } else {
                    [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
                }
                return;
            }
            
            if (buttonIndex == 0)
                [self saveWithOption:SAVE_TYPE_TASK];
            else if (buttonIndex == 1) {
                _action = @"create";
                [self saveWithOption:SAVE_TYPE_DRAFT];
            }
            else if (buttonIndex == 2) {
                _action = @"create";
                _alertForTemplate = [[UIAlertView alloc] initWithTitle:LS(@"Name New Template",@"")
                                                               message:nil
                                                              delegate:self
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:@"Add", @"Cancel", nil];
                _alertForTemplate.alertViewStyle = UIAlertViewStylePlainTextInput;
                [_alertForTemplate show];
            }
        }

    }
    else {
        if (buttonIndex == actionSheet.cancelButtonIndex || buttonIndex == actionSheet.destructiveButtonIndex)
            [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
        else {
#ifdef CV_TARGET_IPAD
            if (_popover)
                [_popover dismissPopoverAnimated:YES];
            else
                [self dismissModalViewController];
#else
            [self popFromStack];
#endif
        }
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == _alertForTemplate){
        if (buttonIndex == 0) {
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
            [_sheetForSaveAs dismissWithClickedButtonIndex:2 animated:NO];
            _templateName = [[alertView textFieldAtIndex:0] text];
            [self saveWithOption:SAVE_TYPE_TEMPLATE];
        }
        if (buttonIndex == 1)
            [_sheetForSaveAs dismissWithClickedButtonIndex:2 animated:NO];
    }

    if (alertView == _alertForRestrict){
        if (buttonIndex == 1) {
            NSString* status = [[(CVOptionCell*)_selectedCell statusLable].text isEqualToString:LS(@"Yes", @"")] ? LS(@"No", @"") : LS(@"Yes", @"");
            [(CVOptionCell*)_selectedCell statusLable].text = status;
            
            if ([status isEqualToString:LS(@"Yes", @"")]) {
                _isRestrictedTask = TRUE;
                
                _updatedAssignees = [CVAPIUtil getCompanyUsersFromUsers:_updatedAssignees];
                
                _updatedCCers = [CVAPIUtil getCompanyUsersFromUsers:_updatedCCers];
            }
        }
    }
}


- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    if (alertView == _alertForTemplate){
    NSString *inputText = [[alertView textFieldAtIndex:0] text];
    if([inputText length] > 0)
        return YES;
    else
        return NO;
}
    return YES;
}

#pragma mark - CVStampsTableViewCellDelegate

- (void)stampsTableViewCell:(CVStampsTableViewCell*)cell didSelectAt:(NSInteger)index {
    
    id object = [cell.items objectAtIndex:index];
    NSArray* initialAssignees = [NSArray array];
    if ([object isKindOfClass:[NSString class]]) {
        if ([((NSString*)object) isEqualToString:@"Add For Assignees"]){            _selectedCell = _assigneesCell;
            initialAssignees = _addPeople ? _addedAssignees : _updatedAssignees;
        } else if([((NSString*)object) isEqualToString:@"Add For CCers"]){
            _selectedCell = _ccersCell;
            initialAssignees = _addPeople ? _addedCCers : _updatedCCers;
        }
        UIViewController* controller = [[CVContactPickerViewController alloc] initWithRecipients:initialAssignees forAddPeople:_addPeople withOptions:@[TYPE_OPTION_ALL, TYPE_OPTION_TRUSTED, TYPE_OPTION_CONNECTED, TYPE_OPTION_ENGAGED, TYPE_OPTION_ACQUAINTANCE, TYPE_OPTION_GROUP, TYPE_OPTION_ADDBOOK]];
        ((CVContactPickerViewController*)controller).delegate = self;
        ((CVContactPickerViewController*)controller).listType = _isRestrictedTask ? CONTACT_LIST_TYPE_RESTRICTED_TASK : CONTACT_LIST_TYPE_TASK;
        
        if (controller)
            [self.navigationController pushViewController:controller animated:YES];
    }
    return;
}
    
#pragma mark -
#pragma mark Public

+ (void) presentTaskFormInPopoverFromBarButtonItem:(UIBarButtonItem *)item withData:(NSDictionary*) data forAddPeople:(BOOL)addPeople {
    
    CVTaskEditViewController* formController = [[CVTaskEditViewController alloc] initWithData:data forAddPeople:addPeople];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:formController];
    
    if (_popover) {
        [_popover dismissPopoverAnimated:NO];
    }
    
    _popover = [[UIPopoverController alloc] initWithContentViewController:nav];
    [_popover presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

+ (void) presentDraftFormInPopoverFromRect:(CGRect)rect inView:(UIView*)view withData:(NSDictionary*) data {
    
    CVTaskEditViewController* formController = [[CVTaskEditViewController alloc] initWithData:data forAddPeople:NO];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:formController];
    
    if (_popover) {
        [_popover dismissPopoverAnimated:NO];
    }
    
    _popover = [[UIPopoverController alloc] initWithContentViewController:nav];
    [_popover presentPopoverFromRect:rect inView:view permittedArrowDirections:0 animated:YES];
}

+ (void) presentTaskForSaveAsNewTaskFromViewController:(UIViewController*)viewController taskKey:(NSString*) key {
    
    CVAPIRequest* request = [[CVAPIRequest alloc] initWithAPIPath:[NSString stringWithFormat:@"/svc/tasks/%@",key]];
    CVAPIRequestModel* model = [[CVAPIRequestModel alloc] init];
    [model sendRequest:request completion:^(NSDictionary* apiResult, NSError* error) {
        if (!error) {
            CVTaskEditViewController* formController = [[CVTaskEditViewController alloc] initWithData:[apiResult objectForKey:@"task"] forAddPeople:NO];
            formController.changeToNewTask = YES;
            UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:formController];
            
            nav.modalPresentationStyle = UIModalPresentationFormSheet;
            nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [viewController presentModalViewController:nav animated:YES];
            nav.view.superview.bounds = CGRectMake(0,0, 500, 660);

//            if (_popover) {
//                [_popover dismissPopoverAnimated:NO];
//            }
//            
//            _popover = [[UIPopoverController alloc] initWithContentViewController:nav];
//            [_popover presentPopoverFromRect:rect inView:view permittedArrowDirections:0 animated:YES];

        } else {
            [CVAPIUtil alertMessage:LS(@"Task action failed!", @"")];
        }
    }];
}

+ (UIPopoverController*) getPopover{
    return _popover;
}
@end
