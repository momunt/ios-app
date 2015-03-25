//
//  MMNTShareTransitionManager.h
//  Momunt
//
//  Created by Masha Belyi on 8/14/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MMNTViewController.h"
#import "MMNTShareViewController.h"
#import "MMNT_BlurContainer.h"
#import "MMNT_DropDownView.h"


//typedef NS_ENUM(NSInteger, MMNTShareTransitionType) {
//    MMNTShareButtonsTransition,
//    MMNTShareScaleTransition,
//    MMNTShareContactsTransition,
//};
typedef NS_ENUM(NSInteger, MMNTTransitionOperation) {
    Present,
    Dismiss
};


@protocol MMNTShareTransitioning <NSObject>

@property UINavigationController *shareNavController;
@property MMNT_BlurContainer *blurContainer;

-(void)captureBlurToImageView:(UIImageView *)view;
-(void)setBlurAlpha:(CGFloat)alpha;
-(void)exitingFromShareView;

@property NSMutableArray *toShare;
@property NSMutableArray *photosToShare;
@property (strong, nonatomic) IBOutlet MMNT_DropDownView *dropDownView;

@end

@class MMNTViewController;

@interface MMNTShareTransitionManager : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate>

+ (instancetype)transitionWithOperation:(MMNTTransitionOperation)operation;
- (instancetype)initWithOperation:(MMNTTransitionOperation)operation;

@property (nonatomic, strong) MMNTViewController *mainController;
@property UIPanGestureRecognizer *mainPanGesture;
@property (nonatomic, strong) MMNTShareViewController *modalController;
@property (assign, nonatomic) BOOL presenting;
@property BOOL swipedToDissmiss;

@property (assign, nonatomic) MMNTTransitionOperation operation;
//@property (assign, nonatomic) MMNTShareTransitionType transitionType;
@property (assign, nonatomic) CGFloat tduration;
@property (assign, nonatomic) CGFloat maxDelay;

@end
