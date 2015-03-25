//
//  MMNTShareTransitionManager.m
//  Momunt
//
//  Pop in transition of share buttons from gallery. This is unnecessarily messe becuase I tried to make this an interactive transition.
//
//
//  Created by Masha Belyi on 8/14/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MMNTShareTransitionManager.h"
#import "MMNTViewController.h"
#import "MMNTShareViewController.h"
#import "MMNT_ShareButtons.h"


#import "MMNT_ShareButtons.h"
#import "MMNT_ShareName.h"

#import "POPSpringAnimation.h"
#import "POPBasicAnimation.h"

@implementation MMNTShareTransitionManager

#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)

+ (instancetype)transitionWithOperation:(MMNTTransitionOperation)operation{
    return [[self alloc] initWithOperation:operation];
}

- (instancetype)initWithOperation:(MMNTTransitionOperation)operation{
    self = [super init];
    if (self) {
        _tduration = 0.3;
        _maxDelay = 0.2;
        _operation = operation;
    }
    return self;
}


- (void)setMainController:(MMNTViewController *)mainController{
    
    _mainController = mainController;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didPanMainController:)];
    panGesture.delegate = self;
    self.mainPanGesture = panGesture;
    
//    [self.mainController.collectionView addGestureRecognizer:panGesture];
    
    
}

-(void)setModalController:(MMNTShareViewController *)modalController{
    _modalController = modalController;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didPanModalController:)];
    panGesture.delegate = _modalController;
    
    
    
//    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapModalController:)];
//    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
////    singleTapGestureRecognizer.delegate = self;
//    [panGesture requireGestureRecognizerToFail:singleTapGestureRecognizer];
    
//    [self.modalController.view addGestureRecognizer:singleTapGestureRecognizer];
    [self.modalController.view addGestureRecognizer:panGesture];

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isEqual:self.mainPanGesture] && [otherGestureRecognizer isEqual:self.mainController.panRight]){
        return YES;
    }
    return NO;
}
// only fire horizontal pan
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isEqual:self.mainPanGesture]) {
        if (gestureRecognizer.numberOfTouches > 0) {
            CGPoint translation = [self.mainPanGesture velocityInView:self.mainController.collectionView];
            return fabs(translation.y) < fabs(translation.x);
        } else {
            return NO;
        }
    }
    return YES;
}

// pan gesture right to left
//-(void)didPanMainController:(UIScreenEdgePanGestureRecognizer*)recognizer{
//    
//    CGPoint translation = [recognizer translationInView:[self.mainController.view window]];
//    CGPoint location = [recognizer locationInView:[self.mainController.view window]];
//    CGPoint velocity = [recognizer velocityInView:[self.mainController.view window]];
//    
//    BOOL horizontal = ABS(velocity.x) > ABS(velocity.y);
//    BOOL left = velocity.x < 0;
//    
//    if((!horizontal  && recognizer.state!=UIGestureRecognizerStateEnded) || (!left && recognizer.state==UIGestureRecognizerStateBegan)){
//        return;
//    }
//    
//    // 1. Gesture is started, show the modal controller
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        if (location.x > self.mainController.view.frame.size.width/2) {
//            // Check that the modal controller view isn't currently shown
//            
////            if(!self.modalController){
//                // present modal share screen controller
//                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//                self.modalController = (MMNTShareViewController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"shareScreen"];
//            
//                self.modalController.transitioningDelegate = self;
//                self.modalController.modalPresentationStyle = UIModalPresentationCustom;
//            
//                // Present the controller
//                [self.mainController presentViewController:self.modalController animated:YES completion:nil];
//                
////            }
//        }
//    }
////    // 2. Update the animation state
////    else if (recognizer.state == UIGestureRecognizerStateChanged) {
////        
////        // Get the ratio of the animation depending on the touch location.
////        CGFloat animationRatio = ABS(translation.x)/(self.mainController.view.frame.size.width);
////        [self updateInteractiveTransition:animationRatio];
////        
//////        NSLog(@"%f", animationRatio);
////    }
//    
//    // 3. Complete or cancel the animation when gesture ends
//    else if (recognizer.state == UIGestureRecognizerStateEnded) {
//        if (velocity.x >= 0 && ABS(translation.x) < self.mainController.view.frame.size.width/2) {
//            [self cancelInteractiveTransition];
//        }else{
//            [self finishInteractiveTransition];
//        }
//        
//        self.modalController = nil;
//        NSLog(@"finished");
//        
//    }
//    
//}

//// pan gesture right to left
-(void)didPanModalController:(UIScreenEdgePanGestureRecognizer*)recognizer{
    
    UINavigationController *navVC = self.modalController.shareNavController;
    if(navVC.visibleViewController.class != [MMNT_ShareButtons class]){
        return;
    }
    
    
    CGPoint translation = [recognizer translationInView:[self.mainController.view window]];
    CGPoint location = [recognizer locationInView:[self.mainController.view window]];
    CGPoint velocity = [recognizer velocityInView:[self.mainController.view window]];
    
    BOOL horizontal = ABS(velocity.x) > ABS(velocity.y);
    BOOL left = velocity.x < 0;
    
    if((!horizontal  && recognizer.state!=UIGestureRecognizerStateEnded) || (left && recognizer.state==UIGestureRecognizerStateBegan)){
        return;
    }
    
    // 1. Gesture is started, show the modal controller
    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        if (location.x > self.mainController.view.frame.size.width/2) {
            // Check that the modal controller view isn't currently shown
            
//            if(!self.modalController){
        self.swipedToDissmiss = YES;
                [self.mainController dismissViewControllerAnimated:YES completion:nil];
                
//            }
//        }
    }
//    // 2. Update the animation state
//    else if (recognizer.state == UIGestureRecognizerStateChanged) {
//        
//        // Get the ratio of the animation depending on the touch location.
//        CGFloat animationRatio = ABS(translation.x)/(self.mainController.view.frame.size.width);
//        [self updateInteractiveTransition:animationRatio];
//        
//        //        NSLog(@"%f", animationRatio);
//    }
//    
//    // 3. Complete or cancel the animation when gesture ends
//    else if (recognizer.state == UIGestureRecognizerStateEnded) {
//        if (velocity.x >= 0 || ABS(translation.x) > self.mainController.view.frame.size.width/2) {
//            [self finishInteractiveTransition];
//        }else{
//            [self cancelInteractiveTransition];
//        }
//    
////        self.modalController = nil;
//        self.swipedToDissmiss = NO;
//        NSLog(@"finished Modal");
//        
//    }
    
}

//-(void)didTapModalController:(UITapGestureRecognizer *)recognizer{
////    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        [self.mainController dismissViewControllerAnimated:YES completion:nil];
//        [self updateInteractiveTransition:0.1];
////    }
////    else if (recognizer.state == UIGestureRecognizerStateEnded) {
//        [self finishInteractiveTransition];
////    }    
//    
//}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController<MMNTShareTransitioning> *fromVC;
    fromVC = (UIViewController<MMNTShareTransitioning>*)([transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey]);
    
    UIViewController<MMNTShareTransitioning> *toVC;
    toVC = (UIViewController<MMNTShareTransitioning>*)([transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]);
    
    
    if (_operation == Present) {
        
        CGRect source = [transitionContext initialFrameForViewController:fromVC];
        source.origin.y = 70.0;
        source.size.height = source.size.height - 70.0;
        toVC.view.frame = source;
        [transitionContext.containerView addSubview:toVC.view];
        
        
        // Always presenting with Share Buttons view as the visibleController
        dispatch_async(dispatch_get_main_queue(), ^{
            toVC.blurContainer.alpha = 0.0f;
            [fromVC captureBlurToImageView:toVC.blurContainer.imageView];
            [toVC setBlurAlpha:1.0f];
        });
        
        MMNT_ShareButtons *shareVC = [toVC.shareNavController.childViewControllers objectAtIndex:0];
        
//        UIButton *closeBtn = shareVC.closeBtn;
//        closeBtn.transform = CGAffineTransformMakeScale(1,1);
//        CGRect frame = closeBtn.frame;
//        frame.origin.y = toVC.view.frame.size.height-60;
//        frame.size.height = 60; // force square
//        closeBtn.frame = frame;
        
        [shareVC.buttons enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
            // will scale up view
            obj.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
        }];

        [self scaleUpViews:shareVC.buttons withMinDelay:0];
//        [self scaleUp:shareVC.view withMinDelay:0];
        
        [toVC.view setAlpha:0.999];
        [UIView animateKeyframesWithDuration:0.5 delay:0 options:UIViewAnimationCurveLinear animations:^{
            [toVC.view setAlpha:1];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
        
        
    }else{
        
        NSTimeInterval wait = 0;
        if ([fromVC respondsToSelector:@selector(exitingFromShareView)]) {
            [fromVC exitingFromShareView];
            wait = 0.1f;
        }
        
        UIViewController *currentVC = fromVC.shareNavController.visibleViewController;
        if([currentVC.restorationIdentifier isEqualToString:@"ShareButtons"]){
            
            [self scaleDown:currentVC.view withMinDelay:0 reversed:YES];
            
            [UIView animateWithDuration:0.3 delay:self.tduration options:UIViewAnimationOptionCurveEaseIn animations:^{
                [fromVC.blurContainer setAlpha:0];
            } completion:^(BOOL finished) {
                if ([fromVC respondsToSelector:@selector(exitingFromShareView)]) {
                    toVC.photosToShare = fromVC.toShare;
                    toVC.dropDownView.hidden = NO;
                }
                
                [transitionContext completeTransition:YES];
            }];
        }else if([currentVC.restorationIdentifier isEqualToString:@"ShareName"]){            
            [self scaleDown:currentVC.view withMinDelay:0 reversed:NO];
            
            [UIView animateWithDuration:0.3 delay:self.tduration options:UIViewAnimationOptionCurveEaseIn animations:^{
                [fromVC.blurContainer setAlpha:0];
            } completion:^(BOOL finished) {
                if ([fromVC respondsToSelector:@selector(exitingFromShareView)]) {
                    toVC.photosToShare = fromVC.toShare;
                    toVC.dropDownView.hidden = NO;
                }
                
                [transitionContext completeTransition:YES];
            }];
            
            
        }else if([currentVC.restorationIdentifier isEqualToString:@"ChatContacts"]){
            // slide down view
            
            if (![fromVC respondsToSelector:@selector(exitingFromShareView)]) {
                fromVC.blurContainer.center = CGPointMake(0, 70);
                fromVC.blurContainer.imageView.frame = CGRectMake(0, -70, SCREEN_WIDTH, SCREEN_HEIGHT);
            }
            POPSpringAnimation *center = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
            center.toValue = [NSValue valueWithCGPoint:CGPointMake(0, SCREEN_HEIGHT)];
            center.springBounciness = 5;
            center.springSpeed = 15;
            center.beginTime = (CACurrentMediaTime() + wait);
            [fromVC.blurContainer pop_addAnimation:center forKey:@"position"];
            
            POPSpringAnimation *center1 = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
            center1.toValue = [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2, -SCREEN_HEIGHT/2)];
            center1.springBounciness = 5;
            center1.springSpeed = 15;
            center1.beginTime = (CACurrentMediaTime() + wait);
            [fromVC.blurContainer.imageView pop_addAnimation:center1 forKey:@"position"];

            
            POPSpringAnimation *center2 = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
            center2.toValue = [NSValue valueWithCGPoint:CGPointMake(toVC.view.frame.size.width/2, SCREEN_HEIGHT-70 + currentVC.view.frame.size.height/2)];
            center2.springBounciness = 5;
            center2.springSpeed = 15;
            center2.beginTime = (CACurrentMediaTime() + wait);
            center2.completionBlock = ^(POPAnimation *animation, BOOL finished){
                if ([fromVC respondsToSelector:@selector(exitingFromShareView)]) {
                    toVC.photosToShare = fromVC.toShare;
                    toVC.dropDownView.hidden = NO;
                }
                
                [transitionContext completeTransition:YES];
            };
            [currentVC.view pop_addAnimation:center2 forKey:@"position"];

        }


        
    }
    
}

#pragma mark - UIVieControllerTransitioningDelegate -

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source{
    _tduration = 0.3;
    _maxDelay = 0.2;
    self.operation = Present;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    _tduration = 0.3;
    _maxDelay = 0.2;
    self.operation = Dismiss;
    return self;
}


//// Implement these 2 methods to perform interactive transitions
//- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator{
////    return self;
//    return nil;
//}
//
//- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator{
////    return self.swipedToDissmiss ? self : nil;
//    return nil;
//}


#pragma mark - Helper Functions
-(void)scaleDown:(UIView *)view withMinDelay:(NSTimeInterval)mindelay reversed:(BOOL)reversed{
    NSArray* views = reversed ? [[view.subviews reverseObjectEnumerator] allObjects] : view.subviews;
    
    [views enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
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

-(void)scaleUpViews:(NSArray *)views withMinDelay:(NSTimeInterval)mindelay{
    [views enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        NSTimeInterval delay = mindelay + ((float)idx / (float)[views count]) * self.maxDelay;
        [self scaleUpView:obj withDelay:delay];
    }];
}

- (void)scaleDownView:(UIView *)view withDelay:(NSTimeInterval)delay
{
    POPBasicAnimation *scaleDown = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleDown.toValue = [NSValue valueWithCGPoint: CGPointMake(0,0)] ;
    scaleDown.beginTime = (CACurrentMediaTime() + delay);
    scaleDown.duration = _tduration;
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



@end
