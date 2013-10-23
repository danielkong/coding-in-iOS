//
//  CVTaskFocusItem.h
//  Vmoso
//
//  Created by Daniel Kong on 10/21/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CVTaskFocusItem : NSObject

@property (nonatomic, strong)NSString *fname;   //name
@property (nonatomic, strong)NSString *selectedOption;   //selected option
@property (nonatomic, assign)BOOL isMultipleSelection;   //check singlton or multiple selection
@property (nonatomic, strong)NSString *itemType;    //type: singlton/multiple
@property (nonatomic, strong)NSArray *itemOptions;
@property int age;

-(id)initWithFname:(NSString *)afname alname:(NSString *)alname type:(NSString *)atype options:(NSArray *)aoptions age:(int)aage;
-(void)setNewSelectedOption:(NSString *)selectedOption isMultiple:(BOOL)isMultipleSelection;

@end
