//
//  MMNT_AskPhoneNumberVC.h
//  Momunt
//
//  Created by Masha Belyi on 2/20/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMNT_AskPhoneNumberVC : UIViewController <UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *backgroundBlur;
@property UINavigationController *navVC;
@property NSString *type;
@end
