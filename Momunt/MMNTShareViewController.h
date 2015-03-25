//
//  MMNTShareViewController.h
//  Momunt
//
//  Created by Masha Belyi on 6/17/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import "MMNT_BlurContainer.h"

@interface MMNTShareViewController : UIViewController <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *storeBtn;
@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
@property (weak, nonatomic) IBOutlet UIButton *facebookBtn;
@property (weak, nonatomic) IBOutlet UIButton *twitterBtn;


@property UINavigationController *shareNavController;

@property MMNT_BlurContainer *blurContainer;
@property (strong, nonatomic) IBOutlet UIView *fakeLogoBar;
@property BOOL sharePile;

-(void)setBlurAlpha:(CGFloat)alpha;
//-(void)storeMomunt;

@end
