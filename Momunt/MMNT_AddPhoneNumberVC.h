//
//  MMNT_AddPhoneNumberVC.h
//  Momunt
//
//  Created by Masha Belyi on 2/20/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryPicker.h"

@interface MMNT_AddPhoneNumberVC : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *prompt1;
@property (strong, nonatomic) IBOutlet UITextView *prompt2;
@property (strong, nonatomic) IBOutlet UITextView *termsText;
@property (strong, nonatomic) IBOutlet UILabel *errorMsg;

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
 Exit/Submit Button
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
