//
//  MMNT_ForgotPassword.h
//  Momunt
//
//  Created by Masha Belyi on 11/29/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryPicker.h"

@interface MMNT_ForgotPassword : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *logoText;
@property (strong, nonatomic) IBOutlet UIImageView *logoPic;
@property (strong, nonatomic) IBOutlet UILabel *tagLine;
//@property (strong, nonatomic) IBOutlet UILabel *errorMsg;
@property (strong, nonatomic) IBOutlet UITextView *errorMsg;
@property (strong, nonatomic) IBOutlet UITextField *callCodeField;


@property (strong, nonatomic) IBOutlet UITextField *phoneField;

/*
 Country Picker
 */
@property (strong, nonatomic) IBOutlet UIButton *countryPickerBtn;
- (IBAction)pressedCountryPicker:(id)sender;
@property CountryPicker *countryPicker;
@property NSDictionary *dictCallCodes;


/*
 Exit-Submit buton
 */
@property (strong, nonatomic) IBOutlet UIButton *exitOrSubmit;
- (IBAction)pressedExitOrSubmit:(id)sender;

/*
 Contact Button
 */
@property (strong, nonatomic) IBOutlet UIButton *contactBtn;
- (IBAction)pressedContactBtn:(id)sender;



/*
 Methods
 */
@property UIView *currentView;
- (NSArray*)visibleCells; // used in wave transition
- (NSArray*)staticCells;
@property NSArray *animatedViews;


@end
