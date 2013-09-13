#pragma mark -
#pragma mark CVTableViewCell

- (void)setObject:(id)object {
    
    if (object == nil)
        return;
    
    [super setObject:object];
    
    _item = object;
    self.contentView.backgroundColor = _item.isNewlyAdded ? BG_COLOR_NEW : BG_COLOR;
    self.bgView.backgroundColor = _item.isNewlyAdded ? BG_COLOR_NEW : BG_COLOR;
    self.bubble.bgView.backgroundColor = _item.isNewlyAdded ? BG_COLOR_NEW : BG_COLOR;

    self.commentKey = _item.commentKey;
    self.seqLabel.text = _item.seqNumber;

    //bubble
    
    self.bubbleButton.hidden = NO;
    [self.bubble setFrom:_item.isFromSelf];
    
    //activity view
    self.activityView.hidden = YES;
    
    //timestamp
    self.timestampLabel.text = _item.timestamp;
    self.timestampLabel.hidden = NO;
    
    // set iconView
    
    if (_item.iconUrl) {
        self.iconView.urlPath = _item.iconUrl;
        [self.iconView setPresenceStatusWithUser:_item.author withLargeIcon:NO];
        if (_item.authorProfileUrl != nil)
            self.iconView.navURL = _item.authorProfileUrl;
    }
    
    //edited/deleted view
    
    self.tsLabel.text = _item.timestamp;
    if (_item.hasDeleted) {
        [self.editedView setImage:[UIImage imageNamed:@"trash_icon.png"]];
    } else if (_item.edited) {
        [self.editedView setImage:[UIImage imageNamed:@"icon_edit.png"]];
        self.editedView.hidden = NO;
        self.tsLabel.hidden = YES;
    } else {
        self.editedView.hidden = YES;
        self.tsLabel.hidden =YES;
    }
    
    //label/audio
    
    if (![_item.audioDownloadKey isEqual: @""]) {
        //NSLog(@"-item.text--%@ *",item.text);
        self.playVoiceView.audroURl = _item.audioDownloadKey;
                
        if (_item.hasDeleted && (!_item.canViewDeleted || _item.hideToggle)) {
            self.playVoiceView.hidden = YES;
            self.editedView.hidden = NO;
            self.tsLabel.hidden = NO;
            self.audioDurationLabel.hidden = YES;
        } else {
            self.playVoiceView.hidden = NO;
            self.editedView.hidden = YES;
            self.tsLabel.hidden = YES;
            if (_item.isFromSelf)
                [self.playVoiceView.voiceView setImage:[UIImage imageNamed:@"voiceself_playing.png"]];
            else
                [self.playVoiceView.voiceView setImage:[UIImage imageNamed:@"voice_playing.png"]];
            self.audioDurationLabel.hidden = NO;
        }
        
        if (_item.audioDurationInSecond >= 0) {
            NSInteger audioDuration = _item.audioDurationInSecond;
            
            NSInteger second = audioDuration % 60;
            NSInteger minute = audioDuration / 60;
            if (minute == 0) {
                self.audioDurationLabel.text = [NSString stringWithFormat:@"%d\"", second];
            } else {
                self.audioDurationLabel.text = [NSString stringWithFormat:@"%d\'%d\"", minute, second];
            }
        } else {
            self.audioDurationLabel.text = @"";
            self.audioDurationLabel.hidden = YES;
        }
        
        if ([_commentKey isEqualToString:@"+"]) {
            _activityView.hidden = NO;
            _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
            [_activityView startAnimating];
        }
    } else {
        // set commentLabel
        self.commentLabel.attributedString = _item.text;
        self.commentLabel.htmlText = _item.htmlText;
        if (_item.hasDeleted && (!_item.canViewDeleted || _item.hideToggle)) {
            self.commentLabel.hidden = YES;
            self.editedView.hidden = NO;
            self.tsLabel.hidden = NO;
        } else if (_item.edited) {
            self.editedView.hidden = NO;
            self.commentLabel.hidden = NO;
            self.tsLabel.hidden = YES;
        } else {
            self.commentLabel.hidden = NO;
            self.editedView.hidden = YES;
            self.tsLabel.hidden = YES;
        }
        
        _commentLabel.lazyImageDelegate = self;
        _commentLabel.lazyImageActionDelegate = self;
                
        //NSLog(@"--item.text---%@",self.commentLabel.attributedString);
    }
    
    //popup menu
    
    UIMenuItem *editMenuItem = nil;
    UIMenuItem *deleteMenuItem = nil;
    if(_item.canEdit && [_item.audioDownloadKey isEqual: @""] && ![_item.htmlText hasPrefix:@"<img"]) {
        editMenuItem = [[UIMenuItem alloc] initWithTitle:LS(@"Edit",@"") action:@selector(editMenuTouched:)];
    }
    if (_item.canDelete) {
        deleteMenuItem = [[UIMenuItem alloc] initWithTitle:LS(@"Delete",@"") action:@selector(deleteMenuTouched:)];
    } else if (_item.canViewDeleted && _item.hideToggle) {
        deleteMenuItem = [[UIMenuItem alloc] initWithTitle:LS(@"View",@"") action:@selector(hideMenuTouched:)];
    } else if (_item.canViewDeleted && !_item.hideToggle) {
        deleteMenuItem = [[UIMenuItem alloc] initWithTitle:LS(@"Hide",@"") action:@selector(hideMenuTouched:)];
    }
    if(editMenuItem != nil && deleteMenuItem != nil)
        _menuItems = @[editMenuItem, deleteMenuItem];
    else if(editMenuItem != nil && deleteMenuItem == nil)
        _menuItems = @[editMenuItem];
    else if(editMenuItem == nil && deleteMenuItem != nil)
        _menuItems = @[deleteMenuItem];
    
    //[self setNeedsLayout];
    //[self setNeedsDisplay];
}

- (void)layoutSubviewsFromSelf {
    if (_item.edited && !_item.hasDeleted) {
        CGFloat tsWidth = [self widthOfText:_timestampLabel.text];
        _editedView.frame = CGRectMake(_bubble.bgView.right - 35 - tsWidth, _bubble.bgView.bottom + TIMESTAMP_V_SPACER + 2, DELETE_BUTTON_WIDTH, DELETE_BUTTON_HEIGHT);
    }
}

- (void)layoutSubviewsToOthers {
}


- (void)editMenuTouched:(UIMenuController*)menuController {
    Comment* comment = [Comment commentWithUniqueId:_commentKey inManagedObjectContext:[[DataStore sharedDataStore] managedObjectContext]];
    
    if (_chatDelegate && [_chatDelegate respondsToSelector:@selector(didEditComment:)])
        [_chatDelegate didEditComment:comment];
}