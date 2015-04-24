//
//  StreetLegal.h
//  playground
//
//  Created by daniel on 4/19/15.
//  Copyright (c) 2015 DK. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol StreetLegal <NSObject>

- (void)signalStop;
- (void)signalLeftTurn;
- (void)signalRightTurn;

@end
