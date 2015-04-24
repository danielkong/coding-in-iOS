//
//  SearchResultItem.h
//  playground
//
//  Created by daniel on 4/4/15.
//  Copyright (c) 2015 DK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchResultItem : NSObject

@property (nonatomic, copy) NSString *imageId;

@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *contentNoFormatting;
@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *tbUrl;
@property (nonatomic, assign) NSInteger tbHeight;
@property (nonatomic, assign) NSInteger tbWidth;

+ (instancetype)initSearchResultItemWithDictionary:(NSDictionary*)dict;

@end
