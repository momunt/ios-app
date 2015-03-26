//
//  MMNT_DropDownView.h
//  Momunt
//
//  Created by Masha Belyi on 8/6/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNTNavigationController.h"
#import "MMNTObj.h"

@class MMNT_DropDownView;

@protocol DropDownViewDelegate

-(void)dropDownView:(MMNT_DropDownView *)view draggingEndedWithVelocity:(CGPoint)velocity withTouchLocation:(CGPoint)location;
-(void)dropDownViewBeganDragging:(MMNT_DropDownView *)view;
-(void)dropDownViewTapped:(MMNT_DropDownView *)view;
-(void)dropDownView:(MMNT_DropDownView *)view dragggingWithPercentage:(CGFloat)percentage;
-(void)dropDownView:(MMNT_DropDownView *)view selectedMomunt:(MMNTObj *)mmnt;

@end


@interface MMNT_DropDownView : UIView <UIGestureRecognizerDelegate>{
    MMNT_NavBar_View *_navBar;
}

@property (strong, nonatomic) MMNTNavigationController *navigationController;
@property (strong, nonatomic) UIView *bottomBar;
@property (strong, nonatomic) UIView *spacerBar;
@property (strong, nonatomic) UIImageView *logo;
@property (strong, nonatomic) UILabel *exit;

@property (nonatomic, weak) id<DropDownViewDelegate> delegate;
-(void) setup;
@property CGPoint startCenter;

@end
