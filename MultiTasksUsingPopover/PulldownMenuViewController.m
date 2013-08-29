#import "PulldownMenuViewController.h"
#import "MenuItemCell.h"
#import "MenuItem.h"
#import "TasksViewController.h"

@interface PulldownMenuViewController ()

@property (nonatomic, retain) UITableView *treeTableView;
@property (nonatomic, retain) NSMutableArray *treeItems;
@property (nonatomic, retain) NSMutableArray *treeArray; 
@property (nonatomic, retain) MenuItem *tmptreeItem;
@property (nonatomic, retain) MenuItem* tempParent;
@property (nonatomic, retain) NSString* tempPath;
@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation PulldownMenuViewController

- (id)initWithMenuItems:(NSArray*)menuArray selectedIndex:(NSInteger)selectedIndex{
    if (self = [super init]) {
        _treeArray = [NSMutableArray array];
        _tempPath = @"/";
        _showExtensionButton = NO;
        _titleFont = [UIFont fontWithName:@"HelveticaNeue" size:20.0f];
        _selectedIndex = selectedIndex;
        
        [self builtMenuTreeWithDataSource:menuArray];
    }
    return self;
}

- (NSArray*)currentMenuItems {
    NSMutableArray *clientTreeItems = [NSMutableArray array];
    for (MenuItem* menuItem in _treeArray) {
        NSString* itemString = nil;
        if(menuItem.alreadyExtend) {
            itemString = [menuItem.path stringByAppendingString:menuItem.base];
        } else {
            itemString = [[menuItem.path stringByAppendingString:menuItem.base] stringByAppendingString: @"/"];
        }
        [clientTreeItems addObject:itemString];
    }
    return clientTreeItems;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.treeItems = [self listItems:@"/"];
	
	_treeTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	[_treeTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
	[_treeTableView setBackgroundColor:[UIColor colorWithRed:1 green:0.976 blue:0.957 alpha:1] /*#fff9f4*/];
	[_treeTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[_treeTableView setRowHeight:28.0f];
	[_treeTableView setDelegate:(id<UITableViewDelegate>)self];
	[_treeTableView setDataSource:(id<UITableViewDataSource>)self];
    
    [self resizeViewHeight];
    
	[self.view addSubview:_treeTableView];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

#pragma mark - private

// According to input array, built the tree structure and save all node (treeItem) into treeArray

- (void) builtMenuTreeWithDataSource: (NSArray *)arrayPath {
    NSInteger size = [arrayPath count];
    for (int i = 0; i < size; i++) {
        _tmptreeItem = [[MenuItem alloc] init];
        _tmptreeItem.base = [[[arrayPath objectAtIndex:i] componentsSeparatedByString: @"/"] lastObject];
        
        //Set treeItem path, root path as "/"
        
        if ([[[arrayPath objectAtIndex:i] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/%@",_tmptreeItem.base] withString:@""]isEqual:@""]) {
            _tmptreeItem.path = @"/";
        } else {
            _tmptreeItem.path = [[arrayPath objectAtIndex:i] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/%@",_tmptreeItem.base] withString:@""];
        }
        //Set treeItem submersionLevel
        _tmptreeItem.submersionLevel = [[[arrayPath objectAtIndex:i] componentsSeparatedByString: @"/"] count]-2;
        NSString *checkParentString = _tmptreeItem.path;
        _tmptreeItem.parentItem = nil;
        _tmptreeItem.alreadyExtend = YES;
        NSInteger numberOfSubitems = 0;
        for (int j = 0; j < size; j++){
            //Get parentItem
            if (j != i && [[arrayPath objectAtIndex:j] isEqualToString:checkParentString]) {
                _tmptreeItem.parentItem = [arrayPath objectAtIndex:j];
            }
            
            //Get descendantItems and numberOfSubitems
            
            NSString *checkDescendantString = [[arrayPath objectAtIndex:j] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/%@",[[[arrayPath objectAtIndex:j] componentsSeparatedByString: @"/"] lastObject]] withString:@""];
            if ([checkDescendantString isEqual:@""])
                checkDescendantString = @"/";
            if (j!=i && [checkDescendantString isEqualToString:[arrayPath objectAtIndex:i]]) {
                _tmptreeItem.descendantItems = [NSMutableArray array];
                numberOfSubitems++;
            }
            _tmptreeItem.numberOfSubitems = numberOfSubitems;
        }
        [_treeArray addObject:_tmptreeItem];
    }
}

// Check MenuItem whether show in show list. Recursive check all its father grandfather could show,
// if all is yes, then add it into show list. Or do not add it in the show list.

- (BOOL)addToListRule:( MenuItem*) treeItem {
    if (treeItem.parentItem) {
         MenuItem* parentTreeItem = nil;
        for (int j = 0; j < [_treeArray count]; j++) {
            if ([[[_treeArray objectAtIndex:j] path] isEqualToString:@"/"]) {
                if ([[[[_treeArray objectAtIndex:j] path] stringByAppendingString:[[_treeArray objectAtIndex:j] base]] isEqualToString:treeItem.parentItem]) {
                    parentTreeItem = [_treeArray objectAtIndex:j];
                    if (parentTreeItem.alreadyExtend == NO || [self addToListRule:parentTreeItem] == NO)
                        return NO;
                }
            } else {
                if ([[[[_treeArray objectAtIndex:j] path] stringByAppendingString:[NSString stringWithFormat:@"/%@",[[_treeArray objectAtIndex:j] base]]] isEqualToString:treeItem.parentItem]) {
                    parentTreeItem = [_treeArray objectAtIndex:j];
                    if (parentTreeItem.alreadyExtend == NO || [self addToListRule:parentTreeItem] == NO)
                        return NO;
                }
            }
        }
    }
    return YES;
}

- (NSMutableArray*)listItems:(NSString *)path {

    NSMutableArray *descendantItems = [NSMutableArray array];
    for (int i=0;i<[_treeArray count];i++) {
        _tmptreeItem=[_treeArray objectAtIndex:i];
        
        if ([self addToListRule:_tmptreeItem] )
            [descendantItems addObject:_tmptreeItem];
    }
    return descendantItems;
}

- (void)resizeViewHeight
{
    float currentTotal = 0;
    for (int i = 0; i < [_treeTableView numberOfSections]; i++)
    {
        CGRect sectionRect = [_treeTableView rectForSection:i];
        currentTotal += sectionRect.size.height;
    }
    self.contentSizeForViewInPopover = CGSizeMake(200, currentTotal+5);
}

#pragma mark - UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.treeItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	 MenuItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectingTableViewCell"];
 	if (!cell)
		cell = [[ MenuItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"selectingTableViewCell" showbutton:_showExtensionButton titleStyle:_titleFont];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	 MenuItem *treeItem = [self.treeItems objectAtIndex:indexPath.row];
	cell.treeItem = treeItem;

	if (_showExtensionButton && [treeItem numberOfSubitems]) {
        [cell.iconButton setBackgroundImage:[UIImage imageNamed:@"down-arrow-highlighted.png"] forState:UIControlStateNormal];
	} else {
        [cell.iconButton setBackgroundImage:[UIImage imageNamed:@" "] forState:UIControlStateNormal];
	}
   
    if (_selectedIndex == [indexPath row]) {
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }
    
	[cell.titleTextField setText:[treeItem base]];
	[cell.titleTextField sizeToFit];
	
	[cell setDelegate:(id< MenuItemSelectionDelegate>)self];
    
	[cell setLevel:[treeItem submersionLevel]];
	
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     MenuItemCell* cell = ( MenuItemCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (_delegate && [_delegate respondsToSelector:@selector(pulldownMenu:didSelectMenuItem:didSelectMenuIndex:)])
        [_delegate pulldownMenu: self didSelectMenuItem:cell.treeItem.base didSelectMenuIndex:[indexPath row]];
}

#pragma mark -  MenuItemCellDelegate

- (void)menuItemDidSelect:( MenuItem *)treeItem {
    treeItem.alreadyExtend = !treeItem.alreadyExtend;
    self.treeItems = [self listItems:@"/"];
    [_treeTableView reloadData];
}

@end
