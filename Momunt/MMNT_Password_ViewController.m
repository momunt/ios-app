//
//  MMNT_Password_ViewController.m
//  Momunt
//
//  Created by Masha Belyi on 7/22/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_Password_ViewController.h"
#import "MMNTSettingsController.h"
#import "MMNT_RowSelection_Transition.h"
#import "MMNTDataController.h"
#import "MMNT_SharedVars.h"
#import "JNKeychain.h"

@interface MMNT_Password_ViewController ()

@property BOOL error;
@property NSString *errorStr;
@property NSInteger currentCell;

@end

@implementation MMNT_Password_ViewController
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.popToController = [MMNTSettingsController class];
    
    _oldPass.delegate = self;
    _pass1.delegate = self;
    _pass2.delegate = self;
    
    [_submitBtn setAlpha:0.0f];
    
    
    
    // listen for shen keyboard slide up
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
//    _submitBtn.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
    _originalCenter= self.tableView.center;
}
-(void)viewDidAppear:(BOOL)animated{
    _submitBtn.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
    [_submitBtn setAlpha:1.0f];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(textField==_oldPass){
        _currentCell = 1;
    }else if(textField == _pass1){
        _currentCell = 2;
    }else if(textField == _pass2){
        _currentCell = 3;
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    _error = NO;
    
    if(textField == _pass1 && [textField.text length]){
//        if(![self validatePassword:textField.text]){
//            _error = YES;
//            [self setError:_errorStr onInput:textField];
//        }else{
            [self setAcceptedInput:textField withPlaceholder:@"new password"];
//        }
    }
    
    else if(textField == _pass2 && [textField.text length] ){
        if([_pass1.text length] && ![textField.text isEqualToString:_pass1.text] ){
            _error = YES;
            _errorStr = @"passwords must match";
            [self setError:_errorStr onInput:textField];
        }
//        else if (![self validatePassword:textField.text]){
//            _error = YES;
//            [self setError:_errorStr onInput:textField];
//        }
        else{
            [self setAcceptedInput:textField withPlaceholder:@"repeat new password"];
        }
    }

    
    // if no error and all fields are filled out -> show submit button
    if(!_error && [_oldPass.text length] && [_pass1.text length] && [_pass2.text length] ){
        [[MMNT_SharedVars sharedVars] scaleUp:_submitBtn];
    }else{
        [[MMNT_SharedVars sharedVars] scaleDown:_submitBtn];
    }
    

}

-(void)keyboardWillShow:(NSNotification *)note{
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UITableViewCell *bottomCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]]; // 4th cell - last cell with text input
    CGFloat overlap = (80+bottomCell.center.y+bottomCell.frame.size.height/2) -(SCREEN_HEIGHT-kbSize.height); // 80=height of top nav bar.
    
    if(overlap > bottomCell.frame.size.height){
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:_currentCell inSection:0]]; // current cell youa re editing
        overlap = (80+cell.center.y+cell.frame.size.height/2) -(SCREEN_HEIGHT-kbSize.height); // 80=height of top nav bar.
    }
    
    if(overlap>0){
        [self.tableView setCenter:CGPointMake(self.originalCenter.x, self.originalCenter.y-overlap-20)];
        NSLog(@"moved");
    }
    
    
}
-(void)keyboardWillHide:(NSNotification *)note{
    [self.tableView setCenter:self.originalCenter];
}


- (IBAction)pressedSubmit:(id)sender {
    [[MMNT_SharedVars sharedVars] scaleUp:_submitBtn];
    
    if(![_pass1.text isEqualToString:_pass2.text]){
        _error = YES;
        _errorStr = @"passwords must match";
        [self setError:_errorStr onInput:_pass2];
        return;
    }
//    NSString *newToken = [[MMNTDataController sharedInstance] resetPasswordFrom:_oldPass.text to:_pass2.text];
    [[MMNTApiCommuniator sharedInstance] resetPasswordFrom:_oldPass.text to:_pass2.text completion:^(NSString *newToken) {
 
        if(!newToken){
            //error - wrong old pwd
            _error = YES;
            _errorStr = @"password does not match our records";
            [self setError:_errorStr onInput:_oldPass];
        }else{
            // store token in keychain
            [JNKeychain saveValue:newToken forKey:@"AccessToken"];
        
            // confirmation alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Reset"
                                                        message:@"Your password was reset."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
            [alert show];

        
            // reset all text inputs?
            [self resetInput:_oldPass withPlaceholder:@"old password"];
            [self resetInput:_pass1 withPlaceholder:@"new password"];
            [self resetInput:_pass2 withPlaceholder:@"repeat password"];
        
            [[MMNT_SharedVars sharedVars] scaleDown:_submitBtn];

        }
    }];
}

/*
 Validate Password
 5-20 chars
 at least one Capital letter
 at least one number
 */
- (BOOL)validatePassword:(NSString *)str {
    if(str.length<5 || str.length>20){
        _errorStr = @"password: 5-20 characters";
        return false;
    }
    NSString *Regex = @"^(?=.*[A-Z])(?=.*[0-9]).{5,20}$";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
    _errorStr = @"password: 1 caps and 1 number";
    return [test evaluateWithObject:str];
}

-(void)setError:(NSString *)errorStr onInput:(UITextField *)input{
    [[MMNT_SharedVars sharedVars] scaleDown:_submitBtn];
    input.placeholder = errorStr;
    input.text = @"";
}

-(void)setAcceptedInput:(UITextField *)input withPlaceholder:(NSString *)placeholder{
    input.placeholder = placeholder;
}
-(void)resetInput:(UITextField *)input withPlaceholder:(NSString *)placeholder{
    input.placeholder = placeholder;
    input.text = @"";
}


@end
