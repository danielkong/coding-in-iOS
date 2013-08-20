//
//  BaseMenuTreeItem.m
//  
//
//  Created by Daniel Kong on 8/13/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "BaseMenuTreeItem.h"

@implementation BaseMenuTreeItem

@synthesize parentSelectingItem;
@synthesize ancestorSelectingItems;

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToSelectingItem:other];
}

- (BOOL)isEqualToSelectingItem:(CVBaseMenuTreeItem *)selectingItem {
	if (self == selectingItem)
        return YES;
	
	if ([_base isEqualToString:selectingItem.base])
		if ([_path isEqualToString:selectingItem.path])
			if (_numberOfSubitems == selectingItem.numberOfSubitems)
				return YES;
	
	return NO;
}

@end
