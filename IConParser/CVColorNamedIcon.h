//
//  CVColorNamedIcon.h
//  Vmoso
//
//  Created by Daniel Kong on 11/14/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CVColorNamedIcon : NSObject

+ (UIImage*)iconNamed:(NSString*)iconName;
+ (UIImage*)iconNamed:(NSString*)iconName inSprite:(NSString*)spriteFileName;

@end
