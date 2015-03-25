//
//  MMNT_Password_ViewController.h
//  Momunt
//
//  Created by Masha Belyi on 7/22/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_NavigationChild_ViewController.h"
#import "MMNT_checkButton.h"

@interface MMNT_Password_ViewController : MMNT_NavigationChild_ViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *oldPass;
@property (strong, nonatomic) IBOutlet UITextField *pass1;
@property (strong, nonatomic) IBOutlet UITextField *pass2;
@property (strong, nonatomic) IBOutlet UIButton *submitBtn;
@property CGPoint originalCenter;

- (IBAction)pressedSubmit:(id)sender;

@end
