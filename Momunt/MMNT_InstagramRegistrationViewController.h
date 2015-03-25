//
//  MMNT_InstagramRegistrationViewController.h
//  Momunt
//
//  Created by Masha Belyi on 1/20/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryPicker.h"

@interface MMNT_InstagramRegistrationViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *phoneField;
@property (strong, nonatomic) IBOutlet UIButton *exitOrSubmit;
@property (strong, nonatomic) IBOutlet UIImageView *profile;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) IBOutlet UILabel *errorMsg;
@property (strong, nonatomic) IBOutlet UITextView *termsText;
@property (strong, nonatomic) IBOutlet UITextField *callCodeField;

@property (strong, nonatomic) UIImage *profileImg;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *token;

@property UIView *currentView;

/* COUNTRY PICKER */
@property (strong, nonatomic) IBOutlet UIButton *countryPickerBtn;
- (IBAction)pressedCountryPicker:(id)sender;
@property CountryPicker *countryPicker;
@property NSDictionary *dictCallCodes;

- (IBAction)presedExitOrSubmit:(id)sender;

- (NSArray*)visibleCells; // used in wave transition
@property NSArray *animatedViews;
- (NSArray*)staticCells;

@end
