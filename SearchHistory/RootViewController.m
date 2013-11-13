- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    
    NSString* text = searchBar.text;
    
#ifdef CV_TARGET_IPAD
    
    UIViewController* viewController = [[CVSearchViewController alloc] initWithQueue:text];
    viewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [[StackScrollViewAppDelegate instance].rootViewController presentViewController:viewController animated:YES completion:nil];
    
    CVSearchHistoryViewController* svc = [CVSearchHistoryViewController sharedInstance];
    [svc updateSearchStatsWithKeyword:text];
    [svc dismissPopover:YES];
#endif
    return;
}