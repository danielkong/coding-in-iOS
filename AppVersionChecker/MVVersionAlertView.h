//
//  MVVersionAlertView.h
//  Vmoso
//
//  Created by Daniel Kong on 4/1/14.
//  Copyright (c) 2014 Broadvision. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVVersionAlertView : UIAlertView <UIAlertViewDelegate>

+ (MVVersionAlertView*)sharedInstance;

- (void)setVersion:(NSString*)version;

@end
