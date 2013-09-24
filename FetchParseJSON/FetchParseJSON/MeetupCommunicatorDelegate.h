//
//  MeetupCommunicatorDelegate.h
//  FetchParseJSON
//
//  Created by developer on 9/8/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MeetupCommunicatorDelegate <NSObject>

- (void)receivedGroupsJSON:(NSData *)objectNotation;
- (void)fetchingGroupsFailedWithError:(NSError *)error;

@end
