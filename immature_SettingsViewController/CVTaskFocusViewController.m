//
//  TaskFocusViewController.m
//
//  Created by Daniel Kong on 10/16/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVTaskFocusViewController.h"
#import "CVContactRequestItemCell.h"
#import "IPadContactItemCell.h"

#import "people.h"
#import "IPadTextPickerViewController.h"
#import "CVTaskFocusCell.h"
#import "CVTaskFocusItem.h"

@interface CVTaskFocusViewController () <IPadTextPickerViewControllerDelegate>

@property(nonatomic, retain)NSArray *person;
@property(nonatomic, retain) UISegmentedControl* segmentControl;
@property(nonatomic, retain) UIBarButtonItem* segmentItem;
@property(nonatomic, assign) NSInteger indexOfFilterOption;

@property(nonatomic, retain) NSMutableArray* _rows;

@property(nonatomic, retain) NSString* settingItem;
@property(nonatomic, retain) NSArray* statusDS;
@property(nonatomic, retain) NSArray* roleDS;
@property(nonatomic, retain) NSArray* typeDS;
@property(nonatomic, retain) NSArray* dueDateDS;
@property(nonatomic, assign) BOOL isMultipleSelection;
@property(nonatomic, retain) CVTaskFocusItem* tempSelectedItem;

@end

@implementation CVTaskFocusViewController 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        __rows = [NSMutableArray array];

        
        _cancelItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Cancel", @"")
                                                       style:UIBarButtonSystemItemCancel
                                                      target:self
                                                      action:@selector(cancel)];
        
        _updateItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Update", @"")
                                                       style:UIBarButtonItemStyleDone
                                                      target:self
                                                      action:@selector(update)];
        
        self.navigationItem.rightBarButtonItem =_updateItem;
        
        self.navigationItem.leftBarButtonItem=_cancelItem;
        
        self.tableView.dataSource=self;
        self.tableView.delegate=self;
        self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundColor = RGBCOLOR(233, 233, 233);
        self.tableView.allowsSelection = YES;
        
        if (getOSf() >= 7.0)
            self.tableView.separatorInset = UIEdgeInsetsZero;
        
    }
    return self;
}

- (void)dealloc {
    self.tableView.delegate = nil;
    self.tableView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showSettingItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//        self.title = @"Focus Settings";

}

#pragma mark -
#pragma mark private

-(void) showSettingItem {
    if(_settingItem == nil || [_settingItem isEqualToString:@""])
        _settingItem = SETTING_ITEM_PROFILE;
    
    if ([_settingItem isEqualToString:SETTING_ITEM_PROFILE])
        [self showTaskFocusForm];
    else if ([_settingItem isEqualToString:SETTING_ITEM_ACCOUNT])
        [self showFileFocusForm];
    else if ([_settingItem isEqualToString:SETTING_ITEM_LANGUAGE])
        [self showFolderFocusForm];

}


-(void) showTaskFocusForm {
    self.title = @"Make it happy.";
    
    NSArray* normalField = @[@"title 1", @"title 2", @"title 3"];
    NSArray* normalFieldValue = [NSArray arrayWithObjects:@"title-1-Default-Value", @"title-2-Default-Value", @"title-3-Default-Value", nil];
    NSArray* normalFieldType = @[@"toggle", @"singlton", @"multiple"];
    
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
    [tempDict setValue:@"test1-1" forKey:@"value"];
    [tempDict setValue:@"test1-2" forKey:@"name"];
    
    NSMutableDictionary *tempDict2 = [NSMutableDictionary dictionary];
    [tempDict2 setValue:@"test2-1" forKey:@"value"];
    [tempDict2 setValue:@"test2-2" forKey:@"name"];
    
    NSMutableDictionary *tempDict3 = [NSMutableDictionary dictionary];
    [tempDict3 setValue:@"test3-1" forKey:@"value"];
    [tempDict3 setValue:@"test3-2" forKey:@"name"];
    _statusDS = @[tempDict, tempDict2, tempDict3];
    _roleDS = @[tempDict2, tempDict, tempDict3];
    NSArray* normalFieldOptions = @[@[],
                                    _statusDS,
                                    _roleDS
                                    ];
    NSMutableArray* rowsInNormalSection = [NSMutableArray array];
    for (NSUInteger index = 0; index < [normalField count]; index++) {
//        CVTaskFocusCell* cell = [[CVTaskFocusCell alloc] initWithTitle:[normalField objectAtIndex:index] andTextField:NO];
//        cell.frame = CGRectZero;
//        cell.textField.text = [normalFieldValue objectAtIndex:index];
//        cell.textLabel.text = [normalFieldValue objectAtIndex:index];
//        [rowsInNormalSection addObject:cell];
        
        CVTaskFocusItem* item = [[CVTaskFocusItem alloc] initWithFname:[normalField objectAtIndex:index] alname:[normalFieldValue objectAtIndex:index] type:[normalFieldType objectAtIndex:index] options:[normalFieldOptions objectAtIndex:index] age:3];
        [rowsInNormalSection addObject:item];
        
    }
    [__rows addObject:rowsInNormalSection];
    self.rows = __rows;
    
    

//    people *pl1 = [[people alloc] initWithFname:@"Hello" alname:@"High Priority" color:[UIColor purpleColor] age:23];
//    people *pl2 = [[people alloc] initWithFname:@"Hello" alname:@"Status:" color:[UIColor greenColor] age:223];
//    people *pl3 = [[people alloc] initWithFname:@"Hello" alname:@"My Role:" color:[UIColor greenColor] age:223];
//    people *pl4 = [[people alloc] initWithFname:@"Hello" alname:@"Type:" color:[UIColor greenColor] age:223];
//    people *pl5 = [[people alloc] initWithFname:@"Hello" alname:@"Due Date:" color:[UIColor greenColor] age:223];
//    
//    self.person = [NSArray arrayWithObjects:pl1, pl2, pl3, pl4, pl5, nil];
//    
//    self.rows = @[self.person];
//    self.tableView.dataSource = self;
//    self.tableView.delegate = self;
//    
//    //indexPath.row == 1
//    NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
//    [tempDict setValue:@"test1-1" forKey:@"value"];
//    [tempDict setValue:@"test1-2" forKey:@"name"];
//    
//    NSMutableDictionary *tempDict2 = [NSMutableDictionary dictionary];
//    [tempDict2 setValue:@"test2-1" forKey:@"value"];
//    [tempDict2 setValue:@"test2-2" forKey:@"name"];
//    
//    NSMutableDictionary *tempDict3 = [NSMutableDictionary dictionary];
//    [tempDict3 setValue:@"test3-1" forKey:@"value"];
//    [tempDict3 setValue:@"test3-2" forKey:@"name"];
//    _statusDS = @[tempDict, tempDict2, tempDict3];
//    
//    //indexPath.row == 2
//    NSMutableDictionary *roleDict = [NSMutableDictionary dictionary];
//    [roleDict setValue:@"role1-1" forKey:@"value"];
//    [roleDict setValue:@"test1-2" forKey:@"name"];
//    
//    NSMutableDictionary *roleDict2 = [NSMutableDictionary dictionary];
//    [roleDict2 setValue:@"role2-1" forKey:@"value"];
//    [roleDict2 setValue:@"test2-2" forKey:@"name"];
//    
//    NSMutableDictionary *roleDict3 = [NSMutableDictionary dictionary];
//    [roleDict3 setValue:@"role3-1" forKey:@"value"];
//    [roleDict3 setValue:@"test3-2" forKey:@"name"];
//    _roleDS = @[roleDict, roleDict2, roleDict3];
//    
//    // set type Data Source (row == 3)
//    NSMutableDictionary *typeDict = [NSMutableDictionary dictionary];
//    [typeDict setValue:@"type1-1" forKey:@"value"];
//    [typeDict setValue:@"test1-2" forKey:@"name"];
//    
//    NSMutableDictionary *typeDict2 = [NSMutableDictionary dictionary];
//    [typeDict2 setValue:@"type2-1" forKey:@"value"];
//    [typeDict2 setValue:@"test2-2" forKey:@"name"];
//    
//    NSMutableDictionary *typeDict3 = [NSMutableDictionary dictionary];
//    [typeDict3 setValue:@"type3-1" forKey:@"value"];
//    [typeDict3 setValue:@"test3-2" forKey:@"name"];
//    _typeDS = @[typeDict, typeDict2, typeDict3];
//    
//    // set dueDate Data Source (row == 4)
//    NSMutableDictionary *dueDateDict = [NSMutableDictionary dictionary];
//    [dueDateDict setValue:@"due1-1" forKey:@"value"];
//    [dueDateDict setValue:@"test1-2" forKey:@"name"];
//    
//    NSMutableDictionary *dueDateDict2 = [NSMutableDictionary dictionary];
//    [dueDateDict2 setValue:@"due2-1" forKey:@"value"];
//    [dueDateDict2 setValue:@"test2-2" forKey:@"name"];
//    
//    NSMutableDictionary *dueDateDict3 = [NSMutableDictionary dictionary];
//    [dueDateDict3 setValue:@"due3-1" forKey:@"value"];
//    [dueDateDict3 setValue:@"test3-2" forKey:@"name"];
//    _dueDateDS = @[dueDateDict, dueDateDict2, dueDateDict3];
    
}

-(void) showFileFocusForm {

}

-(void) showFolderFocusForm {

}


- (void)switchChanged:(UISwitch *)sender
{
    UITableViewCell *theParentCell = [[sender superview] superview];
    NSIndexPath *indexPathOfSwitch = [self.tableView indexPathForCell:(UITableViewCell *)theParentCell];
    //    NSLog(@"the index path of the switch: %d", indexPathOfSwitch.row);
    if(sender.on){
        [switchStatus replaceObjectAtIndex:indexPathOfSwitch.row withObject:@"ON"];
    } else {
        [switchStatus replaceObjectAtIndex:indexPathOfSwitch.row withObject:@"OFF"];
    }
}

- (void)updateMultipleSelection:(id)sender
{
    NSLog(@"I like it!");
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark -
#pragma mark CVBaseListViewController


//- (void)handlePullToRefresh:(SVPullToRefreshView *)refreshView {
//    [self showLoading:YES];
//    //[_rows loadMore:NO];
//}

- (Class)cellClassForObject:(id)object {
    
    if ([object isKindOfClass:[CVTaskFocusItem class]])
        
        return [CVTaskFocusCell class];
    if ([object isKindOfClass:[CVTaskFocusCell class]])
        return [CVTaskFocusCell class];
    
    
    return [super cellClassForObject:object];
}



#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

//    MenuTableViewCell *cell = (MenuTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[MenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
    UISwitch *theSwitch = nil;

    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    CVTaskFocusItem *pl = [[self.rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    ((CVTaskFocusCell*)cell).textLabel.text = pl.lname;
//    cell.textLabel.text = pl.lname;
//    cell.textLabel.backgroundColor = [UIColor purpleColor];
    ((CVTaskFocusCell*)cell).textField.backgroundColor = [UIColor greenColor];
    ((CVTaskFocusCell*)cell).textField.text = pl.selectedOption;
    ((CVTaskFocusCell*)cell).labelField.text = pl.fname;
    
    theSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    CGRect frame = theSwitch.frame;
    frame.origin.x = 360;
    frame.origin.y = 9;
    theSwitch.frame = frame;
    theSwitch.tag = 100;
    [theSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    if ([[[[self.rows objectAtIndex:indexPath.section ] objectAtIndex:indexPath.row] itemType] isEqualToString:@"toggle"]) {
        [cell.contentView addSubview:theSwitch];
        ((CVTaskFocusCell*)cell).textField.hidden = YES;
    } else {
//        ((CVTaskFocusCell*)cell).textField.text = pl.lname;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // remember the switch on/off
    if([[switchStatus objectAtIndex:indexPath.row] isEqualToString:@"ON"]){
        theSwitch.on = YES;
    } else {
        theSwitch.on = NO;
    }

    
    
    return cell;
    
//    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
//    if ([cell isKindOfClass:[people class]]) {
//        people *pl = [self.person objectAtIndex:indexPath.row];
//        cell.textLabel.text = pl.lname;
//    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.rows objectAtIndex:0] count];
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
    
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    IPadTextPickerViewController* controller = [[IPadTextPickerViewController alloc] init];
    
    
    if ([[[[self.rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] itemType] isEqualToString:@"singlton"] ) {
        controller = [controller initWithTitle:LS(@"Select Status",@"") andDataSource:[[[self.rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] itemOptions]];
        controller.isMultipleSelection = NO;
        _isMultipleSelection = NO;
        controller.initialSelection = ((CVTaskFocusCell*)cell).textField.text;
        controller.delegate = self;

        [self.navigationController pushViewController:controller animated:YES];
    } else if ( [[[[self.rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] itemType] isEqualToString:@"multiple"]) {
        controller = [controller initWithTitle:LS(@"Select Status",@"") andDataSource:[[[self.rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] itemOptions]];
        controller.isMultipleSelection = YES;
        _isMultipleSelection = YES;
        controller.initialSelection = ((CVTaskFocusCell*)cell).textField.text;
        controller.delegate = self;
        
        _updateItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"OK", @"")
                                                       style:UIBarButtonItemStyleDone
                                                      target:self
                                                      action:@selector(updateMultipleSelection:)];
        controller.navigationItem.rightBarButtonItem =_updateItem;
        
        [self.navigationController pushViewController:controller animated:YES];
        
//        _cancelItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Cancel", @"")
//                                                       style:UIBarButtonSystemItemCancel
//                                                      target:self
//                                                      action:@selector(cancel2)];
//        

//        self.navigationItem.leftBarButtonItem=_cancelItem;
        

    }
    

    
//    if (indexPath.row == 1) {
//        controller = [controller initWithTitle:LS(@"Select Status",@"") andDataSource:_statusDS];
//        controller.initialSelection = ((CVTaskFocusCell*)cell).textField.text;
//        controller.delegate = self;
//
//        [self.navigationController pushViewController:controller animated:YES];
//    } else if (indexPath.row == 2) {
//        controller = [controller initWithTitle:LS(@"Select Role",@"") andDataSource:_roleDS];
//        controller.initialSelection = ((CVTaskFocusCell*)cell).textField.text;
//        controller.delegate = self;
//        
//        [self.navigationController pushViewController:controller animated:YES];
//
//    } else if (indexPath.row == 3) {
//        controller = [controller initWithTitle:LS(@"Select Type",@"") andDataSource:_typeDS];
//        controller.initialSelection = ((CVTaskFocusCell*)cell).textField.text;
//        controller.delegate = self;
//        
//        [self.navigationController pushViewController:controller animated:YES];
//    } else if (indexPath.row == 4) {
//        controller = [controller initWithTitle:LS(@"Select Due Date",@"") andDataSource:_dueDateDS];
//        controller.initialSelection = ((CVTaskFocusCell*)cell).textField.text;
//        controller.delegate = self;
//        
//        [self.navigationController pushViewController:controller animated:YES];
//    }
    
    controller.navigationItem.hidesBackButton = NO;

//    CVContactItem* item = [[self.rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    
//    if (_model.isActionMode) {
//        
//        // update selectedContacts in model and IPadContactItem with selection
//        item.checked = !item.checked;
//        
//        if ([_model.selectedKeys containsObject:item.key]) {
//            [_model.selectedKeys removeObject:item.key];
//            [_selectedItems removeObjectForKey:item.key];
//        }
//        else {
//            [_model.selectedKeys addObject:item.key];
//            [_selectedItems setObject:item forKey:item.key];
//        }
//        
//        
//        // update the selected cell
//        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        
//        // update _createTaskItem.enabled
//        [self updateStatusOfButtons];
//        
//    } else {
//        self.selectedKey = item.key;
//        CVProfileViewController* pVC = [[CVProfileViewController alloc] initWithKey:self.selectedKey];
//        [pVC pushToStackFromViewController:self];
//    }
}

#pragma mark -
#pragma mark IPadTextPickerDelegate

- (void)didSelectTextPicker:(NSDictionary *)selection {
    if (!_isMultipleSelection) {
        NSIndexPath* selectedIndexPath = self.tableView.indexPathForSelectedRow;
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
        ((CVTaskFocusCell*)cell).textField.text = [selection objectForKey:@"value"];
        _tempSelectedItem = [[self.rows objectAtIndex:selectedIndexPath.section] objectAtIndex:selectedIndexPath.row] ;
//        [temp2 setNewSelectedOption:[selection objectForKey:@"value"]];
        [_tempSelectedItem setNewSelectedOption:[selection objectForKey:@"value"] isMultiple:NO];
        
//        NSString * selectedName = [selection objectForKey:@"name"];
        
        [self.tableView reloadRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        NSIndexPath* selectedIndexPath = self.tableView.indexPathForSelectedRow;
        if (selectedIndexPath){
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
            ((CVTaskFocusCell*)cell).textField.text = [selection objectForKey:@"value"];
            _tempSelectedItem = [[self.rows objectAtIndex:selectedIndexPath.section] objectAtIndex:selectedIndexPath.row] ;
        }
//        ((CVTaskFocusCell*)cell).textField.text = [selection objectForKey:@"value"];
        [_tempSelectedItem setNewSelectedOption:[selection objectForKey:@"value"] isMultiple:YES];

//        [self.tableView reloadRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView reloadData];
    }
}

@end
