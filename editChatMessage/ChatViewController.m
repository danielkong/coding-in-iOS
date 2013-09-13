
#import "CVChatViewController.h"
#import "NSDictionary+DragonAPI.h"
#import "NSDictionary+DragonAPITask.h"
#import "CVCommentComposerViewController.h"
#import "CVChatEditViewController.h"
#import "Task+Bizlogic.h"
#import "CVCommentItem.h"
#import "CVChatItemCell.h"
#import "Task.h"
#import <AVFoundation/AVFoundation.h>
#import "CVChatHeader.h"
#import "CVTableViewSectionHeaderView.h"
#import "CVDataModel.h"
#import "CVDraggableLabel.h"
#import "NSString+HTML.h"

#define IDLE_TIME_INTERVAL 20
#define CHAT_BAR_HEIGHT 90
#define CHAT_BOX_PADDING 7

#ifdef CV_TARGET_IPHONE
#define CHAT_BOX_WIDTH 220
#else
#define CHAT_BOX_WIDTH 370
#endif

#define BG_COLOR        [RGBCOLOR(233,233,233) colorWithAlphaComponent:0.3]

@interface CVChatViewController () <UITextViewDelegate, CVChatItemCellDelegate, TTURLRequestDelegate>

@property(nonatomic, retain) UITextView* textView;
@property(nonatomic, retain) UIActivityIndicatorView* activityIndicator;
@property(nonatomic, retain) UIBarButtonItem* textViewBarItem;
@property(nonatomic, retain) UIBarButtonItem* activityIndicatorBarItem;
@property(nonatomic, retain) NSString* updateCommentKey;
@property(nonatomic, assign) BOOL updateComment;
@property(nonatomic, retain) TTURLRequest* chatPostRequest;

@property(nonatomic, retain) NSTimer* idleTimer;
@property(nonatomic, assign) BOOL isTexting;

@property(nonatomic, retain) UIBarButtonItem* editBarItem;
@property(nonatomic, retain) UIBarButtonItem* addPeopleBarItem;
@property(nonatomic, retain) UIBarButtonItem* rightBarItem;

@property(nonatomic, retain) Task* chatTask;

@property(nonatomic, retain) TTURLRequest* chatCreateRequest;
//@property(nonatomic, retain) CVDraggableLabel* draggableTitleLabel;
@property(nonatomic, assign) BOOL isEditingComment;
@property(nonatomic, retain) NSString* commentKeyForEditing;

@end

@implementation CVChatViewController

- (id)initWithKey:(NSString *)key {}

- (id)init {}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.contentSizeForViewInPopover = CGSizeMake(CHAT_PAGE_WIDTH, CHAT_PAGE_HEIGHT);
    
    _isTexting = NO;
    
    //self.bottomBar.height = CHAT_BAR_HEIGHT;
    self.bottomBar.backgroundColor = [UIColor darkGrayColor];
    _textView = [[UITextView alloc] initWithFrame:CGRectMake (CHAT_BOX_PADDING, CHAT_BOX_PADDING,CHAT_BOX_WIDTH,self.bottomBar.height - CHAT_BOX_PADDING * 2)];
    _textView.layer.cornerRadius = 5;
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _textView.font = [UIFont systemFontOfSize:14];
    _textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    _textView.autocorrectionType = UITextAutocorrectionTypeYes;
    _textView.spellCheckingType = UITextSpellCheckingTypeYes;
    _textViewBarItem = [[UIBarButtonItem alloc] initWithCustomView:_textView];
    _textView.returnKeyType = UIReturnKeySend;
    _textView.enablesReturnKeyAutomatically = YES;
    _textView.keyboardType = UIKeyboardTypeDefault;
    _textView.delegate = self;
    //[_textView becomeFirstResponder];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    _activityIndicatorBarItem = [[UIBarButtonItem alloc] initWithCustomView:_activityIndicator];
   // self.audioCommentButton.frame = CGRectMake(0, 0, self.view.width, 90);
    
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];


    [self setBottomBarItems:[NSArray arrayWithObjects:_textViewBarItem,flexibleSpace, /*_activityIndicatorBarItem, */self.audioCommentBarButton,self.photoCommentBarButton, nil]];

    _editBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(editBarItemTouched)];
    _addPeopleBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPeopleBarItemTouched)];
    
//    self.navigationItem.titleView = _draggableTitleLabel;
}

#pragma mark -
#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        if (_isEditingComment) {
            NSString* editCommonWithHTMLFormat = @"";
            NSArray* splitEditCommentIntoEachLine = [textView.text componentsSeparatedByString: @"\n"];
            NSMutableString* eachLineContent = [[NSMutableString alloc] init];
//            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
//                                     //[NSNumber numberWithFloat:1.23], NSTextSizeMultiplierDocumentOption, // default font size 12pt
//                                     //[NSValue valueWithCGSize:maxImageSize], DTMaxImageSize,
//                                     @"Helvetica", DTDefaultFontFamily,
//                                     @"darkblue", DTDefaultLinkColor,
//                                     nil];
//            for (eachLineContent in splitEditCommentIntoEachLine) {
//
//                NSData* htmlData = [eachLineContent dataUsingEncoding:NSUTF8StringEncoding];
//                DTRichTextEditorView* temp = [[DTRichTextEditorView alloc] init];
//                [temp setAttributedText:[[NSAttributedString alloc] initWithHTMLData:htmlData options:options documentAttributes:nil]];
//                editCommonWithHTMLFormat = [NSString stringWithFormat:@"%@%@%@", editCommonWithHTMLFormat, [temp.attributedText htmlFragment], @"\n"];
//            }
            
            for (eachLineContent in splitEditCommentIntoEachLine) {
                eachLineContent = [NSString stringWithFormat:@"%@%@", @"<p>", eachLineContent];
                eachLineContent = [NSString stringWithFormat:@"%@%@", eachLineContent, @"</p>"];
                editCommonWithHTMLFormat = [NSString stringWithFormat:@"%@%@%@", editCommonWithHTMLFormat, eachLineContent, @"\n"];
//                editCommonWithHTMLFormat = [NSString stringWithFormat:@"%@%@", editCommonWithHTMLFormat, eachLineContent];

            }

            _textView.text = editCommonWithHTMLFormat;
            [self postEditComment];
            _isEditingComment = NO;

        } else {
            [self post];
        }
        return NO;
    }
    return YES;
}

- (void)post {
    
    //[_textView resignFirstResponder];
    
    // display activity indicator    
    [self startActivityIndicator];
    
    
    [_activityIndicator startAnimating];
    
    // stop all controlls
    Comment* comment = [Comment commentWithUniqueId:@"+" inManagedObjectContext:[[DataStore sharedDataStore] managedObjectContext]];
    comment.text = _textView.text;
    comment.creationTime = [[NSDate date] timeIntervalSince1970];
    comment.timeEdited = comment.creationTime;
    comment.inWhichTask = [Task taskWithUniqueId:self.key inManagedObjectContext:[[DataStore sharedDataStore] managedObjectContext]];
    comment.createdBy = [User userWithUniqueUserId:[CVAPIUtil getUserKey] inManagedObjectContext:[[DataStore sharedDataStore] managedObjectContext]];
    comment.seqNumber = [NSNumber numberWithInteger:comment.inWhichTask.commentcount.integerValue + 1];
    [self postNewComment:comment];
    
    _textView.text=@"";
}
- (void)postEditComment{    
   
    // display activity indicator
    [self startActivityIndicator];
    
    [_activityIndicator startAnimating];
    
    Comment* comment = [Comment commentWithUniqueId:_commentKeyForEditing inManagedObjectContext:[[DataStore sharedDataStore] managedObjectContext]];
    comment.text = _textView.text;
    comment.timeEdited = [[NSDate date] timeIntervalSince1970];
    comment.creationTime = comment.timeEdited;
    comment.inWhichTask = [Task taskWithUniqueId:self.key inManagedObjectContext:[[DataStore sharedDataStore] managedObjectContext]];
    [self postNewComment:comment];
 	
    _textView.text=@"";
}

#pragma mark -
#pragma mark CVChatItemCellDelegate

- (void)bubbleTouchedAtCell:(UITableViewCell *)cell {
    [_textView resignFirstResponder];
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    [super tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

- (void)didEditComment:(Comment *)comment {
    NSString* commentShown = [[NSString alloc] init];
    commentShown = [[comment.text stringByStrippingTags]  stringByDecodingHTMLEntities];
    _textView.text = commentShown;
    _isEditingComment = YES;
    _commentKeyForEditing = comment.commentKey;
}

