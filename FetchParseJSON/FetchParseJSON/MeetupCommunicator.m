//
//  MeetupCommunicator.m
//  FetchParseJSON
//
//  Created by developer on 9/8/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import "MeetupCommunicator.h"
#import "MeetupCommunicatorDelegate.h"

#define API_KEY @"4a3b2b52571e4b593d774e92c6a3156"
#define PAGE_COUNT 20

@implementation MeetupCommunicator

- (void)searchGroupsAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSString *urlAsString = [NSString stringWithFormat:@"https://api.meetup.com/2/groups?lat=%f&lon=%f&page=%d&key=%@", coordinate.latitude, coordinate.longitude, PAGE_COUNT, API_KEY];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"%@", urlAsString);
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            [self.delegate fetchingGroupsFailedWithError:error];
        } else {
            [self.delegate receivedGroupsJSON:data];
        }
    }];
}

@end