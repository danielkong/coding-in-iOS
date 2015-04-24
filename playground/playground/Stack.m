//
//  Stack.m
//  playground
//
//  Created by daniel on 4/17/15.
//  Copyright (c) 2015 DK. All rights reserved.
//

#import "Stack.h"

@implementation Stack

- (id)init {
    
    if (self=[super init]) {
        m_array = [NSMutableArray array];
        count = 0;
    }
    
    return self;
}

- (void)push:(id)anObject {
    [m_array addObject:anObject];
    count = (int)m_array.count;
}

- (id)pop {
    id obj = nil;
    if (m_array.count > 0){
        obj = [m_array lastObject];
        [m_array removeLastObject];
        count = (int)m_array.count;
    }
    return obj;
}

- (id)peek {
    id obj = nil;
    if (m_array.count > 0) {
        obj = [[m_array lastObject] copy];
    }
    return obj;
}

- (void)clear {
    [m_array removeAllObjects];
    count = 0;
}

@end
