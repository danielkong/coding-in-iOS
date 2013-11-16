//
//  ViewController.m
//  ChatClient
//
//  Created by developer on 11/14/13.
//  Copyright (c) 2013 Daniel Kong. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <NSStreamDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property(nonatomic, retain) NSInputStream *inputStream;
@property(nonatomic, retain) NSOutputStream *outputStream;
@property(nonatomic, retain) NSMutableArray	*messages;

@end

@implementation ViewController

- (void)initNetworkCommunication {
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [self initNetworkCommunication];
    
    _tView = [[UITableView alloc] initWithFrame:CGRectMake(15, 130, self.view.bounds.size.width- 45, 200) style:UITableViewStylePlain];
    _messages = [[NSMutableArray alloc] init];
	
	_tView.delegate = self;
	_tView.dataSource = self;
    
    [self.view addSubview:_tView];
    _inputMessageField.delegate = self;
    _inputNameField.delegate = self;


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)joinChat:(id)sender {
    
//    [self.view bringSubviewToFront:_chatView];
//    _joinView.hidden = YES;
//    [self.view addSubview:_chatView];

	NSString *response  = [NSString stringWithFormat:@"iam:%@ ", _inputNameField.text];
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[_outputStream write:[data bytes] maxLength:[data length]];
    
//    [self.navigationController pushViewController:ChatRoomViewController animated:YES];
}


- (IBAction) sendMessage {
	
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
