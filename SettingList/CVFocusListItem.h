//
//  CVFocusListItem.h
//  Vmoso
//
//  Created by Daniel Kong on 10/23/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CVFocusListItem : NSObject <NSCoding>

@property (nonatomic, retain)NSString *focusTitle;
@property (nonatomic, retain)NSString *type;
@property (nonatomic, assign)double timeupdated;
@property (nonatomic, assign)double timecreated;
@property (nonatomic, retain)NSString *focusKey;
@property (nonatomic, retain)NSString *definition;
@property (nonatomic, retain)NSString *subtype;
@property (nonatomic, retain)NSDictionary *userrecord;

@end
