//
//  MMNT_VerificationVC.m
//  Momunt
//
//  Created by Masha Belyi on 9/22/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <Security/Security.h>
#import "JNKeychain.h"

#import "MMNT_VerificationVC.h"
#import "MMNT_SharedVars.h"

#import "MMNTApiCommuniator.h"
#import "MMNTApiCommunicatorDelegate.h"
#import "MMNTAccountManager.h"
#import "MMNT_HelpSlidesController.h"
#import "MMNT_SignInController.h"

@interface MMNT_VerificationVC () <MMNTApiCommunicatorDelegate>{
    MMNTApiCommuniator *_apicommunicator;
}
@property NSArray *animatedViews;
@property BOOL loadedView;
@property NSString *code;
@end

@implementation MMNT_VerificationVC

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
    // set up API communicator
    _apicommunicator = [[MMNTApiCommuniator alloc] init];
    _apicommunicator.delegate = self;
    
    // save original center coordinates
    self.originalCenter = self.view.center;
    
    // round profile image
    [self.profileImage.layer setCornerRadius:50];
    self.profileImage.clipsToBounds = YES;
    
    // insert phone number
    self.phonenumber.text = self.phoneStr;
    
//    // make X red
//    self.xImg.image = [ self.xImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    [ self.xImg setTintColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:1]];
//    self.xImg.transform = CGAffineTransformMakeScale(0, 0);
//    
    self.verificationCodeInput.delegate = self;
    
    _animatedViews = [[NSArray alloc] initWithObjects:_textlabel1, _phonenumber, _profileImage, _verificationCodeInput, nil];
    
    // listed for failed verification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(registrationFailed:)
                                                 name:@"registrationFailed"
                                               object:nil];
    
    // listen for when keyboard slides up
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [_profileImage setImage:_profilePic];
}
-(void)viewDidAppear:(BOOL)animated{
    // slide up keyboard
    [self.verificationCodeInput showKeyboard];
}
-(void)viewDidDisappear:(BOOL)animated{
    self.view.center = self.originalCenter;
}

-(void)keyboardWillShow:(NSNotification *)note{
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGFloat offset = kbSize.height+0;
    _exitOrSubmit.transform = CGAffineTransformMakeTranslation(0, -offset);
    
}

-(void)keyboardWillHide:(NSNotification *)note{
    _exitOrSubmit.transform = CGAffineTransformIdentity;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressedExitOrSubmit:(id)sender {
    NSString *action = _exitOrSubmit.currentTitle;
    if([action isEqualToString:@"exit"]){
        // pop to root controller
        [_apicommunicator cancelUserRegistration:[MMNTAccountManager sharedInstance].userId];
        
        _animatedViews = self.view.subviews;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [_exitOrSubmit setTitle:@"verifying your number..." forState:UIControlStateNormal];
        
        NSString *usrId = [NSString stringWithFormat:@"%i", [MMNTAccountManager sharedInstance].userId ];
        [_apicommunicator verifyNumber:self.phoneStrNospaces withCode:_code forUser: usrId ];
        
        // move to loading page - DEV TESTING
//        [self performSegueWithIdentifier:@"goToLoading" sender:self];
        
//        // transition to app
//        MMNT_SignInController *parent = (MMNT_SignInController *)[self.navigationController parentViewController];
//        [parent performSegueWithIdentifier:@"LoadingToGallery" sender:self];

    }
}

- (NSArray*)visibleCells{
//    return self.view.subviews;
    return self.animatedViews;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [super prepareForSegue:segue sender:sender];
    
    _animatedViews = self.animatedViews;
    
    
}



/*
 MMNTVerificationInputDelegate
 */
-(void)enteredCode:(NSString *)code{
    [_exitOrSubmit setTitle:@"submit" forState:UIControlStateNormal];
    _code = code;
}
-(void)changedCode:(NSString *)code{
    [_exitOrSubmit setTitle:@"exit" forState:UIControlStateNormal];
}

/*
 *  MMNTApiCommunicatorDelegate
 */
-(void)receivedAccessToken:(NSString *)token{
    NSLog(@"YAY! Got token: %@", token);
    
    // store token in keychain
    [JNKeychain saveValue:token forKey:@"AccessToken"];
        
    // grab user info
    [_apicommunicator getUserInfo];
    [_apicommunicator fetchUserChats];
    [_apicommunicator getTrendingMomunts];
    
    //transition to gallery
    MMNT_SignInController *parent = (MMNT_SignInController *)[self.navigationController parentViewController];
    [parent performSegueWithIdentifier:@"LoadingToGallery" sender:self];
    
    // move to loading page (map)
//    [self performSegueWithIdentifier:@"goToLoading" sender:self];
    
    // move to help page
//    [self performSegueWithIdentifier:@"goToHelp" sender:self];

    
}
-(void)failedVerificationWithMessage:(NSString *)message{
    [_exitOrSubmit setTitle:@"invalid code" forState:UIControlStateNormal];
    [_verificationCodeInput reset];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_exitOrSubmit setTitle:@"exit" forState:UIControlStateNormal];
    });
    
    NSLog(@"failed verification");
//    [[MMNT_SharedVars sharedVars] scaleUp:_xImg];
}

-(void) registrationFailed:(NSNotification*)notif {
    NSLog(@"registartion failed");
//    if(_loadedView){
//        [self returnToRegistration];
//    }
}


@end
