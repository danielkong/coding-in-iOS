//
//  CVFocusListModel.h
//  Vmoso
//
//  Created by Daniel Kong on 10/25/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//
#import "CVFocusListModel.h"
#import "CVAPIRequest.h"
#import "CVCommentListItem.h"
#import "CVFocusListItem.h"
#import "NSDictionary+DragonAPIComment.h"

@implementation CVFocusListModel

- (void)loadMore:(BOOL)more {
    
    self.pageIdx = !more ? 0 : self.pageIdx + 1;
    if (!self.pageIdx)
        _before = [[NSDate date] timeIntervalSince1970];
    //backend after/before is opposite to ios
    CVAPIRequest* request = [[CVAPIRequest alloc] initWithAPIPath:[NSString stringWithFormat:@"/svc/focuses?options.spaceType=%@&options.subType=%@&options.after=%f&options.filter=&pg.limit=%d&pg.offset=%d",_spaceType , _subType, _before, 50, 0]];
    [request setHTTPMethod:@"GET"];
    
    [self sendRequest:request completion:^(NSDictionary* apiResult, NSError* error) {
        [self updateModelWithResult:apiResult error:error action:@"load"];
    }];

}

- (void)updateModel:(NSDictionary*) apiResult action:(NSString*)action {
    
    if (self.pageIdx == 0)
        [self.items removeAllObjects];
    
    NSArray* focusList = (NSArray*)[apiResult objectForKey:@"focuses"];
    if (focusList == nil || ![focusList isKindOfClass:[NSArray class]]) {
        DLog(@"backend returned corrupt comment list data");
        return;
    }

    for (NSDictionary* focusDataDetailed in focusList) {
        
        if (focusDataDetailed == nil || ![focusDataDetailed isKindOfClass:[NSDictionary class]]) {
            DLog(@"backend returned corrupt comment detailed data");
            continue;
        }
        
        CVFocusListItem* focusListItem = [[CVFocusListItem alloc] init];
        focusListItem.focusTitle = [CVAPIUtil getValidString:[focusDataDetailed objectForKey:@"title"]];
        focusListItem.type = [CVAPIUtil getValidString:[focusDataDetailed objectForKey:@"type"]];
        focusListItem.timecreated = [CVAPIUtil getValidTimestamp:[focusDataDetailed objectForKey:@"timecreated"]];
        focusListItem.timeupdated = [CVAPIUtil getValidTimestamp:[focusDataDetailed objectForKey:@"timeupdated"]];
        focusListItem.focusKey = [CVAPIUtil getValidString:[focusDataDetailed objectForKey:@"key"]];
        focusListItem.definition = [CVAPIUtil getValidString:[focusDataDetailed objectForKey:@"definition"]];
        focusListItem.subtype = [CVAPIUtil getValidString:[focusDataDetailed objectForKey:@"subtype"]];
        focusListItem.userrecord = [CVAPIUtil getDictionaryFromObject:[focusDataDetailed objectForKey:@"userrecord"]];

        [self.items addObject:focusListItem];
    }
    self.hasMore = [(NSNumber*)[[apiResult objectForKey:@"result"] objectForKey:@"showMore"] boolValue];

}

@end
