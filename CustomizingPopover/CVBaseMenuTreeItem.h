//
//  BaseMenuTreeItem.h
//  
//
//  Created by Daniel Kong on 8/13/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseMenuTreeItem : NSObject

@property (nonatomic, strong) NSString *path;
@property (nonatomic, retain) NSString *base;
@property (nonatomic, assign) NSInteger numberOfSubitems;
@property (nonatomic, strong) BaseMenuTreeItem *parentSelectingItem;      
@property (nonatomic, strong) NSMutableArray *ancestorSelectingItems;       
@property (nonatomic, assign) NSInteger submersionLevel;

- (BOOL) isEqualToSelectingItem:(BaseMenuTreeItem *)selectingItem;

@end
