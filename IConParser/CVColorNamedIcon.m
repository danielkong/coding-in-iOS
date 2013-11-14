//
//  CVColorNamedIcon.m
//  Vmoso
//
//  Created by Daniel Kong on 11/14/13.
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVColorNamedIcon.h"

#define DEFAULT_SPRITE_FILE     @"16x16_Sprite_Color.png"

@interface CVColorNamedIcon ()

@property (nonatomic, retain) NSArray* iconTable;
@property (nonatomic, retain) NSDictionary* iconPositions;
@property (nonatomic, retain) NSMutableDictionary* cachedIcons;
@property (nonatomic, retain) NSMutableDictionary* cachedSpriteImages;

@end

@implementation CVColorNamedIcon

static CVColorNamedIcon* sharedInstance;

+ (UIImage*)iconNamed:(NSString*)iconName {
    return [CVColorNamedIcon iconNamed:iconName inSprite:DEFAULT_SPRITE_FILE];
}

+ (UIImage*)iconNamed:(NSString*)iconName inSprite:(NSString*)spriteFileName {
    return [[CVColorNamedIcon shared] iconNamed:iconName inSprite:spriteFileName];
}

#pragma mark - private

+ (CVColorNamedIcon*)shared {
    if (sharedInstance == nil) {
        sharedInstance = [[CVColorNamedIcon alloc] init];
    }
    return sharedInstance;
}

- (id) init {
    
    self = [super init];
    if (self) {
        _cachedIcons = [NSMutableDictionary dictionary];
        _cachedSpriteImages = [NSMutableDictionary dictionary];
        
        _iconTable =
        @[
          @[@"MP Record", @"Favorite", @"Favorite (Blue)", @"Priority Not Selected", @"Priority Not Selected (Blue)", @"Important", @"Important (Blue)",@"Task Archived", @"Task Complete", @"Task Delete"],
          @[@"Task Suspended", @"Task Draft", @"Task Assigned", @"Task Complete (Black)", @"Part Assign", @"Part Accepted", @"Part Decline", @"Part Completed", @"Part Owner", @"Part Viewed"],
          @[@"Summary", @"Content", @"Reference", @"Associations", @"Contact", @"My Place", @"My Place Activity Log", @"My Place Dashboard", @"", @""],
          @[@"My Place Widgets", @"Add Widget", @"My Contents", @"Add to Folder ZAP", @"My Folders", @"Add Folder", @"My Place Template", @"Add Template", @"Add Focus", @"Add Event"],
          @[@"My Tasks", @"Add Tasks", @"My Posts", @"Add Post", @"My Spaces", @"Add Space", @"My Network", @"Add Network", @"Community", @"Add Community"],
          @[@"My Analytics", @"Add Analytics", @"My Files", @"Add File", @"Microblogs", @"Add Microblogs", @"Blog", @"Add Blog", @"Wikis", @"Add Wikis"],
          @[@"Polls", @"Add Poll", @"Links", @"Add Link", @"Plans", @"Add Plan", @"Forums", @"Add Forum", @"", @""]
          ];
        
        
        NSMutableDictionary* tmpDict = [NSMutableDictionary dictionary];
        for (NSUInteger row = 0; row < [_iconTable count]; row++) {
            NSArray* tableRow = (NSArray*)[_iconTable objectAtIndex:row];
            for (NSUInteger col = 0; col < [tableRow count]; col++) {
                [tmpDict setObject:[NSIndexPath indexPathForItem:col inSection:row] forKey:[tableRow objectAtIndex:col]];
            }
        }
        
        _iconPositions = tmpDict;
    }
    
    return self;
    
}

- (UIImage*)iconNamed:(NSString*)iconName inSprite:(NSString*)spriteFileName {
    NSString* cacheKey = [NSString stringWithFormat:@"%@/%@", iconName, spriteFileName];
    UIImage* icon = [_cachedIcons objectForKey:cacheKey];
    if (icon == nil) {
        icon = [self createIcon:iconName fromSprite:spriteFileName];
        [_cachedIcons setObject:icon forKey:cacheKey];
    }
    return icon;
}

- (UIImage*)createIcon:(NSString*)iconName fromSprite:(NSString*)spriteFileName {
    
    UIImage* spriteImage = [_cachedSpriteImages objectForKey:spriteFileName];
    if (spriteImage == nil) {
        spriteImage = [UIImage imageNamed:spriteFileName];
        NSAssert((spriteImage != nil), @"invalid sprite file name:%@", spriteFileName);
        
        [_cachedSpriteImages setObject:spriteImage forKey:spriteFileName];
    }
    
    NSInteger iconWith = [[spriteFileName substringToIndex:2] integerValue];
    NSInteger iconHeight = iconWith;
    
    NSAssert(iconWith <= 100, @"invalid icon width");
    
    NSIndexPath* iconPosition = [_iconPositions objectForKey:iconName];
    
    CGRect imgFrame = CGRectMake(iconPosition.item*iconWith*2, iconPosition.section*iconHeight*2, iconWith, iconHeight);
    CGImageRef imageRef = CGImageCreateWithImageInRect([spriteImage CGImage], imgFrame);
    UIImage* iconImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    
    return iconImage;
}

@end
