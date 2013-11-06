//
//  CVTaskFocusViewController.m
//  Vmoso
//
//  Created by Daniel Kong on 10/16/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVFocusViewController.h"
#import "CVContactRequestItemCell.h"
#import "IPadContactItemCell.h"

#import "IPadTextPickerViewController.h"
#import "CVFocusCell.h"
#import "CVFocusItem.h"
#import "CVAPIRequest.h"
#import "CVAPIRequestModel.h"
#import "CVContactPickerViewController.h"
#import "CVContactPickerImageCollectionCell.h"
#import "CVContactItem.h"
#import "CVContactItem+Bizlogic.h"

@interface CVFocusViewController () <IPadTextPickerViewControllerDelegate, ContactPickerDelegate, UICollectionViewDelegate, UICollectionViewDataSource,  UIActionSheetDelegate>

@property(nonatomic, retain) NSMutableArray* rowsDS;

@property(nonatomic, retain) NSString* settingItem;
@property(nonatomic, retain) NSArray* statusDS;
@property(nonatomic, retain) NSArray* roleDS;
@property(nonatomic, retain) NSArray* typeDS;
@property(nonatomic, retain) NSArray* dueDateDS;
@property(nonatomic, retain) CVFocusItem* tempSelectedItem;
@property(nonatomic, retain) UIView* imageCollectionViewContainer;
@property(nonatomic, retain) UICollectionView* imageCollectionView;
@property(nonatomic, retain) NSMutableArray* selectedOwners;
@property(nonatomic, retain) NSIndexPath* OwnersIndexPath;


@end

@implementation CVFocusViewController

- (id)initWithType:(NSString *)type
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        _rowsDS = [NSMutableArray array];
        _settingItem = type;
        
        _cancelItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Cancel", @"")
                                                       style:UIBarButtonSystemItemCancel
                                                      target:self
                                                      action:@selector(cancel)];
        
        _updateItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Save", @"")
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
    
    // Image picker collection view
    
    _imageCollectionViewContainer = [[UIView alloc] initWithFrame:CGRectMake(120, 0, 190, 50)];
    _imageCollectionViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setItemSize:CGSizeMake(30, 30)];
    [flowLayout setMinimumInteritemSpacing:0.f];
    [flowLayout setMinimumLineSpacing:10.f];
    
    _imageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 7, _imageCollectionViewContainer.width - 30,  _imageCollectionViewContainer.height - 7*2) collectionViewLayout:flowLayout];
    _imageCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _imageCollectionView.delegate = self;
    _imageCollectionView.dataSource = self;
    _imageCollectionView.backgroundColor = [UIColor clearColor];
    _imageCollectionView.showsHorizontalScrollIndicator = NO;
    [_imageCollectionViewContainer addSubview:_imageCollectionView];
    
    [_imageCollectionView registerClass:[CVContactPickerImageCollectionCell class] forCellWithReuseIdentifier:@"selectingCollectionViewCell"];

    [self showSettingItem];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark private

-(void) showSettingItem {
    self.topBar.hidden = YES;

    if(_settingItem == nil || [_settingItem isEqualToString:@""])
        _settingItem = SETTING_FOCUS_TASK;
    
    if ([_settingItem isEqualToString:SETTING_FOCUS_TASK])
        [self showTaskFocusForm];
    else if ([_settingItem isEqualToString:SETTING_FOCUS_FILE])
        [self showFileFocusForm];
    
    [_imageCollectionView reloadData];

}

-(void) showFileFocusForm {
    self.title = LS(@"New File Focus", @"");
    
    NSArray* normalField = @[LS(@"Type", @""), LS(@"My/Shared", @""), LS(@"Last updated", @""), LS(@"Owners" ,@"")];
    NSArray* normalFieldValue = [NSArray arrayWithObjects:LS(@"All", @""), LS(@"All", @""), LS(@"All", @""), @" ", nil];
    NSArray* normalFieldType = @[@"singlton", @"singlton", @"singlton", @"picker"];
    
    NSMutableDictionary *tempDictForStatus = [NSMutableDictionary dictionary];
    [tempDictForStatus setValue:LS(@"All", @"") forKey:@"value"];
    [tempDictForStatus setValue:@"All" forKey:@"name"];
    
    NSMutableDictionary *tempDict2ForStatus = [NSMutableDictionary dictionary];
    [tempDict2ForStatus setValue:LS(@"Documents", @"") forKey:@"value"];
    [tempDict2ForStatus setValue:@"Documents" forKey:@"name"];
    
    NSMutableDictionary *tempDict3ForStatus = [NSMutableDictionary dictionary];
    [tempDict3ForStatus setValue:LS(@"Images", @"") forKey:@"value"];
    [tempDict3ForStatus setValue:@"Images" forKey:@"name"];
    
    NSMutableDictionary *tempDict4ForStatus = [NSMutableDictionary dictionary];
    [tempDict4ForStatus setValue:LS(@"Audio", @"") forKey:@"value"];
    [tempDict4ForStatus setValue:@"Audio" forKey:@"name"];
    
    NSMutableDictionary *tempDict5ForStatus = [NSMutableDictionary dictionary];
    [tempDict5ForStatus setValue:LS(@"Video", @"") forKey:@"value"];
    [tempDict5ForStatus setValue:@"Video" forKey:@"name"];
    
    _typeDS = @[tempDictForStatus, tempDict2ForStatus, tempDict3ForStatus, tempDict4ForStatus, tempDict5ForStatus];
    
    NSMutableDictionary *tempDictForRole = [NSMutableDictionary dictionary];
    [tempDictForRole setValue:LS(@"All", @"") forKey:@"value"];
    [tempDictForRole setValue:@"All" forKey:@"name"];
    
    NSMutableDictionary *tempDict2ForRole = [NSMutableDictionary dictionary];
    [tempDict2ForRole setValue:LS(@"My Files", @"") forKey:@"value"];
    [tempDict2ForRole setValue:@"My Files" forKey:@"name"];
    
    NSMutableDictionary *tempDict3ForRole = [NSMutableDictionary dictionary];
    [tempDict3ForRole setValue:LS(@"Shared Files", @"") forKey:@"value"];
    [tempDict3ForRole setValue:@"Shared Files" forKey:@"name"];
    
    _roleDS = @[tempDictForRole, tempDict2ForRole, tempDict3ForRole];
    
    NSMutableDictionary *tempDictForDueDate = [NSMutableDictionary dictionary];
    [tempDictForDueDate setValue:LS(@"All", @"") forKey:@"value"];
    [tempDictForDueDate setValue:@"All" forKey:@"name"];
    
    NSMutableDictionary *tempDict2ForDueDate = [NSMutableDictionary dictionary];
    [tempDict2ForDueDate setValue:LS(@"Today", @"") forKey:@"value"];
    [tempDict2ForDueDate setValue:@"Today" forKey:@"name"];
    
    NSMutableDictionary *tempDict3ForDueDate = [NSMutableDictionary dictionary];
    [tempDict3ForDueDate setValue:LS(@"Yesterday", @"") forKey:@"value"];
    [tempDict3ForDueDate setValue:@"Yesterday" forKey:@"name"];
    
    NSMutableDictionary *tempDict4ForDueDate = [NSMutableDictionary dictionary];
    [tempDict4ForDueDate setValue:LS(@"This Week", @"") forKey:@"value"];
    [tempDict4ForDueDate setValue:@"This Week" forKey:@"name"];
    
    NSMutableDictionary *tempDict5ForDueDate = [NSMutableDictionary dictionary];
    [tempDict5ForDueDate setValue:LS(@"This Month", @"") forKey:@"value"];
    [tempDict5ForDueDate setValue:@"This Month" forKey:@"name"];

    _dueDateDS = @[tempDictForDueDate, tempDict2ForDueDate, tempDict3ForDueDate, tempDict4ForDueDate, tempDict5ForDueDate];
    
    NSArray* normalFieldOptions = @[_typeDS,
                                    _roleDS,
                                    _dueDateDS,
                                    @[]
                                    ];
    NSMutableArray* rowsInNormalSection = [NSMutableArray array];
    for (NSUInteger index = 0; index < [normalField count]; index++) {
        CVFocusItem* item = [[CVFocusItem alloc] initWithTitle:[normalField objectAtIndex:index] selectedOption:[normalFieldValue objectAtIndex:index] type:[normalFieldType objectAtIndex:index] options:[normalFieldOptions objectAtIndex:index]];
        [rowsInNormalSection addObject:item];
        
    }
    [_rowsDS addObject:rowsInNormalSection];

    self.rows = _rowsDS;
}

-(void) showTaskFocusForm {
    self.title = LS(@"New Task Focus",@"");
    
    NSArray* normalField = @[LS(@"High Priority" ,@""), LS(@"Status" ,@""), LS(@"My Role" ,@""), LS(@"Type" ,@""), LS(@"Due Date" ,@""), LS(@"Owners" ,@"")];
    NSArray* normalFieldValue = [NSArray arrayWithObjects:@"no", LS(@"All" ,@""), LS(@"All" ,@""), LS(@"All" ,@""), LS(@"All" ,@""),@" ", nil];
    NSArray* normalFieldType = @[@"toggle", @"singlton", @"singlton", @"singlton", @"singlton",@"picker"];
    
    NSMutableDictionary *tempDictForStatus = [NSMutableDictionary dictionary];
    [tempDictForStatus setValue:LS(@"All", @"") forKey:@"value"];
    [tempDictForStatus setValue:@"All" forKey:@"name"];
    
    NSMutableDictionary *tempDict2ForStatus = [NSMutableDictionary dictionary];
    [tempDict2ForStatus setValue:LS(@"New", @"") forKey:@"value"];
    [tempDict2ForStatus setValue:@"New" forKey:@"name"];
    
    NSMutableDictionary *tempDict3ForStatus = [NSMutableDictionary dictionary];
    [tempDict3ForStatus setValue:LS(@"Open", @"") forKey:@"value"];
    [tempDict3ForStatus setValue:@"Open" forKey:@"name"];
    
    NSMutableDictionary *tempDict4ForStatus = [NSMutableDictionary dictionary];
    [tempDict4ForStatus setValue:LS(@"Done", @"") forKey:@"value"];
    [tempDict4ForStatus setValue:@"Done" forKey:@"name"];
    
    NSMutableDictionary *tempDict5ForStatus = [NSMutableDictionary dictionary];
    [tempDict5ForStatus setValue:LS(@"Draft", @"") forKey:@"value"];
    [tempDict5ForStatus setValue:@"Draft" forKey:@"name"];
    
    NSMutableDictionary *tempDict6ForStatus = [NSMutableDictionary dictionary];
    [tempDict6ForStatus setValue:LS(@"Closed", @"") forKey:@"value"];
    [tempDict6ForStatus setValue:@"Closed" forKey:@"name"];
    
    NSMutableDictionary *tempDict7ForStatus = [NSMutableDictionary dictionary];
    [tempDict7ForStatus setValue:LS(@"Suspended", @"") forKey:@"value"];
    [tempDict7ForStatus setValue:@"Suspended" forKey:@"name"];
    
    NSMutableDictionary *tempDict8ForStatus = [NSMutableDictionary dictionary];
    [tempDict8ForStatus setValue:LS(@"Archived", @"") forKey:@"value"];
    [tempDict8ForStatus setValue:@"Archived" forKey:@"name"];
    
    NSMutableDictionary *tempDict9ForStatus = [NSMutableDictionary dictionary];
    [tempDict9ForStatus setValue:LS(@"Declined", @"") forKey:@"value"];
    [tempDict9ForStatus setValue:@"Declined" forKey:@"name"];
    
    NSMutableDictionary *tempDict10ForStatus = [NSMutableDictionary dictionary];
    [tempDict10ForStatus setValue:LS(@"Trash", @"") forKey:@"value"];
    [tempDict10ForStatus setValue:@"Trash" forKey:@"name"];
    _statusDS = @[tempDictForStatus, tempDict2ForStatus, tempDict3ForStatus, tempDict4ForStatus, tempDict5ForStatus, tempDict6ForStatus, tempDict7ForStatus, tempDict8ForStatus, tempDict9ForStatus, tempDict10ForStatus];
    
    NSMutableDictionary *tempDictForRole = [NSMutableDictionary dictionary];
    [tempDictForRole setValue:LS(@"All", @"") forKey:@"value"];
    [tempDictForRole setValue:@"All" forKey:@"name"];
    
    NSMutableDictionary *tempDict2ForRole = [NSMutableDictionary dictionary];
    [tempDict2ForRole setValue:LS(@"To", @"") forKey:@"value"];
    [tempDict2ForRole setValue:@"To" forKey:@"name"];
    
    NSMutableDictionary *tempDict3ForRole = [NSMutableDictionary dictionary];
    [tempDict3ForRole setValue:LS(@"Cc", @"") forKey:@"value"];
    [tempDict3ForRole setValue:@"Cc" forKey:@"name"];
    
    NSMutableDictionary *tempDict4ForRole = [NSMutableDictionary dictionary];
    [tempDict4ForRole setValue:LS(@"Sent", @"") forKey:@"value"];
    [tempDict4ForRole setValue:@"Sent" forKey:@"name"];
    _roleDS = @[tempDictForRole, tempDict2ForRole, tempDict3ForRole, tempDict4ForRole];
    
    NSMutableDictionary *tempDictForType = [NSMutableDictionary dictionary];
    [tempDictForType setValue:LS(@"All", @"") forKey:@"value"];
    [tempDictForType setValue:@"All" forKey:@"name"];
    
    NSMutableDictionary *tempDict2ForType = [NSMutableDictionary dictionary];
    [tempDict2ForType setValue:LS(@"Discussion", @"") forKey:@"value"];
    [tempDict2ForType setValue:@"Discussion" forKey:@"name"];
    
    NSMutableDictionary *tempDict3ForType = [NSMutableDictionary dictionary];
    [tempDict3ForType setValue:LS(@"FYI", @"") forKey:@"value"];
    [tempDict3ForType setValue:@"FYI" forKey:@"name"];
    
    NSMutableDictionary *tempDict4ForType = [NSMutableDictionary dictionary];
    [tempDict4ForType setValue:LS(@"Chat", @"") forKey:@"value"];
    [tempDict4ForType setValue:@"Chat" forKey:@"name"];
    
    NSMutableDictionary *tempDict5ForType = [NSMutableDictionary dictionary];
    [tempDict5ForType setValue:LS(@"Action", @"") forKey:@"value"];
    [tempDict5ForType setValue:@"Action" forKey:@"name"];
    
    NSMutableDictionary *tempDict6ForType = [NSMutableDictionary dictionary];
    [tempDict6ForType setValue:LS(@"Approval", @"") forKey:@"value"];
    [tempDict6ForType setValue:@"Approval" forKey:@"name"];
    _typeDS = @[tempDictForType, tempDict2ForType, tempDict3ForType, tempDict4ForType, tempDict5ForType, tempDict6ForType];
    
    NSMutableDictionary *tempDictForDueDate = [NSMutableDictionary dictionary];
    [tempDictForDueDate setValue:LS(@"All", @"") forKey:@"value"];
    [tempDictForDueDate setValue:@"All" forKey:@"name"];
    
    NSMutableDictionary *tempDict2ForDueDate = [NSMutableDictionary dictionary];
    [tempDict2ForDueDate setValue:LS(@"None", @"") forKey:@"value"];
    [tempDict2ForDueDate setValue:@"None" forKey:@"name"];
    
    NSMutableDictionary *tempDict3ForDueDate = [NSMutableDictionary dictionary];
    [tempDict3ForDueDate setValue:LS(@"Today", @"") forKey:@"value"];
    [tempDict3ForDueDate setValue:@"Today" forKey:@"name"];
    
    NSMutableDictionary *tempDict4ForDueDate = [NSMutableDictionary dictionary];
    [tempDict4ForDueDate setValue:LS(@"Tomorrow", @"") forKey:@"value"];
    [tempDict4ForDueDate setValue:@"Tomorrow" forKey:@"name"];
    
    NSMutableDictionary *tempDict5ForDueDate = [NSMutableDictionary dictionary];
    [tempDict5ForDueDate setValue:LS(@"This Week", @"") forKey:@"value"];
    [tempDict5ForDueDate setValue:@"This Week" forKey:@"name"];
    
    NSMutableDictionary *tempDict6ForDueDate = [NSMutableDictionary dictionary];
    [tempDict6ForDueDate setValue:LS(@"Upcoming", @"") forKey:@"value"];
    [tempDict6ForDueDate setValue:@"Upcoming" forKey:@"name"];
    
    NSMutableDictionary *tempDict7ForDueDate = [NSMutableDictionary dictionary];
    [tempDict7ForDueDate setValue:LS(@"Past", @"") forKey:@"value"];
    [tempDict7ForDueDate setValue:@"Past" forKey:@"name"];
    _dueDateDS = @[tempDictForDueDate, tempDict2ForDueDate, tempDict3ForDueDate, tempDict4ForDueDate, tempDict5ForDueDate, tempDict6ForDueDate, tempDict7ForDueDate];
    
    
    NSArray* normalFieldOptions = @[@[],
                                    _statusDS,
                                    _roleDS,
                                    _typeDS,
                                    _dueDateDS,
                                    @[]
                                    ];
    NSMutableArray* rowsInNormalSection = [NSMutableArray array];
    for (NSUInteger index = 0; index < [normalField count]; index++) {
        CVFocusItem* item = [[CVFocusItem alloc] initWithTitle:[normalField objectAtIndex:index] selectedOption:[normalFieldValue objectAtIndex:index] type:[normalFieldType objectAtIndex:index] options:[normalFieldOptions objectAtIndex:index]];
        [rowsInNormalSection addObject:item];
        
    }
    [_rowsDS addObject:rowsInNormalSection];
    
    self.rows = _rowsDS;
}

- (void)switchChanged:(UISwitch *)sender
{
    CVFocusCell *theParentCell = [[[sender superview] superview] superview];
    NSIndexPath *indexPathOfSwitch = [self.tableView indexPathForCell:(CVFocusCell *)theParentCell];
    _tempSelectedItem = [[self.rows objectAtIndex:indexPathOfSwitch.section] objectAtIndex:indexPathOfSwitch.row] ;

    if(sender.on){
        _tempSelectedItem.selectedOption = @"yes";
    } else {
        _tempSelectedItem.selectedOption = @"no";
    }
}

- (void)updateMultipleSelection:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) update
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:LS(@"Create New Focus",@"") message:LS(@"Please enter focus name here.", @"") delegate:self cancelButtonTitle:LS(@"Cancel", @"") otherButtonTitles:LS(@"Save",@""), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;

//    UITextField *textField = [alert textFieldAtIndex:0];
//    textField.placeholder = @"Save As";
    
    [alert show];
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    return ([[[alertView textFieldAtIndex:0] text] length]>0)?YES:NO;
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"cancel button pressed!");
    } else {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSLog(@"confirm pressed, %@", textField.text);
        CVAPIRequest* request = [[CVAPIRequest alloc] initWithAPIPath:@"/svc/focuses"];
        
        NSMutableDictionary* focusRecord = [NSMutableDictionary dictionary];
        NSMutableDictionary* focusDefinitionRecord = [NSMutableDictionary dictionary];
        for (CVFocusItem* tempItem in [self.rows objectAtIndex:0]) {
          [focusDefinitionRecord setObject:tempItem.selectedOption forKey:tempItem.title];
        }
        
        [focusRecord setObject:@"basic" forKey:@"mode"];
        if ([_settingItem isEqualToString:@"Task"]) {
            [focusRecord setObject:@"Task" forKey:@"subtype"];
            [focusRecord setObject:@"space" forKey:@"spacetype"];
        } else if ([_settingItem isEqualToString:@"File"]) {
            [focusRecord setObject:@"File" forKey:@"subtype"];
            [focusRecord setObject:@"content" forKey:@"spacetype"];
        }
        [focusRecord setObject:textField.text forKey:@"title"];
        
        NSString* definitionStr = [NSString stringWithFormat:@"%@", focusDefinitionRecord];
        [focusRecord setObject:definitionStr forKey:@"definition"];
        
        NSDictionary* params = @{@"focus": focusRecord};
        NSString *paraJson = [params jsonValue];
        
        CVAPIRequestModel* reqModel = [[CVAPIRequestModel alloc] init];

        [request setPOSTParamString:paraJson isJsonFormat:YES];
        
        [reqModel sendRequest:request completion:^(NSDictionary* apiResult, NSError* error){
            UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:LS(@" Create Focus Successfully",@"") message:nil delegate:nil cancelButtonTitle:LS(@"OK",@"") otherButtonTitles:nil, nil];
                    
            [alertview show];
        }];
        
       [self.navigationController popViewControllerAnimated:YES];
       [self.tableView reloadData];

    }
}

- (void)cancel {
#ifdef CV_TARGET_IPAD
    [self cancel:YES];
#else
    [self popFromStack];
#endif
}

- (void)cancel:(BOOL)confirmIfNecessary {
    if (confirmIfNecessary) {
        [self confirmCancellation];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark -
#pragma mark CVBaseListViewController

- (Class)cellClassForObject:(id)object {
    
    if ([object isKindOfClass:[CVFocusItem class]])
        return [CVFocusCell class];
    
    return [super cellClassForObject:object];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UISwitch *theSwitch = nil;
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    CVFocusItem *tempTaskFocusItem = [[self.rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    ((CVFocusCell*)cell).textField.text = tempTaskFocusItem.selectedOption;
    ((CVFocusCell*)cell).labelField.text = tempTaskFocusItem.title;
    
    theSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    CGRect frame = theSwitch.frame;
    frame.origin.x = 260;
    frame.origin.y = 9;
    theSwitch.frame = frame;
    theSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
    [theSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
    if ([[[[self.rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] itemType] isEqualToString:@"toggle"]) {
        
        if ([tempTaskFocusItem.selectedOption isEqualToString:@"yes"])
            theSwitch.on = YES;
        else
            theSwitch.on = NO;
        
        [cell.contentView addSubview:theSwitch];
        ((CVFocusCell*)cell).textField.hidden = YES;
    } else if ([[[[self.rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] itemType] isEqualToString:@"picker"] && ![[[[self.rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] selectedOption] isEqualToString:@" "]) {
        [cell.contentView addSubview:_imageCollectionViewContainer];
        ((CVFocusCell*)cell).textField.hidden = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
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
        controller = [controller initWithTitle:[NSString stringWithFormat:@"Select %@", [[[self.rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] title]] andDataSource:[[[self.rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] itemOptions]];
        controller.isMultipleSelection = NO;
        controller.initialSelection = ((CVFocusCell*)cell).textField.text;
        controller.delegate = self;

        [self.navigationController pushViewController:controller animated:YES];
    } else if ( [[[[self.rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] itemType] isEqualToString:@"multiple"]) {
        controller = [controller initWithTitle:[NSString stringWithFormat:@"Select %@", [[[self.rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] title]] andDataSource:[[[self.rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] itemOptions] andMultipleSelection:YES];
        controller.isMultipleSelection = YES;
        controller.initialSelection = ((CVFocusCell*)cell).textField.text;
        controller.delegate = self;
        
        [self.navigationController pushViewController:controller animated:YES];
    } else if ( [[[[self.rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] itemType] isEqualToString:@"picker"]) {
        _OwnersIndexPath = indexPath;
        NSArray* initialAssignees = _selectedOwners;
        CVContactPickerViewController* pickerVC = [[CVContactPickerViewController alloc] initWithRecipients:initialAssignees forAddPeople:NO withOptions:@[TYPE_OPTION_ALL, TYPE_OPTION_TRUSTED, TYPE_OPTION_CONNECTED, TYPE_OPTION_ENGAGED, TYPE_OPTION_ACQUAINTANCE, TYPE_OPTION_GROUP]];
        pickerVC.delegate = self;
        
        [self.navigationController pushViewController:pickerVC animated:NO];
    }

    controller.navigationItem.hidesBackButton = NO;
}

#pragma mark -
#pragma mark IPadTextPickerDelegate

- (void)didSelectTextPicker:(NSDictionary *)selection {

    NSIndexPath* selectedIndexPath = self.tableView.indexPathForSelectedRow;
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
        ((CVFocusCell*)cell).textField.text = [selection objectForKey:@"value"];
        _tempSelectedItem = [[self.rows objectAtIndex:selectedIndexPath.section] objectAtIndex:selectedIndexPath.row];
        [_tempSelectedItem setNewSelectedOption:[selection objectForKey:@"value"] isMultiple:NO];
    
        [self.tableView reloadRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];

}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == actionSheet.cancelButtonIndex || buttonIndex == actionSheet.destructiveButtonIndex)
        [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
    else
        [self.navigationController popViewControllerAnimated:YES];

}

#pragma mark -
#pragma mark ContactPickerDelegate

-(void)recipientsChanged:(NSArray*)recipients {
    
    [_selectedOwners removeAllObjects];
    _selectedOwners = (NSMutableArray *)recipients;
    _tempSelectedItem = [[self.rows objectAtIndex:_OwnersIndexPath.section] objectAtIndex:_OwnersIndexPath.row];

    NSMutableString* recipientsString = [NSMutableString string];
    for (NSDictionary* recipient in recipients) {
        if ([recipient objectForKey:@"key"] != nil) {
            NSString* userKey = [recipient objectForKey:@"key"];
            [recipientsString appendFormat:(recipientsString.length > 0) ? @", %@" : @"%@", userKey];
        }
    }

    _tempSelectedItem.selectedOption = recipientsString;
    
    [self.tableView reloadData];
    if (recipients.count<5) {
        _imageCollectionViewContainer.frame = CGRectMake( 120, 0, 45* recipients.count + 15, 50);
    } else {
        _imageCollectionViewContainer.frame = CGRectMake( 120, 0, 190, 50);
    }
    [_imageCollectionView reloadData];

}

# pragma mark -
# pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_selectedOwners count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CVContactPickerImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"selectingCollectionViewCell" forIndexPath:indexPath];
 	[cell.collectionImageView unsetImage];
    
    if (!cell)
		cell = [[CVContactPickerImageCollectionCell alloc] init];
    
    CVContactItem* collectionContactItem = [[CVContactItem alloc] init];
    NSMutableArray* collectionContactArray = [NSMutableArray array];
    for (NSDictionary* temp in _selectedOwners){
        collectionContactItem = [CVContactItem contactItemWithDictionary:temp];
        [collectionContactArray addObject:collectionContactItem];
    }
    NSString* iconPath = [[collectionContactArray objectAtIndex:indexPath.item] iconUrlOfSize:@"small"];
    if ([iconPath hasPrefix:@"bundle://default"] || [iconPath hasPrefix:@"bundle://alien"] )
        iconPath = [(CVContactItem*)[collectionContactArray objectAtIndex:indexPath.item] getInitials];
    cell.collectionImageView.iconPath = iconPath;
    
    return cell;
}

@end
