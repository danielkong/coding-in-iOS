//
//  NSMutableArray+Stack.h
//  playground
//
//  Created by daniel on 4/19/15.
//  Copyright (c) 2015 DK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Stack)

- (void)push:(id)item;
- (id)pop;
- (id)peek;
- (void)clear;
- (BOOL)isEmpty;

@end
