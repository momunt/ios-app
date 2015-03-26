//
//  MMNT_HelpTasksController.m
//  Momunt
//
//  Created by Masha Belyi on 12/17/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_HelpTasksController.h"
#import "MMNT_HelpCircle.h"
#import "POPSPringAnimation.h"
#import "MMNT_SharedVars.h"
#import "MMNT_ShareButtons.h"
#import "MMNTShareTransitionManager.h"
#import "MMNT_PassTouches.h"

#import "Amplitude.h"

@interface MMNT_HelpTasksController () <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, MMNT_PassTouchesDelegate>

@property MMNT_HelpCircle *helpCircle;
@property UIView          *promptView;
@property UIView          *promptContainer;
@property UITextView      *promptText;
//@property CGFloat          dX;
//@property CGFloat          dY;
@property UIButton        *skipBtn;
@property UIImageView     *smiley;
@property CGPoint         propmptOrigPos;


@end

@implementation MMNT_HelpTasksController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    CLS_LOG(@"presented help taskId: %i", _taskId);
    
    if([_taskType isEqualToString:@"tip"] || [_taskType isEqualToString:@"tap"]){ // OR TAP
//        MMNT_PassTouches *myview = [[MMNT_PassTouches alloc] initWithFrame:self.view.frame passRect:CGRectMake(0,80, self.view.frame.size.width,self.view.frame.size.width-80 )];
        MMNT_PassTouches *myview = [[MMNT_PassTouches alloc] initWithFrame:self.view.frame passRect:_passArea];
        myview.delegate = self;
        self.view = myview;
    }
    
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;
    
    // clear background
    self.view.backgroundColor = [UIColor clearColor];
    
    // add help circle
    if([_taskType isEqualToString:@"swipe"] || [_taskType isEqualToString:@"tap"]){
        _helpCircle = [[MMNT_HelpCircle alloc] initWithFrame:CGRectMake(0,0,72,72)];
        [self.view addSubview:_helpCircle];
        [_helpCircle reset];
        _helpCircle.animationType = _taskType;
    }
    
    //prompt container
    NSInteger yoffset = (_taskId>=103 && _taskId<=106) ? 70 : 0;
    _promptContainer = [[UIView alloc] initWithFrame:CGRectMake(0,yoffset,self.view.frame.size.width, 80)];
    _promptContainer.backgroundColor = [UIColor clearColor];
    _promptContainer.clipsToBounds = YES;
    [self.view addSubview:_promptContainer];
    _propmptOrigPos = CGPointMake(self.view.frame.size.width/2, yoffset+40);
    
    // add prompt view
    _promptView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width, 80)];
    _promptCenter = [_position isEqualToString:@"top"] ? CGPointMake(self.view.frame.size.width/2, 40) :
                                                            CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-40);
                   
    // shift up/down
    _promptView.center = CGPointMake(_promptCenter.x, _promptCenter.y + ([_position isEqualToString:@"top"] ? -80 : 80) );
    _promptView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    [_promptContainer addSubview:_promptView];
    
    // prompt image
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    background.image = _blurImage;
    [_promptView addSubview:background];
    
    // white overlay
    UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    overlay.backgroundColor = [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:0.3];
    [_promptView addSubview:overlay];
    
    // prompt text
    _promptText = [[UITextView alloc] initWithFrame:CGRectMake(60,10,self.view.frame.size.width-60, 60) ];
    _promptText.backgroundColor = [UIColor clearColor];
    _promptText.text = _helpText;
    _promptText.textColor = [UIColor colorWithWhite:1 alpha:1];
    _promptText.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size: _taskId==108 ? 14.0 : 18.0];
    _promptText.textAlignment = NSTextAlignmentLeft;
    _promptText.editable = NO;
    [_promptView addSubview:_promptText];
    
    
    //skip button
    _skipBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0,60,80)];
    _skipBtn.center = CGPointMake(30, 40);
    [_skipBtn setImage:[UIImage imageNamed:@"X"] forState:UIControlStateNormal];

    _skipBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _skipBtn.imageEdgeInsets = UIEdgeInsetsMake(30,20,30,20);
    [_promptView addSubview:_skipBtn];
    
    if([_taskType isEqualToString:@"swipe"]){
        // drag gesture
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDrag:)];
        [self.view addGestureRecognizer:recognizer];
    }else if([_taskType isEqualToString:@"tap"]){
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        [self.view addGestureRecognizer:recognizer];
    }
    
    // tap skip
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedSkip:)];
    [_skipBtn addGestureRecognizer:recognizer];
    
    
    
    _taskIds= [NSDictionary dictionaryWithObjectsAndKeys:@"menu to gallery", @"102",
                        @"swipe to share", @"104",
                        @"pull down to load",@"103",
                        @"swipe to camera", @"105",
                        @"gallery to menu", @"106",
                        @"use map to travel", @"107",
                        @"tap photo to see map", @"108", nil];

    _taskName = [_taskIds valueForKey:[NSString stringWithFormat:@"%i", _taskId]];

}
-(void)viewDidAppear:(BOOL)animated{
//    _skipBtn.imageEdgeInsets = UIEdgeInsetsMake(30,20,30,20);
    
    _smiley.transform = CGAffineTransformMakeScale(0.001, 0.001);
    
    POPSpringAnimation *move = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    move.toValue = [NSValue valueWithCGPoint:_promptCenter] ;
    move.springBounciness = 1;
    move.springSpeed = 5;
    [_promptView pop_addAnimation:move forKey:@"position"];
    
    if([_taskType isEqualToString:@"swipe"] || [_taskType isEqualToString:@"tap"]){
        [self performSelector:@selector(showAnimation) withObject:nil afterDelay:0.5];
    }
    
    // AMPLITUDE ---------------------------------------------------------------------------------------------------
    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    [eventProperties setValue:_taskName forKey:@"tip"];
    [eventProperties setValue:[NSNumber numberWithInt:_taskId] forKey:@"id"];
    [Amplitude logEvent:@"saw tooltip" withEventProperties:eventProperties];
    //--------------------------------------------------------------------------------------------------------------
}

-(void)hide{
    [UIView animateWithDuration:0.2 animations:^{
        _promptView.center = CGPointMake(_promptCenter.x, _promptCenter.y + ([_position isEqualToString:@"top"] ? -80 : 80) );
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


-(void)showAnimation{
    [_helpCircle reset];
    [_helpCircle animateFrom:_fromPoint to:_toPoint];
}

-(void)show{
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;
    
    if([_taskType isEqualToString:@"tip"] || [_taskType isEqualToString:@"tap"]){
        // just present pass-through view
        [_parentVC.view addSubview:self.view];
    }else{
        // present modal controller
        [(UIViewController *)_delegate presentViewController:self animated:NO completion:^{}];
    }
}
-(void)setFinished{
    // AMPLITUDE ---------------------------------------------------------------------------------------------------
    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    [eventProperties setValue:_taskName forKey:@"tip"];
    [eventProperties setValue:[NSNumber numberWithInt:_taskId] forKey:@"id"];
    [Amplitude logEvent:@"completed tooltip" withEventProperties:eventProperties];
    //--------------------------------------------------------------------------------------------------------------
    [_delegate MMNTHelpTaskFinishedTaskWithId:_taskId];
}
-(void)didDrag:(UIPanGestureRecognizer *)recognizer{
    
    CGPoint point = [recognizer translationInView:self.view];
    CGFloat percent = [self percentFromPoint:point];

    
    // START
    if (recognizer.state == UIGestureRecognizerStateBegan){
        [_delegate MMNTHelpTaskStartedTaskWithId:_taskId];
    }
    // STOP
    else if (recognizer.state == UIGestureRecognizerStateEnded){
        if(percent>=1.0) {
            [self setFinished];
            if(_taskId==103){
                [UIView animateWithDuration:0.2 animations:^{
                    _promptContainer.center = CGPointMake(_propmptOrigPos.x, _propmptOrigPos.y+20);
                }];
            }
        }else{
            //start over
            [self showAnimation];
            [_delegate MMNTHelpTaskCancelledTaskWithId:_taskId];
            [UIView animateWithDuration:0.2 animations:^{
                _promptContainer.center = _propmptOrigPos;
            }];
        }
    }
    // DRAGGING
    else{
        [_helpCircle draggedToPoint:[recognizer locationInView:self.view] withPercent:percent];
        [_delegate MMNTHelpTaskId:_taskId completedWithPercent:percent];
        
        if(_taskId==103){ // pulling down to refresh
            _promptContainer.center = CGPointMake(_propmptOrigPos.x, _propmptOrigPos.y+(80*percent));
        }
    }
    
}

-(void)didTap:(UIPanGestureRecognizer *)recognizer{

    CGPoint point = [recognizer locationInView:self.view];
    
    if(CGRectContainsPoint(_targetArea, point)){
        
        [self setFinished];
        [_helpCircle setCompleted];
    }
}

-(void)tappedSkip:(UIPanGestureRecognizer *)recognizer{
    // AMPLITUDE ---------------------------------------------------------------------------------------------------
    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    [eventProperties setValue:_taskName forKey:@"tip"];
    [eventProperties setValue:[NSNumber numberWithInt:_taskId] forKey:@"id"];
    [Amplitude logEvent:@"skipped tooltip" withEventProperties:eventProperties];
    //--------------------------------------------------------------------------------------------------------------

    
    
    if([_taskType isEqualToString:@"tip"]){
        [UIView animateWithDuration:0.2 animations:^{
            _promptView.center = CGPointMake(_promptCenter.x, _promptCenter.y + ([_position isEqualToString:@"top"] ? -80 : 80) );
        } completion:^(BOOL finished) {
            [_delegate MMNTHelpTaskSkippedTaskWithId:_taskId];
        }];
    }else{
        [_delegate MMNTHelpTaskSkippedTaskWithId:_taskId];
    }
}

-(CGFloat)percentFromPoint:(CGPoint)point{
    CGFloat dx = 0;
    CGFloat dy = 0;
    
    if(_targetMotion.x!=0){
        dx = point.x/_targetMotion.x;
    }
    if(_targetMotion.y!=0){
        dy = point.y/_targetMotion.y;
    }
    
    // dx and dy are between 0 and 1
    dx = dx>1 ? 1 : dx;
    dy = dy>1 ? 1 : dy;
    
    if(dx<0){ dx = 0;}
    if(dy<0){ dy = 0;}
    
    CGFloat total = (_targetMotion.x!=0 ? 1:0) + (_targetMotion.y!=0 ? 1:0);
    
    return (dx+dy)/total;
    
    
}


#pragma mark - UIViewControllerTransitioningDelegate
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                 presentingController:(UIViewController *)presenting
                                                                     sourceController:(UIViewController *)source{
    
//    return [MMNT_FadeOutTransition transitionWithOperation:@"present"];
    _transitionOperation = presented==self ? @"present" : @"dismiss";
    return self;
    
}
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    _transitionOperation = dismissed==self ? @"dismiss" : @"present";
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {

    if ([_transitionOperation  isEqual: @"present"]) {
        UIViewController *fromVC = (UIViewController *)([transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey]);
        MMNT_HelpTasksController *toVC = (MMNT_HelpTasksController *)([transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]);
        
        CGRect source = [transitionContext initialFrameForViewController:fromVC];

        // set up toVC
        toVC.view.frame = source;
    
        // just add toVC on top of fromVC and slide in the text prompt
        [transitionContext.containerView addSubview:toVC.view];
        
        
//        
//        [UIView animateWithDuration:0.5 animations:^{
//            toVC.promptView.transform = CGAffineTransformIdentity;
//        } completion:^(BOOL finished) {
//            [transitionContext completeTransition:YES];
//        }];
        
        

    }else{
        MMNT_HelpTasksController *fromVC = (MMNT_HelpTasksController *)([transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey]);
        UIViewController<MMNTShareTransitioning> *toVC = (UIViewController<MMNTShareTransitioning> *)([transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]);
        
        
        CGRect source = [transitionContext initialFrameForViewController:fromVC];
        
        if([toVC.restorationIdentifier isEqualToString:@"shareScreen"]){
            // popping to Share buttons view. animate that
            
            source.origin.y = 70.0;
            source.size.height = source.size.height - 70.0;
            
            [toVC.view removeFromSuperview];
            
            toVC.view.frame = source;
            [transitionContext.containerView insertSubview:toVC.view atIndex:0];
            
            MMNT_ShareButtons *shareVC = [toVC.shareNavController.childViewControllers objectAtIndex:0];
            shareVC.view.frame = CGRectMake(0, 0, source.size.width, source.size.height);
            
            [shareVC.buttons enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
                obj.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
            }];
            
            [self scaleUpViews:shareVC.buttons withMinDelay:0];
            
            [toVC.view setAlpha:0.999];
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                [toVC.view setAlpha:1];
            } completion:^(BOOL finished) {
                
//                [[MMNT_SharedVars sharedVars] scaleDown:_skipBtn completion:^(BOOL finished) {
//                    [[MMNT_SharedVars sharedVars] scaleUp:_smiley completion:^(BOOL finished) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        
                            // scale down orange circle
                            [[MMNT_SharedVars sharedVars] scaleDown:fromVC.helpCircle];
            
                            // hide prompt
                            CGPoint newCenter = CGPointMake(fromVC.promptCenter.x, fromVC.promptCenter.y + ([fromVC.position isEqualToString:@"top"] ? -80 : 80) );
                            POPSpringAnimation *move = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
                            move.toValue = [NSValue valueWithCGPoint:newCenter];
                            move.springBounciness = 0;
                            move.springSpeed = 5;
                            move.completionBlock = ^(POPAnimation *animation, BOOL finished){
                                // done!
                                [transitionContext completeTransition:YES];
                            };
                            [fromVC.promptView pop_addAnimation:move forKey:@"position"];
                        });
//                    }];
//                }];

            }];
        }else{
            // set up toVC
//            toVC.view.frame = source;
            
            // scale down orange circle
            [[MMNT_SharedVars sharedVars] scaleDown:fromVC.helpCircle];
        
            // hide prompt
            CGPoint newCenter = CGPointMake(fromVC.promptCenter.x, fromVC.promptCenter.y + ([fromVC.position isEqualToString:@"top"] ? -80 : 80) );
            POPSpringAnimation *move = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
            move.toValue = [NSValue valueWithCGPoint:newCenter];
            move.springBounciness = 0;
            move.springSpeed = 5;
            move.completionBlock = ^(POPAnimation *animation, BOOL finished){
                // done!
                [transitionContext completeTransition:YES];
            };

            [fromVC.promptView pop_addAnimation:move forKey:@"position"];
        }

        
        
    }
}

-(void)scaleUp:(UIView *)view withMinDelay:(NSTimeInterval)mindelay{
    [view.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        NSTimeInterval delay = mindelay + ((float)idx / (float)[view.subviews count]) * 0.2;
        [self scaleUpView:obj withDelay:delay];
    }];
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

-(void)scaleUpViews:(NSArray *)views withMinDelay:(NSTimeInterval)mindelay{
    [views enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        NSTimeInterval delay = mindelay + ((float)idx / (float)[views count]) * 0.2;
        [self scaleUpView:obj withDelay:delay];
    }];
}

-(void) MMNTPassTouchesView:(MMNT_PassTouches *)view passedPoint:(CGPoint)point{
    if(_taskId==101){
        // finished task!
        [self setFinished];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
