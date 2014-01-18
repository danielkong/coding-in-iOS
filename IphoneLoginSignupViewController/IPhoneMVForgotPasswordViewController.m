//
//  IPhoneMVForgotPasswordViewController.m
//  Vmoso
//
//  Created by Daniel Kong on 1/10/14.
//  Copyright (c) 2014 Broadvision. All rights reserved.
//

#import "IPhoneMVForgotPasswordViewController.h"
#import "IPhoneMVLoginViewController.h"
#import "NSDictionary+DragonAPI.h"
#import "FlipBoardNavigationController.h"
#import "CVAPIUtil.h"
#import "NSDictionary+DragonAPI.h"
#import "NSDictionary+DragonAPIUser.h"
#import "CVPushController.h"
#import "IPadNewProfileFormViewController.h"
#import "CVFilePostViewController.h"
#import "CVTaskViewController.h"
#import "CVSettingsModel.h"
#import "CVChatsViewController.h"
#import "CVLanguageNameViewController.h"
#import "IPhoneMenuViewController.h"

#define TABLEVIEW_CELL_HEIGHT     55
#define TEXT_FIELD_FONT           [UIFont boldSystemFontOfSize:16]
#define TEXT_FIELD_FONT_SMALL     [UIFont systemFontOfSize:14]

#define FORM_WIDTH      300
#define FORM_HEIGHT     310
#define CELL_PADDING    5
#define IMAGE_X         50
#define IMAGE_Y         20

#define FIELD_HEIGHT    40
#define FORM_SPACER     20
#define TITLE_HEIGHT    110
#define FORM_LR_SPACER  40
#define BUTTON_HEIGHT   34
#define BUTTON_WIDTH    300

static NSString* kReqParamKeyForUserId = @"userid";
static NSString* kReqParamKeyForPassword = @"password";
static NSString* kReqParamKeyForNetworkId = @"networkid";
static NSString* kLoginAPI = @"%@/api/rest";
static NSString* defaultSite = @"www.vmoso.com";

@interface IPhoneMVForgotPasswordViewController ()

@property(nonatomic, retain) UITextField* usernameTextField;
@property(nonatomic, retain) UITextField* passwordTextField;
@property(nonatomic, retain) UITextField* domainTextField;
@property(nonatomic, retain) UIButton* forgotPasswordButton;
@property(nonatomic, retain) NSArray* signInFormItems;
@property(nonatomic, retain) UIButton* requestPasswordButton;
@property(nonatomic, retain) UIActivityIndicatorView* activityIndicator;
@property(nonatomic, retain) NSString* currentDomain;
@property(nonatomic, retain) UIView* currentForm;
@property(nonatomic, retain) UIView* resetPasswordFormView;
@property(nonatomic, retain) UILabel* messageLabel;
@property(nonatomic, retain) UIView* confirmFormView;
@property(nonatomic, retain) UIView* formView;
@property(nonatomic, retain) UIView* signInFormView;
@property(nonatomic, retain) UIView* signUpFormView;
@property(nonatomic, retain) UIView* forgotPasswordFormView;
@property(nonatomic, assign) CGFloat bottomOfForm;
@property(nonatomic, retain) UITextField* resetPasswordField1;
@property(nonatomic, retain) NSString* defaultLanguage;
@property(nonatomic, assign) BOOL showWelcomeWizard;
@property(nonatomic, retain) CVSettingsModel* model;

@end

@implementation IPhoneMVForgotPasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.title = LS(@"FORGET PASSWORD", @"");
    
    UITableViewCell* cell = nil;
    NSMutableArray* formItems = [[NSMutableArray alloc] init];
    
    NSString *cellIdentifier=@"cellInfo";
    
    // login name (email address)
    _usernameTextField = [self emailTextField];
    _usernameTextField.delegate = self;
    [_usernameTextField setReturnKeyType:UIReturnKeyNext];
    [_usernameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:_usernameTextField];
    [formItems addObject:cell];
    
    // network URL
    _domainTextField = [self domainField];
    
    // specifiy some input traits for this last text field
    _domainTextField.enablesReturnKeyAutomatically=YES;
    _domainTextField.delegate = self;
    [_domainTextField setReturnKeyType:UIReturnKeyGo];
    [_domainTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:_domainTextField];
    [formItems addObject:cell];
    
    _signInFormItems = formItems;
    
    self.rows = @[_signInFormItems];
    
    [_usernameTextField becomeFirstResponder];
    
    UIView* loginFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0.5)];
    line.alpha = 0.5;
    line.backgroundColor = [UIColor lightGrayColor];
    [loginFooterView addSubview:line];
    
    _requestPasswordButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 15, 260, 40)];
    [_requestPasswordButton setTitle:LS(@"Request Password",@"") forState:UIControlStateNormal];
    _requestPasswordButton.backgroundColor = [UIColor orangeColor];
    [_requestPasswordButton setFont:[UIFont boldSystemFontOfSize:18.0]];
    [[_requestPasswordButton layer] setBorderWidth:2.0f];
    [[_requestPasswordButton layer] setBorderColor:[UIColor orangeColor].CGColor];
    [[_requestPasswordButton layer] setCornerRadius:3.0f];
    _requestPasswordButton.hidden = YES;
    [_requestPasswordButton addTarget:self action:@selector(requestPasswordButtonTouched) forControlEvents:UIControlEventTouchDown];
    
    _activityIndicator = [self activityIndicatorView];
    _activityIndicator.frame = CGRectMake(_requestPasswordButton.width/2 + 50, 15, 10, 10);
    [_requestPasswordButton addSubview:_activityIndicator];
    
    [loginFooterView addSubview:_requestPasswordButton];
    
    if (getOSf() >= 7.0)
        self.tableView.separatorInset = UIEdgeInsetsZero;
    
    self.tableView.separatorStyle = YES;
    self.tableView.scrollEnabled = NO;
    self.tableView.tableFooterView = loginFooterView;
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark private methods

-(NSString*) networkHostname: (NSString*)networkURL {
	
	NSString* lowercaseURL = [networkURL lowercaseString];
	if (![lowercaseURL hasPrefix:@"https://"] && ![lowercaseURL hasPrefix:@"http://"])
		return lowercaseURL;
	
	NSURL *url = [NSURL URLWithString:lowercaseURL];
	return [url host];
}

-(NSString*) networkAddress: (NSString*) networkURL {
	NSString *host = [self networkHostname:networkURL];
	return [NSString stringWithFormat:@"https://%@", host];
}

-(NSString*) networkId:(NSString*)networkURL {
    NSString* host = [self networkHostname:networkURL];
    NSArray* components = [host componentsSeparatedByString:@"."];
    if (components)
        return [components objectAtIndex:0];
    
    return host;
}

-(UITextField*) emailTextField{
    UITextField* emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 5, self.view.width-15, 40)];
    emailTextField.font = [self textFont];
    emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    emailTextField.backgroundColor = [UIColor clearColor];
    emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    emailTextField.secureTextEntry = NO;
    emailTextField.textColor=[UIColor blackColor];
    emailTextField.placeholder=LS(@"Email address", @"");
    emailTextField.text = @"";
    return emailTextField;
}

-(UITextField*) domainField{
    UITextField* domainField = [[UITextField alloc] initWithFrame:CGRectMake(15, 5, self.view.width-15, 40)];
    domainField.font = [self textFont];
    domainField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    domainField.backgroundColor = [UIColor clearColor];
    domainField.clearButtonMode = UITextFieldViewModeWhileEditing;
    domainField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    domainField.autocorrectionType = UITextAutocorrectionTypeNo;
    domainField.spellCheckingType = UITextSpellCheckingTypeNo;
    domainField.keyboardType = UIKeyboardTypeURL;
    domainField.secureTextEntry = NO;
    domainField.textColor=[UIColor blackColor];
    domainField.placeholder = defaultSite;
    domainField.text = defaultSite;
    return domainField;
}

- (UIFont*)textFont {
    return TEXT_FIELD_FONT;
}

- (UIFont*)textFontSmall {
    return TEXT_FIELD_FONT_SMALL;
}

-(UIActivityIndicatorView*) activityIndicatorView{
    UIActivityIndicatorView* activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.hidesWhenStopped = YES;
    return activityIndicatorView;
}

# pragma mark - UITableView Delgate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TABLEVIEW_CELL_HEIGHT;
}

#pragma mark -
#pragma mark private - forgot password button handler

- (void)requestPasswordButtonTouched {
    
    if([_usernameTextField.text length] <= 0) {
        [self raiseAlert:LS(@"Please enter your email address", @"")];
        return;
    }
    _requestPasswordButton.enabled = NO;
    
    if (_domainTextField.text && _domainTextField.text.length > 0)
        _currentDomain  = _domainTextField.text;
    else
        _currentDomain  = defaultSite;
    
    [self requestPassword];
    
}

#pragma mark -
#pragma mark private - send remote password request

- (void) requestPassword
{
    NSString* emailAddress = self.usernameTextField.text;
    
    NSString* address = self.currentDomain;
    NSString* networkId = [self networkId:address];
    
    NSString* apiURL = nil;
    
    if ([address hasSubStr:@"/api/rest"])
        apiURL = address;
    else {
        // nomalize networkAddress
        NSString* networkAddress = [self networkAddress:address];
        apiURL = [NSString stringWithFormat:kLoginAPI, networkAddress];
    }
    
    CVAPIRequest* request = [[CVAPIRequest alloc] initWithCommand:@"cvauth.CVAuthenticator.ResetPwdRequest" andApiPath:apiURL];
    NSDictionary* param = [NSDictionary dictionaryWithObjectsAndKeys:networkId, kReqParamKeyForNetworkId, emailAddress, @"account", nil];
    NSString* jsonRequest = [param jsonValue];
    [request setParamString:jsonRequest];
    
    CVAPIRequestModel* model = [[CVAPIRequestModel alloc] init];
    [model sendRequest:request completion:^(NSDictionary* apiResult, NSError* error) {
        _requestPasswordButton.enabled = YES;
        [_activityIndicator stopAnimating];
        
        if (!error) {
            if ([apiResult isDragonAPIResultOK]) {
                [self checkResult:apiResult];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:LS(@"Authentication failed",@"")
                                                               delegate:nil
                                                      cancelButtonTitle:LS(@"OK",@"")
                                                      otherButtonTitles: nil];
                [alert show];
            }
        } else {
            NSString *errorMsg = @"Invalid network address.";
            
            if (![[ReachabilityManager sharedManager] isReachable]) {
                errorMsg = @"This network is not reachable,please check your network connection.";
            }
            
            // connection failed
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:LS(errorMsg,@"")
                                                           delegate:nil
                                                  cancelButtonTitle:LS(@"OK",@"")
                                                  otherButtonTitles: nil];
            [alert show];
        }
    }];
    
}

#pragma mark -
#pragma mark private - registration complete

- (void) checkResult:(NSDictionary *)remoteData {
    
    NSDictionary* result = [remoteData objectForKey:@"result"];
    if (! result) {
        [self raiseAlert:LS(@"Invalid network address.",@"")];
        return;
    }
    
    NSInteger returnCode = [[result objectForKey:@"returnCode"] intValue];
    
    NSString* errorMessage = [result objectForKey:@"errorMessage"];
    
    if (returnCode == 0) {
        if(![_currentForm isEqual:_resetPasswordFormView]) {
            NSString* confirmMessage = @"";
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"My Vmoso"
                                                            message:LS(@"Request password successfully", @"")
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
            
            _messageLabel.text = confirmMessage;
            [self setMessageLabelFrame];
            [self transitionFormFromView:self.currentForm toView:self.confirmFormView];
            _currentForm = _confirmFormView;
        } else {
            [self loginWithNetwork:self.currentDomain username:[result objectForKey:@"userName"] password:_resetPasswordField1.text];
        }
        
    }
    else if (errorMessage) {
        [self raiseAlert:errorMessage];
    } else {
        [self raiseAlert:LS(@"Invalid network address.",@"")];
    }
    
    return;
}

-(void)setMessageLabelFrame {
    CGFloat formWidth = self.formView.width;
    CGFloat msgsWidth = formWidth - 2* FORM_LR_SPACER;
    self.confirmFormView.frame=CGRectMake(FORM_LR_SPACER, TITLE_HEIGHT, msgsWidth, FORM_HEIGHT - TITLE_HEIGHT - 2*CELL_PADDING);
    
    CGFloat msgWidth = msgsWidth - 2* CELL_PADDING;
    CGSize theSize = [self.messageLabel.text sizeWithFont:[self textFont]
                                        constrainedToSize:CGSizeMake(msgWidth, 9999)];
    CGFloat height = theSize.height;
    
    self.messageLabel.frame = CGRectMake(CELL_PADDING, FIELD_HEIGHT, msgWidth, height);
}

#pragma mark -
#pragma mark Utility - bring up AlertView to show error message

- (void) raiseAlert:(NSString*)errorMsg {
    // connection failed
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:LS(errorMsg,@"")
                                                   delegate:nil
                                          cancelButtonTitle:LS(@"OK",@"")
                                          otherButtonTitles: nil];
    [alert show];
}

#pragma mark -
#pragma mark private - send remote login request

- (void)loginWithNetwork:(NSString*)address username:(NSString *)username password:(NSString *)password {
    
    NSString* networkId = [self networkId:address];
    NSString* apiURL = nil;
    
    if ([address hasSubStr:@"/api/rest"])
        apiURL = address;
    else {
        // nomalize networkAddress
        NSString* networkAddress = [self networkAddress:address];
        apiURL = [NSString stringWithFormat:kLoginAPI, networkAddress];
    }
    
    CVAPIRequest* request = [[CVAPIRequest alloc] initWithCommand:@"cvauth.CVAuthenticator.RequestAccessToken" andApiPath:apiURL];
    NSDictionary* param = [NSDictionary dictionaryWithObjectsAndKeys:username, kReqParamKeyForUserId, password, kReqParamKeyForPassword, networkId, kReqParamKeyForNetworkId, nil];
    NSString* jsonRequest = [param jsonValue];
    [request setParamString:jsonRequest];
    
    CVAPIRequestModel* model = [[CVAPIRequestModel alloc] init];
    [model sendRequest:request completion:^(NSDictionary* apiResult, NSError* error) {
        _requestPasswordButton.enabled = YES;
        [_activityIndicator stopAnimating];
        
        if (!error) {
            if ([apiResult isDragonAPIResultOK]) {
                NSString* token = [apiResult getDragonAPIStringValueForKey:@"token"];
                NSString* sharedKey = [apiResult getDragonAPIStringValueForKey:@"sharedkey"];
                NSString* clientId = [apiResult getDragonAPIStringValueForKey:@"clientid"];
                NSMutableDictionary* userInfo = [[apiResult objectForKey:@"result" ] objectForKey:@"userinfo"];
                [userInfo setObject:username forKey:@"email"];
                
                // save the login data for future use
                [CVAPIUtil saveUserId:username
                             password:password
                             clientId:clientId
                            sharedKey:sharedKey
                                token:token
                              userKey:[userInfo userKey]
                          apiEndpoint:apiURL
                             userInfo:userInfo];
                
#if !TARGET_IPHONE_SIMULATOR
                // enable the device to receive push notificaions
                CVPushController *controller = [CVPushController sharedController];
                controller.userKey = [userInfo userKey];
                [controller enable];
#endif
                
                //[self requestForGetConfigOfPush];
                
                NSMutableString* apiPath = [[NSMutableString alloc] initWithString:@"/svc/push/getconfig"];;
                NSString* paramsString = [CVAPIRequest GETParamString:@{@"protocol":@"ws", @"_hdr.ofmt":@"json"}];
                [apiPath appendString:paramsString];
                CVAPIRequest* requestForGetConfig = [[CVAPIRequest alloc] initWithAPIUrlString:apiPath];
                NSLog(@"CVWebSocket: request = %@", [requestForGetConfig description]);
                
                CVAPIRequestModel* model = [[CVAPIRequestModel alloc] init];
                [model sendRequest:requestForGetConfig completion:^(NSDictionary* apiResult, NSError* error) {
                    if (!error && [apiResult isDragonAPIResultOK]) {
                        NSLog(@"CVWebSocket: requestForGetConfigOfPush data: %@",apiResult);
                        NSString* host = [CVAPIUtil getValidString:[apiResult objectForKey:@"host"]];
                        [CVAPIUtil savePushConfigInfo:host];
                        NSLog(@"CVWebSocket: saved push host:%@", [CVAPIUtil getPushConfigInfo]);
                        
                        //handle welcom wizard
                        NSString* firstENN = [userInfo objectForKey:@"first_name_romanized"];
                        NSString* lastENN = [userInfo objectForKey:@"last_name_romanized"];
                        if(firstENN == nil || lastENN == nil || [firstENN isEqualToString:@""] || [lastENN isEqualToString:@""]) {
                            [self setUserLanguage];
                        }
                        else {
                            _showWelcomeWizard = NO;
                            [self signedInSuccessfully];
                        }
                        
                        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                        [nc postNotificationName:NOTIF_USER_PREFERENCE_REFRESH object:nil userInfo:nil];
                        
                        Context* context = [Context sharedContext];
                        if ([context objectForKey:@"TargetUrl"]) {
                            NSURL* url = [context objectForKey:@"TargetUrl"];
                            NSString* urlString = [url absoluteString];
                            if ([urlString hasPrefix:@"file://"]){
                                [CVFilePostViewController openFileUploadViewController: url];
                            } else if ([urlString hasPrefix:@"vmoso://"]){
                                [CVTaskViewController openTaskOrCommentFromWebUrl: url];
                                [context removeObjectForKey:@"TargetUrl"];
                            }
                        }
                        
                    }
                    else{
                        NSLog(@"CVWebSocket: invalid result from /svc/push/getconfig = %@, error: %@", apiResult, error);
                    }
                }];
                
                
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:LS(@"Authentication failed",@"")
                                                               delegate:nil
                                                      cancelButtonTitle:LS(@"OK",@"")
                                                      otherButtonTitles: nil];
                [alert show];
            }
        } else {
            
            //distinguish the error info:invalid network address or network unreachable
            
            NSString *errorMsg = @"Invalid network address.";
            
            if (![[ReachabilityManager sharedManager] isReachable]) {
                errorMsg = @"This network is not reachable,please check your network connection.";
            }
            
            // connection failed
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:LS(errorMsg,@"")
                                                           delegate:nil
                                                  cancelButtonTitle:LS(@"OK",@"")
                                                  otherButtonTitles: nil];
            [alert show];
        }
    }];
    
}

#pragma mark -
#pragma mark private - set user language

- (void) setUserLanguage {
    NSMutableDictionary* para = [NSMutableDictionary dictionary];
    NSMutableArray* settingsArray = [NSMutableArray array];
    
    [para setObject:[NSDictionary dictionaryWithObjectsAndKeys:SETTING_ITEM_LANGUAGE, @"namespace", nil] forKey:@"options"];
    
    _defaultLanguage = [CVAPIUtil getDefaultLanguage];
    NSDictionary* setting = [NSDictionary dictionaryWithObjectsAndKeys:@"language", @"name", _defaultLanguage, @"value", nil];
    [settingsArray addObject:setting];
    
    [para setObject:settingsArray forKey:@"settings"];
    [_model saveSettings:para isPassword:NO];
}

- (void)signedInSuccessfully {
    BOOL showWelcomeWizard = self.showWelcomeWizard;
    [self dismissViewControllerAnimated:YES completion:^{
        if(showWelcomeWizard)
            [CVLanguageNameViewController presentModalViewFromViewController:self animated:YES];
        else {
            CVChatsViewController* sVC = [[CVChatsViewController alloc] init];
            [sVC pushToStack];
        }
    }];
}

// transition from Signup form to confirmation form
- (void) transitionFormFromView:(UIView*)fromView toView:(UIView*)toView {
    
    [UIView transitionWithView:fromView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        
                        _signInFormView.hidden = YES;
                        _signUpFormView.hidden = YES;
                        _forgotPasswordFormView.hidden = YES;
                        _confirmFormView.hidden = YES;
                        _resetPasswordFormView.hidden = YES;
                        
                    }
                    completion:^(BOOL finished) {
                        
                        [UIView transitionWithView:toView
                                          duration:0.7
                                           options:UIViewAnimationOptionTransitionCrossDissolve
                                        animations:^{
                                            
                                            toView.hidden = NO;
                                            
                                        }
                                        completion:nil];
                    }];
    
    [self.view endEditing:YES];
}


# pragma mark - UITextField Delgate

- (void)textFieldDidChange:(UITextField *)textField {
    if ([_usernameTextField.text isEqualToString:@""] || [_domainTextField.text isEqualToString:@""])
        _requestPasswordButton.hidden = YES;
    else
        _requestPasswordButton.hidden = NO;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _domainTextField) {
        [self requestPasswordButtonTouched];
    } else if (textField == _usernameTextField) {
        [_domainTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

# pragma mark - AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self popFromStack];
}

@end
