//
//  MMNT_ShareView_Transition.m
//  Momunt
//
//  Created by Masha Belyi on 7/22/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_ShareView_Transition.h"
#import "MMNT_ShareButtons.h"
#import "MMNTViewController.h"

@implementation MMNT_ShareView_Transition

#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)

#define DURATION    0.65
#define MAX_DELAY   0.15
#define CELL_OFFSET -300

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _duration = DURATION;
    _maxDelay = MAX_DELAY;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return self.duration + self.maxDelay;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.presenting) {
        // Grab the from and to view controllers from the context
        MMNTViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        MMNT_ShareButtons *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        [fromVC captureBlur];
        
        
        CGRect source = [transitionContext initialFrameForViewController:fromVC];
        toVC.view.frame = source;
        
        [transitionContext.containerView addSubview:toVC.view];
        
        // start positions
        toVC.storeBtn.transform = CGAffineTransformMakeTranslation(0,-20);
        toVC.storeBtn.alpha = 0;
        toVC.messageBtn.transform = CGAffineTransformMakeTranslation(0,-30);
        toVC.messageBtn.alpha = 0;
        toVC.facebookBtn.transform = CGAffineTransformMakeTranslation(0,-35);
        toVC.facebookBtn.alpha = 0;
        toVC.twitterBtn.transform = CGAffineTransformMakeTranslation(0,-40);
        toVC.twitterBtn.alpha = 0;
        
         // animate!
        [UIView animateWithDuration: 0.3
                              delay: 0.2
                            options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                         animations:^{
                             toVC.storeBtn.transform = CGAffineTransformIdentity;
                             toVC.storeBtn.alpha = 1.0f;}
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                             
                         }
         ];
        [UIView animateWithDuration: 0.3
                              delay: 0.2
                            options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                         animations:^{
                             toVC.messageBtn.transform = CGAffineTransformIdentity;
                             toVC.messageBtn.alpha = 1.0f;}
                        completion:nil
         ];
        [UIView animateWithDuration: 0.3
                              delay: 0.1
                            options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                         animations:^{
                             toVC.facebookBtn.transform = CGAffineTransformIdentity;
                             toVC.facebookBtn.alpha = 1.0f;}
                         completion:nil
         ];
        [UIView animateWithDuration: 0.3
                              delay: 0
                            options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                         animations:^{
                             toVC.twitterBtn.transform = CGAffineTransformIdentity;
                             toVC.twitterBtn.alpha = 1.0f;}
                         completion:nil
         ];
        
        
    }else{
        // Return
        // Grab the from and to view controllers from the context
        MMNT_ShareButtons *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        MMNTViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        [toVC unBlur];
        
        
        //CGRect source = [transitionContext initialFrameForViewController:fromVC];
//        toVC.view.frame = source;
        
//        [transitionContext.containerView addSubview:fromVC.view];
//        [transitionContext.containerView addSubview:toVC.view];
        
//        // start positions
//        fromVC.storeBtn.transform = CGAffineTransformMakeTranslation(0,-20);
//        fromVC.storeBtn.alpha = 0;
//        fromVC.messageBtn.transform = CGAffineTransformMakeTranslation(0,-30);
//        fromVC.messageBtn.alpha = 0;
//        fromVC.facebookBtn.transform = CGAffineTransformMakeTranslation(0,-35);
//        fromVC.facebookBtn.alpha = 0;
//        fromVC.twitterBtn.transform = CGAffineTransformMakeTranslation(0,-40);
//        fromVC.twitterBtn.alpha = 0;
        
        // animate!
        [UIView animateWithDuration: 0.3
                              delay: 0
                            options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                         animations:^{
                             fromVC.storeBtn.transform = CGAffineTransformMakeTranslation(0,-20);
                             fromVC.storeBtn.alpha = 0.0f;}
         
                         completion:nil
         ];
        [UIView animateWithDuration: 0.3
                              delay: 0.1
                            options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                         animations:^{
                             fromVC.messageBtn.transform = CGAffineTransformMakeTranslation(0,-30);
                             fromVC.messageBtn.alpha = 0.0f;}
                         completion:nil
         ];
        [UIView animateWithDuration: 0.3
                              delay: 0.2
                            options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                         animations:^{
                             fromVC.facebookBtn.transform = CGAffineTransformMakeTranslation(0,-35);
                             fromVC.facebookBtn.alpha = 0.0f;}
                         completion:nil
         ];
        [UIView animateWithDuration: 0.3
                              delay: 0.2
                            options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                         animations:^{
                             fromVC.twitterBtn.transform = CGAffineTransformMakeTranslation(0,-40);
                             fromVC.twitterBtn.alpha = 0.0f;}
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                             
                         }
         ];
        

    }
    
}

@end
