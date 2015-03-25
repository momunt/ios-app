//
//  MMNT_SignIn.m
//  Momunt
//
//  Created by Masha Belyi on 1/21/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import "MMNT_SignIn.h"
#import "MMNTApiCommuniator.h"
#import "JNKeychain.h"
#import "MMNT_SignInController.h"
#import "MMNT_SharedVars.h"
#import "MMNTContactsManager.h"

@interface MMNT_SignIn () <UITextFieldDelegate>{
    MMNTApiCommuniator *_apicommunicator;
}
@property BOOL keyboardActive;
@property UITextField *errorField;
@end

@implementation MMNT_SignIn

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _apicommunicator = [[MMNTApiCommuniator alloc] init];
    
    _usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"username" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.45]}];
    _passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"password" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.45]}];
    
    _usernameField.delegate = self;
    _passwordField.delegate = self;
    
    [[_usernameField.superview.subviews objectAtIndex:0] setAlpha:0.45f];
    [[_passwordField.superview.subviews objectAtIndex:0] setAlpha:0.45f];
    
    //_errorMsg.center = CGPointMake(_errorMsg.center.x, _errorMsg.center.y+40);
    //_errorMsg.hidden = NO;
    _errorMsg.titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    
    // listen for when keyboard slides up
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _animatedViews = [[NSArray alloc] initWithObjects:_errorMsg, _usernameField.superview, _passwordField.superview, _exitOrSubmit ,nil];

    // Resign keyboard when click out of textfield
    UITapGestureRecognizer *clickout = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:clickout];

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
-(void)resetInputs{
    [self hideErrorOnField:_errorField];
    _usernameField.text = @"";
    _passwordField.text = @"";
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _currentView = textField.superview;
    if(textField == _errorField){
        [self hideErrorOnField:textField];
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
    
    _errorMsg.hidden = YES;
    _logoPic.transform = CGAffineTransformMakeTranslation(0, -offset/3);
    _logoText.transform = CGAffineTransformMakeTranslation(0, -offset/3);
    _tagLine.transform = CGAffineTransformMakeTranslation(0, -offset/3);
    
    
}

-(void)keyboardWillHide:(NSNotification *)note{
    _keyboardActive = NO;
    _usernameField.superview.transform = CGAffineTransformIdentity;
    _passwordField.superview.transform = CGAffineTransformIdentity;
    _exitOrSubmit.transform =  CGAffineTransformIdentity;
    
    _errorMsg.hidden = NO;
    _logoPic.transform = CGAffineTransformIdentity;
    _logoText.transform = CGAffineTransformIdentity;
    _tagLine.transform = CGAffineTransformIdentity;
    
    if(![_usernameField.text isEqualToString:@""] && ![_passwordField.text isEqualToString:@""]){
        [_exitOrSubmit setTitle:@"submit" forState:UIControlStateNormal];
//        [self loginInstagram]; 
    }else{
        [_exitOrSubmit setTitle:@"exit" forState:UIControlStateNormal];
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
        // exit keyboard
        if(_keyboardActive){
            [_usernameField resignFirstResponder];
            [_passwordField resignFirstResponder];
            return;
        }

        // pop to root controller
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [_usernameField resignFirstResponder];
        [_passwordField resignFirstResponder];
        
        if(![_usernameField.text isEqualToString:@""] && ![_passwordField.text isEqualToString:@""]){
            // veirfy username/password, get token
            NSDictionary *login = [_apicommunicator loginUsername:_usernameField.text password:_passwordField.text];
        
            NSString *token = [login objectForKey:@"token"];
            if(token){
            
                // store token in keychain
                [JNKeychain saveValue:token forKey:@"AccessToken"];
            
                // grab user info
                [_apicommunicator registerDeviceToken];
                [_apicommunicator getUserInfo];
                [_apicommunicator fetchUserChats];
                [_apicommunicator getTrendingMomunts];
                [[MMNTContactsManager sharedInstance] updateContacts];
                
                // if have device token - register for this user
                NSString *deviceTokenString = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceTokenString"];
                if(deviceTokenString){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"fetchedDeviceToken"
                                                                        object:self
                                                                      userInfo:[NSDictionary dictionaryWithObject:deviceTokenString
                                                                                                           forKey:@"DeviceToken"]];
                }
            
                //transition to gallery
                MMNT_SignInController *parent = (MMNT_SignInController *)[self.navigationController parentViewController];
                [parent performSegueWithIdentifier:@"LoadingToGallery" sender:self];
            
            
            }else{
                NSLog(@"error logging in");
                [self setError:@"Can't remember your info?" onField:_passwordField];
                // [self showErrorPrompt];
                // [self performSelector:@selector(hideErrorPrompt) withObject:nil afterDelay:3.0];
            }

        }
    }
}

- (void)dismissKeyboard {
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];
}

/*
 Set error
 */
-(void)setError:(NSString *)errorMsg onField:(UITextField *)textField{
//    if(!_errorMsg.hidden){
//        return;
//    }
//    _errorMsg.alpha = 0.0;
    _errorMsg.hidden = NO;
    _errorMsg.titleLabel.text = errorMsg;
    
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
//                         _errorMsg.center = CGPointMake(_errorMsg.center.x, _errorMsg.center.y-40);
                         _errorMsg.titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         NSLog(@"here");
                     }];
    
    _errorField = textField;
    textField.textColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:1.0];
    UIImageView *icon = [textField.superview.subviews objectAtIndex:0];
    UIImage *redIcon = [MMNT_SharedVars tintImage:icon.image WithColor:[UIColor colorWithRed:1.0 green:0 blue:0 alpha:1.0]];
    icon.image = redIcon;
}
-(void)hideErrorOnField:(UITextField *)textField{
    
    // hide error prompt. Fade out
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _errorMsg.titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
                     }
                     completion:^(BOOL finished) {
//                            _errorMsg.alpha = 0.5;
//                         _errorMsg.hidden = YES;
//                         _errorMsg.center = CGPointMake(_errorMsg.center.x, _errorMsg.center.y+40);
                     }];
    
    _errorField = nil;
    textField.textColor = [UIColor whiteColor];
    UIImageView *icon = [textField.superview.subviews objectAtIndex:0];
    UIImage *redIcon = [MMNT_SharedVars tintImage:icon.image WithColor:[UIColor whiteColor]];
    icon.image = redIcon;
    
    
}

@end
