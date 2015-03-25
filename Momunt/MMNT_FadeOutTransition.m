//
//  MMNT_FadeOutTransition.m
//  Momunt
//
//  Created by Masha Belyi on 9/25/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_FadeOutTransition.h"

@implementation MMNT_FadeOutTransition

+ (instancetype)transitionWithOperation:(NSString *)operation{
    return [[self alloc] initWithOperation:operation];
}

- (instancetype)initWithOperation:(NSString *)operation{
    self = [super init];
    if (self) {
        _operation = operation;
    }
    return self;
}



- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC;
    fromVC = (UIViewController*)([transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey]);
    
    UIViewController *toVC;
    toVC = (UIViewController*)([transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]);
    
    
    if ([_operation  isEqual: @"present"]) {
        CGRect source = [transitionContext initialFrameForViewController:fromVC];
        toVC.view.frame = source;
        [transitionContext.containerView insertSubview:toVC.view atIndex:0];
//        [transitionContext.containerView addSubview:toVC.view];
 
        // fade out FROM VC
        [UIView animateWithDuration:0.5
                         animations:^{
                             [fromVC.view setAlpha:0.0];
                         } completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];
        
        
    }else{
    }
}



@end
