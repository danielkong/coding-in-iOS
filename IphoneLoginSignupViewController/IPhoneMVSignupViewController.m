//
//  IPhoneMVSignupViewController.m
//  Vmoso
//
//  Created by Daniel Kong on 1/7/14.
//  Copyright (c) 2014 Broadvision. All rights reserved.
//

#import "IPhoneMVSignupViewController.h"
#import "NSDictionary+DragonAPI.h"
#import "IPhoneMVLoginViewController.h"
#import "CVBaseLoginViewController.h"
#import "CVAPIUtil.h"
#import "NSDictionary+DragonAPI.h"
#import "NSDictionary+DragonAPIUser.h"
#import "CVPushController.h"
#import "IPadNewProfileFormViewController.h"
#import "CVFilePostViewController.h"
#import "CVTaskViewController.h"
#import "CVSettingsModel.h"
#import "CVLanguageNameViewController.h"
#import "CVChatsViewController.h"

#define TABLEVIEW_CELL_HEIGHT     55
#define TEXT_FIELD_FONT           [UIFont systemFontOfSize:16]
#define TEXT_FIELD_FONT_SMALL     [UIFont systemFontOfSize:12]

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

@interface IPhoneMVSignupViewController () 

// SignUp fields
@property(nonatomic, retain) UITextField* firstNameField;
@property(nonatomic, retain) UITextField* lastNameField;
@property(nonatomic, retain) UITextField* emailField;
@property(nonatomic, retain) UITextField* passwordField1;
@property(nonatomic, retain) UITextField* passwordField2;
@property(nonatomic, retain) UITextField* domainTextField;
@property(nonatomic, retain) NSArray* signUpFormItems;
@property(nonatomic, retain) UIButton* signUpButton;
@property(nonatomic, retain) UILabel* agreeLabel;
@property(nonatomic, retain) UIButton* termsAndPolicyButton;

@property(nonatomic, retain) UIView* lineView1;
@property(nonatomic, retain) UIView* lineView2;
@property(nonatomic, retain) NSString* currentDomain;
@property(nonatomic, retain) UIView* currentForm;
@property(nonatomic, retain) UIView* resetPasswordFormView;
// Confirmation field
@property(nonatomic, retain) UILabel* messageLabel;
@property(nonatomic, retain) UIButton* activateSignUpButton;
@property(nonatomic, retain) UIView* confirmFormView;
// Reset password fields
@property(nonatomic, retain) UITextField* resetPasswordField1;
@property(nonatomic, retain) UITextField* resetPasswordField2;
@property(nonatomic, retain) UIView* formView;
@property(nonatomic, retain) UIView* signInFormView;
@property(nonatomic, retain) UIView* signUpFormView;
@property(nonatomic, retain) UIView* forgotPasswordFormView;
@property(nonatomic, retain) UIButton* signInButton;
@property(nonatomic, retain) UIButton* requestPasswordButton;
@property(nonatomic, retain) UIButton* resetPasswordButton;
@property(nonatomic, assign) BOOL showWelcomeWizard;
@property(nonatomic, retain) NSString* defaultLanguage;
@property(nonatomic, retain) CVSettingsModel* model;
@property(nonatomic, retain) UIActivityIndicatorView* activityIndicator;

@end

@implementation IPhoneMVSignupViewController

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
    _firstNameField = [self firstNameFieldWithPlaceholder:LS(@"First", @"")];
    [_firstNameField setReturnKeyType:UIReturnKeyNext];
    _firstNameField.enablesReturnKeyAutomatically=YES;
    _firstNameField.delegate = self;
    [_firstNameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    
    _lastNameField = [self lastNameFieldWithPlaceholder:LS(@"Last", @"")];
    [_lastNameField setFrame:CGRectMake((self.view.width-15)/2, 5, (self.view.width-15)/2 + 10, 40)];
    // specifiy some input traits for this last text field
    [_lastNameField setReturnKeyType:UIReturnKeyNext];
    _lastNameField.enablesReturnKeyAutomatically=YES;
    _lastNameField.delegate = self;
    [_lastNameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

//    _lineView1 = [self lineView];
//    _lineView1.frame = CGRectMake(145, 0, 1, TABLEVIEW_CELL_HEIGHT);
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:_firstNameField];
    [cell.contentView addSubview:_lastNameField];
//    [cell.contentView addSubview:_lineView1];
    [formItems addObject:cell];
    
    // network URL
    _emailField = [self emailTextField];
    
    // specifiy some input traits for this last text field
    [_emailField setReturnKeyType:UIReturnKeyNext];
    _emailField.enablesReturnKeyAutomatically=YES;
    _emailField.delegate = self;
    [_emailField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:_emailField];
    [formItems addObject:cell];
    
    // password
    _passwordField1 = [self passwordFieldWithPlaceholder:LS(@"Password", @"")];
    [_passwordField1 setFrame:CGRectMake(15, 5, (self.view.width-15)/2 - 20, 40)];
    
    // specifiy some input traits for this last text field
    [_passwordField1 setReturnKeyType:UIReturnKeyNext];
    _passwordField1.enablesReturnKeyAutomatically=YES;
    _passwordField1.delegate = self;
    [_passwordField1 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

//    _lineView2 = [self lineView];
//    _lineView2.frame = CGRectMake(145, 5, 1, TABLEVIEW_CELL_HEIGHT);
    
    _passwordField2 = [self passwordFieldWithPlaceholder:LS(@"Confirm Password", @"")];
    [_passwordField2 setFrame:CGRectMake((self.view.width-15)/2, 5, (self.view.width-15)/2 + 10, 40)];

    // specifiy some input traits for this last text field
    [_passwordField2 setReturnKeyType:UIReturnKeyNext];
    _passwordField2.enablesReturnKeyAutomatically=YES;
    _passwordField2.delegate = self;
    [_passwordField2 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:_passwordField1];
    [cell.contentView addSubview:_passwordField2];
//    [cell.contentView addSubview:_lineView2];

    [formItems addObject:cell];
    
    _domainTextField = [self domainField];
    
    // specifiy some input traits for this last text field
    [_domainTextField setReturnKeyType:UIReturnKeyGo];
    _domainTextField.enablesReturnKeyAutomatically=YES;
    _domainTextField.delegate = self;
    [_domainTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:_domainTextField];
    [formItems addObject:cell];
    
    _signUpFormItems = formItems;
    
    self.rows = @[_signUpFormItems];
    
    [_firstNameField becomeFirstResponder];
    
    //    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 6)];
    
    UIView* loginFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0.5)];
    line.alpha = 0.5;
    line.backgroundColor = [UIColor lightGrayColor];
    [loginFooterView addSubview:line];
    
    _signUpButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 5, 240, 50)];
    [_signUpButton setTitle:@"SIGN UP" forState:UIControlStateNormal];
    [_signUpButton setFont:[UIFont boldSystemFontOfSize:24.0]];
    _signUpButton.backgroundColor = [UIColor orangeColor];
    [[_signUpButton layer] setBorderWidth:2.0f];
    [[_signUpButton layer] setBorderColor:[UIColor orangeColor].CGColor];
    [[_signUpButton layer] setCornerRadius:3.0f];
    _signUpButton.hidden = YES;
    [_signUpButton addTarget:self action:@selector(signUpButtonTouched) forControlEvents:UIControlEventTouchDown];
    _activityIndicator = [self activityIndicatorView];
    _activityIndicator.frame = CGRectMake(_signUpButton.width/2 + 50, 20, 10, 10);
    [_signUpButton addSubview:_activityIndicator];
    
    [loginFooterView addSubview:_signUpButton];
    
    _agreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, _signUpButton.bottom, 105, 20)];
    [_agreeLabel setFont:TEXT_FIELD_FONT_SMALL];
    _agreeLabel.text = @"I agree to the";
    [loginFooterView addSubview:_agreeLabel];
    
    //forgot password
    _termsAndPolicyButton = [[UIButton alloc] initWithFrame:CGRectMake(135, _signUpButton.bottom, 130, 20)];
    [_termsAndPolicyButton setFont:TEXT_FIELD_FONT_SMALL];
    [_termsAndPolicyButton setTitle:LS(@"Terms & Privacy", @"") forState:UIControlStateNormal];
    [_termsAndPolicyButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [_termsAndPolicyButton addTarget:self action:@selector(forgotPasswordButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [loginFooterView addSubview:_termsAndPolicyButton];
    
    if (getOSf() >= 7.0)
        self.tableView.separatorInset = UIEdgeInsetsZero;

    self.tableView.separatorStyle = YES;
    self.tableView.scrollEnabled = NO;
    self.tableView.tableFooterView = loginFooterView;
    
    [self.tableView reloadData];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
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

-(UITextField*) firstNameFieldWithPlaceholder:(NSString*)placeholder {
    UITextField* firstNameField = [[UITextField alloc] initWithFrame:CGRectMake(15, 5, (self.view.width-15)/2 - 20, 40)];
    firstNameField.font = [self textFont];
    firstNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    firstNameField.backgroundColor = [UIColor clearColor];
    firstNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    firstNameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    firstNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    firstNameField.spellCheckingType = UITextSpellCheckingTypeNo;
    firstNameField.keyboardType = UIKeyboardTypeASCIICapable;
    firstNameField.textColor=[UIColor blackColor];
    firstNameField.placeholder=placeholder;
    firstNameField.text=@"";
    firstNameField.delegate = self;
    
    return firstNameField;
}

-(UITextField*) lastNameFieldWithPlaceholder:(NSString*)placeholder {
    UITextField* passwordField = [[UITextField alloc] initWithFrame:CGRectMake(145, 5, (self.view.width-15)/2 - 20, 40)];
    passwordField.font = [self textFont];
    passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    passwordField.backgroundColor = [UIColor clearColor];
    passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordField.spellCheckingType = UITextSpellCheckingTypeNo;
    passwordField.keyboardType = UIKeyboardTypeASCIICapable;
    passwordField.textColor=[UIColor blackColor];
    passwordField.placeholder=placeholder;
    passwordField.text=@"";
    passwordField.delegate = self;
    
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

-(UIActivityIndicatorView*) activityIndicatorView{
    UIActivityIndicatorView* activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.hidesWhenStopped = YES;
    return activityIndicatorView;
}

-(UIView*) lineView {
    UIView* lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor lightGrayColor];
    return lineView;
}

- (UIFont*)textFont {
    return TEXT_FIELD_FONT;
}

- (UIFont*)textFontSmall {
    return TEXT_FIELD_FONT_SMALL;
}

# pragma mark - 
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TABLEVIEW_CELL_HEIGHT;
}

#pragma mark -
#pragma mark private - signup button handler

- (void)signUpButtonTouched {
    
    _signUpButton.enabled = NO;
    [_activityIndicator startAnimating];
    
    if (_domainTextField.text && _domainTextField.text.length > 0)
        _currentDomain  = _domainTextField.text;
    else
        _currentDomain  = defaultSite;
    
    [self signUpForVmoso];
    
}

#pragma mark -
#pragma mark private - sign up to Vmoso

- (void) signUpForVmoso
{
    NSString* emailAddress = self.emailField.text;
    NSString* password = self.passwordField1.text;
    NSString* confirmPassword = self.passwordField2.text;
    NSString* firstName = self.firstNameField.text;
    NSString* lastName = self.lastNameField.text;
    
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
    
    CVAPIRequest* request = [[CVAPIRequest alloc] initWithCommand:@"cvauth.CVAuthenticator.JoinAccessToken" andApiPath:apiURL];
    NSDictionary* param = [NSDictionary dictionaryWithObjectsAndKeys:networkId, kReqParamKeyForNetworkId, firstName, @"firstName", lastName, @"lastName", emailAddress, @"emailAddress", password, @"password_su", confirmPassword, @"confirmPassword", nil];
    NSString* jsonRequest = [param jsonValue];
    [request setParamString:jsonRequest];
    
    CVAPIRequestModel* model = [[CVAPIRequestModel alloc] init];
    [model sendRequest:request completion:^(NSDictionary* apiResult, NSError* error) {
        _signUpButton.enabled = YES;
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
                                                             message:LS(@"Sign up successfully", @"")
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
            [alert show];
            return;
            
            _messageLabel.text = confirmMessage;
            [self setMessageLabelFrame];
            [self.activateSignUpButton setTitle:LS(@"Sign In For Vmoso", @"") forState:UIControlStateNormal];
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
        _signInButton.enabled = YES;
        _signUpButton.enabled = YES;
        _requestPasswordButton.enabled = YES;
        _resetPasswordButton.enabled = YES;
        _activateSignUpButton.enabled = YES;
//        [_activityIndicator stopAnimating];
//        [_activityIndicator2 stopAnimating];
//        [_activityIndicator3 stopAnimating];
//        [_activityIndicator4 stopAnimating];
        
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

# pragma mark - 
# pragma mark UITextField Delgate

- (void)textFieldDidChange:(UITextField *)textField {
    if ([_firstNameField.text isEqualToString:@""] || [_lastNameField.text isEqualToString:@""] || [_emailField.text isEqualToString:@""] || [_passwordField1.text isEqualToString:@""] || [_passwordField2.text isEqualToString:@""] || [_domainTextField.text isEqualToString:@""])
        _signUpButton.hidden = YES;
    else
        _signUpButton.hidden = NO;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _domainTextField) {
        [self signUpButtonTouched];
    } else if (textField == _firstNameField) {
        [_lastNameField becomeFirstResponder];
    } else if (textField == _lastNameField) {
        [_emailField becomeFirstResponder];
    } else if (textField == _emailField) {
        [_passwordField1 becomeFirstResponder];
    } else if (textField == _passwordField1) {
        [_passwordField2 becomeFirstResponder];
    } else if (textField == _passwordField2) {
        [_domainTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

# pragma mark - AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    [self popFromStack];
    IPhoneMVLoginViewController* loginVC = [[IPhoneMVLoginViewController alloc] init];
    [loginVC pushToStack];
}

@end
