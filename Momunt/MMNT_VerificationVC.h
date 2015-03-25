//
//  MMNT_VerificationVC.h
//  Momunt
//
//  Created by Masha Belyi on 9/22/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNT_VerificationInputView.h"

@interface MMNT_VerificationVC : UIViewController <MMNTVerificationInputDelegate>

@property (strong, nonatomic) IBOutlet MMNT_VerificationInputView *verificationCodeInput;

@property (strong, nonatomic) IBOutlet UILabel *textlabel1;
@property (strong, nonatomic) IBOutlet UILabel *phonenumber;
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property NSString *userId;
@property NSString *phoneStr;
@property NSString *phoneStrNospaces;
@property BOOL registrationFailed;

@property UIImage *profilePic;
@property CGPoint originalCenter;

@property (strong, nonatomic) IBOutlet UIButton *exitOrSubmit;
- (IBAction)pressedExitOrSubmit:(id)sender;


- (NSArray*)visibleCells;

-(void)returnToRegistration;

@end
