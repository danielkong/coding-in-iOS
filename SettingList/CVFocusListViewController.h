//
//  CVFocusListViewController.h
//  Vmoso
//
//  Created by Daniel Kong on 10/23/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVBaseListViewController.h"

@protocol IPadFocusApplyDelegate <NSObject>

- (void)didApplyFocus:(NSString*)focusKey;

@end

@interface CVFocusListViewController : CVBaseListViewController

@property(nonatomic, retain) NSString *subType;
@property(nonatomic, retain) NSString *spaceType;
@property(nonatomic, unsafe_unretained) id<IPadFocusApplyDelegate> focusApplyDelegate;

- (void)addNewFocusItem:(id)sender;

@end
