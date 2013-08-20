//
//  PulldownMenuViewController.m
//  
//
//  Created by daniel kong on 8/12/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "PulldownMenuViewController.h"
#import "BaseMenuTreeTableViewCell.h"
#import "BaseMenuTreeItem.h"
#import "TasksViewController.h"



#define TEST [NSArray arrayWithObjects:@"All",[NSArray arrayWithObjects:@"Test",@"Baby",nil],[NSArray arrayWithObjects:@"Cici",@"Daddy",nil],nil]

@interface PulldownMenuViewController ()
@property (nonatomic, retain) CVBaseMenuTreeItem* tempParent;
@property (nonatomic, retain) NSString* tempPath;
@property (nonatomic, assign) NSInteger submesionlevel;
@end

NSInteger submesionlevel = 0;
NSInteger IndexOftreeArray = 0;

@implementation PulldownMenuViewController


- (id)initWithDelegate:(id<PulldownMenuDelegate>)delegate forMenuFilter:(NSArray*)menuArray {
    if (self = [super init]) {
        _treeArray = [NSMutableArray array];
        _tempPath=@"/";
        [self builtTreeWithDataSource:menuArray];
         self.delegate = delegate;
    }
    return self;
}

- (void) builtTreeWithDataSource: (NSArray *)strings {
    NSInteger size = [strings count];
    NSInteger k = size;    //size of array
    
    for (NSInteger i=0; i<size; i++) {
        if ([[strings objectAtIndex:i] isKindOfClass:[NSArray class]]) {
            k = [[strings objectAtIndex:i] count];
            submesionlevel++;
            [self builtTreeWithDataSource:[strings objectAtIndex:i]];
        } else {
            _tmptreeItem = [[CVBaseMenuTreeItem alloc] init];
            if (i==0) {
                _tmptreeItem.base = [strings objectAtIndex:0];
                _tmptreeItem.path = _tempPath;
                _tmptreeItem.submersionLevel=submesionlevel;
                _tmptreeItem.numberOfSubitems=size-1;
                _tmptreeItem.parentSelectingItem=_tempParent;
                _tmptreeItem.ancestorSelectingItems=[NSMutableArray array];
                _tempParent = [strings objectAtIndex:0];
                _tempPath = [NSString stringWithFormat:@"%@%@/", _tempPath, [strings objectAtIndex:0]];
            } else {
                _tmptreeItem.base=[strings objectAtIndex:i];
                _tmptreeItem.path= _tempPath;
                _tmptreeItem.submersionLevel=submesionlevel+1;
                _tmptreeItem.numberOfSubitems=0;
                _tmptreeItem.parentSelectingItem=_tempParent;
                _tmptreeItem.ancestorSelectingItems=[NSMutableArray array];
            }
            [_treeArray addObject:_tmptreeItem];
            IndexOftreeArray++;
        }
    }
    if (submesionlevel>0){
        submesionlevel--;
    }
    NSArray* pathSplit = [_tempPath componentsSeparatedByString: @"/"];
    _tempPath = [_tempPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",[pathSplit objectAtIndex: [pathSplit count]-2]] withString:@""];
}

- (NSMutableArray*)listItemsAtPath:(NSString *)path {
    NSLog(@"%@", path);
    NSMutableArray *AncestorItems=[NSMutableArray array];
    for (int i=0;i<[_treeArray count];i++) {
        _tmptreeItem=[_treeArray objectAtIndex:i];
        if ([[NSString stringWithFormat:@"%@/", path] isEqualToString:_tmptreeItem.path] || [path isEqualToString:_tmptreeItem.path]) {
            [AncestorItems addObject:_tmptreeItem];
        }
    }
    return AncestorItems;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.selectedTreeItems = [NSMutableArray array];
	// Do any additional setup after loading the view.
	
	self.treeItems = [self listItemsAtPath:@""];
	
	_treeTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	[_treeTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
	[_treeTableView setBackgroundColor:[UIColor colorWithRed:1 green:0.976 blue:0.957 alpha:1] /*#fff9f4*/];
	[_treeTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[_treeTableView setRowHeight:40.0f];
	[_treeTableView setDelegate:(id<UITableViewDelegate>)self];
	[_treeTableView setDataSource:(id<UITableViewDataSource>)self];
    
	[self.view addSubview:_treeTableView];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

}

#pragma mark - UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.treeItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	CVBaseMenuTreeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectingTableViewCell"];
    
	if (!cell)
		cell = [[CVBaseMenuTreeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"selectingTableViewCell"];
//	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	CVBaseMenuTreeItem *treeItem = [self.treeItems objectAtIndex:indexPath.row];
	
	cell.treeItem = treeItem;
	
	[cell.iconButton setSelected:[self.selectedTreeItems containsObject:cell.treeItem]];
	
	if ([treeItem numberOfSubitems]) {
        [cell.iconButton setBackgroundImage:[UIImage imageNamed:@"down-arrow-highlighted.png"] forState:UIControlStateNormal];

	} else {
        [cell.iconButton setBackgroundImage:[UIImage imageNamed:@" "] forState:UIControlStateNormal];
	}
	[cell.titleTextField setText:[treeItem base]];
	[cell.titleTextField sizeToFit];
	
	[cell setDelegate:(id<CVBaseMenuTreeTableViewCellDelegate>)self];
    
	[cell setLevel:[treeItem submersionLevel]];
	
	return cell;
}

- (void)selectingItemsToDelete:(CVBaseMenuTreeItem *)selItems saveToArray:(NSMutableArray *)deleteSelectingItems{
	for (CVBaseMenuTreeItem *obj in selItems.ancestorSelectingItems) {
		[self selectingItemsToDelete:obj saveToArray:deleteSelectingItems];
	}
	
	[deleteSelectingItems addObject:selItems];
}

- (NSMutableArray *)removeIndexPathForTreeItems:(NSMutableArray *)treeItemsToRemove {
	NSMutableArray *result = [NSMutableArray array];
	
	for (NSInteger i = 0; i < [_treeTableView numberOfRowsInSection:0]; ++i) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
		CVBaseMenuTreeTableViewCell *cell = (CVBaseMenuTreeTableViewCell *)[_treeTableView cellForRowAtIndexPath:indexPath];
        
		for (CVBaseMenuTreeItem *tmpTreeItem in treeItemsToRemove) {
			if ([cell.treeItem isEqualToSelectingItem:tmpTreeItem])
				[result addObject:indexPath];
		}
	}
	
	return result;
}
- (void)tableViewAction:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath {
	
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CVBaseMenuTreeTableViewCell* cell = (CVBaseMenuTreeTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectTypeFilter:)])
        [_delegate didSelectMenuItem:cell.treeItem];
}

#pragma mark - Actions

- (void)iconButtonAction:(CVBaseMenuTreeTableViewCell *)cell treeItem:(CVBaseMenuTreeItem *)tmpTreeItem {

	NSInteger insertTreeItemIndex = [self.treeItems indexOfObject:cell.treeItem];
	NSMutableArray *insertIndexPaths = [NSMutableArray array];
	NSMutableArray *insertselectingItems = [self listItemsAtPath:[cell.treeItem.path stringByAppendingPathComponent:cell.treeItem.base]];
	
	NSMutableArray *removeIndexPaths = [NSMutableArray array];
	NSMutableArray *treeItemsToRemove = [NSMutableArray array];
	
	for (CVBaseMenuTreeItem *tmpTreeItem in insertselectingItems) {
		[tmpTreeItem setPath:[cell.treeItem.path stringByAppendingPathComponent:cell.treeItem.base]];
		[tmpTreeItem setParentSelectingItem:cell.treeItem];
		
		[cell.treeItem.ancestorSelectingItems removeAllObjects];
		[cell.treeItem.ancestorSelectingItems addObjectsFromArray:insertselectingItems];
		
		insertTreeItemIndex++;
		
		BOOL contains = NO;
		
		for (CVBaseMenuTreeItem *tmp2TreeItem in self.treeItems) {
			if ([tmp2TreeItem isEqualToSelectingItem:tmpTreeItem]) {
				contains = YES;
				
				[self selectingItemsToDelete:tmp2TreeItem saveToArray:treeItemsToRemove];
				
				removeIndexPaths = [self removeIndexPathForTreeItems:(NSMutableArray *)treeItemsToRemove];
			}
		}
		
		for (CVBaseMenuTreeItem *tmp2TreeItem in treeItemsToRemove) {
			[self.treeItems removeObject:tmp2TreeItem];
			
			for (CVBaseMenuTreeItem *tmp3TreeItem in self.selectedTreeItems) {
				if ([tmp3TreeItem isEqualToSelectingItem:tmp2TreeItem]) {
					NSLog(@"%@", tmp3TreeItem.base);
					[self.selectedTreeItems removeObject:tmp2TreeItem];
					break;
				}
			}
		}
		
		if (!contains) {
			[tmpTreeItem setSubmersionLevel:tmpTreeItem.submersionLevel];
			
			[self.treeItems insertObject:tmpTreeItem atIndex:insertTreeItemIndex];
			
			NSIndexPath *indexPth = [NSIndexPath indexPathForRow:insertTreeItemIndex inSection:0];
			[insertIndexPaths addObject:indexPth];
		}
	}
	
	if ([insertIndexPaths count])
		[_treeTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
	
	if ([removeIndexPaths count])
		[_treeTableView deleteRowsAtIndexPaths:removeIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
}

#pragma mark - KOTreeTableViewCellDelegate

- (void)treeTableViewCell:(CVBaseMenuTreeTableViewCell *)cell didTapIconWithTreeItem:(CVBaseMenuTreeItem *)tmpTreeItem {
	NSLog(@"didTapIconWithselectingItem.base: %@", [tmpTreeItem base]);
	
	[self iconButtonAction:cell treeItem:tmpTreeItem];
}


#pragma mark - Actions

- (void)titleTextFieldFilterAction:(CVBaseMenuTreeTableViewCell *)cell treeItem:(CVBaseMenuTreeItem *)tmpTreeItem {
	if ([self.selectedTreeItems containsObject:cell.treeItem]) {
		[cell.iconButton setSelected:NO];
		[self.selectedTreeItems removeObject:cell.treeItem];
	} else {
		[cell.iconButton setSelected:YES];
		
		[self.selectedTreeItems removeAllObjects];
		[self.selectedTreeItems addObject:cell.treeItem];
		
		[_treeTableView reloadData];
	}
}


@end
