//
//  MMNTCameraTransitioningManager.m
//  Momunt
//
//  Created by Masha Belyi on 9/6/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNTCameraTransitioningManager.h"
#import "POPSpringAnimation.h"
#import "POPBasicAnimation.h"

@implementation MMNTCameraTransitioningManager

- (void)setMainController:(MMNTViewController *)mainController{
    
    _mainController = mainController;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didPanMainController:)];
    panGesture.delegate = self;
    self.mainPanGesture = panGesture;
    [self.mainController.collectionView addGestureRecognizer:panGesture];
    
}
-(void)setModalController:(MMNT_Camera *)modalController{
    _modalController = modalController;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didPanModalController:)];
//    panGesture.delegate = _modalController;
    [self.modalController.view addGestureRecognizer:panGesture];
    
}

#pragma mark - UIGestureRecognizerDelegate
// only fire horizontal pan
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:[self.mainController.view window]];
    
    if ([gestureRecognizer isEqual:self.mainPanGesture]) {
        if(location.x > self.mainController.view.frame.size.width/2){
            return NO;
        }
        
        if (gestureRecognizer.numberOfTouches > 0) {
            CGPoint translation = [self.mainPanGesture velocityInView:self.mainController.collectionView];
            return fabs(translation.y) < fabs(translation.x);
        } else {
            return NO;
        }
    }
    return YES;
}

-(void)didPanMainController:(UIScreenEdgePanGestureRecognizer*)recognizer{
    
    CGPoint translation = [recognizer translationInView:[self.mainController.view window]];
    CGPoint location = [recognizer locationInView:[self.mainController.view window]];
    CGPoint velocity = [recognizer velocityInView:[self.mainController.view window]];
    
    BOOL horizontal = ABS(velocity.x) > ABS(velocity.y); // swiped horizontal?
    NSLog(@"%id", horizontal);
    BOOL right = velocity.x > 0; // swiped left->right?
    
    if((!horizontal  && recognizer.state!=UIGestureRecognizerStateEnded) || (!right && recognizer.state==UIGestureRecognizerStateBegan)){
        return;
    }
    
    // 1. Gesture is started, show the modal controller
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (location.x < self.mainController.view.frame.size.width/2) {
            // present modal share screen controller
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            self.modalController = (MMNT_Camera *)[mainStoryboard instantiateViewControllerWithIdentifier: @"camera"];
            
            self.modalController.transitioningDelegate = self;
            self.mainController.transitioningDelegate = self;
            self.modalController.modalPresentationStyle = UIModalPresentationCustom;
            
            // Present the controller
            [self.mainController presentViewController:self.modalController animated:YES completion:nil];
            
            //            }
        }
    }
    // 2. Update the animation state
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // Get the ratio of the animation depending on the touch location.
        CGFloat animationRatio = ABS(translation.x)/(self.mainController.view.frame.size.width);
        [self updateInteractiveTransition:animationRatio];
        NSLog(@"%f", animationRatio);
    }
    
    // 3. Complete or cancel the animation when gesture ends
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
//        if (velocity.x <= 0 && ABS(translation.x) < self.mainController.view.frame.size.width/2) {
//            [self cancelInteractiveTransition];
//        }else{
            [self finishInteractiveTransition];
//        }
        
        self.modalController = nil;
        NSLog(@"finished");
        
    }
    
}

-(void)didPanModalController:(UIScreenEdgePanGestureRecognizer*)recognizer{
    
    CGPoint translation = [recognizer translationInView:[self.mainController.view window]];
    CGPoint location = [recognizer locationInView:[self.mainController.view window]];
    CGPoint velocity = [recognizer velocityInView:[self.mainController.view window]];
    
    BOOL horizontal = ABS(velocity.x) > ABS(velocity.y); // swiped horizontal?
    BOOL right = velocity.x > 0; // swiped left->right?
    
    if((!horizontal  && recognizer.state!=UIGestureRecognizerStateEnded) || (right && recognizer.state==UIGestureRecognizerStateBegan)){
        return;
    }
    
    // 1. Gesture is started, show the modal controller
    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        if (location.x < self.mainController.view.frame.size.width/2) {
        [self.mainController dismissViewControllerAnimated:YES completion:nil];
        
//        }
    }
    // 2. Update the animation state
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // Get the ratio of the animation depending on the touch location.
        CGFloat animationRatio = ABS(translation.x)/(self.mainController.view.frame.size.width);
        [self updateInteractiveTransition:animationRatio];
        NSLog(@"%f", animationRatio);
    }
    
    // 3. Complete or cancel the animation when gesture ends
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
//        if (velocity.x >= 0 && ABS(translation.x) > self.mainController.view.frame.size.width/2) {
//            [self cancelInteractiveTransition];
//        }else{
            [self finishInteractiveTransition];
//        }
        NSLog(@"finished dismiss transition");
        
    }
    
}


#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromVC;
    fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIViewController *toVC;
    toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect source = [transitionContext initialFrameForViewController:fromVC];
    
    if(_presenting){
        // add toVC on the LEFT size of the screen
//        toVC.view.frame = CGRectMake(-source.size.width, 0, source.size.width, source.size.height);
        toVC.view.frame = source;
        toVC.view.center = CGPointMake(toVC.view.center.x-source.size.width, toVC.view.center.y);
        // insert toVC into transitionContext
        [transitionContext.containerView addSubview:toVC.view];
        
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:0.7
              initialSpringVelocity:1
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
//                             toVC.view.frame = source;
//                             fromVC.view.frame = CGRectMake(source.size.width, 0, source.size.width, source.size.height);
                             toVC.view.center = CGPointMake(toVC.view.center.x+source.size.width, toVC.view.center.y);
                             fromVC.view.center = CGPointMake(fromVC.view.center.x+source.size.width, fromVC.view.center.y);
                             
                         } completion:^(BOOL finished) {
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];
        
//        // animate bothViews to the right
//        POPSpringAnimation *fromA = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
//        fromA.toValue = [NSValue valueWithCGRect:CGRectMake(source.size.width, 0, source.size.width, source.size.height)];
//        fromA.springBounciness = 5;
//        fromA.springSpeed = 15;
//        [fromVC.view pop_addAnimation:fromA forKey:@"frame"];
//        
//        POPSpringAnimation *toA = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
//        toA.toValue = [NSValue valueWithCGRect:source];
//        toA.springBounciness = 5;
//        toA.springSpeed = 15;
//        toA.completionBlock = ^(POPAnimation *animation, BOOL finished){
//            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//        };
//        [toVC.view pop_addAnimation:toA forKey:@"frame"];
        
        
        
    }else{
        // add toVC on the RIGHT size of the screen
//        toVC.view.frame = CGRectMake(source.size.width, 0, source.size.width, source.size.height);
        toVC.view.center = CGPointMake(toVC.view.center.x+source.size.width, toVC.view.center.y);


        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:0.7
              initialSpringVelocity:1
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
//                             toVC.view.frame = source;
//                             fromVC.view.frame = CGRectMake(-source.size.width, 0, source.size.width, source.size.height);
                             toVC.view.center = CGPointMake(toVC.view.center.x-source.size.width, toVC.view.center.y);
                             fromVC.view.center = CGPointMake(fromVC.view.center.x-source.size.width, fromVC.view.center.y);
                         } completion:^(BOOL finished) {
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];
        
//        //reverse animation
//        // animate bothViews to the left
//        POPSpringAnimation *fromA = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
//        fromA.toValue = [NSValue valueWithCGRect:CGRectMake(- source.size.width, 0, source.size.width, source.size.height)];
//        fromA.springBounciness = 5;
//        fromA.springSpeed = 15;
//        [fromVC.view pop_addAnimation:fromA forKey:@"frame"];
//        
//        POPSpringAnimation *toA = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
//        toA.toValue = [NSValue valueWithCGRect:source];
//        toA.springBounciness = 5;
//        toA.springSpeed = 15;
//        toA.completionBlock = ^(POPAnimation *animation, BOOL finished){
//            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//        };
//        [toVC.view pop_addAnimation:toA forKey:@"frame"];
        
    }
}

#pragma mark - UIViewControllerTransitioningDelegate -

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source{
    _presenting = YES;
//    _duration = 0.5;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    _presenting = NO;
//    _duration = 0.5;
    return self;
}
// Implement these 2 methods to perform interactive transitions
- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator{
    return self;
//    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator{
    return self;
//    return nil;
}

@end
