//
//  NSMutableArray+Queue.m
//  playground
//
//  Created by daniel on 4/19/15.
//  Copyright (c) 2015 DK. All rights reserved.
//

#import "NSMutableArray+Queue.h"

@implementation NSMutableArray (Queue)

- (void)enqueue:(id)item {
    [self addObject:item];
}

- (id)dequeue {
    id item = nil;
    if (self.count != 0) {
        item = [self objectAtIndex:0];
        [self removeObjectAtIndex:0];
    }
    return item;
}

- (id)peek {
    id item = nil;
    if (self.count != 0) {
        item = [self objectAtIndex:0];
    }
    return item;
}

- (BOOL)isEmpty {
    if ([self count] == 0)
        return true;
    return false;
}

@end
