#import "CVNamedIcon.h"


#define DEFAULT_SPRITE_FILE     @"30x30_Sprite_White100.png"

@interface CVNamedIcon ()

@property (nonatomic, retain) NSArray* iconTable;
@property (nonatomic, retain) NSDictionary* iconPositions;
@property (nonatomic, retain) NSMutableDictionary* cachedIcons;
@property (nonatomic, retain) NSMutableDictionary* cachedSpriteImages;

@end

@implementation CVNamedIcon

static CVNamedIcon* sharedInstance;

+ (UIImage*)iconNamed:(NSString*)iconName {
    return [CVNamedIcon iconNamed:iconName inSprite:DEFAULT_SPRITE_FILE];
}

+ (UIImage*)iconNamed:(NSString*)iconName inSprite:(NSString*)spriteFileName {
    return [[CVNamedIcon shared] iconNamed:iconName inSprite:spriteFileName];
}

#pragma mark - private

+ (CVNamedIcon*)shared {
    if (sharedInstance == nil) {
        sharedInstance = [[CVNamedIcon alloc] init];
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
          @[@"", @"GTB Search Global", @"GTB Local Search", @"GTB Search", @"GTB Ping", @"GTB Chat", @"GTB Quick Folders",@"GTB Add Post", @"GTB Add Task", @"GTB Help"],
          @[@"GTB Setting", @"GTB Logout", @"", @"", @"", @"", @"", @"", @"", @""],
          @[@"My Place", @"My Place Dashboard", @"My Place Widgets", @"My Place Fouses", @"My Place Template", @"My Place Activity Log", @"Add Widget", @"Add Focus", @"Add Template", @""],
          @[@"My Folders", @"My Tasks", @"My Posts", @"My Contacts", @"My Spaces", @"My Network", @"Community", @"My Events", @"My Analytics", @""],
          @[@"Add Folder", @"Add Tasks", @"Add Post", @"Add Contact", @"Add Space", @"Add Network", @"Add Community", @"Add Event", @"Add Analytics", @"Add to Folder ZAP"],
          @[@"My Contents", @"My Files", @"Microblogs", @"Blog", @"Forums", @"Wikis", @"Polls", @"Plans", @"Links", @"Upload"],
          @[@"Add Generic", @"Add File", @"Add Microblogs", @"Add Blog", @"Add Forum", @"Add Wikis", @"Add Poll", @"Add Plan", @"Add Link", @"Download"],
          @[@"View Tabular", @"View Tile", @"Caret Left", @"Caret Right", @"Dismiss", @"Page Frame Collapse", @"Page Frame Expand", @"Section Expand", @"Section Collapse", @"Menu"],
          @[@"Edit", @"Delete", @"History", @"Print", @"Redo", @"Undo", @"Reset", @"Folder Quick Access", @"Copy Link", @"Share"],
          @[@"Comment", @"Add Comment", @"Contact", @"Add Contact", @"Downgrade Contact", @"Group", @"Add Group", @"Post it", @"Task It", @"Attachment"],
          @[@"Element Nav First", @"Element Nav Previous", @"Element Nav Next", @"Element Nav Last", @"Page Nav First", @"Page Nav Previous", @"Page Nav Next", @"Page Nav Last", @"Page Frame Switch", @"People"],
          @[@"View Stream", @"Summary", @"Add Summary", @"Content", @"Add Content", @"Reference", @"Add Reference", @"Associations", @"Add Associations", @"Add People"],
          @[@"Important", @"Favorite", @"Priority Not Selected", @"Announcement", @"Audio", @"Video", @"Sortable", @"Sort Down", @"Sort Up", @"Task Complete"],
          @[@"MP Record", @"MP Play", @"MP Pause", @"MP Fast Forward", @"MP Rewind", @"Task Assigned", @"Task Suspended", @"Task Draft", @"Task Archived", @"Task Delete"],
          @[@"Part Assign", @"Part Decline", @"Part Completed", @"Part Accepted", @"Part Viewed", @"Part Owner", @"Check Box Delete", @"Hot Spot", @"", @""]
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
