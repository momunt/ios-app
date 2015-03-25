//
//  MMNT_AskPhoneNumberVC.m
//  Momunt
//
//  Created by Masha Belyi on 2/20/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import "MMNT_AskPhoneNumberVC.h"
#import "MMNT_SlideUpTransition.h"
#import "AMWaveTransition.h"
#import "Amplitude.h"

@interface MMNT_AskPhoneNumberVC ()

@end

@implementation MMNT_AskPhoneNumberVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _navVC = [self.childViewControllers objectAtIndex:0];
    [_navVC setDelegate:self];
    UIViewController *rootVC = [[_navVC childViewControllers] objectAtIndex:0];
    rootVC.view.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height);

    // Set background blur
    NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"blurImage"];
    UIImage *blur = [UIImage imageWithData:imageData];
    if(blur){
        _backgroundBlur.image = blur;
    }
    
    if([_type isEqualToString:@"gallery"]){
        _backgroundBlur.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height-60);
//        _navVC.view.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height-60);
//        rootVC.view.frame = CGRectMake(0,0,_navVC.view.frame.size.width, _navVC.view.frame.size.height);
    }
    
    [Amplitude logEvent:@"saw request for phone number"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    return [AMWaveTransition transitionWithOperation:operation andTransitionType:AMWaveTransitionTypeNervous andDirection:@"right"];
    
}


#pragma mark - UIViewControllerAnimatedTransitioning

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                 presentingController:(UIViewController *)presenting
                                                                     sourceController:(UIViewController *)source{
    
    return [[MMNT_SlideUpTransition alloc] initWithOperation:@"present"];
    presented.view.frame = CGRectMake(0,80,source.view.frame.size.width, source.view.frame.size.height-80);
    
    
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[MMNT_SlideUpTransition alloc] initWithOperation:@"dismiss"];
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
