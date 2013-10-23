//
//  ViewController2.m
//  NavigationControllerTut
//
//  Created by developer on 10/15/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import "ViewController2.h"
#import "ViewController1.h" 
@interface ViewController2 ()

@end

@implementation ViewController2

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
    
    // set title
    self.navigationItem.title = @"Screen 2";
    
    self.displayLabel2.text = self.stringFromVC1;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)passTextToVC1Button:(id)sender
{
    ViewController1 *VC1 = [[ViewController1 alloc]init];
    
    VC1.stringFromVC2 = self.textField2.text;
    
    [self presentViewController:VC1 animated:YES completion:nil];
    
}
@end
