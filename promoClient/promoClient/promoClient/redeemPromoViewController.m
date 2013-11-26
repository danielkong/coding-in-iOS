//
//  redeemPromoViewController.m
//  promoClient
//
//  Created by developer on 11/25/13.
//  Copyright (c) 2013 Daniel Kong. All rights reserved.
//

#import "redeemPromoViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SBJSON.h"
#import "MBProgressHUD.h"

@interface redeemPromoViewController ()
@end

@implementation redeemPromoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor grayColor];
        UILabel* enterPromoCode = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, self.view.frame.size.width, 30)];
        enterPromoCode.text = @"Enter your promotion code:";
        [self.view addSubview:enterPromoCode];
        
        _input = [[UITextField alloc] initWithFrame:CGRectMake(30, 70, self.view.frame.size.width - 60, 30)];
        _input.delegate = self;
        _input.backgroundColor = [UIColor whiteColor];
        _input.autocapitalizationType = NO;
        _input.autocorrectionType = NO;
        [self.view addSubview:_input];
        
        _output = [[UITextView alloc] initWithFrame:CGRectMake(30, 110, self.view.frame.size.width - 60, 150)];
        _output.backgroundColor = [UIColor whiteColor];
        _output.text = @"Result will show here.";
        [self.view addSubview:_output];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - UITextfield Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Want to redeem: %@", textField.text);
    
    // Get device unique ID
    UIDevice *device = [UIDevice currentDevice];
    NSString *uniqueIdentifier = [device name];
    
    // Start request
    NSString *code = textField.text;
    NSURL *url = [NSURL URLWithString:@"http://mysite-xkong.rhcloud.com/testDB.php/"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:@"1" forKey:@"rw_app_id"];
    [request setPostValue:code forKey:@"code"];
    [request setPostValue:uniqueIdentifier forKey:@"device_id"];
    [request setDelegate:self];
    [request startAsynchronous];
    
    // Hide keyword
    [textField resignFirstResponder];
    
    // Clear text field
    _output.text = @"";
    
    // let the user know what’s going on
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Redeeming code...";
    return TRUE;
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (request.responseStatusCode == 400) {
        _output.text = @"Invalid code";
    } else if (request.responseStatusCode == 403) {
        _output.text = @"Code already used";
    } else if (request.responseStatusCode == 200) {
        NSString *responseString = [request responseString];
        NSDictionary *responseDict = [responseString JSONValue];
        NSString *unlockCode = [responseDict objectForKey:@"unlock_code"];
        
        if ([unlockCode compare:@"com.razeware.test.unlock.cake"] == NSOrderedSame) {
            _output.text = @"The cake is a lie!";
        } else {
            _output.text = [NSString stringWithFormat:@"Received unexpected unlock code: %@", unlockCode];
        }
        
    } else {
        _output.text = @"Unexpected error";
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    NSError *error = [request error];
    _output.text = error.localizedDescription;
}

@end
