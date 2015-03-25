//
//  MMNT_SignInController.m
//  Momunt
//
//  Created by Masha Belyi on 9/26/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_SignInController.h"
#import "MMNT_FadeOutTransition.h"
#import "MMNT_OnboardingNC.h"
#import "MMNTViewController.h"

#import "JNKeychain.h"
#import "MMNTDataController.h"
#import "MMNTApiCommuniator.h"

@interface MMNT_SignInController (){
    MMNTApiCommuniator *_apicommunicator;
}


@end

@implementation MMNT_SignInController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.transitioningDelegate = self;
    
    MMNT_OnboardingNC *nc = [self.childViewControllers objectAtIndex:0];
    nc.view.frame = self.view.frame;
    nc.parentVC = self;
    
    
    
    
    
}
//- (void)viewWillAppear:(BOOL)animated{
//    NSString *token = [JNKeychain loadValueForKey:@"AccessToken"];
//    
//    // set up API communicator
//    _apicommunicator = [[MMNTApiCommuniator alloc] init];
//    
//    if(token!=nil){// && [_apicommunicator getUserInfo] ){
//        
//        
//        [self performSegueWithIdentifier:@"LoadingToGallery" sender:self];
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)resetToSignInScreen{
    // set up sign in screen
    [self.view setAlpha:1.0f];
    
    MMNT_OnboardingNC *nc = [self.childViewControllers objectAtIndex:0];
    
    MMNT_SignInController *vc = [nc.viewControllers objectAtIndex:0];
    for(int i=0; i<[vc.view.subviews count]; i++){
        UIView *view = vc.view.subviews[i];
        view.alpha = 1.0;
        view.transform = CGAffineTransformIdentity;
    }
    
    [nc popToRootViewControllerAnimated:NO];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Transition Animations
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                 presentingController:(UIViewController *)presenting
                                                                     sourceController:(UIViewController *)source{
    
    return [MMNT_FadeOutTransition transitionWithOperation:@"present"];

    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"prepare for segue");
    MMNTViewController *toVC = ((MMNTViewController *)segue.destinationViewController);
    if([toVC respondsToSelector:@selector(currSegue)]){
        toVC.currSegue = [segue identifier];
    }
    
    
}


@end
