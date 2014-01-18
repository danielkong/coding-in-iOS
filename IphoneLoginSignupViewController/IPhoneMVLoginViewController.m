//
//  IPhoneMVLoginViewController.m
//  Vmoso
//
//  Created by Daniel Kong on 1/7/14.
//  Copyright (c) 2014 Broadvision. All rights reserved.
//

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
#import "IPhoneMVForgotPasswordViewController.h"
#import "CVWebSocket.h"

#define TABLEVIEW_CELL_HEIGHT     55
#define TEXT_FIELD_FONT           [UIFont systemFontOfSize:16]
#define TEXT_FIELD_FONT_SMALL     [UIFont systemFontOfSize:14]

static NSString* kReqParamKeyForUserId = @"userid";
static NSString* kReqParamKeyForPassword = @"password";
static NSString* kReqParamKeyForNetworkId = @"networkid";
static NSString* kLoginAPI = @"%@/api/rest";
static NSString* defaultSite = @"www.vmoso.com";

@interface IPhoneMVLoginViewController () <UITableViewDelegate>

// Login fields
@property(nonatomic, retain) UITextField* usernameTextField;
@property(nonatomic, retain) UITextField* passwordTextField;
@property(nonatomic, retain) UITextField* domainTextField;
@property(nonatomic, retain) UIButton* forgotPasswordButton;
@property(nonatomic, retain) NSArray* signInFormItems;
@property(nonatomic, retain) UIButton* loginButton;

@property(nonatomic, assign) BOOL showWelcomeWizard;
@property(nonatomic, retain) NSString* defaultLanguage;
@property(nonatomic, retain) CVSettingsModel* model;
@property(nonatomic, retain) UIActivityIndicatorView* activityIndicator;

@end

@implementation IPhoneMVLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.title = LS(@"MyVmoso", @"");
    
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
    
    // password
    _passwordTextField = [self passwordFieldWithPlaceholder:LS(@"Password", @"")];
    
    // specifiy some input traits for this last text field
    [_passwordTextField setReturnKeyType:UIReturnKeyGo];
    _passwordTextField.enablesReturnKeyAutomatically=YES;
    _passwordTextField.delegate = self;
    [_passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:_passwordTextField];
    [formItems addObject:cell];
    
    // network URL
    _domainTextField = [self domainField];
    
    // specifiy some input traits for this last text field
    _domainTextField.enablesReturnKeyAutomatically=YES;
    _domainTextField.delegate = self;
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
    
    _loginButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 15, 240, 50)];
    [_loginButton setTitle:@"LOG IN" forState:UIControlStateNormal];
    _loginButton.backgroundColor = [UIColor orangeColor];
    [_loginButton setFont:[UIFont boldSystemFontOfSize:24.0]];
    [[_loginButton layer] setBorderWidth:2.0f];
    [[_loginButton layer] setBorderColor:[UIColor orangeColor].CGColor];
    [[_loginButton layer] setCornerRadius:3.0f];
    _loginButton.hidden = YES;
    [_loginButton addTarget:self action:@selector(signInButtonTouched) forControlEvents:UIControlEventTouchDown];
    
    _activityIndicator = [self activityIndicatorView];
    _activityIndicator.frame = CGRectMake(_loginButton.width - 40, 20, 10, 10);
    [_loginButton addSubview:_activityIndicator];
    
    [loginFooterView addSubview:_loginButton];
    
    //forgot password
    _forgotPasswordButton = [[UIButton alloc] initWithFrame:CGRectMake(90, _loginButton.bottom + 10, 140, 20)];
    [_forgotPasswordButton setTitle:LS(@"Forgot Password?", @"") forState:UIControlStateNormal];
    _forgotPasswordButton.titleLabel.font = [self textFontSmall];
    [_forgotPasswordButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [_forgotPasswordButton addTarget:self action:@selector(forgotPasswordButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [loginFooterView addSubview:_forgotPasswordButton];
    
    if (getOSf() >= 7.0)
        self.tableView.separatorInset = UIEdgeInsetsZero;

    self.tableView.separatorStyle = YES;
    self.tableView.scrollEnabled = NO;
    self.tableView.tableFooterView = loginFooterView;
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    emailTextField.placeholder=LS(@"Email", @"");
    emailTextField.text = @"";
    return emailTextField;
}

-(UITextField*) passwordFieldWithPlaceholder:(NSString*)placeholder {
    UITextField* passwordField = [[UITextField alloc] initWithFrame:CGRectMake(15, 5, self.view.width-15, 40)];
    passwordField.font = [self textFont];
    passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    passwordField.backgroundColor = [UIColor clearColor];
    passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordField.spellCheckingType = UITextSpellCheckingTypeNo;
    passwordField.keyboardType = UIKeyboardTypeASCIICapable;
    passwordField.secureTextEntry = YES;
    passwordField.textColor=[UIColor blackColor];
    passwordField.placeholder=placeholder;
    passwordField.text=@"";
    return passwordField;
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

- (void) forgotPasswordButtonTouched {
    IPhoneMVForgotPasswordViewController* forgotPwdVC = [[IPhoneMVForgotPasswordViewController alloc] init];
    [forgotPwdVC pushToStack];
}

#pragma mark -
#pragma mark private - signin button handler

- (void)signInButtonTouched {
    
    if([_usernameTextField.text length] <= 0) {
        [self raiseAlert:LS(@"Please enter your email address", @"")];
        return;
    }
    if([_passwordTextField.text length] <= 0) {
        [self raiseAlert:LS(@"Please enter your password", @"")];
        return;
    }
    _loginButton.enabled = NO;
    [_activityIndicator startAnimating];
    
    [self loginWithNetwork:_domainTextField.text username:_usernameTextField.text password:_passwordTextField.text];
    
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
        _loginButton.enabled = YES;

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
                        
                        [[CVWebSocket shared] connect];
                        
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
    
    if(showWelcomeWizard)
        [CVLanguageNameViewController presentModalViewFromViewController:self animated:YES];
    else {
        IPhoneMenuViewController* iphoneMenu = [[IPhoneMenuViewController alloc] init];
        IPhoneAppDelegate* appDelegate = (IPhoneAppDelegate*)[UIApplication sharedApplication];
        appDelegate.window.rootViewController = [[FlipBoardNavigationController alloc]initWithRootViewController:iphoneMenu];
        CVChatsViewController* sVC = [[CVChatsViewController alloc] init];
        [sVC pushToStack];
    }
}

# pragma mark - UITableView Delgate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TABLEVIEW_CELL_HEIGHT;
}

# pragma mark - UITextField Delgate

- (void)textFieldDidChange:(UITextField *)textField {
    if ([_usernameTextField.text isEqualToString:@""] || [_passwordTextField.text isEqualToString:@""])
       _loginButton.hidden = YES;
    else
       _loginButton.hidden = NO;

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _passwordTextField) {
        [self signInButtonTouched];
    } else if (textField == _usernameTextField) {
        [_passwordTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
