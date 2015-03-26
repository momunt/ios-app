//
//  MMNT_OnboardingVC.m
//  Momunt
//
//  Onboarding tip controller
//  Step 1: Click here (momuntBtn) to load the momunt from your location
//  Step 2: Add photo to your location (cameraBtn)
//  Step 3: Share your momunt (shareBtn)
//  Step 4: Click here to see trending momunts
//
//  Created by Masha Belyi on 3/25/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import "MMNT_OnboardingVC.h"

@interface MMNT_OnboardingVC () <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@end

@implementation MMNT_OnboardingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // flip arrow
    _arrow.transform = CGAffineTransformMakeRotation(90);
    _arrow.center = CGPointMake(_momuntBtn.center.x, _momuntBtn.center.y-100);
    
    // text
    _tooltip.text = _tooltipText;
    
    _cameraBtn.hidden = _taskId==202 ? NO : YES;
    _menuBtn.hidden = _taskId==204 ? NO : YES;
    _momuntBtn.hidden = _taskId==201 ? NO : YES;
    _shareBtn.hidden = _taskId==203 ? NO : YES;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// move to next step
-(void)setTask:(int)taskId{
    
}

-(void)show{
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;
    
    // present modal controller
    [(UIViewController *)_parent presentViewController:self animated:YES completion:^{}];
}

-(void)exit{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)pressedCameraBtn:(id)sender {
}

- (IBAction)pressedMenuBtn:(id)sender {
}

- (IBAction)pressedMomuntBtn:(id)sender {
}

- (IBAction)pressedShareBtn:(id)sender {
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
        UIViewController *toVC = ([transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]);
        
        CGRect source = [transitionContext initialFrameForViewController:fromVC];
        
        // set up toVC
        toVC.view.frame = CGRectMake(0,70,source.size.width, source.size.height-70);
        
        [transitionContext.containerView addSubview:toVC.view];
        [transitionContext completeTransition:YES];

    }else{
        
        [transitionContext completeTransition:YES];
        
        
    }
}


@end
