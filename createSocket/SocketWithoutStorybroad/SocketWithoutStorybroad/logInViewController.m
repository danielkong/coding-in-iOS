//
//  logInViewController.m
//  SocketWithoutStorybroad
//
//  Created by developer on 11/15/13.
//  Copyright (c) 2013 Daniel Kong. All rights reserved.
//

#import "logInViewController.h"

#define AUTHOR_FONT     [UIFont systemFontOfSize:13]
#define AUTHOR_COLOR    [UIColor darkGrayColor]

@interface logInViewController () <UITableViewDataSource, UITableViewDelegate, NSStreamDelegate, UITextFieldDelegate>

@property (nonatomic, retain) UITableView* tView;
@property (nonatomic, retain) NSInputStream* inputStream;
@property (nonatomic, retain) NSOutputStream* outputStream;
@property (nonatomic, retain) NSMutableArray* messages;

@property (nonatomic, retain) UITextField* inputNameField;
@property (nonatomic, retain) UITextField* inputMessageField;
@property (nonatomic, retain) UIButton *joinButton;
@property (nonatomic, retain) UIButton *chatButton;
@property (nonatomic, retain) UILabel *inputNameLabel;

@end

@implementation logInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"192.168.2.191", 81, &readStream, &writeStream);
        _inputStream = (__bridge NSInputStream *)readStream;
        _outputStream = (__bridge NSOutputStream *)writeStream;
        
        [_inputStream setDelegate:self];
        [_outputStream setDelegate:self];
        
        [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [_inputStream open];
        [_outputStream open];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _inputNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 70, 30)];
    _inputNameLabel.font = AUTHOR_FONT;
    _inputNameLabel.textColor = [UIColor blackColor];
    _inputNameLabel.text = @"User Name";
//    _inputNameLabel.backgroundColor = BG_COLOR;
    _inputNameLabel.textAlignment = NSTextAlignmentCenter;
    _inputNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _inputNameLabel.numberOfLines = 1;
    
    [self.view addSubview:_inputNameLabel];

    _inputNameField = [[UITextField alloc] initWithFrame:CGRectMake(95, 30, 100, 30)];
    _inputNameField.borderStyle = UITextBorderStyleRoundedRect;
    _inputNameField.keyboardType = UIKeyboardTypeDefault;
    _inputNameField.font = [UIFont systemFontOfSize:14];

    [self.view addSubview:_inputNameField];

    _joinButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _joinButton.frame = CGRectMake(self.view.frame.size.width - 90, 30, 60, 30);
    [_joinButton setTitle:@"Log In" forState:UIControlStateNormal];
    [_joinButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    _joinButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _joinButton.layer.cornerRadius = 3;
    _joinButton.layer.masksToBounds = YES;
    [_joinButton addTarget:self action:@selector(joinChat:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_joinButton];

    
    _inputMessageField = [[UITextField alloc] initWithFrame:CGRectMake(15, 85, self.view.frame.size.width - 120, 30)];
    _inputMessageField.borderStyle = UITextBorderStyleRoundedRect;
    _inputMessageField.font = [UIFont systemFontOfSize:14];
    _inputMessageField.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    _inputMessageField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    _inputMessageField.spellCheckingType = UITextSpellCheckingTypeYes;
    [self.view addSubview:_inputMessageField];

    _chatButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _chatButton.frame = CGRectMake(self.view.frame.size.width - 90, 85, 60, 30);
    [_chatButton setTitle:@"Send" forState:UIControlStateNormal];
    [_chatButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    _chatButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _chatButton.layer.cornerRadius = 3;
    _chatButton.layer.masksToBounds = YES;
    [_chatButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_chatButton];
    
    _tView = [[UITableView alloc] initWithFrame:CGRectMake(15, 130, self.view.bounds.size.width- 45, 200) style:UITableViewStylePlain];
    _messages = [[NSMutableArray alloc] init];
	
	_tView.delegate = self;
	_tView.dataSource = self;
    
    [self.view addSubview:_tView];
    _inputMessageField.delegate = self;
    _inputNameField.delegate = self;
    
    [self.view addSubview:_tView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_tView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)joinChat:(id)sender {
    
    //    [self.view bringSubviewToFront:_chatView];
    //    _joinView.hidden = YES;
    //    [self.view addSubview:_chatView];
    
	NSString *response  = [NSString stringWithFormat:@"iam:%@ ", _inputNameField.text];
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[_outputStream write:[data bytes] maxLength:[data length]];
}

- (void) sendMessage: (id)sender {
	
	NSString *response  = [NSString stringWithFormat:@"msg:%@", _inputMessageField.text];
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[_outputStream write:[data bytes] maxLength:[data length]];
	_inputMessageField.text = @"";
	
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
	NSLog(@"stream event %i", streamEvent);
	
	switch (streamEvent) {
			
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
		case NSStreamEventHasBytesAvailable:
            
			if (theStream == _inputStream) {
				
				uint8_t buffer[1024];
				int len;
				
				while ([_inputStream hasBytesAvailable]) {
					len = [_inputStream read:buffer maxLength:sizeof(buffer)];
					if (len > 0) {
						
						NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
						
						if (nil != output) {
                            
							NSLog(@"server said: %@", output);
							[self messageReceived:output];
							
						}
					}
				}
			}
			break;
            
			
		case NSStreamEventErrorOccurred:
			
			NSLog(@"Can not connect to the host!");
			break;
			
		case NSStreamEventEndEncountered:
            
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            theStream = nil;
			
			break;
		default:
			NSLog(@"Unknown event");
	}
    
}

- (void) messageReceived:(NSString *)message {
	
	[_messages addObject:message];
	[_tView reloadData];
    
    if (_messages.count > 1){
    	NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:_messages.count-1
                                                       inSection:0];
        [_tView scrollToRowAtIndexPath:topIndexPath
                      atScrollPosition:UITableViewScrollPositionMiddle
							  animated:YES];
    }
    
}


#pragma mark -
#pragma mark Table delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *s = (NSString *) [_messages objectAtIndex:indexPath.row];
	
    static NSString *CellIdentifier = @"ChatCellIdentifier";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	
	cell.textLabel.text = s;
	
	return cell;
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _messages.count;
}

#pragma mark -
#pragma mark TextField delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

@end
