//
//  LinkedList.h
//  playground
//
//  Created by daniel on 4/21/15.
//  Copyright (c) 2015 DK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LinkedList : NSObject
{
    NSInteger _currentValue;
    LinkedList * _next;
}

- (void) insert: (NSInteger) valueToInsert;
- (void) printValue;

@property (readwrite) NSInteger currentValue;
@property (retain) LinkedList * next;

@end
