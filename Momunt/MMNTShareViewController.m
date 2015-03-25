//
//  MMNTShareViewController.m
//
//
//  Created by Masha Belyi on 6/17/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNTShareViewController.h"
#import "MMNT_BlurContainer.h"
#import "MMNT_ShareButtons.h"
#import "MMNT_SharedVars.h"

#import "MMNTApiCommuniator.h"

#import "MMNTShareTransitionManager.h"

@interface MMNTShareViewController () <UINavigationControllerDelegate, UIViewControllerTransitioningDelegate> {
    UIImage *blurredImage;
}

@end

@implementation MMNTShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.view.hidden = YES;
    // SET SHARE BUTTONS POSITIONS
//    [self animateToStartState];

    self.shareNavController = [self.childViewControllers objectAtIndex:0];
    [self.shareNavController setDelegate:self];
    MMNT_ShareButtons *shareVC = [self.shareNavController.childViewControllers objectAtIndex:0];
    [shareVC loadView];
    self.storeBtn = shareVC.storeBtn;
    self.facebookBtn = shareVC.facebookBtn;
    self.twitterBtn = shareVC.twitterBtn;
    self.messageBtn = shareVC.messageBtn;
    
    // INIT GESTURE HANDLERS
    [self.view setUserInteractionEnabled:YES];
    
//    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
//                                                          initWithTarget:self
//                                                          action:@selector(close:)];
//    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
//    singleTapGestureRecognizer.delegate = self;
////    [[self.shareNavController.viewControllers objectAtIndex:0] addGestureRecognizer:singleTapGestureRecognizer];
//    [self.view addGestureRecognizer:singleTapGestureRecognizer];
    
//    CGRect frame = self.view.frame;
//    frame.origin.y = 80;
//    frame.size.height = self.view.frame.size.height - 80;
    self.blurContainer = [[MMNT_BlurContainer alloc] initWithFrame:self.view.frame];
    [self.view insertSubview:self.blurContainer atIndex:0];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Button Handlers
- (IBAction)handleStore:(id)sender {
    NSLog(@"store momunt");
}

- (IBAction)handleMessage:(id)sender {
}

- (IBAction)handleFacebook:(id)sender {
}

- (IBAction)handleTwitter:(id)sender {
}

#pragma mark Tap Handler

-(void)close:(UITapGestureRecognizer *)recognizer {
    if(self.navigationController.visibleViewController.class != [MMNT_ShareButtons class]){
        return;
    }
//    [self animateToStartState];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//    self.view.hidden=YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

//    if(gestureRecognizer.view != otherGestureRecognizer.view){
//        return NO;
//    }
    return YES;
}

-(void)setBlurAlpha:(CGFloat)alpha{
    [UIView animateWithDuration:0.3 animations:^{
        self.blurContainer.alpha = alpha;
    }];
    
}



/*
 <UIViewControllerTransitioningDelegate>
 */

#pragma mark - Transition Animations
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                 presentingController:(UIViewController *)presenting
                                                                     sourceController:(UIViewController *)source{
    
//    return [[MMNTShareTransitionManager alloc] initWithOperation:Present];
    return [MMNTShareTransitionManager transitionWithOperation:Present];
    
    
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
//    return [[MMNTShareTransitionManager alloc] initWithOperation:Dismiss];
    return [MMNTShareTransitionManager transitionWithOperation:Dismiss];

}


@end
