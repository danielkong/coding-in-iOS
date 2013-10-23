//
//  ViewController1.h
//  NavigationControllerTut
//
//  Created by developer on 10/15/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController1 : UIViewController<UITextFieldDelegate>

@property (nonatomic, retain) UITextField *firstTextField;
@property (nonatomic, retain) UILabel *displayLabel1;
@property (nonatomic, strong) NSString *stringFromVC2;

- (IBAction)passTextToVC2Button:(id)sender;

@end
