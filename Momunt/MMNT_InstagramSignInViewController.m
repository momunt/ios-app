//
//  MMNT_InstagramSignInViewController.m
//  Momunt
//
//  Created by Masha Belyi on 1/19/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import "MMNT_InstagramSignInViewController.h"
#import "MMNT_InstagramRegistrationViewController.h"
#import "MMNTApiCommuniator.h"
#import "MMNTAccountManager.h"

#define kBaseURL @"https://instagram.com/"
#define kInstagramAPIBaseURL @"https://api.instagram.com"
#define kAuthenticationURL @"oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=code&scope=likes+comments+basic"  // comments
#define kClientID @"0857cc0cfd6a471b898c0c2035c64d9b"
#define kClientSecret @"794eba2cd6a844ae8c546a540e78d0cf"
#define kRedirectURI @"http://www.momunt.com"

@interface MMNT_InstagramSignInViewController () <UIWebViewDelegate, UITextFieldDelegate>
@property BOOL loadedInstagramWeb;
@property BOOL loadedAuthorizePage;
@property BOOL keyboardActive;
@property NSString *profileUrl;
@property NSString *username;
@property NSString *fullName;
@property NSString *token;
@end

@implementation MMNT_InstagramSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"username" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.45]}];
    _passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"password" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.45]}];
    
    _usernameField.delegate = self;
    _passwordField.delegate = self;
    
    _usernamePic.alpha = 0.45f;
    _passwordPic.alpha = 0.45f;
    
    // listen for when keyboard slide up
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // Resign keyboard when click out of textfield
    UITapGestureRecognizer *clickout = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:clickout];

    if(!_type){
        _type=@"register";
    }
    _animatedViews = self.view.subviews;
    
    self.view.clipsToBounds = YES;
    
    [self openWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSArray*)visibleCells{
    //    return self.view.subviews;
    return self.animatedViews;
}
- (NSArray*)staticCells{
    return self.view.subviews;
}


-(void)openWebView{
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width, 260)];
    _webView.center = CGPointMake(self.view.frame.size.width/2, -140);
//    _webView.transform = CGAffineTransformMakeTranslation(0, -380);
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    
    NSString* urlString = [kBaseURL stringByAppendingFormat:kAuthenticationURL,kClientID,kRedirectURI];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [_webView loadRequest:request];
    
//    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.instagram.com"]] ];
    
    
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString* urlString = [[request URL] absoluteString];
    NSLog(@"URL STRING : %@ ",urlString);
    
    NSArray *authorizeParts = [urlString componentsSeparatedByString:@"authorize/"];
    NSArray *loginParts = [urlString componentsSeparatedByString:@"login/"];
    if ([loginParts count] > 1) {
        _loadedAuthorizePage = NO;
    }else{
        _loadedAuthorizePage = YES;
    }
    
    NSArray *UrlParts = [urlString componentsSeparatedByString:[NSString stringWithFormat:@"%@/", kRedirectURI]];
    if ([UrlParts count] > 1) {
        // do any of the following here
        urlString = [UrlParts objectAtIndex:1];
        NSRange accessToken = [urlString rangeOfString: @"code="];
        if (accessToken.location != NSNotFound) {
            NSString* strCode = [urlString substringFromIndex: NSMaxRange(accessToken)];
            // Save access token to user defaults for later use.
            // Add contant key #define KACCESS_TOKEN @”access_token” in contant //class [[NSUserDefaults standardUserDefaults] setValue:strAccessToken forKey: KACCESS_TOKEN]; [[NSUserDefaults standardUserDefaults] synchronize];
            NSLog(@"Code = %@ ",strCode);
            [self getAccessTokenWithCode:strCode];
//            [self loadRequestForMediaData];
        }
        return NO;
    }
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    if(!_loadedInstagramWeb){
        _loadedInstagramWeb = YES;
    }else{
        // check if URL contains "authorize" vs. "login"
        // If login -> wrong user & pass provided
        [UIView animateWithDuration:0.3 animations:^{
            _webView.center = CGPointMake(self.view.frame.size.width/2, 180);
        } completion:^(BOOL finished) {
            _instgramPng.alpha = 0;
        }];
    }  
    
    
}

-(void)getAccessTokenWithCode:(NSString *)code{
    
    NSString *postString = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&code=%@",
                            kClientID, kClientSecret, kRedirectURI, code];
    NSData *postDataString = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:@"https://api.instagram.com/oauth/access_token" ];
    
    NSMutableURLRequest *mutableRelquest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    [mutableRelquest setURL:url];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postDataString length]];
    [mutableRelquest setHTTPMethod:@"POST"];
    [mutableRelquest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [mutableRelquest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mutableRelquest setHTTPBody:postDataString];
    
    NSURLRequest *request = [mutableRelquest copy];
    
    // RUN SynchronousRequest because this is already running on a background thread
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSError *e;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    
    NSString *token = [res objectForKey:@"access_token"];
    NSDictionary *user = [res objectForKey:@"user"];
    NSString *profile = [user objectForKey:@"profile_picture"];
    NSString *username = [user objectForKey:@"username"];
    NSString *fullName = [user objectForKey:@"full_name"];
    
    _profileUrl =[user objectForKey:@"profile_picture"];
    _username = [user objectForKey:@"username"];
    _token = [res objectForKey:@"access_token"];
    _fullName = [user objectForKey:@"full_name"];
    
    NSLog(@"TOKEN = %@", token);
    NSLog(@"USERNAME = %@", username);
    
    if([_type isEqualToString:@"register"]){
        [self performSegueWithIdentifier:@"instgramLogIn" sender:self];
    }
    else if ([_type isEqualToString:@"signin"]){
        // 1) send instagram token to server,
        [[MMNTApiCommuniator sharedInstance] authenticate:@"instagram" status:1 withToken:token setName:_fullName];
        // 2) Update
        [MMNTAccountManager sharedInstance].authInstagram = 1;
        // 2) signed in - dismiss controller, go back to gallery
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    //transition to next screen
    
//    BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
//    if(failed){
//        
//    }else{
//        
//    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _currentView = textField.superview;
    if(textField.text.length==0){
        [_exitOrSubmit setTitle:@"exit" forState:UIControlStateNormal];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    _currentView = textField.superview;
    UIView *icon = [_currentView.subviews objectAtIndex:0]; // icon image

    if(newLength>0){
        [UIView animateWithDuration:0.3 animations:^{icon.alpha = 1.0f;}];
        [_exitOrSubmit setTitle:@"submit" forState:UIControlStateNormal];
    }else{
        [UIView animateWithDuration:0.3 animations:^{icon.alpha = 0.45f;}];
        [_exitOrSubmit setTitle:@"exit" forState:UIControlStateNormal];
    }
    return YES;
}

-(void)keyboardWillShow:(NSNotification *)note{
    _keyboardActive = YES;
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    CGFloat offset = kbSize.height+3;
    if(_currentView==_usernameField.superview){
        _usernameField.superview.transform = CGAffineTransformMakeTranslation(0, -(offset-63));
        _exitOrSubmit.transform = CGAffineTransformMakeTranslation(0, -offset);
    }else{
        _passwordField.superview.transform = CGAffineTransformMakeTranslation(0, -offset);
        _exitOrSubmit.transform = CGAffineTransformMakeTranslation(0, -offset);
    }
    
}

-(void)keyboardWillHide:(NSNotification *)note{
    _keyboardActive = NO;
    _usernameField.superview.transform = CGAffineTransformIdentity;
    _passwordField.superview.transform = CGAffineTransformIdentity;
    _exitOrSubmit.transform =  CGAffineTransformIdentity;
    
    if(![_usernameField.text isEqualToString:@""] && ![_passwordField.text isEqualToString:@""]){
        [_exitOrSubmit setTitle:@"submit" forState:UIControlStateNormal];
    }else{
        [_exitOrSubmit setTitle:@"exit" forState:UIControlStateNormal];
    }
}




#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [super prepareForSegue:segue sender:sender];
    
    if([segue.destinationViewController isKindOfClass: [MMNT_InstagramRegistrationViewController class] ] || [segue.sourceViewController isKindOfClass: [MMNT_InstagramRegistrationViewController class] ]){
        _animatedViews = [[NSArray alloc] initWithObjects: _instgramPng, _webView, _usernameField.superview, _passwordField.superview ,nil];
        
    }else{
        _animatedViews = self.view.subviews;
    }
    
    if([segue.destinationViewController isKindOfClass: [MMNT_InstagramRegistrationViewController class] ]){
        
        MMNT_InstagramRegistrationViewController *toVC = segue.destinationViewController;
        toVC.profileImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_profileUrl]]];
        toVC.username = _username;
        toVC.token = _token;
        toVC.password = _passwordField.text;
        toVC.fullName = _fullName;

    }
    
}

- (IBAction)pressedExitOrSubmit:(id)sender {
//    if(_keyboardActive){
//        [_usernameField resignFirstResponder];
//        [_passwordField resignFirstResponder];
//        return;
//    }

    
    NSString *action = _exitOrSubmit.currentTitle;
    if([action isEqualToString:@"exit"]){
        if(_keyboardActive){
            [_usernameField resignFirstResponder];
            [_passwordField resignFirstResponder];
            return;
        }

        if([_type isEqualToString:@"signin"]){
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }else{
            // pop to root controller
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }else{
        [_usernameField resignFirstResponder];
        [_passwordField resignFirstResponder];
        
        if(![_usernameField.text isEqualToString:@""] && ![_passwordField.text isEqualToString:@""]){
            [self loginInstagram];
        }
    }
}
- (void)dismissKeyboard {
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];
}
-(void)loginInstagram{
    if(!_loadedInstagramWeb){
        return;
    }
    if(_loadedAuthorizePage){
        // show auth page
        [UIView animateWithDuration:0.3 animations:^{
            _webView.center = CGPointMake(self.view.frame.size.width/2, 180);
        } completion:^(BOOL finished) {
            _instgramPng.alpha = 0;
        }];

    }else{
        // submit info, then load & show auth page
        NSString *scroll = @"window.scrollTo(0, 30);"; // mobile page leaves 20px on top for status bar
        NSString *username = [NSString stringWithFormat: @"document.getElementById('id_username').value = '%@';", _usernameField.text ];
        NSString *password = [NSString stringWithFormat: @"document.getElementById('id_password').value = '%@';", _passwordField.text ];
        NSString *submit = @"$(\"input[value='Log in']\").click()";
    
        //    [_webView stringByEvaluatingJavaScriptFromString:scroll];
        [_webView stringByEvaluatingJavaScriptFromString:username];
        [_webView stringByEvaluatingJavaScriptFromString:password];
        [_webView stringByEvaluatingJavaScriptFromString:submit];
    }

}




-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                 presentingController:(UIViewController *)presenting
                                                                     sourceController:(UIViewController *)source{
    
    return [[MMNT_SlideUpTransition alloc] initWithOperation:@"present"];

    
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[MMNT_SlideUpTransition alloc] initWithOperation:@"dismiss"];
}
@end
