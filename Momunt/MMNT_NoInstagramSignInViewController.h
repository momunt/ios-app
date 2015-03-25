//
//  MMNT_NoInstagramSignInViewController.h
//  Momunt
//
//  Created by Masha Belyi on 1/20/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryPicker.h"

@interface MMNT_NoInstagramSignInViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *prompt;
@property (strong, nonatomic) IBOutlet UILabel *errorMsg;
@property (strong, nonatomic) IBOutlet UITextView *termsText;
@property (strong, nonatomic) IBOutlet UIButton *cameraButton;
- (IBAction)pressedUploadPhoto:(id)sender;



/*
 User Info
 */
@property (strong, nonatomic) IBOutlet UIImageView *profile;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *phoneField;
@property (strong, nonatomic) IBOutlet UITextField *callCodeField;

/* 
 Country Picker
 */
@property (strong, nonatomic) IBOutlet UIButton *countryPickerBtn;
- (IBAction)pressedCountryPicker:(id)sender;
@property CountryPicker *countryPicker;
@property NSDictionary *dictCallCodes;

/*
 exit,submit
 */
@property (strong, nonatomic) IBOutlet UIButton *exitOrSubmit;
- (IBAction)pressedExitOrSubmit:(id)sender;

/*
 Methods
 */
@property UIView *currentView;
- (NSArray*)visibleCells; // used in wave transition
- (NSArray*)staticCells;
@property NSArray *animatedViews;

@end
