//
//  CVTaskFocusItem.m
//  Vmoso
//
//  Created by Daniel Kong on 10/21/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVTaskFocusItem.h"

@implementation CVTaskFocusItem

-(id)initWithFname:(NSString *)afname alname:(NSString *)alname type:(NSString *)atype options:(NSArray *)aoptions age:(int)aage {
    self = [super init];
    
    if (self) {
        self.fname = afname;
        self.selectedOption = alname;
        self.itemType = atype;
        self.itemOptions = aoptions;
        self.age = aage;
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
