//
//  ViewController2.h
//  NavigationControllerTut
//
//  Created by developer on 10/15/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController2 : UIViewController //<TextFieldDelegate>

@property (nonatomic, retain) UILabel *displayLabel2;
@property (nonatomic, retain) UITextField *textField2;
@property (nonatomic, strong) NSString *stringFromVC1;

- (IBAction)passTextToVC1Button:(id)sender;

@end
