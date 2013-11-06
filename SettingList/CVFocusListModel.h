//
//  CVFocusListModel.h
//  Vmoso
//
//  Created by Daniel Kong on 10/25/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVAPIListModel.h"

@interface CVFocusListModel : CVAPIListModel

@property (nonatomic, assign) double before;
@property (nonatomic, retain) NSString* subType;
@property (nonatomic, retain) NSString* spaceType;

@end

