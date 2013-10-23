//
//  ViewController1.m
//  NavigationControllerTut
//
//  Created by developer on 10/15/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import "ViewController1.h"
#import "ViewController2.h"

@interface ViewController1 ()

@end

@implementation ViewController1

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
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationItem setTitle:@"ScreenOne"];
    
    // create uibarbuttonItem
    UIBarButtonItem *goToVC2Button = [[UIBarButtonItem alloc] initWithTitle:@"Go to 2" style:UIBarButtonItemStylePlain target:self action:@selector(goToView2)];
    [self.navigationItem setRightBarButtonItem:goToVC2Button];
    
    // change back bar button title
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"back to 1" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];

    self.firstTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.firstTextField.delegate = self;
    self.displayLabel1.text = self.stringFromVC2? self.stringFromVC2:nil;
}

- (void) goToView2
{
    ViewController2 *VC2 = [[ViewController2 alloc] init];
    [[self navigationController]pushViewController:VC2 animated:YES];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)passTextToVC2Button:(id)sender
{
    ViewController2 *VC2 = [[ViewController2 alloc]init];
    
    VC2.stringFromVC1 = self.firstTextField.text;
    
    [self presentViewController:VC2 animated:YES completion:nil];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

@end
