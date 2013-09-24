//
//  MeetupCommunicator.h
//  FetchParseJSON
//
//  Created by developer on 9/8/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@protocol MeetupCommunicatorDelegate;

@interface MeetupCommunicator : NSObject
@property (weak, nonatomic) id<MeetupCommunicatorDelegate> delegate;

- (void)searchGroupsAtCoordinate:(CLLocationCoordinate2D)coordinate;

@end