//
//  MMNT_VerifyPhoneNumberVC.m
//  Momunt
//
//  Created by Masha Belyi on 2/20/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import "MMNT_VerifyPhoneNumberVC.h"
#import "MMNT_SharedVars.h"
#import "MMNTApiCommuniator.h"
#import "MMNTAccountManager.h"
@interface MMNT_VerifyPhoneNumberVC ()
@property UITextField *errorField;
@end

@implementation MMNT_VerifyPhoneNumberVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _codeField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"verification code" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.45]}];
    _codeField.textColor = [UIColor whiteColor];
    _codeField.delegate = self;
    
    // listen for when keyboard slides up
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _animatedViews = self.view.subviews;
    
    _phoneLabel.text = self.phoneStr;
    
    _errorMsg.center = CGPointMake(_errorMsg.center.x, _errorMsg.center.y+40);
    _errorMsg.hidden = YES;
    

}
-(void)viewWillAppear:(BOOL)animated{
    [_codeField becomeFirstResponder];
}
- (NSArray*)visibleCells{
    //    return self.view.subviews;
    return self.animatedViews;
}
- (NSArray*)staticCells{
    return self.view.subviews;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _currentView = textField.superview;
    if(textField == _errorField){
        [self hideErrorOnField:textField];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(textField == _errorField){
        [self hideErrorOnField:textField];
    }
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    _currentView = textField.superview;
    if(newLength==4){
        [_exitOrSubmit setTitle:@"submit" forState:UIControlStateNormal];
        _exitOrSubmit.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
        _exitOrSubmit.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.24];
    }else{
        [_exitOrSubmit setTitle:@"Exit" forState:UIControlStateNormal];
        _exitOrSubmit.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
        _exitOrSubmit.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    }

    
    return (newLength > 4) ? NO : YES;
}

-(void)keyboardWillShow:(NSNotification *)note{
//    _keyboardActive = YES;
    
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGFloat offset = kbSize.height+3;
    CGFloat newY = self.view.frame.size.height-(kbSize.height+3)-123;
    CGFloat correction = newY - _currentView.frame.origin.y;
    
    _currentView.transform = CGAffineTransformTranslate(_currentView.transform, 0, correction);
    _exitOrSubmit.transform = CGAffineTransformMakeTranslation(0, -offset);
    _errorMsg.center = CGPointMake(_errorMsg.center.x, _phoneLabel.center.y+70);
    
    // may need to move the prompts
//    _prompt1.transform = CGAffineTransformMakeTranslation(0, -50);
    
    
}
-(void)keyboardWillHide:(NSNotification *)note{
    _codeField.superview.transform = CGAffineTransformIdentity;
    _exitOrSubmit.superview.transform =  CGAffineTransformIdentity;

//    if(![_phoneField.text isEqualToString:@""]){
//        [_exitOrSubmit setTitle:@"submit" forState:UIControlStateNormal];
//    }else{
//        [_exitOrSubmit setTitle:@"Exit" forState:UIControlStateNormal];
//    }
}



- (IBAction)pressedExitOrSubmit:(id)sender {
    NSString *action = _exitOrSubmit.currentTitle;
    if([action isEqualToString:@"Exit"]){
        
        // dissmiss parent nav controller
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }else if([action isEqualToString:@"submit"]){
        //        [self dismissKeyboard];
        
        if(_codeField.text.length==4){
            
            _exitOrSubmit.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
            _exitOrSubmit.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
            
            
            // submit phone number + code
            [[MMNTApiCommuniator sharedInstance] verifyNumber:_phoneStrNospaces withCode:_codeField.text completion:^(BOOL done) {
                if(!done){
                    [_exitOrSubmit setTitle:@"Exit" forState:UIControlStateNormal];
                    [self setError:@"Invalid code" onField:_codeField];
                }else{
                    [_exitOrSubmit setTitle:@"Verified!" forState:UIControlStateNormal];
                    [MMNTAccountManager sharedInstance].phone = _phoneStrNospaces;
                    //transition out
                    
                    // update user chats
                    [[MMNTApiCommuniator sharedInstance] fetchUserChats];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [_codeField resignFirstResponder];
                        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                    });
                    
                    
                }
            }];

        }
        
        
    }
}

#pragma mark - Validation
/*
 Set error
 */
-(void)setError:(NSString *)errorMsg onField:(UITextField *)textField{
    if(!_errorMsg.hidden){
        return;
    }
    _errorMsg.alpha = 0.0;
    _errorMsg.hidden = NO;
    _errorMsg.text = errorMsg;
    
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _errorMsg.center = CGPointMake(_errorMsg.center.x, _phoneLabel.center.y+30);
                         _errorMsg.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         NSLog(@"here");
                     }];
    
    _errorField = textField;
    textField.textColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:1.0];
//    UIImageView *icon = [textField.superview.subviews objectAtIndex:0];
//    UIImage *redIcon = [MMNT_SharedVars tintImage:icon.image WithColor:[UIColor colorWithRed:1.0 green:0 blue:0 alpha:1.0]];
//    icon.image = redIcon;
}
-(void)hideErrorOnField:(UITextField *)textField{
    
    // hide error prompt. Fade out
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _errorMsg.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         _errorMsg.hidden = YES;
                         _errorMsg.center = CGPointMake(_errorMsg.center.x, _errorMsg.center.y+40);
                     }];
    
    _errorField = nil;
    textField.textColor = [UIColor whiteColor];
//    UIImageView *icon = [textField.superview.subviews objectAtIndex:0];
//    UIImage *redIcon = [MMNT_SharedVars tintImage:icon.image WithColor:[UIColor whiteColor]];
//    icon.image = redIcon;
    
    
}
@end
