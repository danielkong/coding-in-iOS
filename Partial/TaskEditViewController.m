
@implementation CVTaskEditViewController

- (id) initWithData:(NSDictionary*)data forAddPeople:(BOOL)addPeople {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {

        _addPeople = addPeople;
        _model = [[CVTaskModel alloc] initWithKey:[data objectForKey:@"key"]];
        _model.delegate = self;
        _taskData = (data != nil) ? [NSMutableDictionary dictionaryWithDictionary:data] : [NSMutableDictionary dictionary];
        // task type key(lower), e.g. "fyi"
        _oldTaskType = [[data objectForKey:@"taskType"] lowercaseString];
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

- (void)stampsTableViewCell:(CVStampsTableViewCell*)cell didSelectAt:(NSInteger)index {
    
    id object = [cell.items objectAtIndex:index];
    NSArray* initialAssignees = [NSArray array];
    if ([object isKindOfClass:[NSString class]]) {
        if ([((NSString*)object) isEqualToString:@"Add For Assignees"]){
            _selectedCell = _assigneesCell;
            initialAssignees = _addPeople ? _addedAssignees : _updatedAssignees;
        } else if([((NSString*)object) isEqualToString:@"Add For CCers"]){
            _selectedCell = _ccersCell;
            initialAssignees = _addPeople ? _addedCCers : _updatedCCers;
        }
        UIViewController* controller;
        
        if ([_taskData objectForKey:@"relatedKey"])
            controller = [[CVContactPickerViewController alloc] initPingPickerWithTask:_oldTaskItem];
        else
            controller = [[CVContactPickerViewController alloc] initWithRecipients:initialAssignees forAddPeople:_addPeople withOptions:@[TYPE_OPTION_ALL, TYPE_OPTION_TRUSTED, TYPE_OPTION_CONNECTED, TYPE_OPTION_ENGAGED, TYPE_OPTION_ACQUAINTANCE, TYPE_OPTION_GROUP, TYPE_OPTION_ADDBOOK]];
        
        ((CVContactPickerViewController*)controller).delegate = self;
        ((CVContactPickerViewController*)controller).listType = _isRestrictedTask ? CONTACT_LIST_TYPE_RESTRICTED_TASK : CONTACT_LIST_TYPE_TASK;
        
        if (controller)
            [self.navigationController pushViewController:controller animated:YES];
    }
    return;
}

+ (void) presentTaskForRelatedTaskWithTaskItemFromViewController:(UIViewController*)viewController taskKey:(NSString*)key taskItem:(CVTaskSvcItem*)taskItem type:(NSString*)relatedType{
    CVTaskEditViewController* formController = [[CVTaskEditViewController alloc] initWithData:@{@"relatedKey" : key, @"relatedType" : relatedType} forAddPeople:NO];
    formController.oldTaskItem = taskItem;
    
#ifdef CV_TARGET_IPAD
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:formController];
    
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [viewController presentViewController:nav animated:YES completion:nil];
    nav.view.superview.bounds = CGRectMake(0,0, 500, 660);
#else
    [formController pushToStack];
#endif
    
}
