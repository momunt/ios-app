//
//  MMNT_RowSelection_Transition.m
//  Momunt
//
//  Created by Masha Belyi on 7/22/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_RowSelection_Transition.h"

@implementation MMNT_RowSelection_Transition

#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)

#define DURATION    0.3
#define MAX_DELAY   0.3
#define T_SLIDEUP   0.3

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
        _operation = UINavigationControllerOperationNone;
        _rowIdx = 0;
        _direction = @"right";
    }
    return self;
}

- (void)setup
{
    _duration = DURATION;
    _maxDelay = MAX_DELAY;
    _tSlideup = T_SLIDEUP;
}

+(instancetype)transitionWithOperation:(UINavigationControllerOperation)operation andRowIndex:(NSInteger)idx andDirection:(NSString*)direction
{
    return [[self alloc] initWithOperation:operation andRowIndex:idx andDirection:direction];
}
-(instancetype)initWithOperation:(UINavigationControllerOperation)operation andRowIndex:(NSInteger)idx andDirection:(NSString*)direction
{
    self = [super init];
    if (self) {
        [self setup];
        _operation = operation;
        _rowIdx = idx;
        _direction = direction;
    }
    return self;
    
}


- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return self.duration + self.maxDelay;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController<AMWaveTransitioning> *fromVC;
    if ([[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey] isKindOfClass:[UINavigationController class]]) {
        fromVC = (UIViewController<AMWaveTransitioning>*)([(UINavigationController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey] visibleViewController]);
    } else {
        fromVC = (UIViewController<AMWaveTransitioning>*)([transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey]);
    }
    
    UIViewController<AMWaveTransitioning> *toVC;
    if ([[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey] isKindOfClass:[UINavigationController class]]) {
        toVC = (UIViewController<AMWaveTransitioning>*)([(UINavigationController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey] visibleViewController]);
    } else {
        toVC = (UIViewController<AMWaveTransitioning>*)([transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]);
    }
	
//    CGRect source = [transitionContext initialFrameForViewController:fromVC];
    CGRect source = CGRectMake(0,0,fromVC.view.frame.size.width, fromVC.view.frame.size.height);
    [[transitionContext containerView] addSubview:toVC.view];
    
    CGFloat delta;
    CGFloat dir = [_direction  isEqual: @"right"] ? 1 : -1;
    if (self.operation == UINavigationControllerOperationPush) {
        delta = SCREEN_WIDTH*dir;
    } else {
        delta = -SCREEN_WIDTH*dir;
    }
    
    // Move the destination in place
    toVC.view.frame = source;
    fromVC.view.frame = source;
    // And kick it aside
    toVC.view.transform = CGAffineTransformMakeTranslation(SCREEN_WIDTH, 0);
    
    // First step is required to trigger the load of the visible cells.
    [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:nil completion:^(BOOL done) {
        
        // Plain animation that moves the destination controller in place. Once it's done it will notify the transition context
        if (self.operation == UINavigationControllerOperationPush) {
            [toVC.view setTransform:CGAffineTransformMakeTranslation(1, 0)];
			[UIView animateWithDuration: 1.5*(self.duration + self.maxDelay) delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
				[toVC.view setTransform:CGAffineTransformIdentity];
			} completion:^(BOOL finished) {
				[transitionContext completeTransition:YES];
			}];
        } else {
            [fromVC.view setTransform:CGAffineTransformMakeTranslation(1, 0)];
            [toVC.view setTransform:CGAffineTransformIdentity];
			[UIView animateWithDuration: 1.5*(self.duration + self.maxDelay) delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
//				[fromVC.view setTransform:CGAffineTransformMakeTranslation(SCREEN_WIDTH, 0)];
                [fromVC.view setTransform:CGAffineTransformIdentity];
			} completion:^(BOOL finished) {
				[transitionContext completeTransition:YES];
				[fromVC.view removeFromSuperview];
			}];
        }
        
        if (self.operation == UINavigationControllerOperationPush) {
            // Position first cell of toVC on top of corresponding cell in fromVC
            UITableViewCell *header = [toVC cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            UITableViewCell *cell = [fromVC cellForRowAtIndexPath:[NSIndexPath indexPathForItem:_rowIdx inSection:0]];
            CGRect originalFrame = header.frame;
            
            CGRect frame = cell.frame;
            frame.origin.y = frame.origin.y - fromVC.currentOffsetY;
            
            [header setAlpha:1.0f];
            [header setFrame: frame];
            [cell setAlpha:0.0f];
//            [header setTransform:CGAffineTransformMakeTranslation(0, cell.frame.origin.y) ];
            
            // Animates the cells of the starting view controller
            if ([fromVC respondsToSelector:@selector(visibleCells)]) {
                [[fromVC visibleCells] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
                    NSTimeInterval delay = ((float)idx / (float)[[fromVC visibleCells] count]) * self.maxDelay;
                    [self hideView:obj withDelay:delay andDelta:-delta];
                }];
            } else {
                // The controller has no table view, let's animate it gracefully
                [self hideView:fromVC.view withDelay:0 andDelta:-delta];
            }
            
            // Animate header to the top
            [UIView animateWithDuration: self.tSlideup
                                  delay: self.duration
                usingSpringWithDamping:0.6
                  initialSpringVelocity:0.1
                                options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                            animations:^{
//                                [header setTransform:CGAffineTransformIdentity];
                                [header setFrame:originalFrame];
                            }
                            completion:^(BOOL finished) {}
            ];
            
            // Animates the cells of the presenting view controller
            if ([toVC respondsToSelector:@selector(visibleCells)]) {
                [[toVC visibleCells] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
                    if(idx!=0){
                        NSTimeInterval delay = ((float)idx / (float)[[toVC visibleCells] count]) * self.maxDelay + 0.5*(self.duration + self.maxDelay);
                        [self presentView:obj withDelay:delay andDelta:delta];
                    }
                }];
            } else {
                [self presentView:toVC.view withDelay:0 andDelta:delta];
            }

            
            
        }else{
         // POP !!! REVERSE EVERYTHING
            
            // 1) Animates the cells of the starting view controller
            if ([fromVC respondsToSelector:@selector(visibleCells)]) {
                [[fromVC visibleCells] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
                    if(idx!=0){
                        NSTimeInterval delay = ((float)idx / (float)[[fromVC visibleCells] count]) * self.maxDelay;
                        [self hideView:obj withDelay:delay andDelta:-delta];
                    }
                }];
            } else {
                [self hideView:toVC.view withDelay:0 andDelta:-delta];
            }
            
            // 2) Animate header down to correct position
            UITableViewCell *header = [fromVC cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            UITableViewCell *cell = [toVC cellForRowAtIndexPath:[NSIndexPath indexPathForItem:_rowIdx inSection:0]];
            
            CGRect newFrame = cell.frame;
            newFrame.origin.y = newFrame.origin.y - toVC.currentOffsetY;
            
            [UIView animateWithDuration: self.tSlideup
                                  delay: self.duration
                 usingSpringWithDamping:0.6
                  initialSpringVelocity:0.1
                                options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                             animations:^{
                                 // [header setTransform:CGAffineTransformIdentity];
                                 [header setFrame:newFrame];
                             }
                             completion:^(BOOL finished) {
                                 [cell setTransform:CGAffineTransformIdentity];
                                 [cell setAlpha:1.0f];
                                 [header setAlpha:0.0f];
                             }
             ];

            // 3) Animates the cells of the presenting view controller
            if ([toVC respondsToSelector:@selector(visibleCells)]) {
                [[toVC visibleCells] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
                    if(idx!=self.rowIdx){
                        NSTimeInterval delay = ((float)idx / (float)[[toVC visibleCells] count]) * self.maxDelay + 0.5*(self.duration + self.maxDelay);
                        [self presentView:obj withDelay:delay andDelta:delta];
                    }else{
//                        NSTimeInterval delay = ((float)idx / (float)[[toVC visibleCells] count]) * self.maxDelay + 0.5*(self.duration + self.maxDelay);
//                        void (^animation)() = ^{
//                            [obj setTransform:CGAffineTransformIdentity];
//                            [obj setAlpha:1];
//                        };
//                        [UIView animateWithDuration:0 delay:delay options:UIViewAnimationOptionCurveEaseIn animations:animation completion:nil];

                        
                        
                    }
                }];
            } else {
                // The controller has no table view, let's animate it gracefully
                [self presentView:toVC.view withDelay:0 andDelta:delta];
            }


        }
        
    }];
}

- (void)hideView:(UIView *)view withDelay:(NSTimeInterval)delay andDelta:(float)delta
{
    void (^animation)() = ^{
        [view setTransform:CGAffineTransformMakeTranslation(delta, 0)];
        //        [view setAlpha:0];
    };
    void (^completion)(BOOL) = ^(BOOL finished){
        [view setAlpha:0];
        [view setTransform:CGAffineTransformIdentity];
    };
//    if (self.transitionType == AMWaveTransitionTypeSubtle) {
//        [UIView animateWithDuration:self.duration delay:delay options:UIViewAnimationOptionCurveEaseIn animations:animation completion:completion];
//    } else if (self.transitionType == AMWaveTransitionTypeNervous) {
        [UIView animateWithDuration:self.duration delay:delay usingSpringWithDamping:0.75 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseIn animations:animation completion:completion];
//    } else if (self.transitionType == AMWaveTransitionTypeBounce){
//        [UIView animateWithDuration:self.duration delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:animation completion:completion];
//    }
}

- (void)presentView:(UIView *)view withDelay:(NSTimeInterval)delay andDelta:(float)delta
{
    [view setTransform:CGAffineTransformMakeTranslation(delta, 0)];
    [view setAlpha:1];
    void (^animation)() = ^{
        [view setTransform:CGAffineTransformIdentity];
        //        [view setAlpha:1];
    };
//    if (self.transitionType == AMWaveTransitionTypeSubtle) {
//        [UIView animateWithDuration:self.duration delay:delay options:UIViewAnimationOptionCurveEaseIn animations:animation completion:nil];
//    } else if (self.transitionType == AMWaveTransitionTypeNervous) {
        [UIView animateWithDuration:self.duration delay:delay usingSpringWithDamping:0.75 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseIn animations:animation completion:nil];
//    } else if (self.transitionType == AMWaveTransitionTypeBounce){
//        [UIView animateWithDuration:self.duration delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:animation completion:nil];
//    }
}



@end
