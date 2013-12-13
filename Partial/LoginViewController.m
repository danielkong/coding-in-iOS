BaseLoginViewController: UIViewController

- (void)loginWithNetwork:(NSString*)address username:(NSString *)username password:(NSString *)password {
    request = NSMutableRequest
    param = NSDictionary dictionaryWithObjectsAndKeys
    NSString* jsonRequest = [param jsonValue];
    [request setParamString:jsonRequest];
    CVAPIRequestModel* model = [[CVAPIRequestModel alloc] init];
    [model sendRequest:request completion:^(NSDictionary* apiResult, NSError* error) {
        _signInButton.enabled = YES;
        _signUpButton.enabled = YES;
        _requestPasswordButton.enabled = YES;
        _resetPasswordButton.enabled = YES;
        _activateSignUpButton.enabled = YES;
        [_activityIndicator stopAnimating];
        [_activityIndicator2 stopAnimating];
        [_activityIndicator3 stopAnimating];
        [_activityIndicator4 stopAnimating];
    }];   
}