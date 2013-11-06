//
//  CVTaskFocusItem.m
//  Vmoso
//
//  Created by Daniel Kong on 10/21/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVFocusItem.h"

@implementation CVFocusItem

-(id)initWithTitle:(NSString *)atitle selectedOption:(NSString *)aselectedOption type:(NSString *)atype options:(NSArray *)aoptions {
    self = [super init];
    
    if (self) {
        self.title = atitle;
        self.selectedOption = aselectedOption;
        self.itemType = atype;
        self.itemOptions = aoptions;
    }
    
    return self;
}

-(void)setNewSelectedOption:(NSString *)selectedOption isMultiple:(BOOL)isMultipleSelection {
    if (selectedOption) {
        if (isMultipleSelection)
            self.selectedOption = [NSString stringWithFormat:@"%@, %@", self.selectedOption, selectedOption];
        else
            self.selectedOption = selectedOption;
    }
    return;
}


@end
