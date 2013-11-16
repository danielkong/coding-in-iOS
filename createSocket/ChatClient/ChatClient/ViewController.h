//
//  ViewController.h
//  ChatClient
//
//  Created by developer on 11/14/13.
//  Copyright (c) 2013 Daniel Kong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController  

@property (nonatomic, retain) IBOutlet UIView *joinView;
@property (nonatomic, retain) IBOutlet UIView *chatView;

@property (weak, nonatomic) IBOutlet UITextField *inputNameField;
@property (nonatomic, retain) IBOutlet UITextField	*inputMessageField;

@property (weak, nonatomic) IBOutlet UILabel *name;
@property(nonatomic, retain) IBOutlet UITableView *tView;


@end
