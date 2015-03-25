//
//  MMNT_InstagramSignInViewController.h
//  Momunt
//
//  Created by Masha Belyi on 1/19/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNT_SlideUpTransition.h"

@interface MMNT_InstagramSignInViewController : UIViewController <UIViewControllerTransitioningDelegate>

@property NSString *type;

@property UIWebView *webView;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIButton *exitOrSubmit;
- (IBAction)pressedExitOrSubmit:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *usernamePic;
@property (strong, nonatomic) IBOutlet UIImageView *passwordPic;
@property (strong, nonatomic) IBOutlet UIImageView *instgramPng;

@property UIView *currentView;

- (NSArray*)visibleCells; // used in wave transition
@property NSArray *animatedViews;
- (NSArray*)staticCells;

@end
