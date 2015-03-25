//
//  MMNT_SignIn.h
//  Momunt
//
//  Created by Masha Belyi on 1/21/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMNT_SignIn : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *logoPic;
@property (strong, nonatomic) IBOutlet UILabel *logoText;
@property (strong, nonatomic) IBOutlet UILabel *tagLine;
@property (strong, nonatomic) IBOutlet UIButton *errorMsg;


@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@property (strong, nonatomic) IBOutlet UIButton *exitOrSubmit;
- (IBAction)pressedExitOrSubmit:(id)sender;

/*
 */
@property UIView *currentView;
- (NSArray*)visibleCells; // used in wave transition
- (NSArray*)staticCells; // used in wave transition
@property NSArray *animatedViews;
-(void)resetInputs;

@end
