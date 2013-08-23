//
//  KOSelectingViewController.m
//
//  Created by Daniel Kong on 08/23/2013.
//  Copyright (c) 2013 Daniel Kong
//
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "KOTreeViewController.h"
#import "KOTreeTableViewCell.h"
#import "KOTreeItem.h"


#define TYPE_OPTION_ALL_LS         @"All"
#define TYPE_OPTION_MESSAGE_LS     @"Message"
#define TYPE_OPTION_MAIL_LS        @"Mail"
#define TYPE_OPTION_DISCUSSION_LS  @"Discussion"
#define TYPE_OPTION_FYI_LS         @"FYI"
#define TYPE_OPTION_CHAT_LS        @"Chat"
#define TYPE_OPTION_TODO_LS        @"To Do"
#define TYPE_OPTION_ACTION_LS      @"Action"
#define TYPE_OPTION_APPROVAL_LS    @"Approval"


@interface KOTreeViewController ()
@property (nonatomic, retain) NSString* tempPath;
@property(nonatomic, retain) NSArray* typeOptionsPath;

@end

@implementation KOTreeViewController

@synthesize treeTableView;
@synthesize treeItems;
@synthesize selectedTreeItems;
@synthesize item0, item1, item1_1, item1_2, item1_2_1, item2, item3;


- (id)init {
    if (self = [super init]) {
        _treeArray = [NSMutableArray array];
        _tempPath=@"/";
        NSString* type_option_all_path=[NSString stringWithFormat:@"/%@",TYPE_OPTION_ALL_LS];
        NSString* type_option_mail_path=[NSString stringWithFormat:@"/%@/%@",TYPE_OPTION_ALL_LS,TYPE_OPTION_MAIL_LS];
        NSString* type_option_chat_path=[NSString stringWithFormat:@"/%@/%@",TYPE_OPTION_ALL_LS,TYPE_OPTION_CHAT_LS];
        NSString* type_option_message_path=[NSString stringWithFormat:@"/%@/%@",TYPE_OPTION_ALL_LS,TYPE_OPTION_MESSAGE_LS];
        NSString* type_option_discussion_path=[NSString stringWithFormat:@"/%@/%@/%@",TYPE_OPTION_ALL_LS,TYPE_OPTION_MESSAGE_LS,TYPE_OPTION_DISCUSSION_LS];
        NSString* type_option_FYI_path=[NSString stringWithFormat:@"/%@/%@/%@",TYPE_OPTION_ALL_LS,TYPE_OPTION_MESSAGE_LS,TYPE_OPTION_FYI_LS];
        NSString* type_option_todo_path=[NSString stringWithFormat:@"/%@/%@",TYPE_OPTION_ALL_LS,TYPE_OPTION_TODO_LS];
        NSString* type_option_action_path=[NSString stringWithFormat:@"/%@/%@/%@",TYPE_OPTION_ALL_LS,TYPE_OPTION_TODO_LS,TYPE_OPTION_ACTION_LS];
        NSString* type_option_action_accept_path=[NSString stringWithFormat:@"/%@/%@/%@/%@",TYPE_OPTION_ALL_LS,TYPE_OPTION_TODO_LS,TYPE_OPTION_ACTION_LS,@"accept"];
        NSString* type_option_approval_decline_path=[NSString stringWithFormat:@"/%@/%@/%@/%@",TYPE_OPTION_ALL_LS,TYPE_OPTION_TODO_LS,TYPE_OPTION_ACTION_LS,@"decline"];
        NSString* type_option_approval_path=[NSString stringWithFormat:@"/%@/%@/%@",TYPE_OPTION_ALL_LS,TYPE_OPTION_TODO_LS,TYPE_OPTION_APPROVAL_LS];

        _typeOptionsPath=@[type_option_all_path,type_option_mail_path,type_option_chat_path,type_option_message_path,type_option_discussion_path,type_option_FYI_path,type_option_todo_path,type_option_action_path,type_option_action_accept_path,type_option_approval_decline_path,type_option_approval_path];
        
        [self builtTreeWithDataSource:_typeOptionsPath];
    }
    return self;
}


- (void) builtTreeWithDataSource: (NSArray *)strings {
    NSInteger size = [strings count];
    for (int i=0; i<size; i++) {
        _tmptreeItem=[[KOTreeItem alloc] init];
        _tmptreeItem.base=[[[strings objectAtIndex:i] componentsSeparatedByString: @"/"] lastObject];
        if ([[[strings objectAtIndex:i] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/%@",_tmptreeItem.base] withString:@""]isEqual:@""]) {
            _tmptreeItem.path=@"/";
        } else {
            _tmptreeItem.path=[[strings objectAtIndex:i] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/%@",_tmptreeItem.base] withString:@""];
        }
        _tmptreeItem.submersionLevel=[[[strings objectAtIndex:i] componentsSeparatedByString: @"/"] count]-2;
        NSString *checkParentString=_tmptreeItem.path;
        _tmptreeItem.parentItem=nil;
        _tmptreeItem.alreadyExtend=YES;         // add property alreadyExtend
        NSInteger numberOfSub=0;
        for (int j=0; j<size; j++){
            //To Do Get parentItem
            if (j!=i && [[strings objectAtIndex:j] isEqualToString:checkParentString]) {
                _tmptreeItem.parentItem=[strings objectAtIndex:j];
            }
            //To Do Get descendantItems
            NSString *checkDescendantString=[[strings objectAtIndex:j] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/%@",[[[strings objectAtIndex:j] componentsSeparatedByString: @"/"] lastObject]] withString:@""];
            if ([checkDescendantString isEqual:@""])
                checkDescendantString=@"/";
            if (j!=i && [checkDescendantString isEqualToString:[strings objectAtIndex:i]]) {
                _tmptreeItem.descendantItems=[NSMutableArray array];
                numberOfSub++;
            }
            _tmptreeItem.numberOfSubitems=numberOfSub;
        }
        [_treeArray addObject:_tmptreeItem];
    }
}


- (BOOL) addToListRule:(KOTreeItem*) treeItem {
    if (treeItem.parentItem) {
        KOTreeItem* parentTreeItem=nil;
        for (int j=0;j<[_treeArray count];j++) {//[NSString stringWithFormat:@"/%@",[[_treeArray objectAtIndex:j] base]]]
            if ([[[_treeArray objectAtIndex:j] path] isEqualToString:@"/"]) {
                if ([[[[_treeArray objectAtIndex:j] path] stringByAppendingString:[[_treeArray objectAtIndex:j] base]] isEqualToString:treeItem.parentItem]) {
                    parentTreeItem=[_treeArray objectAtIndex:j];
                    if (parentTreeItem.alreadyExtend==NO || [self addToListRule:parentTreeItem]==NO)
                        return NO;
                }

            } else {
                if ([[[[_treeArray objectAtIndex:j] path] stringByAppendingString:[NSString stringWithFormat:@"/%@",[[_treeArray objectAtIndex:j] base]]] isEqualToString:treeItem.parentItem]) {
                    parentTreeItem=[_treeArray objectAtIndex:j];
                    if (parentTreeItem.alreadyExtend==NO || [self addToListRule:parentTreeItem]==NO)
                        return NO;
                }
            }
        }
    }
    return YES;
}

- (NSMutableArray *)listItemsAtPath:(NSString *)path {
	    
    NSLog(@"%@", path);
    NSMutableArray *descendantItems=[NSMutableArray array];
    //    NSString* collapsePath=@"";
    for (int i=0;i<[_treeArray count];i++) {
        _tmptreeItem=[_treeArray objectAtIndex:i];
//        if ([path isEqualToString:_tmptreeItem.path]) {       // this is show ALL first and do not show its descendant
//          if ([_tmptreeItem.path hasPrefix:path] && [self addToListItems:_tmptreeItem]) { // this is show ALL and its descendant
            //1.3        if ([_tmptreeItem.path hasPrefix:path] && _tmptreeItem.path != collapsePath) {
            //1.4       if ([_tmptreeItem.path hasPrefix:path]) {       //show all and descendant
            //1.3            if (_tmptreeItem.alreadyExtend==NO) {
            //1.3                collapsePath=[_tmptreeItem.path stringByAppendingPathComponent:_tmptreeItem.base];
            //1.3            }
        if ([self addToListRule:_tmptreeItem] )
            [descendantItems addObject:_tmptreeItem];
            
        //}
    }
    return descendantItems;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.selectedTreeItems = [NSMutableArray array];
	// Do any additional setup after loading the view.
	
	self.treeItems = [self listItemsAtPath:@"/"];
	
	treeTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	[treeTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
	[treeTableView setBackgroundColor:[UIColor colorWithRed:1 green:0.976 blue:0.957 alpha:1] /*#fff9f4*/];
	[treeTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[treeTableView setRowHeight:65.0f];
	[treeTableView setDelegate:(id<UITableViewDelegate>)self];
	[treeTableView setDataSource:(id<UITableViewDataSource>)self];
	[self.view addSubview:treeTableView];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[[self treeTableView] delegate] tableView:treeTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

#pragma mark - UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.treeItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	KOTreeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectingTableViewCell"];
	if (!cell)
		cell = [[KOTreeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"selectingTableViewCell"];
	
	KOTreeItem *treeItem = [self.treeItems objectAtIndex:indexPath.row];
	
	cell.treeItem = treeItem;
	
	[cell.iconButton setSelected:[self.selectedTreeItems containsObject:cell.treeItem]];
	
	if ([treeItem numberOfSubitems])
		[cell.countLabel setText:[NSString stringWithFormat:@"%d", [treeItem numberOfSubitems]]];
	else
		[cell.countLabel setText:@"-"];
	
	[cell.titleTextField setText:[treeItem base]];
	[cell.titleTextField sizeToFit];
	
	[cell setDelegate:(id<KOTreeTableViewCellDelegate>)self];

	[cell setLevel:[treeItem submersionLevel]];
	
	return cell;
}

- (void)selectingItemsToDelete:(KOTreeItem *)selItems saveToArray:(NSMutableArray *)deleteSelectingItems{
	for (KOTreeItem *obj in selItems.ancestorSelectingItems) {
		[self selectingItemsToDelete:obj saveToArray:deleteSelectingItems];
	}
	
	[deleteSelectingItems addObject:selItems];
}

- (NSMutableArray *)removeIndexPathForTreeItems:(NSMutableArray *)treeItemsToRemove {
	NSMutableArray *result = [NSMutableArray array];
	
	for (NSInteger i = 0; i < [treeTableView numberOfRowsInSection:0]; ++i) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
		KOTreeTableViewCell *cell = (KOTreeTableViewCell *)[treeTableView cellForRowAtIndexPath:indexPath];

		for (KOTreeItem *tmpTreeItem in treeItemsToRemove) {
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

}

#pragma mark - Actions

- (void)iconButtonAction:(KOTreeTableViewCell *)cell treeItem:(KOTreeItem *)tmpTreeItem {
    tmpTreeItem.alreadyExtend=!tmpTreeItem.alreadyExtend;
    NSLog(@"click this %@",tmpTreeItem.path);
    self.treeItems = [self listItemsAtPath:@"/"];
    [treeTableView reloadData];
}

#pragma mark - KOTreeTableViewCellDelegate

- (void)treeTableViewCell:(KOTreeTableViewCell *)cell didTapIconWithTreeItem:(KOTreeItem *)tmpTreeItem {
	NSLog(@"didTapIconWithselectingItem.base: %@", [tmpTreeItem base]);
	[self iconButtonAction:cell treeItem:tmpTreeItem];
}

@end
