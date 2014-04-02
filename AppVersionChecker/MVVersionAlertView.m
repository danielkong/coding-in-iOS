//
//  MVVersionAlertView.m
//  Vmoso
//
//  Created by Daniel Kong on 4/1/14.
//  Copyright (c) 2014 Broadvision. All rights reserved.
//

#import "MVVersionAlertView.h"

#define TITLE_FOR_CANCEL    LS(@"Cancel", @"")
#define TITLE_FOR_UPDATE   LS(@"Update", @"")
#define ALERT_MESSAGE       LS(@"New version %@ available", @"")

#define URL_FOR_QA_INSTALL_IPHONE   @"https://test.com/iPad/"

@implementation MVVersionAlertView

static MVVersionAlertView* _instance;

+ (MVVersionAlertView*)sharedInstance {
    if (_instance == nil) {
        _instance = [[MVVersionAlertView alloc] init];
        _instance.title = nil;
        _instance.delegate = _instance;
        [_instance addButtonWithTitle:TITLE_FOR_CANCEL];
        [_instance addButtonWithTitle:TITLE_FOR_UPDATE];
    }
    return _instance;
}

- (void)setVersion:(NSString *)version {
    NSString* message = [NSString stringWithFormat:ALERT_MESSAGE, version];
    _instance.message = message;    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
    
    if (buttonIndex == 1) {
        NSURL* urlForInstall = [NSURL URLWithString:URL_FOR_QA_INSTALL_IPHONE];
        [[UIApplication sharedApplication] openURL:urlForInstall];
    }
}

@end
