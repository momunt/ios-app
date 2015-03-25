//
//  MMNT_SignInFront.h
//  Momunt
//
//  Created by Masha Belyi on 9/23/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMNT_SignInFront : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *btn1;
@property (strong, nonatomic) IBOutlet UIButton *btn2;
@property (strong, nonatomic) IBOutlet UIImageView *launchPic;
@property (strong, nonatomic) IBOutlet UIView *dotsContainer;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *darkOverlay;


@property NSArray *animatedSubViews;
@property NSArray *animatedViews;
- (NSArray*)visibleCells;

@end
