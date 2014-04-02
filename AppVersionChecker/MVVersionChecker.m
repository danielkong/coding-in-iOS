//
//  MVVersionChecker.m
//  Vmoso
//
//  Created by Daniel Kong on 4/1/14.
//  Copyright (c) 2014 Broadvision. All rights reserved.
//

#import "MVVersionChecker.h"
#import "MVVersionAlertView.h"
#import "NSURLConnection+CVHttps.h"

#define HOURS_FOR_REMOTE_CHECKING       1
#define REQUEST_TIMEOUT                20
#define URL_FOR_QA_VERSION_IPHONE     @"https://www.test.com/package-version.php"

@interface MVVersionChecker ()

@property(nonatomic, assign) NSArray* remoteVersionArray;
@property(nonatomic, assign) NSArray* localVersionArray;
@property(nonatomic, assign) NSString* remoteVersionPrefix;
@property(nonatomic, assign) NSInteger remoteVersionSuffix;
@property(nonatomic, assign) NSString* localVersionPrefix;
@property(nonatomic, assign) NSInteger localVersionSuffix;

@end

@implementation MVVersionChecker

- (NSString*)handlerId {
    return [[self class] description];
}

- (NSTimeInterval)intervalForExecution {
    return HOURS_FOR_REMOTE_CHECKING * 3600;    // time inverval in seconds
}

- (void)execute {
    
    NSURL* urlForVersionCheck = [NSURL URLWithString:URL_FOR_QA_VERSION_IPHONE];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:urlForVersionCheck
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:REQUEST_TIMEOUT];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequestHttps:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSString *versionString = nil;
        
        if (error == nil && [data length] > 0) {
            versionString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            // trim the trailing characters
            versionString = [[versionString componentsSeparatedByString:@"\n"] objectAtIndex:0];
        }
        
        if (versionString && [self shouldUpdate:versionString]) {
            // call completion handler in main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                MVVersionAlertView* alertView = [MVVersionAlertView sharedInstance];
                if (!alertView.isVisible) {
                    [alertView setVersion:versionString];
                    [alertView show];
                }
            });
        }
        
    }];
    
}

- (BOOL)shouldUpdate:(NSString*)versionString {
    
    NSString* remoteVersionString = [versionString uppercaseString];
    NSString* localVersionString = [getVersionString() uppercaseString];
    
    if ([remoteVersionString rangeOfString:@"QA"].location == NSNotFound && [localVersionString rangeOfString:@"QA"].location == NSNotFound) {
        
        // product version
        _remoteVersionArray = [remoteVersionString componentsSeparatedByString: @"V"];
        _localVersionArray = [localVersionString componentsSeparatedByString: @"V"];
        
    } else if ([remoteVersionString rangeOfString:@"QA"].location != NSNotFound && [localVersionString rangeOfString:@"QA"].location != NSNotFound) {
        
        // QA version
        _remoteVersionArray = [remoteVersionString componentsSeparatedByString: @"QA"];
        _localVersionArray = [localVersionString componentsSeparatedByString: @"QA"];

    }
    
    _remoteVersionPrefix = [_remoteVersionArray objectAtIndex:0];
    _remoteVersionSuffix = [[_remoteVersionArray objectAtIndex:1] integerValue];
    _localVersionPrefix = [_localVersionArray objectAtIndex:0];
    _localVersionSuffix = [[_localVersionArray objectAtIndex:1] integerValue];
    
    if ([_remoteVersionPrefix isEqualToString:_localVersionPrefix] && (_remoteVersionSuffix > _localVersionSuffix))
        return YES;
    
    return NO;
}

@end
