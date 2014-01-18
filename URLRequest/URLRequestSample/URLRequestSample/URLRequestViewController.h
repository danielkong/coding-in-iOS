//
//  URLRequestViewController.h
//  URLRequestSample
//
//  Created by developer on 12/18/13.
//  Copyright (c) 2013 Daniel Kong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface URLRequestViewController : UIViewController<NSURLConnectionDelegate>

@property(nonatomic, retain) NSMutableData* responseData;

@end
