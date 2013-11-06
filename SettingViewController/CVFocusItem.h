//
//  CVTaskFocusItem.h
//  Vmoso
//
//  Created by Daniel Kong on 10/21/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CVFocusItem : NSObject

@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong)NSString *selectedOption;
@property (nonatomic, assign)BOOL isMultipleSelection;
@property (nonatomic, strong)NSString *itemType;
@property (nonatomic, strong)NSArray *itemOptions;


-(id)initWithTitle:(NSString *)atitle selectedOption:(NSString *)aselectedOption type:(NSString *)atype options:(NSArray *)aoptions;
-(void)setNewSelectedOption:(NSString *)selectedOption isMultiple:(BOOL)isMultipleSelection;

@end
