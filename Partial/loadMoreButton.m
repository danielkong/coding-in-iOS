- (void)createLoadMoreButton {
    // create a footer view for drawing a loadmore box
    
    _loadMoreBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, LOAD_MORE_VIEW_HEIGHT)];
    _loadMoreBoxView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _loadMoreBoxView.autoresizesSubviews = YES;
    _loadMoreBoxView.backgroundColor = [UIColor yellowColor];
    
    // Add loadMoreButton and place inside loadMoreBox
    _loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _loadMoreButton.backgroundColor = [UIColor greenColor];
    _loadMoreButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    CGFloat left = (self.view.width - 220)/2;
    _loadMoreButton.frame = CGRectMake(left, (42 - 32)/2, 220, 32);
    // button label
    [_loadMoreButton setTitle:LS(@"Load More", @"") forState:UIControlStateNormal];
    [_loadMoreButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _loadMoreButton.titleLabel.font = [UIFont systemFontOfSize:14];
    _loadMoreButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    // button border
    _loadMoreButton.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
    _loadMoreButton.layer.borderWidth = 1;
    _loadMoreButton.layer.cornerRadius = 5;
    [_loadMoreButton.layer setMasksToBounds:YES];
    // button action
    [_loadMoreButton addTarget:self action:@selector(loadMoreButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    // put together subviews of the footer view
    [_loadMoreBoxView addSubview:_loadMoreButton];
    
    // Create activity spinning icon
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
    _activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    _activityView.frame = CGRectMake(_loadMoreButton.width - 20 - 20, (32 - 20)/2, 20, 20);
    _activityView.backgroundColor = [UIColor purpleColor];
    
    [_loadMoreButton addSubview:_activityView];
}

- (void)loadMoreButtonTouched {
    [self showLoadMoreButtonLoading:YES];
    
    [_model loadMore:YES];
}

- (void)showLoadMoreButtonLoading:(BOOL)show {
    
    if (show) {
        [_activityView startAnimating];
        [_loadMoreButton setTitle:LS(@"Loading...", @"") forState:UIControlStateNormal];
        _loadMoreButton.enabled = NO;

    } else {
        [_activityView stopAnimating];
        [_loadMoreButton setTitle:LS(@"Load More", @"") forState:UIControlStateNormal];
        _loadMoreButton.enabled = YES;
    }
}

- (void)loadMore:(BOOL)more {
    
    self.pageIdx = !more ? 0 : self.pageIdx + 1;
    self.page = self.pageIdx == 0 ? PARAM_FIRST_PAGE : PARAM_NEXT_PAGE;
    if(self.pageIdx == 0) {
        self.pgRecord = [NSDictionary dictionary];
    }
    
    if ([self.delegate respondsToSelector:@selector(modelWillLoad:action:)]) {
        [self.delegate modelWillLoad:self action:ACTION_LOAD_RECORD];
    }
    
    CVAPIRequest* request = [[CVAPIRequest alloc] initWithAPIUrlString:[self getAPIPath]];
    [request setHTTPMethod:@"GET"];
    
    [self sendRequest:request completion:^(NSDictionary* apiResult, NSError* error){
        [self updateModelWithResult:apiResult error:error action:ACTION_LOAD_RECORD];
    }];
}

-(NSString*)getAPIPath {
    
    NSMutableString* apiPath = [[NSMutableString alloc] init];;

    [apiPath appendString:@"/svc/stream/search"];
    
    [self setAPIParams];

    NSString* paramsString = [CVAPIRequest GETParamString:_params];
    [apiPath appendString:paramsString];
    
    return apiPath;
}

-(void)setAPIParams{
    _spaceKey = _spaceKey ? _spaceKey : [CVAPIUtil getUserKey];
    _nameSpace = _nameSpace ? _nameSpace : @"";
    _typeFilters = _typeFilters ? _typeFilters : [NSMutableArray array];
    _subtypeFilters = _subtypeFilters ? _subtypeFilters : [NSMutableArray array];
    _statusFilters = _statusFilters ? _statusFilters : [NSMutableArray array];
    _lifecycleFilters = _lifecycleFilters ? _lifecycleFilters : [NSMutableArray array];
    _creatorFilter = _creatorFilter ? _creatorFilter : STREAM_LIST_CREATOR_FILTER_ALL;
    _folderFilters = _folderFilters ? _folderFilters : [NSMutableArray array];
    _userStatusFilters = _userStatusFilters ? _userStatusFilters : [NSMutableArray array];
    _flagFilters = _flagFilters ? _flagFilters : [NSMutableArray array];
    _creatorKeyFilters = _creatorKeyFilters ? _creatorKeyFilters : [NSMutableArray array];
    _updaterKeyFilters = _updaterKeyFilters ? _updaterKeyFilters : [NSMutableArray array];
    _updateTimeFilter = _updateTimeFilter ? _updateTimeFilter : [NSMutableDictionary dictionary];
    self.sortBy = self.sortBy ? self.sortBy : STREAM_LIST_SORT_LAST_ACTIVITY_TIME;
    self.order = self.order ? self.order : STREAM_LIST_ORDER_DESC;
    self.searchText = self.searchText ? self.searchText : @"";
    _focusKey = _focusKey ? _focusKey : @"";
    _params = _params? _params :[NSMutableDictionary dictionary];
    NSString* c_next = _pgRecord ? [CVAPIUtil getValidString:[_pgRecord objectForKey:@"c_next"]] : @"";
    
    if(_statusFilters.count == 0)
        [_statusFilters addObject:@"online"];
    
    [_params setObject:self.spaceKey forKey:@"options.spacekey"];
    [_params setObject:self.nameSpace forKey:@"options.namespace"];
    [_params setObject:self.sortBy forKey:@"options.sort_attr"];
    [_params setObject:self.order forKey:@"options.sort_dir"];
    [_params setObject:self.searchText forKey:@"options.search_string"];
    [_params setObject:self.typeFilters forKey:@"options.type_filter"];
    [_params setObject:self.subtypeFilters forKey:@"options.subtype_filter"];
    [_params setObject:self.statusFilters forKey:@"options.status_filter"];
    [_params setObject:self.lifecycleFilters forKey:@"options.lifecycle_filter"];
    [_params setObject:self.creatorFilter forKey:@"options.creator_filter"];
    [_params setObject:self.focusKey forKey:@"options.focusKey"];
    [_params setObject:[[NSNumber numberWithInt:PAGE_LIMIT] stringValue]forKey:@"pg.limit"];
    [_params setObject:c_next forKey:@"pg.c_next"];
    [_params setObject:self.page forKey:@"pg.page"];
    [_params setObject:self.folderFilters forKey:@"options.folder_filter"];
    [_params setObject:self.userStatusFilters forKey:@"options.user_status_filter"];
    [_params setObject:self.flagFilters forKey:@"options.flag_filter"];
    [_params setObject:self.creatorKeyFilters forKey:@"options.creator_key_filter"];
    [_params setObject:self.updaterKeyFilters forKey:@"options.updater_key_filter"];
    [_params setObject:self.updateTimeFilter forKey:@"options.update_time_filter"];
    
}
