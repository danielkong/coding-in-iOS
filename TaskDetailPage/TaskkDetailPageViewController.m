//
//  CVMVTaskDetailPageViewController.m
//  Vmoso
//
//  Created by Daniel Kong on 01/04/14.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVMVTaskDetailPageViewController.h"
#import "CVTabControl.h"
#import "CVTaskModel.h"
#import "CVTaskDetailBottomTableViewCell.h"
#import "CVContactStampListCell.h"
#import "CVReferenceStampListCell.h"
#import "CVAssociationStampListCell.h"
#import "IPhoneTaskDetailPageInfoCell.h"
#import "CVMVTaskDetailInfoCell.h"
#import "CVTaskSummaryCell.h"
#import "IPadProfileFormInputCell.h"
#import "IPadTaskPageDescCell.h"
#import "CVMenuPopup.h"
#import "CVTaskEditViewController.h"
#import "CVCommentsViewController.h"
#import "CVCommentComposerViewController.h"
#import "CVFolderPickerViewController.h"
#import "CVTaskHistoryViewController.h"
#import "CVTaskHistorySvcModel.h"
#import "CVCommentListSvcModel.h"
#import "CVContentStampListCell.h"
#import "CVContactPickerViewController.h"
#import "CVFilePickerViewController.h"
#import "CVFolderListItem.h"
#import "CVFolderListModel.h"
#import "CVRatingModel.h"
#import "CVTaskDetailCell.h"
#import "CVSparcViewController.h"
#import "CVTaskPageDescCell.h"
#import "CVNamedIcon.h"
#import "CVChatEditViewController.h"

#define MODEL_ID    @"CVMVTaskDetailPageViewController"

@interface CVMVTaskDetailPageViewController () <CVTaskDetailPageTabControlDelegate, CVTileTitleDelegate, CVMenuPopupDelegate, ContactPickerDelegate, CVFilePickerDelegate, CVFolderPickerDelegate, CVAPIModelDelegate>

@property (nonatomic, retain) CVTaskModel* model;
@property (nonatomic, retain) CVTaskHistorySvcModel* historyModel;
@property (nonatomic, retain) CVCommentListSvcModel* commentModel;
@property (nonatomic, retain) CVFolderListModel* folderModel;
@property (nonatomic, retain) CVMenuPopup* popupMenu;
@property (nonatomic, retain) CVMVTaskDetailInfoCell* taskInfoCell;
@property (nonatomic, retain) CVTaskDetailBottomTableViewCell* bottomCell;
@property (nonatomic, assign) NSUInteger selectedTabIndex;
@property (nonatomic, retain) UIAlertView* templateAlert;
@property (nonatomic, assign) BOOL isFirstLoad;

@end

@implementation CVMVTaskDetailPageViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _model.delegate = nil;
    _model = nil;
    
    _folderModel.delegate = nil;
    _folderModel = nil;
    
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    self.tableView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.isFirstLoad = YES;
    self.title = LS(@"Task", @"");
    
    self.tableView.allowsSelection = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _commentModel = [[CVCommentListSvcModel alloc] init];
    _commentModel.taskKey = self.key;
    [_commentModel loadMore:NO];
    _historyModel = [[CVTaskHistorySvcModel alloc] initWithKey:self.key];
    [_historyModel load];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_isFirstLoad) {
        [self showLoading:YES];
        [self loadCacheModel:[NSString stringWithFormat:@"%@_%@",MODEL_ID, self.key]];
        [_model loadTask];
        _isFirstLoad = NO;
    }
    
    if (!_folderModel) {
        _folderModel = [[CVFolderListModel alloc] init];
        _folderModel.delegate = self;
    }
    
    NSNotificationCenter *ncObserver = [NSNotificationCenter defaultCenter];
    [ncObserver removeObserver:self name:NOTIF_TASK_UPDATE object:nil];
	[ncObserver addObserver:self selector:@selector(processTaskUpdateNotif:) name:NOTIF_TASK_UPDATE object:nil];
}

#pragma mark -
#pragma mark CVBaseEntityViewController

- (void)handlePullToRefresh:(SVPullToRefreshView *)refreshView {
    [_model loadTask];
}

#pragma mark -
#pragma mark CVAPIModelDelegate

- (void)modelDidFinishLoad:(CVAPIRequestModel*)model action:(NSString*)action {
    [CVTaskModel persistModel:_model withId:[NSString stringWithFormat:@"%@_%@", MODEL_ID, self.key]];
    [self.pullToRefreshView stopAnimating];
    [self showLoading:NO];
    
    if ([_model.taskItem.creator.key isEqualToString:[CVAPIUtil getUserKey]]) {
        [self.topBar.rightButton setImage:[CVNamedIcon iconNamed:@"Edit"] forState:UIControlStateNormal];
        [self.topBar.rightButton addTarget:self action:@selector(editBarItemTouched) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (_model.taskItem != nil) {
        CVTaskSvcItem* task = _model.taskItem;
        CGRect defaultRect = CGRectMake(0, 0, self.view.width, 0);
        
        self.title = task.name;
        
        _taskInfoCell = [[CVMVTaskDetailInfoCell alloc] initWithFrame:defaultRect];
        _taskInfoCell.tabControl.selectedTabIndex = _selectedTabIndex;
        _taskInfoCell.task = task;
        _taskInfoCell.tabControldelegate = self;
        [_taskInfoCell.moreButton addTarget:self action:@selector(moreButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        
        CVPageSectionHeaderView* header = [[CVPageSectionHeaderView alloc] initWithFrame:defaultRect];
        header.hidden = YES;
        
        NSMutableArray* rows = [NSMutableArray arrayWithObject:[NSMutableArray arrayWithObject:_taskInfoCell]];
        NSMutableArray* sections = [NSMutableArray arrayWithObject:header];
        
        //desc section
        CVPageSectionHeaderView* descSection = [[CVPageSectionHeaderView alloc] initWithFrame:defaultRect];
        descSection.title = LS(@"Description", @"");
        [sections addObject:descSection];

        CVTaskPageDescCell* descCell = [[CVTaskPageDescCell alloc] initWithFrame:defaultRect];
        descCell.desc = [task.description isEqualToString:@""]? LS(@"None Description", @"") : task.description;
        descCell.textViewingDelegate = self;
        descCell.linkDelegate = self.linkHandler;
        [descCell.moreButton addTarget:self action:@selector(descMoreButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [rows addObject:[NSMutableArray arrayWithObject:descCell]];
        
        //participants section
        NSMutableArray* participantRows = [NSMutableArray array];
        CVTaskDetailCell* toCell = [[CVTaskDetailCell alloc] init];
        toCell.title.text = LS(@"Participants", @"");
        toCell.count.text = [NSString stringWithFormat:@"%d", [_model.taskItem.assignees count]];
        [participantRows addObject:toCell];
        
        [rows addObject:participantRows];
        CVPageSectionHeaderView* participantHeader = [[CVPageSectionHeaderView alloc] initWithFrame:defaultRect];
        participantHeader.hidden = YES;
        participantHeader.title = LS(@"Participants", @"");
        [sections addObject:participantHeader];
        
        //references section
        NSMutableArray* referenceRows = [NSMutableArray array];
        CVTaskDetailCell* attachmentCell = [[CVTaskDetailCell alloc] init];
        attachmentCell.title.text = LS(@"Attachments", @"");
        attachmentCell.count.text = [NSString stringWithFormat:@"%d", [_model.taskItem.attachments count]];
        [referenceRows addObject:attachmentCell];

        [rows addObject:referenceRows];
        CVPageSectionHeaderView* referenceHeader = [[CVPageSectionHeaderView alloc] initWithFrame:defaultRect];
        referenceHeader.hidden = YES;
        referenceHeader.title = LS(@"References", @"");
        [sections addObject:referenceHeader];
        
        //associations section
        NSMutableArray* associationRows = [NSMutableArray array];
        CVTaskDetailCell* folderCell = [[CVTaskDetailCell alloc] init];
        folderCell.title.text = LS(@"Folders", @"");
        folderCell.count.text = [NSString stringWithFormat:@"%d", [_model.taskItem.folders count]];
        [associationRows addObject:folderCell];
        
        CVTaskDetailCell* taskCell = [[CVTaskDetailCell alloc] init];
        taskCell.title.text = LS(@"Hotspots", @"");
        taskCell.count.text = [NSString stringWithFormat:@"%d", [_model.taskItem.relatedTasks count]];
        [associationRows addObject:taskCell];
        
        [rows addObject:associationRows];
        CVPageSectionHeaderView* associationHeader = [[CVPageSectionHeaderView alloc] initWithFrame:defaultRect];
        associationHeader.title = LS(@"Associations", @"");
        associationHeader.hidden = YES;
        [sections addObject:associationHeader];
        
        self.sectionHeaders = sections;
        self.rows = rows;
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 1)];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self.tableView reloadData];
    }

}

- (void)modelDidSucceedWithResult:(NSDictionary*)result  model:(CVAPIRequestModel*)model action:(NSString*)action {
    if ([action isEqualToString:@"delete"]) {
        [self popFromStack];
    } else if ([action isEqualToString:@"updateState"]) {
        [_model load];
    } if ([action isEqualToString:@"addTo"]) {
        if ([model isKindOfClass:[CVFolderListModel class]]) {
            [CVAPIUtil alertMessage:LS(@"Contents added to folders successfully!", @"")];
        } else if ([model isKindOfClass:[CVTaskModel class]]) {
            [_model load];
        }
    } else if ([action isEqualToString:@"addAttachments"]) {
        [_model load];
    } else if ([action isEqualToString:@"saveAsTemplate"]) {
        [CVAPIUtil alertMessage:LS(@"Task template saved successfully!", @"")];
    }
    
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:NOTIF_TASK_UPDATE object:nil userInfo:[NSDictionary dictionaryWithObject:self.key forKey:@"taskKey"]];
}

- (void)modelDidFailWithError:(NSError*)error model:(CVAPIRequestModel*)model action:(NSString*)action{
    [self.pullToRefreshView performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
}

#pragma mark -
#pragma mark private

- (void)loadCacheModel:(NSString*)cacheId {
    self.model = (CVTaskModel*)[CVTaskModel cachedModelWithId:cacheId];
    if (_model == nil) {
        _model = [[CVTaskModel alloc] initWithKey:self.key];
    }
    else {
        [self modelDidFinishLoad:_model action:@""];
    }
    _model.delegate = self;
}

- (void)setModel:(CVTaskModel *)model {
    if (_model)
        [_model cancel];
    _model = model;
}

-(void) processTaskUpdateNotif:(NSNotification*) notif {
    
    // do nothing if the notif is not for the current task
    NSString* taskKey = [notif.userInfo objectForKey:@"taskKey"];
    if (![taskKey isEqualToString:self.key])
        return;
    
    // do nothing if the page is not visible
    if (self.view.hidden == YES)
        return;
    
    [_model load];
}

- (void)moreButtonTouched {
    // find the cell to be expanded or collapsed
    IPhoneTaskDetailPageInfoCell* oldCell = [[self.rows objectAtIndex:0] objectAtIndex:0];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    // create a new cell
    
    IPhoneTaskDetailPageInfoCell* newCell = [[IPhoneTaskDetailPageInfoCell alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
    newCell.expanded = !oldCell.expanded;
    newCell.task = _model.taskItem;
    newCell.titleView.delegate = self;
    [newCell.moreButton setTitle:(newCell.expanded ? LS(@"Less", @"") : LS(@"More", @"")) forState:UIControlStateNormal];
    [newCell.moreButton addTarget:self action:@selector(moreButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    // replace with the new cell in data source
    
    NSMutableArray* sectionCells = [self.rows objectAtIndex:indexPath.section];
    [sectionCells replaceObjectAtIndex:0 withObject:newCell];
    
    // replace the row in tableView with a new cell
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)descMoreButtonTouched {
    // find the cell to be expanded or collapsed
    CVTaskPageDescCell* oldCell = [[self.rows objectAtIndex:1] objectAtIndex:0];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    // create a new cell
    CVTaskPageDescCell* newCell = [[CVTaskPageDescCell alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
    newCell.expanded = !oldCell.expanded;
    newCell.desc = _model.taskItem.description;
    newCell.textViewingDelegate = self;
    newCell.linkDelegate = self.linkHandler;
    [newCell.moreButton setTitle:(newCell.expanded ? LS(@"-", @"") : LS(@"+", @"")) forState:UIControlStateNormal];
    [newCell.moreButton addTarget:self action:@selector(descMoreButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    // replace with the new cell in data source
    
    NSMutableArray* sectionCells = [self.rows objectAtIndex:indexPath.section];
    [sectionCells replaceObjectAtIndex:0 withObject:newCell];
    
    // replace the row in tableView with a new cell
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    if (!newCell.expanded)
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark -
#pragma mark CVTileViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || indexPath.section == 1)
        return;
    else {
        CVTaskDetailCell* cell = (CVTaskDetailCell*)[tableView cellForRowAtIndexPath:indexPath];
        NSString* title = cell.title.text;
        if ([title isEqualToString:LS(@"Hotspots", @"")] || [title isEqualToString:LS(@"Folders", @"")]) {
            return;
        } else if ([title isEqualToString:LS(@"Comments", @"")]) {
            CVTaskSvcItem* task = _model.taskItem;
            int commentsCount = task.commentCount;
            // fixed:Should not allow to add comment for Supended/Archived/Trashed task
            if (0 == commentsCount
                && ([task.status isEqualToString:TASK_STATUS_SUSPENDED] || [task.status isEqualToString:TASK_STATUS_ARCHIVED] /*|| task.trash*/ || !task.enable || [task.status isEqualToString:TASK_STATUS_CLOSED])) {
                return;
            }
            
            UIViewController* vc = (commentsCount == 0) ? [[CVCommentComposerViewController alloc] initWithTaskKey:self.key] : [[CVCommentsViewController alloc] initWithKey:self.key];
            if (commentsCount != 0) {
                ((CVCommentsViewController*)vc).taskItem = task;
                [vc pushToStackFromViewController:self];
            }
            else {
                ((CVCommentComposerViewController*)vc).isFirstComment = YES;
                ((CVCommentComposerViewController*)vc).taskItem = task;
#ifdef CV_TARGET_IPAD
                [vc pushToStackFromViewController:self];
#else
                [self presentViewController:vc animated:YES completion:nil];
#endif
            }
        }
        else if ([title isEqualToString:LS(@"History Log", @"")]) {
            UIViewController* vc = [[CVTaskHistoryViewController alloc] initWithKey:self.key];
            [vc pushToStackFromViewController:self];
        } else if ([title isEqualToString:LS(@"Participants", @"")]){
            CVSparcViewController* svc = [[CVSparcViewController alloc] init];
            svc.type = @"To";
            svc.model = _model;
            [svc pushToStackFromViewController:self];
        }
        else {
            CVSparcViewController* svc = [[CVSparcViewController alloc] init];
            svc.type = title;
            svc.model = _model;
            [svc pushToStackFromViewController:self];
        }
    }
}

#pragma mark -
#pragma mark CVTileViewDelegate

- (void)didClickOnTileTitle:(CVTileTitleView *)tileTitleView {
    
}

- (void)didClickOnTileTypeIcon:(CVTileTitleView *)tileTitleView {
    
}

- (void)didClickOnTileVotes:(CVTileTitleView*)tileTitleView {
    _popupMenu = [[CVMenuPopup alloc] init];
    _popupMenu.items = @[@"up", @"down"];
    _popupMenu.rows = 2;
    _popupMenu.columns = 1;
    _popupMenu.delegate = self;
    [_popupMenu presentFromView:self.view];
    
}

- (void)didClickOnTileMore:(CVTileTitleView *)tileTitleView {
    CVTaskSvcItem* task = _model.taskItem;
    
    // If task is in Trash, don't enable anything
    if (!task.enable) {
        return;
    }
    
    NSMutableArray* items = [NSMutableArray array];
    
    if ([_model.taskACLItem canEditTask]) {
        [items addObject:@"Edit"];
    } else if (_model.taskACLItem.canAddParticipants)
        [items addObject:@"Add"];
    if (![[task subType] isEqualToString:@"draft"]) {
        if (_model.taskACLItem.canDeleteTask)
            [items addObject:@"Delete"];
        
        if (_model.taskACLItem.canAcceptTask)
            [items addObject:@"Accept"];
        if (_model.taskACLItem.canApprovalTask)
            [items addObject:@"Approve"];
        
        if (_model.taskACLItem.canCompleteTask && ![_model.taskItem.taskType isEqualToString:@"approval"])
            [items addObject:@"Complete"];
        
        if (_model.taskACLItem.canUndoComplete)
            [items addObject:@"Undo Complete"];
        
        if (_model.taskACLItem.canDeclineTask)
            [items addObject:@"Decline"];
        
        if (_model.taskACLItem.canCloseTask)
            [items addObject:@"Close"];
        
        if (_model.taskACLItem.canReopenTask)
            [items addObject:@"Reopen"];
        
        if (_model.taskACLItem.canArchiveTask)
            [items addObject:@"Archive"];
        
        if (_model.taskACLItem.canSuspendTask)
            [items addObject:@"Suspend"];
        
        if (_model.taskACLItem.canResumeTask)
            [items addObject:@"Resume"];
        
        if (_model.taskACLItem.canDismissTask)
            [items addObject:@"Acknowledge"];
    }
    [items addObject:@"Comments"];
    [items addObject:TILE_ACTION_ADD_TO_FOLDER];
    [items addObject:TILE_ACTION_COPY_LINK];
    [items addObject:TILE_ACTION_VIEW_HISTORY];
    [items addObject:TASK_TILE_ACTION_SAVE_AS_NEW];
    [items addObject:TASK_TILE_ACTION_SAVE_AS_TEMPLATE];
    _popupMenu = [[CVMenuPopup alloc] init];
    _popupMenu.items = items;
    _popupMenu.rows = [items count]%3 == 0 ? [items count]/3 : [items count]/3 + 1;
    _popupMenu.columns = 3;
    _popupMenu.delegate = self;
    [_popupMenu presentFromView:self.view];
    
}


#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        UITextField* nameField = [alertView textFieldAtIndex:0];
        NSString* name = nameField.text;
        if (!name || [name isEqualToString:@""]) {
            [CVAPIUtil alertMessage:LS(@"Please input a template name", @"")];
        }
        _model = [[CVTaskModel alloc] initWithKey:self.key];
        _model.delegate = self;
        [_model saveAsTemplate:name];
    }
}


#pragma mark -
#pragma mark CVMenuPopupDelegate

- (void)popup:(CVMenuPopup *)popup didSelectForAction:(NSString *)action {
    
    NSString* state = nil;
    
    if([action isEqualToString:TILE_ACTION_ADD_TO_FOLDER]) {
#ifdef CV_TARGET_IPAD
        [CVFolderPickerViewController presentZapViewControllerModallyFrom:self withDelegate:self andFolders:nil shouldDissmiss:YES];
#else
        CVFolderPickerViewController* vc = [[CVFolderPickerViewController alloc] initWithFolders:nil];
        vc.delegate = self;
        [vc pushToStack];
#endif
    }
    else if([action isEqualToString:TILE_ACTION_COPY_LINK]) {
        
    }
    else if([action isEqualToString:TILE_ACTION_VIEW_HISTORY]) {
        UIViewController* vc = [[CVTaskHistoryViewController alloc] initWithKey:self.key];
        [vc pushToStackFromViewController:self];
    }
    else if([action isEqualToString:TASK_TILE_ACTION_SAVE_AS_NEW]) {
        [CVTaskEditViewController presentTaskForRelatedTaskFromViewController:self taskKey:self.key type:RELATED_TYPE_REFERENCE];
    }
    else if([action isEqualToString:TASK_TILE_ACTION_SAVE_AS_TEMPLATE]) {
        _templateAlert = [[UIAlertView alloc] initWithTitle:LS(@"Please input a template name", @"") message:nil delegate:self cancelButtonTitle:LS(@"Cancel", @"") otherButtonTitles:LS(@"Add", @""), nil];
        [_templateAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        _templateAlert.delegate = self;
        [_templateAlert show];
    }
    else if ([action isEqualToString:@"up"] || [action isEqualToString:@"down"]) {
        CVRatingModel* ratingModel = [[CVRatingModel alloc] init];
        ratingModel.delegate = self;
        [ratingModel ratingWithAction:action andKeys:[NSArray arrayWithObject:self.key]];
    }
    else if ([action isEqualToString:@"Comments"]) {
        CVTaskSvcItem* task = _model.taskItem;
        int commentsCount = task.commentCount;
        // fixed:Should not allow to add comment for Supended/Archived/Trashed task
        if (0 == commentsCount
            && ([task.status isEqualToString:TASK_STATUS_SUSPENDED] || [task.status isEqualToString:TASK_STATUS_ARCHIVED] /*|| task.trash*/ || !task.enable || [task.status isEqualToString:TASK_STATUS_CLOSED])) {
            return;
        }
        
        UIViewController* vc = (commentsCount == 0) ? [[CVCommentComposerViewController alloc] initWithTaskKey:self.key] : [[CVCommentsViewController alloc] initWithKey:self.key];
        if (commentsCount != 0) {
            ((CVCommentsViewController*)vc).taskItem = task;
            [vc pushToStackFromViewController:self];
        }
        else {
            ((CVCommentComposerViewController*)vc).isFirstComment = YES;
            ((CVCommentComposerViewController*)vc).taskItem = task;
#ifdef CV_TARGET_IPAD
            [vc pushToStackFromViewController:self];
#else
            [self presentViewController:vc animated:YES completion:nil];
#endif
        }
        
    }
    else if ([action isEqualToString:@"Edit"]) {
        CVTaskEditViewController* editVC = [[CVTaskEditViewController alloc] initWithData:_model.taskRecord forAddPeople:NO];
#ifdef CV_TARGET_IPAD
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:editVC];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nav animated:YES completion:nil];
#else
        [editVC pushToStackFromViewController:self];
#endif
    }
    else if ([action isEqualToString:@"Add"]) {
        CVTaskEditViewController* editVC = [[CVTaskEditViewController alloc] initWithData:_model.taskRecord forAddPeople:YES];
#ifdef CV_TARGET_IPAD
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:editVC];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nav animated:YES completion:nil];
#else
        [editVC pushToStackFromViewController:self];
#endif
    }
    else if ([action isEqualToString:@"Delete"]) {
        [_model delete];
    }
    else {
        if ([action isEqualToString:@"Complete"])
            state = @"complete";
        else if ([action isEqualToString:@"Undo Complete"])
            state = @"undoComplete";
        else if ([action isEqualToString:@"Decline"])
            state = @"decline";
        else if ([action isEqualToString:@"Close"])
            state = @"close";
        else if ([action isEqualToString:@"Reopen"])
            state = @"reopen";
        else if ([action isEqualToString:@"Archive"])
            state = @"archive";
        else if ([action isEqualToString:@"Suspend"])
            state = @"suspend";
        else if ([action isEqualToString:@"Resume"])
            state = @"resume";
        else if ([action isEqualToString:@"Accept"])
            state = @"accept";
        else if ([action isEqualToString:@"Approve"])
            state = @"complete";
        else if ([action isEqualToString:@"Acknowledge"])
            state = @"dismiss";
        if (state)
            [_model updateState:state];
    }
    
}

#pragma mark -
#pragma mark CVContactPickerDelegate

-(void)recipientsChanged:(NSArray*)recipients {
    
    NSMutableArray* array = [NSMutableArray array];
    if (_bottomCell.tabControl.selectedTabIndex == 1) {
        for (CVUserListItem* item in _model.taskItem.assignees)
            [array addObject:item.key];
    }
    if (_bottomCell.tabControl.selectedTabIndex == 2) {
        for (CVUserListItem* item in _model.taskItem.ccers)
            [array addObject:item.key];
    }
    if (_bottomCell.tabControl.selectedTabIndex == 3) {
        for (CVUserListItem* item in _model.taskItem.bccers)
            [array addObject:item.key];
    }
    if (_bottomCell.tabControl.selectedTabIndex == 4) {
        for (CVUserListItem* item in _model.taskItem.sccers)
            [array addObject:item.key];
    }
    for (NSDictionary* item in recipients) {
        NSString* userKey = [item objectForKey:@"key"];
        if (![array containsObject:userKey])
            [array addObject:userKey];
    }
    if (_bottomCell.tabControl.selectedTabIndex == 1)
        [_model addParticipants:array forType:@"assignee"];
    if (_bottomCell.tabControl.selectedTabIndex == 2)
        [_model addParticipants:array forType:@"cc"];
    if (_bottomCell.tabControl.selectedTabIndex == 3)
        [_model addParticipants:array forType:@"bcc"];
    if (_bottomCell.tabControl.selectedTabIndex == 4)
        [_model addParticipants:array forType:@"scc"];
    
}

#pragma mark -
#pragma mark CVFilePickerDelegate

- (void)AttachmentsChanged:(NSArray *)attachments {
    
    NSMutableArray* array = [NSMutableArray array];
    for (CVFileListItem* item in _model.taskItem.attachments)
        [array addObject:item.key];
    for (NSDictionary* item in attachments) {
        NSString* key = [item objectForKey:@"key"];
        if (![array containsObject:key])
            [array addObject:key];
    }
    [_model addAttachments:array];
    
}

#pragma mark -
#pragma mark CVFolderPickerDelegate

- (void)foldersChanged:(NSArray *)folders {
    NSMutableArray* folderKeys = [NSMutableArray array];
    for (CVFolderListItem* folderItem in folders) {
        [folderKeys addObject:folderItem.key];
    }
    [_folderModel addToFoldersWithContentKeys:[NSArray arrayWithObject:self.key] andFolderKeys:folderKeys];
}

- (void)editBarItemTouched {
    UIViewController* vc = [[CVChatEditViewController alloc] initWithData:_model.taskRecord forAddPeople:NO];
    
    if (self.navigationController)
        [self.navigationController pushViewController:vc animated:YES];
    else {
        UINavigationController* nv = [[UINavigationController alloc] initWithRootViewController:vc];
        [nv pushToStack];
    }
}

@end
