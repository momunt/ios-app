//
//  AMWaveTransitioning.m
//  AMWaveTransitioning
//
//  Created by Andrea on 11/04/14.
//  Copyright (c) 2014 Fancy Pixel. All rights reserved.
//

#import "AMWaveTransition.h"
#import "POPSpringAnimation.h"
#import "POPBasicAnimation.h"

@interface AMWaveTransition ()

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *gesture;
@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, assign) int selectionIndexFrom;
@property (nonatomic, assign) int selectionIndexTo;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) NSMutableArray *attachmentsFrom;
@property (nonatomic, strong) NSMutableArray *attachmentsTo;

@end

@implementation AMWaveTransition

#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)

#define DURATION    0.65
#define MAX_DELAY   0.15

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
        _operation = UINavigationControllerOperationNone;
        _transitionType = AMWaveTransitionTypeNervous;
        _direction = @"right";
        _cellId = NULL;
    }
    return self;
}

+ (instancetype)transitionWithOperation:(UINavigationControllerOperation)operation
{
    return [[self alloc] initWithOperation:operation andTransitionType:AMWaveTransitionTypeNervous andDirection:@"right"];
}

- (instancetype)initWithOperation:(UINavigationControllerOperation)operation
{
    return [self initWithOperation:operation andTransitionType:AMWaveTransitionTypeNervous andDirection:@"right"];
}

+ (instancetype)transitionWithOperation:(UINavigationControllerOperation)operation andTransitionType:(AMWaveTransitionType)type
{
    return [[self alloc] initWithOperation:operation andTransitionType:type andDirection:@"right"];
}

- (instancetype)initWithOperation:(UINavigationControllerOperation)operation andTransitionType:(AMWaveTransitionType)type
{
    return [self initWithOperation:operation andTransitionType:type andDirection:@"right"];
}
+(instancetype)transitionWithOperation:(UINavigationControllerOperation)operation andTransitionType:(AMWaveTransitionType)type andDirection:(NSString*)direction{
    return [[self alloc] initWithOperation:operation andTransitionType:type andDirection:direction];
}
- (instancetype)initWithOperation:(UINavigationControllerOperation)operation andTransitionType:(AMWaveTransitionType)type andDirection:(NSString*)direction
{
    self = [super init];
    if (self) {
        [self setup];
        _operation = operation;
        _transitionType = type;
        _direction = direction;
        _cellId = NULL;
    }
    return self;
}

+(instancetype)transitionWithOperation:(UINavigationControllerOperation)operation andTransitionType:(AMWaveTransitionType)type andDirection:(NSString*)direction andSlideCell:(int*)id
{
    return [[self alloc] initWithOperation:operation andTransitionType:type andDirection:direction andSlideCell:id];
}
-(instancetype)initWithOperation:(UINavigationControllerOperation)operation andTransitionType:(AMWaveTransitionType)type andDirection:(NSString*)direction andSlideCell:(int*)id{
    self = [super init];
    if (self) {
        [self setup];
        _operation = operation;
        _transitionType = type;
        _direction = direction;
        _cellId = id;
    }
    return self;

}


- (void)setup
{
    _duration = DURATION;
    _maxDelay = MAX_DELAY;
}

- (void)attachInteractiveGestureToNavigationController:(UINavigationController *)navigationController
{
    self.navigationController = navigationController;
    self.gesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.gesture setEdges:UIRectEdgeLeft];
    [navigationController.view addGestureRecognizer:self.gesture];
    
    self.animator = [[UIDynamicAnimator alloc]initWithReferenceView:navigationController.view];
    self.attachmentsFrom = [@[] mutableCopy];
    self.attachmentsTo = [@[] mutableCopy];
}

- (void)detachInteractiveGesture
{
    [self.navigationController.view removeGestureRecognizer:self.gesture];
    self.navigationController = nil;
    self.gesture = nil;
    [self.animator removeAllBehaviors];
    self.animator = nil;
}

- (void)handlePan:(UIScreenEdgePanGestureRecognizer *)gesture
{
    // Starting controller
    UIViewController<AMWaveTransitioning> *fromVC;
    fromVC = (UIViewController<AMWaveTransitioning> *)self.navigationController.topViewController;
    
    // Controller that will be visible after the pop
    UIViewController<AMWaveTransitioning> *toVC;
    int index = (int)[self.navigationController.viewControllers indexOfObject:self.navigationController.topViewController];
    toVC = (UIViewController<AMWaveTransitioning> *)self.navigationController.viewControllers[index-1];
    
    // The gesture velocity will also determine the velocity of the cells
    float velocity = [gesture velocityInView:self.navigationController.view].x;
    CGPoint touch = [gesture locationInView:self.navigationController.view];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [[fromVC visibleCells] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
            // The 'selected' cell will be the one leading the other cells
            if (CGRectContainsPoint([view.superview convertRect:view.frame toView:nil], touch)) {
                self.selectionIndexFrom = (int)idx;
            }
            UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:view
                                                                         attachedToAnchor:(CGPoint){touch.x, [view.superview convertPoint:view.frame.origin toView:nil].y + view.frame.size.height / 2}];
            [attachment setDamping:0.4];
            [attachment setFrequency:1];
            [self.animator addBehavior:attachment];
            [self.attachmentsFrom addObject:attachment];
        }];
        
        
        // Kick the 'new' cells outside the view
        [[toVC visibleCells] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
            CGRect rect = view.frame;
            rect.origin.x = -SCREEN_WIDTH;
            view.frame = rect;
        }];
        
        [self.navigationController.view addSubview:toVC.view];
        [[toVC visibleCells] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
            CGRect futureRect = view.frame;
            futureRect.origin.x = 0;
            if (CGRectContainsPoint([view.superview convertRect:futureRect toView:nil], touch)) {
                self.selectionIndexTo = (int)idx;
            }
            
//            // TODO: move the setalpha below and scale it
//            [view setAlpha:1];
//            UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:view attachedToAnchor:(CGPoint){touch.x, [view.superview convertPoint:view.frame.origin toView:nil].y + view.frame.size.height / 2}];
//            [attachment setDamping:0.4];
//            [attachment setFrequency:1];
//            [self.animator addBehavior:attachment];
//            [self.attachmentsTo addObject:attachment];
        }];
        
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        
        [[fromVC visibleCells] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
            float delta = touch.x - abs(self.selectionIndexFrom - (int)idx) * velocity / 50;
            // Prevent the anchor point from going 'over' the cell
            if (delta > view.frame.origin.x + view.frame.size.width / 2) {
                delta = view.frame.origin.x + view.frame.size.width / 2 - 2;
            }
            [self.attachmentsFrom[idx] setAnchorPoint:(CGPoint){delta, [view.superview convertPoint:view.frame.origin toView:nil].y + view.frame.size.height / 2}];
        }];
        
        [[toVC visibleCells] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
            float delta = [gesture locationInView:self.navigationController.view].x - abs(self.selectionIndexTo - (int)idx) * velocity / 50;
            // Prevent the anchor point from going 'over' the cell
            if (delta < view.frame.origin.x + view.frame.size.width / 2) {
                delta = view.frame.origin.x + view.frame.size.width / 2 + 2;
            }
            [self.attachmentsTo[idx] setAnchorPoint:(CGPoint){delta, [view.superview convertPoint:view.frame.origin toView:nil].y + view.frame.size.height / 2}];
        }];
        
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        [self.attachmentsFrom enumerateObjectsUsingBlock:^(UIAttachmentBehavior *obj, NSUInteger idx, BOOL *stop) {
            [self.animator removeBehavior:obj];
        }];
        [self.attachmentsFrom removeAllObjects];
        
        [self.attachmentsTo enumerateObjectsUsingBlock:^(UIAttachmentBehavior *obj, NSUInteger idx, BOOL *stop) {
            [self.animator removeBehavior:obj];
        }];
        [self.attachmentsTo removeAllObjects];
        
        if (gesture.state == UIGestureRecognizerStateEnded && touch.x > self.navigationController.view.frame.size.width * 0.7) {
            // Complete the transition
            [UIView animateWithDuration:0.3 animations:^{
                [[fromVC visibleCells] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
                    CGRect rect = view.frame;
                    rect.origin.x = SCREEN_WIDTH;
                    view.frame = rect;
                }];
                [[toVC visibleCells] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
                    CGRect rect = view.frame;
                    rect.origin.x = 0;
                    view.frame = rect;
                }];
            } completion:^(BOOL finished) {
                [self.navigationController popViewControllerAnimated:NO];
            }];
        } else {
            // Abort
            [UIView animateWithDuration:0.3 animations:^{
                [[fromVC visibleCells] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
                    CGRect rect = view.frame;
                    rect.origin.x = 0;
                    view.frame = rect;
                }];
                [[toVC visibleCells] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
                    CGRect rect = view.frame;
                    rect.origin.x = -SCREEN_WIDTH;
                    view.frame = rect;
                }];
            } completion:^(BOOL finished) {
                // Bring 'silently' the cell back to their place, or the normal pop operation would fail
                [[toVC visibleCells] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
                    CGRect rect = view.frame;
                    rect.origin.x = 0;
                    view.frame = rect;
                }];
                [toVC.view removeFromSuperview];
            }];
            
        }
    }
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
//    toVC.view.transform = CGAffineTransformMakeTranslation(SCREEN_WIDTH, 0);
    toVC.view.layer.transform =  CATransform3DMakeTranslation(SCREEN_WIDTH*dir, 0, 0);
    toVC.view.alpha = 1.0; // just in case view was faded out before..
    
    // First step is required to trigger the load of the visible cells.
    [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:nil completion:^(BOOL done) {

        
//        // Plain animation that moves the destination controller in place. Once it's done it will notify the transition context
//        POPBasicAnimation *vcMove = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerTranslationXY];
//        vcMove.toValue = [NSValue valueWithCGPoint:CGPointMake(0, 0)];
//        vcMove.duration = self.duration + self.maxDelay;
//        vcMove.completionBlock = (^)(POPAnimation *animation, BOOL finished){
//            [transitionContext completeTransition:YES];
//        };
//        [toVC.view.layer pop_addAnimation:vcMove forKey:@"translate"];
        
        if (self.operation == UINavigationControllerOperationPush) {
            [toVC.view setTransform:CGAffineTransformMakeTranslation(1, 0)];
			[UIView animateWithDuration:self.duration + self.maxDelay/2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
				[toVC.view setTransform:CGAffineTransformIdentity];
			} completion:^(BOOL finished) {
				[transitionContext completeTransition:YES];
			}];
        } else {
            [fromVC.view setTransform:CGAffineTransformMakeTranslation(1, 0)];
            [toVC.view setTransform:CGAffineTransformIdentity];
			[UIView animateWithDuration:self.duration + self.maxDelay/2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
//				[fromVC.view setTransform:CGAffineTransformMakeTranslation(SCREEN_WIDTH, 0)];
                [fromVC.view setTransform:CGAffineTransformIdentity];
			} completion:^(BOOL finished) {
				[transitionContext completeTransition:YES];
				[fromVC.view removeFromSuperview];
			}];
        }
        
        // Animates the cells of the starting view controller
        if ([fromVC respondsToSelector:@selector(visibleCells)]) {
            [[fromVC visibleCells] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
                NSTimeInterval delay = ((float)idx / (float)[[fromVC visibleCells] count]) * self.maxDelay;
                [self hideView:obj withDelay:delay andDelta:-delta];
            }];
            
            // hide all other cells
            if ([fromVC respondsToSelector:@selector(staticCells)]) {
                [[fromVC staticCells] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
                    if( ![[fromVC visibleCells] containsObject:obj]){
                        obj.alpha = 0.0;
                    }
                }];
            }
            
        } else {
            // The controller has no table view, let's animate it gracefully
//            [self hideView:fromVC.view withDelay:0 andDelta:-delta];
            // animate all subviews
            [fromVC.view.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
                NSTimeInterval delay = ((float)idx / (float)[fromVC.view.subviews count]) * self.maxDelay;
                [self hideView:obj withDelay:delay andDelta:-delta];
            }];
        }
        
        // Animates the cells of the presenting view controller
        if ([toVC respondsToSelector:@selector(visibleCells)]) {
            [[toVC visibleCells] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
                NSTimeInterval delay = ((float)idx / (float)[[toVC visibleCells] count]) * self.maxDelay;
                [self presentView:obj withDelay:delay andDelta:delta];
            }];
            
            // hide all other cells
            if ([toVC respondsToSelector:@selector(staticCells)]) {
                [[toVC staticCells] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
                    if( ![[toVC visibleCells] containsObject:obj]){
                        obj.alpha = 1.0;
                    }
                }];
            }

        } else {
//            [self presentView:toVC.view withDelay:0 andDelta:delta];
            // animate all subviews
            [toVC.view.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
                NSTimeInterval delay = ((float)idx / (float)[toVC.view.subviews count]) * self.maxDelay;
                [self presentView:obj withDelay:delay andDelta:delta];
            }];
        }
    }];
}

- (void)hideView:(UIView *)view withDelay:(NSTimeInterval)delay andDelta:(float)delta
{
    void (^animation)() = ^{
        [view setTransform:CGAffineTransformMakeTranslation(delta, 0)];
    };
    void (^completion)(BOOL) = ^(BOOL finished){
        [view setAlpha:0];
        [view setTransform:CGAffineTransformIdentity];
    };
    if (self.transitionType == AMWaveTransitionTypeSubtle) {
        [UIView animateWithDuration:self.duration delay:delay options:UIViewAnimationOptionCurveEaseIn animations:animation completion:completion];
    } else if (self.transitionType == AMWaveTransitionTypeNervous) {
        [UIView animateWithDuration:self.duration delay:delay usingSpringWithDamping:0.75 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseIn animations:animation completion:completion];
    } else if (self.transitionType == AMWaveTransitionTypeBounce){
        [UIView animateWithDuration:self.duration delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:animation completion:completion];
    }
}

- (void)presentView:(UIView *)view withDelay:(NSTimeInterval)delay andDelta:(float)delta
{
    [view setTransform:CGAffineTransformMakeTranslation(delta, 0)];
    [view setAlpha:1];
    void (^animation)() = ^{
        [view setTransform:CGAffineTransformIdentity];
    };
    if (self.transitionType == AMWaveTransitionTypeSubtle) {
        [UIView animateWithDuration:self.duration delay:delay options:UIViewAnimationOptionCurveEaseIn animations:animation completion:nil];
    } else if (self.transitionType == AMWaveTransitionTypeNervous) {
        [UIView animateWithDuration:self.duration delay:delay usingSpringWithDamping:0.75 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseIn animations:animation completion:nil];
    } else if (self.transitionType == AMWaveTransitionTypeBounce){
        [UIView animateWithDuration:self.duration delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:animation completion:nil];
    }
}

@end
