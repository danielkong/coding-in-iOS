//
//  IPhoneMVLoginSignupViewController.m
//  Vmoso
//
//  Created by Daniel Kong on 1/7/14.
//  Copyright (c) 2014 Broadvision. All rights reserved.
//

#import "IPhoneMVLoginSignupViewController.h"
#import "IPhoneMVLoginViewController.h"
#import "IPhoneMVSignupViewController.h"

#define BUTTON_HEIGHT       50

@interface IPhoneMVLoginSignupViewController ()

@property(nonatomic, retain) UIImage* logoImage;            //the logo image
@property(nonatomic, retain) UIImageView* imageView;        //the container of logo
@property(nonatomic, retain) UIButton* loginButton;
@property(nonatomic, retain) UIButton* signUpButton;

@end

@implementation IPhoneMVLoginSignupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];//[[UIColor grayColor] colorWithAlphaComponent:0.5];
        self.view.autoresizesSubviews = YES;
        self.title = @"Login Page";
        
        _logoImage=[UIImage imageNamed:@"MyV_rounded.png"];
        _imageView=[[UIImageView alloc] initWithFrame:CGRectMake(100, 60, 120, 120)];
        _imageView.image = _logoImage;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_imageView];
        
        UILabel* appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imageView.left, _imageView.bottom, _imageView.width, 50)];
        appNameLabel.textColor = RGBCOLOR(50, 57, 66);
        appNameLabel.font = [UIFont systemFontOfSize:24];
        appNameLabel.textAlignment = NSTextAlignmentCenter;
        appNameLabel.text = @"My Vmoso";
        [self.view addSubview:appNameLabel];
        
        _loginButton = [[UIButton alloc] initWithFrame:CGRectMake(40, self.view.bottom - 240, 240, BUTTON_HEIGHT)];
        [_loginButton setTitle:@"LOG IN" forState:UIControlStateNormal];
        _loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:26.0];
        _loginButton.backgroundColor = [UIColor orangeColor];
        [[_loginButton layer] setBorderWidth:2.0f];
        [[_loginButton layer] setBorderColor:[UIColor orangeColor].CGColor];
        [[_loginButton layer] setCornerRadius:3.0f];
        [_loginButton addTarget:self action:@selector(loginButtonTouched) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:_loginButton];
        
        _signUpButton = [[UIButton alloc] initWithFrame:CGRectMake(40, self.view.bottom - 160, 240, BUTTON_HEIGHT)];
        [_signUpButton setTitle:@"SIGN UP" forState:UIControlStateNormal];
        [_signUpButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _signUpButton.titleLabel.font = [UIFont boldSystemFontOfSize:26.0];
        _signUpButton.backgroundColor = [UIColor whiteColor];
        [[_signUpButton layer] setBorderWidth:2.0f];
        [[_signUpButton layer] setBorderColor:[UIColor lightGrayColor].CGColor];
        [[_signUpButton layer] setCornerRadius:3.0f];
        [_signUpButton addTarget:self action:@selector(signupButtonTouched) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:_signUpButton];
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


#pragma mark -
#pragma mark private - login button handler

- (void)loginButtonTouched {
    IPhoneMVLoginViewController* loginVC = [[IPhoneMVLoginViewController alloc] init];
    
    [loginVC pushToStack];
    
}

#pragma mark -
#pragma mark private - signup button handler

- (void)signupButtonTouched {
    IPhoneMVSignupViewController* loginVC = [[IPhoneMVSignupViewController alloc] init];

    [loginVC pushToStack];
    
}

@end
