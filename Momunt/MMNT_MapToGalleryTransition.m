//
//  MMNT_MapToGalleryTransition.m
//  Momunt
//
//  Created by Masha Belyi on 12/16/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_MapToGalleryTransition.h"
#import "MMNTViewController.h"
#import "MMNT_SignInController.h"
#import "MMNTAccountManager.h"

@implementation MMNT_MapToGalleryTransition

+ (instancetype)transitionWithOperation:(NSString *)operation{
    return [[self alloc] initWithOperation1:operation];
}

- (instancetype)initWithOperation1:(NSString *)operation{
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
    MMNT_SignInController *fromVC = (MMNT_SignInController *)([transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey]);
    MMNTViewController *toVC = (MMNTViewController *)([transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]);
    
    
    if ([_operation  isEqual: @"present"]) {
        CGRect source = [transitionContext initialFrameForViewController:fromVC];

        // set up toVC
        toVC.view.frame = source;
//        toVC.dropDownView.transform = CGAffineTransformMakeTranslation(0, -80);
        toVC.dropDownView.center =  CGPointMake(source.size.width/2, -source.size.height/2);
        toVC.dropDownView.backgroundColor = [UIColor whiteColor];
        toVC.collectionView.backgroundColor = [UIColor clearColor];
        
//        toVC.mapBackgroundView.frame = CGRectMake(0,70,source.size.width, source.size.height-70);
//        toVC.mapImageView.frame = CGRectMake(0,-70,source.size.width, source.size.height);
//        toVC.mapImageView.image = fromVC.blurredMap;
//        toVC.mapWhiteOverlay.alpha = 0.0;
//        toVC.mapPrompt.alpha = 0.0;
//        
//        toVC.arrowView.frame = CGRectMake(0,0,35,70);
//        toVC.arrowView.contentMode = UIViewContentModeScaleAspectFit;
//        toVC.arrowView.center = CGPointMake(source.size.width/2, source.size.height*0.5);
//        toVC.arrowView.alpha = 0.0;
//        
//        if( [[MMNTAccountManager sharedInstance] isTaskDone:8] ){
//            toVC.mapPrompt.selectable = YES;
//            [toVC.mapPrompt setText: @"the photos around you."];
//            toVC.mapPrompt.selectable = NO;
//            toVC.arrowView.hidden = YES;
//        }
        
        [transitionContext.containerView addSubview:toVC.view];
        
        // slide down logo bar and fade in white overlay
        [UIView animateWithDuration:0.5
                         animations:^{
//                             toVC.dropDownView.transform = CGAffineTransformIdentity;
                             toVC.dropDownView.center =  CGPointMake(source.size.width/2, 70-source.size.height/2);
//                             toVC.mapWhiteOverlay.alpha = 0.4;
//                             toVC.mapPrompt.alpha = 1.0;
//                             toVC.arrowView.alpha = 1.0;
                         } completion:^(BOOL finished) {
                            [transitionContext completeTransition:YES];
                         }];
        
        
    }else{
    }
}



@end
