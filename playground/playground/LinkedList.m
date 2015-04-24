//
//  LinkedList.m
//  playground
//
//  Created by daniel on 4/21/15.
//  Copyright (c) 2015 DK. All rights reserved.
//

#import "LinkedList.h"

@implementation LinkedList

@synthesize currentValue = _currentValue;
@synthesize next = _next;

// doing the below assignment allows us to insert a zero into the linked list
// if desired...
#define kNotYetSet NSIntegerMin
// there's also a NSNotFound enum, but that's set to NSIntegerMax so that
// would break our algorithm below

// creates a LList object with no value and no payload and a nil object for next
- (id) init
{
    self = [super init];
    if(self)
    {
        _currentValue = kNotYetSet;
        
        // no need to do this, since Objective C does it automagically
        // but just to make it clear...
        _next = NULL;
    }
    return(self);
}

- (void) insert: (NSInteger) valueToInsert
{
    // look at the next value (if it exists) and see if there is the right place to insert a new LinkedList node
    LinkedList * nextNode = self.next;
    LinkedList * newNode;
    
    if(self.currentValue == kNotYetSet)
    {
        self.currentValue = valueToInsert;
        return;
    }
    
    if(valueToInsert < self.currentValue)
    {
        newNode = [[LinkedList alloc] init];
        if(newNode)
        {
            newNode.currentValue = self.currentValue;
            newNode.next = self.next;
            
            self.currentValue = valueToInsert;
            self.next = newNode;
        }
        return;
    }
    
    if(nextNode == NULL)
    {
        // nothing is next, so this is the place to insert the new LinkedList node
        newNode = [[LinkedList alloc] init];
        if(newNode)
        {
            newNode.currentValue = valueToInsert;
            // no need to reset "next" for the newNode, since this is the new tail of the LinkedList
            self.next = newNode;
            return;
        }
    } else {
        // see if the value we're trying to insert fits between the current and the next value
        if((valueToInsert >= self.currentValue) && (valueToInsert < nextNode.currentValue))
        {
            newNode = [[LinkedList alloc] init];
            if(newNode)
            {
                newNode.currentValue = valueToInsert;
                newNode.next = nextNode;
                self.next = newNode;
            }
        } else {
            [nextNode insert: valueToInsert];
        }
    }
}

- (void) printValue
{
    LinkedList * nextNode = self.next;
    NSLog( @"%ld", self.currentValue);
    if(nextNode)
    {
        // keep going down the list
        [nextNode printValue];
    }
}

@end

