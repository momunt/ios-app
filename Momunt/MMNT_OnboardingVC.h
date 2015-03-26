//
//  MMNT_OnboardingVC.h
//  Momunt
//
//  Created by Masha Belyi on 3/25/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNTViewController.h"

@interface MMNT_OnboardingVC : UIViewController

// parameters
@property (nonatomic) int taskId;
@property (nonatomic) int step; //which onboarding step are we on
@property (nonatomic) NSString *tooltipText;
@property MMNTViewController *parent;

// tooltip text
@property (strong, nonatomic) IBOutlet UILabel *tooltip;

// buttons
@property (strong, nonatomic) IBOutlet UIButton *cameraBtn;
@property (strong, nonatomic) IBOutlet UIButton *menuBtn;
@property (strong, nonatomic) IBOutlet UIButton *momuntBtn;
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;

// arrow
@property (strong, nonatomic) IBOutlet UIImageView *arrow;

// actions
- (IBAction)pressedCameraBtn:(id)sender;
- (IBAction)pressedMenuBtn:(id)sender;
- (IBAction)pressedMomuntBtn:(id)sender;
- (IBAction)pressedShareBtn:(id)sender;

-(void)show; // present this view

// transition
@property (nonatomic) NSString *transitionOperation;



@end
