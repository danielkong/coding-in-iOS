//
//  NSMutableArray+Stack.m
//  playground
//
//  Created by daniel on 4/19/15.
//  Copyright (c) 2015 DK. All rights reserved.
//

#import "NSMutableArray+Stack.h"

@implementation NSMutableArray (Stack)

- (void)push:(id)item {
    [self addObject:item];
}

- (id)pop {
    id item = nil;
    if (self.count != 0) {
        item = [self lastObject];
        [self removeLastObject];
    }
    return item;
}

- (id)peek {
    id item = nil;
    if (self.count != 0) {
        item = [self lastObject];
    }
    return item;
}

- (BOOL)isEmpty {
    if ([self count] == 0)
        return true;
    return false;
}

@end
