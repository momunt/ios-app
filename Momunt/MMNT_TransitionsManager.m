//
//  MMNT_TransitionsManager.m
//  Momunt
//
//  Created by Masha Belyi on 9/5/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_TransitionsManager.h"
#import "POPSpringAnimation.h"
#import "POPBasicAnimation.h"

@implementation MMNT_TransitionsManager

+ (instancetype)transitionWithOperation:(UINavigationControllerOperation)operation{
    return [[self alloc] initWithOperation:operation andType:MMNTTransitionScaleInOut];
}

+ (instancetype)transitionWithOperation:(UINavigationControllerOperation)operation andTransitionType:(MMNTScaleTransitionType)type{
    return [[self alloc] initWithOperation:operation andType:type];
}


- (instancetype)initWithOperation:(UINavigationControllerOperation)operation andType:(MMNTScaleTransitionType)type{
    self = [super init];
    if (self) {
        _duration = 0.4;
        _maxDelay = 0.2;
        _operation = operation;
        _transitionType = type;
    }
    
    
    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return self.duration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = (UIViewController *)([transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey]);
    UIViewController *toVC = (UIViewController *)([transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]);
    
    CGRect source = [transitionContext initialFrameForViewController:fromVC];
    [[transitionContext containerView] addSubview:toVC.view];
    
    // scale = 0 for all subviews of toVC
    if(_transitionType==MMNTTransitionScaleInOut){
        [toVC.view.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
            [obj layoutSubviews]; // force layour before scaling. Important for custom buttons - centering and sizing images
            obj.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
        }];
    }
    // Move the destination in place
    toVC.view.frame = source;
    
    // move destination down off-screen
    if(_transitionType==MMNTTransitionFadeOutSlideUp){
        toVC.view.transform = CGAffineTransformMakeTranslation(0, source.size.height);
    }
    
    // Plain animation. Once it's done it will notify the transition context
    //    [toVC.view setTransform:CGAffineTransformMakeTranslation(1, 0)];
    [toVC.view setAlpha:0.999];
    [UIView animateWithDuration:self.duration + self.maxDelay*(_transitionType==MMNTTransitionScaleOutSlideUp ? 2:1) delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [toVC.view setAlpha:1];
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
    
    if(_transitionType==MMNTTransitionScaleInOut){
        [self scaleDown:fromVC.view withMinDelay:0];
        [self scaleUp:toVC.view withMinDelay:self.duration/2];
    }else if(_transitionType==MMNTTransitionFadeOutSlideUp){
        
        [self fadeOutView:fromVC.view withDuration:self.duration/2 withDelay:0];
        [self slideUpView:toVC.view withDuration:self.duration/2+self.maxDelay withDelay:self.duration/2];
    }
    
    
}

-(void)scaleDown:(UIView *)view withMinDelay:(NSTimeInterval)mindelay{
    [view.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        NSTimeInterval delay = mindelay + ((float)idx / (float)[view.subviews count]) * self.maxDelay;
        [self scaleDownView:obj withDelay:delay];
    }];
}

-(void)scaleUp:(UIView *)view withMinDelay:(NSTimeInterval)mindelay{
//    [view.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
//        NSTimeInterval delay = mindelay + ((float)idx / (float)[view.subviews count]) * self.maxDelay;
//        [self scaleUpView:obj withDelay:delay];
//    }];
    [view.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        NSTimeInterval delay = mindelay + ((float)idx / (float)[view.subviews count]) * self.maxDelay;
        [self scaleUpView:obj withDelay:delay];
    }];

}

- (void)scaleDownView:(UIView *)view withDelay:(NSTimeInterval)delay
{
    POPBasicAnimation *scaleDown = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleDown.toValue = [NSValue valueWithCGPoint: CGPointMake(0,0)] ;
    scaleDown.beginTime = (CACurrentMediaTime() + delay);
    scaleDown.duration = self.duration/2;
    [view pop_addAnimation:scaleDown forKey:@"scale"];
}

- (void)scaleUpView:(UIView *)view withDelay:(NSTimeInterval)delay
{
    POPSpringAnimation *scaleUp = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleUp.toValue = [NSValue valueWithCGPoint: CGPointMake(1, 1)] ;
    scaleUp.springBounciness = 15;
    scaleUp.springSpeed = 15;
    scaleUp.beginTime = (CACurrentMediaTime() + delay);
    [view pop_addAnimation:scaleUp forKey:@"scale"];
}

-(void)fadeOutView:(UIView *)view withDuration:(NSTimeInterval)duration withDelay:(NSTimeInterval)delay{
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [view setAlpha:0];
                     }
                     completion:^(BOOL finished) {
                     }
     ];
}

-(void)slideUpView:(UIView *)view withDuration:(NSTimeInterval)duration withDelay:(NSTimeInterval)delay{
    [UIView animateWithDuration:duration
                          delay:delay
         usingSpringWithDamping:0.7
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         view.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                     }
     ];
}


@end
