//
//  NSMutableArray+Queue.h
//  playground
//
//  Created by daniel on 4/19/15.
//  Copyright (c) 2015 DK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Queue)

- (void)enqueue:(id)item; // offer
- (id)dequeue;   // pop
- (id)peek;
- (BOOL)isEmpty;

@end
