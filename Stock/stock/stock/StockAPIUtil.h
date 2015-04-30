//
//  StockAPIUtil.h
//  stock
//
//  Created by daniel on 4/29/15.
//  Copyright (c) 2015 DK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StockAPIUtil : NSObject

+(NSString*) getVolumeString:(NSString*)data;
+(NSString*) getValidRatio:(NSString*)data;

@end
