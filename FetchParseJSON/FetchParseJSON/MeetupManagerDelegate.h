//
//  MeetupManagerDelegate.h
//  FetchParseJSON
//
//  Created by developer on 9/8/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MeetupManagerDelegate
- (void)didReceiveGroups:(NSArray *)groups;
- (void)fetchingGroupsFailedWithError:(NSError *)error;
@end

@interface MeetupManagerDelegate : NSObject

@end
