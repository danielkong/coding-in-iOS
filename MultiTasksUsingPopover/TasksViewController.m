@interface TasksViewController () <UIActionSheetDelegate, DataModelDelegate, UITableViewDelegate, UISearchBarDelegate, RowItemDelegate, PulldownMenuDelegate>

@property(nonatomic, retain) UIPopoverController* popoverForMenu;
@property(nonatomic, retain) PulldownMenuViewController* menuForSource;
@property(nonatomic, retain) PulldownMenuViewController* menuForType;
@property(nonatomic, retain) PulldownMenuViewController* menuForDuedate;
@property(nonatomic, retain) NSArray* sourceOptionsPath;
@property(nonatomic, retain) NSArray* typeOptionsPath;

@property(nonatomic, retain) NSArray* duedateOptionsPath;

- (void)viewDidLoad {
    [super viewDidLoad];
    _sourceOptionTitles = @[SOURCE_OPTION_ALL, SOURCE_OPTION_INBOX, SOURCE_OPTION_TO, SOURCE_OPTION_CC, SOURCE_OPTION_OUTBOX];
    _sourceOptions = @[TASK_SOURCE_ALL, TASK_SOURCE_INBOX, TASK_SOURCE_TO, TASK_SOURCE_CC, TASK_SOURCE_OUTBOX];
    NSString* source_option_all_path = [NSString stringWithFormat:@"/%@",SOURCE_OPTION_ALL];
    NSString* source_option_inbox_path = [NSString stringWithFormat:@"/%@/%@",SOURCE_OPTION_ALL, SOURCE_OPTION_INBOX];
    NSString* source_option_to_path = [NSString stringWithFormat:@"/%@/%@/%@",SOURCE_OPTION_ALL, SOURCE_OPTION_INBOX, SOURCE_OPTION_TO];
    NSString* source_option_cc_path = [NSString stringWithFormat:@"/%@/%@/%@",SOURCE_OPTION_ALL, SOURCE_OPTION_INBOX, SOURCE_OPTION_CC];
    NSString* source_option_outbox_path = [NSString stringWithFormat:@"/%@/%@",SOURCE_OPTION_ALL, SOURCE_OPTION_OUTBOX];
    _sourceOptionsPath = @[source_option_all_path,source_option_inbox_path,source_option_to_path,source_option_cc_path,source_option_outbox_path];
    _indexOfSourceOption = 0;
    
    _typeOptionTitles = @[TYPE_OPTION_ALL_LS, TYPE_OPTION_MESSAGE_LS, TYPE_OPTION_MAIL_LS, TYPE_OPTION_DISCUSSION_LS, TYPE_OPTION_FYI_LS, TYPE_OPTION_CHAT_LS, TYPE_OPTION_TODO_LS, TYPE_OPTION_ACTION_LS, TYPE_OPTION_APPROVAL_LS];
    _typeOptions = @[TASK_TYPE_ALL, TASK_TYPE_MESSAGE, TASK_TYPE_MAIL, TASK_TYPE_DISCUSSION, TASK_TYPE_FYI, TASK_TYPE_CHAT, TASK_TYPE_TODO, TASK_TYPE_ACTION, TASK_TYPE_APPROVAL];
    NSString* type_option_all_path=[NSString stringWithFormat:@"/%@",TYPE_OPTION_ALL_LS];
    NSString* type_option_mail_path=[NSString stringWithFormat:@"/%@/%@",TYPE_OPTION_ALL_LS,TYPE_OPTION_MAIL_LS];
    NSString* type_option_chat_path=[NSString stringWithFormat:@"/%@/%@",TYPE_OPTION_ALL_LS,TYPE_OPTION_CHAT_LS];
    NSString* type_option_message_path=[NSString stringWithFormat:@"/%@/%@",TYPE_OPTION_ALL_LS,TYPE_OPTION_MESSAGE_LS];
    NSString* type_option_discussion_path=[NSString stringWithFormat:@"/%@/%@/%@",TYPE_OPTION_ALL_LS,TYPE_OPTION_MESSAGE_LS,TYPE_OPTION_DISCUSSION_LS];
    NSString* type_option_FYI_path=[NSString stringWithFormat:@"/%@/%@/%@",TYPE_OPTION_ALL_LS,TYPE_OPTION_MESSAGE_LS,TYPE_OPTION_FYI_LS];
    NSString* type_option_todo_path=[NSString stringWithFormat:@"/%@/%@",TYPE_OPTION_ALL_LS,TYPE_OPTION_TODO_LS];
    NSString* type_option_action_path=[NSString stringWithFormat:@"/%@/%@/%@",TYPE_OPTION_ALL_LS,TYPE_OPTION_TODO_LS,TYPE_OPTION_ACTION_LS];
    NSString* type_option_approval_path=[NSString stringWithFormat:@"/%@/%@/%@",TYPE_OPTION_ALL_LS,TYPE_OPTION_TODO_LS,TYPE_OPTION_APPROVAL_LS];
    _typeOptionsPath=@[type_option_all_path,type_option_mail_path,type_option_chat_path,type_option_message_path,type_option_discussion_path,type_option_FYI_path,type_option_todo_path,type_option_action_path,type_option_approval_path];
    _indexOfTypeOption = 0;
    
    _duedateOptionTitles = @[DUE_OPTION_ALL, DUE_OPTION_TODAY, DUE_OPTION_TOMORROW, DUE_OPTION_WEEK, DUE_OPTION_UPCOMING, DUE_OPTION_OVERDUE];
    _duedateOptions = @[TASK_DUE_ALL, TASK_DUE_TODAY, TASK_DUE_TOMORROW, TASK_DUE_WEEK, TASK_DUE_UPCOMING, TASK_DUE_PAST];
    NSString* due_option_all_path=[NSString stringWithFormat:@"/%@",DUE_OPTION_ALL];
    NSString* due_option_today_path=[NSString stringWithFormat:@"/%@/%@",DUE_OPTION_ALL, DUE_OPTION_TODAY];
    NSString* due_option_tomorrow_path=[NSString stringWithFormat:@"/%@/%@",DUE_OPTION_ALL, DUE_OPTION_TOMORROW];
    NSString* due_option_week_path=[NSString stringWithFormat:@"/%@/%@",DUE_OPTION_ALL, DUE_OPTION_WEEK];
    NSString* due_option_upcoming_path=[NSString stringWithFormat:@"/%@/%@",DUE_OPTION_ALL, DUE_OPTION_UPCOMING];
    NSString* due_option_overdue_path=[NSString stringWithFormat:@"/%@/%@",DUE_OPTION_ALL, DUE_OPTION_OVERDUE];
    _duedateOptionsPath=@[due_option_all_path, due_option_today_path, due_option_tomorrow_path, due_option_week_path, due_option_upcoming_path, due_option_overdue_path];
    _indexOfDuedateOption = 0;

    _sourceButton = CreateFilterButton(SOURCE_BUTTON_WIDTH, SOURCE_BUTTON_ICON);
    [_sourceButton setTitle:SOURCE_OPTION_ALL forState:UIControlStateNormal];
    [_sourceButton addTarget:self action:@selector(sourceItemTouched) forControlEvents:UIControlEventTouchUpInside];
    _sourceItem = [[UIBarButtonItem alloc] initWithCustomView:_sourceButton];
    
    _typeButton = CreateFilterButton(TYPE_BUTTON_WIDTH, TYPE_BUTTON_ICON);
    [_typeButton setTitle:TYPE_OPTION_ALL forState:UIControlStateNormal];
    [_typeButton addTarget:self action:@selector(typeItemTouched) forControlEvents:UIControlEventTouchUpInside];
    _typeItem = [[UIBarButtonItem alloc] initWithCustomView:_typeButton];
    
    _dueButton = CreateFilterButton(DUE_BUTTON_WIDTH, DUE_BUTTON_ICON);
    [_dueButton setTitle:DUE_OPTION_ALL forState:UIControlStateNormal];
    [_dueButton addTarget:self action:@selector(dueDateItemTouched) forControlEvents:UIControlEventTouchUpInside];
    _dueDateItem = [[UIBarButtonItem alloc] initWithCustomView:_dueButton];
}

#pragma mark -
#pragma mark PulldownMenuDelegate

- (void)pulldownMenu:(PulldownMenuViewController *)pulldownMenu didSelectMenuItem:(NSString*) menuItem didSelectMenuIndex:(int) selectedIndex {
    NSString* filterMenuItem = menuItem;
    self.selectedKey = @"";
    
    if (pulldownMenu == _menuForType) {
        _indexOfTypeOption = selectedIndex;
        
        if ([filterMenuItem isEqualToString:TYPE_OPTION_ALL_LS]) {
            [_model updateWithType:TASK_TYPE_ALL];
            [_typeButton setTitle:filterMenuItem forState:UIControlStateNormal];
        } else if ([filterMenuItem isEqualToString:TYPE_OPTION_MESSAGE_LS]) {
            [_model updateWithType:TASK_TYPE_MESSAGE];
            [_typeButton setTitle:filterMenuItem forState:UIControlStateNormal];
        } else if ([filterMenuItem isEqualToString:TYPE_OPTION_MAIL_LS]) {
            [_model updateWithType:TASK_TYPE_MAIL];
            [_typeButton setTitle:filterMenuItem forState:UIControlStateNormal];
        } else if ([filterMenuItem isEqualToString:TYPE_OPTION_DISCUSSION_LS]) {
            [_model updateWithType:TASK_TYPE_DISCUSSION];
            [_typeButton setTitle:filterMenuItem forState:UIControlStateNormal];
        } else if ([filterMenuItem isEqualToString:TYPE_OPTION_FYI_LS]) {
            [_model updateWithType:TASK_TYPE_FYI];
            [_typeButton setTitle:filterMenuItem forState:UIControlStateNormal];
        } else if ([filterMenuItem isEqualToString:TYPE_OPTION_CHAT_LS]) {
            [_model updateWithType:TASK_TYPE_CHAT];
            [_typeButton setTitle:filterMenuItem forState:UIControlStateNormal];
        } else if ([filterMenuItem isEqualToString:TYPE_OPTION_TODO_LS]) {
            [_model updateWithType:TASK_TYPE_TODO];
            [_typeButton setTitle:filterMenuItem forState:UIControlStateNormal];
        } else if ([filterMenuItem isEqualToString:TYPE_OPTION_ACTION_LS]) {
            [_model updateWithType:TASK_TYPE_ACTION];
            [_typeButton setTitle:filterMenuItem forState:UIControlStateNormal];
        } else if ([filterMenuItem isEqualToString:TYPE_OPTION_APPROVAL_LS]) {
            [_model updateWithType:TASK_TYPE_APPROVAL];
            [_typeButton setTitle:filterMenuItem forState:UIControlStateNormal];
        } else {
            [_model updateWithType:TASK_TYPE_ALL];
            [_typeButton setTitle:@"All" forState:UIControlStateNormal];
            [_sourceButton setTitle:@"All" forState:UIControlStateNormal];
            [_dueButton setTitle:@"All" forState:UIControlStateNormal];
        }
        
    } else if (pulldownMenu == _menuForSource) {
        _indexOfSourceOption = selectedIndex;
        
        if ([filterMenuItem isEqualToString:SOURCE_OPTION_ALL]) {
            [_model updateWithFilter:TASK_SOURCE_ALL];
            [_sourceButton setTitle:filterMenuItem forState:UIControlStateNormal];
        } else if ([filterMenuItem isEqualToString:SOURCE_OPTION_INBOX]) {
            [_model updateWithFilter:TASK_SOURCE_INBOX];
            [_sourceButton setTitle:filterMenuItem forState:UIControlStateNormal];
        } else if ([filterMenuItem isEqualToString:SOURCE_OPTION_TO]){
            [_model updateWithFilter:TASK_SOURCE_TO];
            [_sourceButton setTitle:filterMenuItem forState:UIControlStateNormal];
        } else if ([filterMenuItem isEqualToString:SOURCE_OPTION_CC]){
            [_model updateWithFilter:TASK_SOURCE_CC];
            [_sourceButton setTitle:filterMenuItem forState:UIControlStateNormal];
        } else if ([filterMenuItem isEqualToString:SOURCE_OPTION_OUTBOX]){
            [_model updateWithFilter:TASK_SOURCE_OUTBOX];
            [_sourceButton setTitle:filterMenuItem forState:UIControlStateNormal];
        } else {
            [_model updateWithType:TASK_TYPE_ALL];
            [_typeButton setTitle:@"All" forState:UIControlStateNormal];
            [_sourceButton setTitle:@"All" forState:UIControlStateNormal];
            [_dueButton setTitle:@"All" forState:UIControlStateNormal];
        }
        
    } else if (pulldownMenu == _menuForDuedate){
        _indexOfDuedateOption = selectedIndex;
        
        if ([filterMenuItem isEqualToString:DUE_OPTION_ALL]) {
            [_model updateWithDueDate:TASK_DUE_ALL];
            [_sourceButton setTitle:filterMenuItem forState:UIControlStateNormal];
        } else if ([filterMenuItem isEqualToString:DUE_OPTION_TODAY]){
            [_model updateWithDueDate:TASK_DUE_TODAY];
            [_dueButton setTitle:filterMenuItem forState:UIControlStateNormal];
        } else if ([filterMenuItem isEqualToString:DUE_OPTION_TOMORROW]){
            [_model updateWithDueDate:TASK_DUE_TOMORROW];
            [_dueButton setTitle:filterMenuItem forState:UIControlStateNormal];
        } else if ([filterMenuItem isEqualToString:DUE_OPTION_WEEK]){
            [_model updateWithDueDate:TASK_DUE_WEEK];
            [_dueButton setTitle:filterMenuItem forState:UIControlStateNormal];
        } else if ([filterMenuItem isEqualToString:DUE_OPTION_UPCOMING]){
            [_model updateWithDueDate:TASK_DUE_UPCOMING];
            [_dueButton setTitle:filterMenuItem forState:UIControlStateNormal];
        } else if ([filterMenuItem isEqualToString:DUE_OPTION_OVERDUE]){
            [_model updateWithDueDate:TASK_DUE_PAST];
            [_dueButton setTitle:filterMenuItem forState:UIControlStateNormal];
        } else {
            [_model updateWithType:TASK_TYPE_ALL];
            [_typeButton setTitle:@"All" forState:UIControlStateNormal];
            [_sourceButton setTitle:@"All" forState:UIControlStateNormal];
            [_dueButton setTitle:@"All" forState:UIControlStateNormal];
        }
        
    } else {
        [_model updateWithType:TASK_TYPE_ALL];
        [_typeButton setTitle:@"All" forState:UIControlStateNormal];
        [_sourceButton setTitle:@"All" forState:UIControlStateNormal];
        [_dueButton setTitle:@"All" forState:UIControlStateNormal];
    }
    
    [self showLoading:YES];

    [_popoverForMenu dismissPopoverAnimated:YES];
    
    return;
}

- (void) sourceItemTouched {
    
    [self closeAllSheets];

    _menuForSource = [[PulldownMenuViewController alloc]initWithMenuItems:_sourceOptionsPath selectedIndex: _indexOfSourceOption];
    _menuForSource.delegate = self;
    
    if (_popoverForMenu)
        [_popoverForMenu dismissPopoverAnimated:NO];
    
    _popoverForMenu = [[UIPopoverController alloc]initWithContentViewController:_menuForSource];
    _popoverForMenu.popoverBackgroundViewClass = [PopoverBackgroundView class];    
    [_popoverForMenu presentPopoverFromBarButtonItem:_sourceItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];    
}

- (void) typeItemTouched {
    
    [self closeAllSheets];

    _menuForType = [[PulldownMenuViewController alloc]initWithMenuItems:_typeOptionsPath selectedIndex: _indexOfTypeOption];
    _menuForType.delegate = self;

    if (_popoverForMenu)
        [_popoverForMenu dismissPopoverAnimated:NO];

    _popoverForMenu = [[UIPopoverController alloc]initWithContentViewController:_menuForType];
    _popoverForMenu.popoverBackgroundViewClass = [PopoverBackgroundView class];
    [_popoverForMenu presentPopoverFromBarButtonItem:_typeItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)dueDateItemTouched {
    
    [self closeAllSheets];

    _menuForDuedate = [[PulldownMenuViewController alloc]initWithMenuItems:_duedateOptionsPath  selectedIndex: _indexOfDuedateOption];
    _menuForDuedate.delegate = self;
    
    if (_popoverForMenu)
        [_popoverForMenu dismissPopoverAnimated:NO];

    _popoverForMenu = [[UIPopoverController alloc]initWithContentViewController:_menuForDuedate];
    _popoverForMenu.popoverBackgroundViewClass = [PopoverBackgroundView class];
    [_popoverForMenu presentPopoverFromBarButtonItem:_dueDateItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)resetItemTouched {
    
    [_sourceButton setTitle:SOURCE_OPTION_ALL forState:UIControlStateNormal];
    [_typeButton setTitle:TYPE_OPTION_ALL forState:UIControlStateNormal];
    [_dueButton setTitle:DUE_OPTION_ALL forState:UIControlStateNormal];
    
    _indexOfDuedateOption = 0;
    _indexOfSourceOption = 0;
    _indexOfTypeOption = 0;
    
    Session* session = [Session sessionInManagedObjectContext:[[DataStore sharedDataStore] managedObjectContext]];
    session.taskSource = TASK_SOURCE_ALL;
    session.taskType = TASK_TYPE_ALL;
    session.taskDueDate = TASK_DUE_ALL;
    
    [_model.query setObject:TASK_SOURCE_ALL forKey:@"filter"];
    [_model.query setObject:TASK_TYPE_ALL forKey:@"subType"];
    [_model.query setObject:TASK_DUE_ALL forKey:@"dueDateFilter"];
    
    [_model updateWithFilter:TASK_SOURCE_ALL withType:TASK_TYPE_ALL withDuedate:TASK_DUE_ALL ];
    
}
