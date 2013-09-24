//
//  MasterViewController.h
//  FetchParseJSON
//
//  Created by developer on 9/8/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import "Group.h"
#import "MeetupManager.h"
#import "MeetupCommunicator.h"

@interface MasterViewController () <MeetupManagerDelegate> {
    NSArray *_groups;
    MeetupManager *_manager;
}
