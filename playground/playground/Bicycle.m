//
//  Bicycle.m
//  playground
//
//  Created by daniel on 4/19/15.
//  Copyright (c) 2015 DK. All rights reserved.
//

#import "Bicycle.h"

@implementation Bicycle

#pragma mark - StreetLegal

- (void)signalStop {
    NSLog(@"Bending left arm downwards");
}
- (void)signalLeftTurn {
    NSLog(@"Extending left arm outwards");
}
- (void)signalRightTurn {
    NSLog(@"Bending left arm upwards");
}

#pragma mark - private

- (void)startPedaling {
    NSLog(@"Here we go!");
}
- (void)removeFrontWheel {
    NSLog(@"Front wheel is off."
          "Should probably replace that before pedaling...");
}
- (void)lockToStructure:(id)theStructure {
    NSLog(@"Locked to structure. Don't forget the combination!");
}

@end
