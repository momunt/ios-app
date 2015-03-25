//
//  MMNTCameraTransitioningManager.h
//  Momunt
//
//  Created by Masha Belyi on 9/6/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMNTViewController.h"
#import "MMNT_Camera.h"

//typedef NS_ENUM(NSInteger, MMNTTransitionOperation) {
//    Present,
//    Dismiss
//};

@class MMNTViewController;

@interface MMNTCameraTransitioningManager : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) MMNTViewController *mainController;
@property (nonatomic, strong) MMNT_Camera *modalController;
@property BOOL presenting;

@property UIPanGestureRecognizer *mainPanGesture;


@end
