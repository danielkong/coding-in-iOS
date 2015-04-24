//
//  Stack.h
//  playground
//
//  Created by daniel on 4/17/15.
//  Copyright (c) 2015 DK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stack : NSObject {
    NSMutableArray *m_array;
    int count;
}

- (void)push:(id)anObject;
- (id)pop;
- (id)peek;
- (void)clear;

@property (nonatomic, readonly) int count;

@end
