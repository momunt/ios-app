//
//  MMNT_SlideUpTransition.m
//  Momunt
//
//  Created by Masha Belyi on 2/2/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import "MMNT_SlideUpTransition.h"
#import "MMNTViewController.h"

@implementation MMNT_SlideUpTransition

//+ (instancetype)transitionWithOperation:(NSString *)operation{
//    return [[self alloc] initWithOperation:operation];
//}

- (instancetype)initWithOperation:(NSString *)operation{
    self = [super init];
    if (self) {
        _operation = operation;
    }
    return self;
}
- (instancetype)initWithOperation:(NSString *)operation andFrame:(CGRect)frame{
    self = [super init];
    if (self) {
        _operation = operation;
        _type = @"partial";
        _myFrame = frame;
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
        toVC.view.frame = [_type isEqualToString:@"partial"] ? _myFrame : source;
        [transitionContext.containerView insertSubview:toVC.view atIndex:0];
        
        toVC.view.transform = CGAffineTransformMakeTranslation(0, source.size.height);
        
        if([toVC.restorationIdentifier isEqualToString:@"instagramSignIn"] && [fromVC.restorationIdentifier isEqualToString:@"Gallery"]){
            // insert blur img
            MMNTViewController *mainVC = (MMNTViewController*)([transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey]);
            UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,source.size.width, source.size.height)];
            [mainVC captureBlurToImageView:imgV];
            [toVC.view insertSubview:imgV atIndex:0];
        }

        
        // slide up toVC
        [UIView animateWithDuration:0.5
                         animations:^{
                             toVC.view.transform = CGAffineTransformIdentity;
                         } completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];
        
        
    }else{
        CGRect source = [transitionContext initialFrameForViewController:fromVC];
        toVC.view.frame = source;
//        [transitionContext.containerView insertSubview:toVC.view atIndex:0];
        
//        toVC.view.transform = CGAffineTransformMakeTranslation(0, source.size.height);
        
        // slide down fromVC
        [UIView animateWithDuration:0.5
                         animations:^{
                             fromVC.view.transform =  CGAffineTransformMakeTranslation(0, source.size.height);
                         } completion:^(BOOL finished) {
                             if([fromVC.restorationIdentifier isEqualToString:@"instagramSignIn"]){
                                 // remove blur img
                                 [[fromVC.view.subviews objectAtIndex:0] removeFromSuperview];
                             }
                             [transitionContext completeTransition:YES];
                         }];

    }
}

@end
