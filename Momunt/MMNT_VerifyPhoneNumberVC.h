//
//  MMNT_VerifyPhoneNumberVC.h
//  Momunt
//
//  Created by Masha Belyi on 2/20/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 Views
 */
@interface MMNT_VerifyPhoneNumberVC : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *prompt1;
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;
@property (strong, nonatomic) IBOutlet UITextField *codeField;
@property (strong, nonatomic) IBOutlet UILabel *errorMsg;

/*
 Properties
 */
@property NSString *phoneStr;
@property NSString *phoneStrNospaces;

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
