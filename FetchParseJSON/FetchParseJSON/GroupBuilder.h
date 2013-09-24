//
//  GroupBuilder.h
//  FetchParseJSON
//
//  Created by developer on 9/8/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupBuilder : NSObject

+ (NSArray *)groupsFromJSON:(NSData *)objectNotation error:(NSError **)error;

@end