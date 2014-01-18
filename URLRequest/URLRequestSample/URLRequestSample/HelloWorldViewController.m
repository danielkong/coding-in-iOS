//
//  HelloWorldViewController.m
//  URLRequestSample
//
//  Created by developer on 12/18/13.
//  Copyright (c) 2013 Daniel Kong. All rights reserved.
//

#import "HelloWorldViewController.h"

@interface HelloWorldViewController ()

@property (nonatomic, retain) UILabel* outputLabel;
@property (nonatomic, retain) UITextField* addressField;
@property (nonatomic, retain) UIActivityIndicatorView* loading;
@property (nonatomic, retain) UIBarButtonItem* fetchButton;

@end

@implementation HelloWorldViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _outputLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 80, 30)];
        _outputLabel.backgroundColor = [UIColor redColor];
        
        _addressField = [[UITextField alloc] initWithFrame:CGRectMake(20, 50, 80, 30)];
        _addressField.backgroundColor = [UIColor yellowColor];
        
        [self.view addSubview:_outputLabel];
        [self.view addSubview:_addressField];
 
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

-(void)fetchAddress:(NSString *)address
{
    NSLog(@"Loading Address: %@",address);
//    [iOSRequest requestPath:address onCompletion:^(NSString *result, NSError *error){
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (!error) {
//                // No Error
//                [self stopFetching:result];
//            } else {
//                // Handle Error
//                NSLog(@"ERROR: %@",error);
//                [self stopFetching:@"Failed to Load"];
//            }
//        });
//    }];
}

- (IBAction)fetch:(id)sender
{
    [self startFetching];
    [self fetchAddress:self.addressField.text];
}

-(void)startFetching
{
    NSLog(@"Fetching...");
    [self.addressField resignFirstResponder];
    [self.loading startAnimating];
    self.fetchButton.enabled = NO;
}

-(void)stopFetching:(NSString *)result
{
    NSLog(@"Done Fetching!");
    self.outputLabel.text = result;
    [self.loading stopAnimating];
    self.fetchButton.enabled = YES;
}

@end
