//
//  SearchResultItem.m
//  playground
//
//  Created by daniel on 4/4/15.
//  Copyright (c) 2015 DK. All rights reserved.
//

#import "SearchResultItem.h"

@implementation SearchResultItem

+ (instancetype)initSearchResultItemWithDictionary:(NSDictionary*)dict {
    if (dict == nil || ![dict isKindOfClass:[NSDictionary class]])
        return nil;

    SearchResultItem *item = [[SearchResultItem alloc] init];
    
    item.imageId = [dict objectForKey:@"imageId"];
    item.content = [dict objectForKey:@"content"];
    item.contentNoFormatting = [dict objectForKey:@"contentNoFormatting"];
    item.title = [dict objectForKey:@"title"];
    item.tbUrl = [dict objectForKey:@"tbUrl"];
    item.tbHeight = [[dict objectForKey:@"tbHeight"] integerValue];
    item.tbWidth = [[dict objectForKey:@"tbHeight"] integerValue];
    
    return item;
}

@end
