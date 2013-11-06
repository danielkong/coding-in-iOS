//
//  CVFocusListItem.m
//  Vmoso
//
//  Created by Daniel Kong on 10/23/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVFocusListItem.h"

@implementation CVFocusListItem


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    // encode the properties that need to be cached

    [aCoder encodeObject:_focusTitle forKey:@"title"];
    [aCoder encodeObject:_type forKey:@"type"];
    [aCoder encodeDouble:_timeupdated forKey:@"timeupdated"];
    [aCoder encodeDouble:_timecreated forKey:@"timecreated"];
    [aCoder encodeObject:_focusKey forKey:@"key"];
    [aCoder encodeObject:_definition forKey:@"definition"];
    [aCoder encodeObject:_subtype forKey:@"subtype"];
    [aCoder encodeObject:_userrecord forKey:@"userrecord"];

}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        
        // restore cached properties
        
        _focusTitle = [aDecoder decodeObjectForKey:@"title"];
        _type = [aDecoder decodeObjectForKey:@"type"];
        _timeupdated = [aDecoder decodeDoubleForKey:@"timeupdated"];
        _timecreated = [aDecoder decodeDoubleForKey:@"timecreated"];
        _focusKey = [aDecoder decodeObjectForKey:@"key"];
        _definition = [aDecoder decodeObjectForKey:@"definition"];
        _subtype = [aDecoder decodeObjectForKey:@"subtype"];
        _userrecord = [aDecoder decodeObjectForKey:@"userrecord"];

    }
    return self;
}

@end
