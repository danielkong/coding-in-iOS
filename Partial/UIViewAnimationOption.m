
// Transit from Signup form to confirmation form/sign-in form
- (void) transitionFormFromView:(UIView*)fromView toView:(UIView*)toView {
    
    [UIView transitionWithView:fromView
        duration:0.5
        options:UIViewAnimationOptionTransitionCrossDissolve
        animations:^{
                        
            _signInFormView.hidden = YES;
            _signUpFormView.hidden = YES;
            _forgotPasswordFormView.hidden = YES;
            _confirmFormView.hidden = YES;
            _resetPasswordFormView.hidden = YES;
                        
        }
        completion:^(BOOL finished) {
                        
            [UIView transitionWithView:toView
                duration:0.7
                options:UIViewAnimationOptionTransitionCrossDissolve
                animations:^{
                                            
                    toView.hidden = NO;
                                            
                }
                completion:nil];
                }];

    [self.view endEditing:YES];
}
