//
//  MMNT_ShareButtons.m
//  Momunt
//
//  Created by Masha Belyi on 8/25/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_ShareButtons.h"
#import "MMNT_ShareName.h"
#import "AMWaveTransition.h"
#import "MMNT_TransitionsManager.h"
#import "MMNTShareViewController.h"
#import "POPSpringAnimation.h"
#import "MMNTDataController.h"
#import "MMNTAccountManager.h"
#import "MMNT_SharedVars.h"

#import "Amplitude.h"

#import "MMNTAccountManager.h"
#import "MMNT_AskPhoneNumberVC.h"


@interface MMNT_ShareButtons () <UINavigationControllerDelegate, UIViewControllerTransitioningDelegate>

@end

@implementation MMNT_ShareButtons

#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)


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
    self.view.backgroundColor = [UIColor colorWithRed:(0 / 255.0) green:(0 / 255.0) blue:(0 / 255.0) alpha:0]; // clear background
    // Do any additional setup after loading the view.
    [self.navigationController setDelegate:self];
    
//    CGRect frame = _closeBtn.frame;
//    frame.size.height = 60; // force square
//    _closeBtn.frame = frame;
//    _closeBtn.frame = CGRectMake(0, self.view.frame.size.height-60, self.view.frame.size.width, 60);
    
    _storeBtn.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    _facebookBtn.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    _messageBtn.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    _twitterBtn.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
//    _closeBtn.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    _l1.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    _l2.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    
    MMNTDataController *mmntDataController = [MMNTDataController sharedInstance];
    _l1.text = mmntDataController.sharePile ? @"Share my photo pile." : @"Share this momunt.";
//    _l2.hidden = mmntDataController.sharePile ? YES : NO;
    
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    self.view.frame = CGRectMake(0,0,SCREEN_WIDTH, SCREEN_HEIGHT-70);
    
    CGRect frame = _closeBtn.frame;
    frame.size.height = frame.size.width; // force square
    _closeBtn.frame = frame;

    
//    MMNTDataController *mmntDataController = [MMNTDataController sharedInstance];
//    
//    if(!_sharePromptView){
//        _sharePromptView = [[MMNT_PassTouches alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 80) ];
//        _sharePromptView.backgroundColor = [UIColor clearColor];
////        _sharePromptView.layer.transform =  CATransform3DMakeTranslation(0, 100, 0);
//        [self.view addSubview:_sharePromptView];
//        
//        _sharePrompt = [[UITextView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-200)/2, 10, 200, 60) ];
//        _sharePrompt.backgroundColor = [UIColor clearColor];
//        _sharePrompt.text = mmntDataController.sharePile ? @"save or share your collection" : @"save or share the whole momunt";
//        _sharePrompt.textColor = [UIColor colorWithWhite:1 alpha:1];
//        _sharePrompt.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
//        _sharePrompt.textAlignment = NSTextAlignmentCenter;
//        [_sharePromptView addSubview:_sharePrompt];
//    }else{
//        _sharePromptView.layer.transform =  CATransform3DMakeTranslation(0, 0, 0);
//        _sharePromptView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 80);
//        
//    }
//    
    _saveLabel.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    _messageLabel.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    _postLabel.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    _tweetLabel.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    


}
-(void)close:(UITapGestureRecognizer *)recognizer {
    [self.navigationController.parentViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [Amplitude logEvent:@"went to share_buttons"];
    
    // INIT GESTURE HANDLERS
    [self.view setUserInteractionEnabled:YES];
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                          initWithTarget:self
                                                          action:@selector(close:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    singleTapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:singleTapGestureRecognizer];

    [self.navigationController setDelegate:self];
    
    // IF NEED TO SHOW..
    if( ![[MMNTAccountManager sharedInstance] isTaskDone:7]){
        POPSpringAnimation *slideUp = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerTranslationXY];
        slideUp.toValue = [NSValue valueWithCGPoint:CGPointMake(0,0)];
        slideUp.toValue = [NSValue valueWithCGPoint:CGPointMake(0,-100)];
        slideUp.springBounciness = 10;
        slideUp.springSpeed = 10;
        slideUp.completionBlock = ^(POPAnimation *animation, BOOL finished){
            [MMNT_SharedVars runPOPSpringAnimation:kPOPViewScaleXY onView:_saveLabel toValue:[NSValue valueWithCGPoint: CGPointMake(1, 1)] springBounciness:15 springSpeed:15 delay:0 forKey:@"scale" completion:nil];
            [MMNT_SharedVars runPOPSpringAnimation:kPOPViewScaleXY onView:_messageLabel toValue:[NSValue valueWithCGPoint: CGPointMake(1, 1)] springBounciness:15 springSpeed:15 delay:0.5 forKey:@"scale" completion:nil];
            [MMNT_SharedVars runPOPSpringAnimation:kPOPViewScaleXY onView:_postLabel toValue:[NSValue valueWithCGPoint: CGPointMake(1, 1)] springBounciness:15 springSpeed:15 delay:1.0 forKey:@"scale" completion:nil];
            [MMNT_SharedVars runPOPSpringAnimation:kPOPViewScaleXY onView:_tweetLabel toValue:[NSValue valueWithCGPoint: CGPointMake(1, 1)] springBounciness:15 springSpeed:15 delay:1.5 forKey:@"scale" completion:nil];
        };

        [_sharePromptView.layer pop_addAnimation:slideUp forKey:@"position"];
        
        
        
        
    }
//    _closeBtn.frame = CGRectMake(0, self.view.frame.size.height-60, self.view.frame.size.width, 60);
//    _closeBtn.transform = CGAffineTransformMakeScale(1,1);
    
}

- (void) buttonPress:(UIButton*)button {
    [UIView animateWithDuration:0.1 animations:^{
        button.transform = CGAffineTransformMakeScale(0.8, 0.8);
    }];
}

- (IBAction)pressedMessage:(id)sender {
    if([MMNTAccountManager sharedInstance].phone.length<1){
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        MMNT_AskPhoneNumberVC *askPhoneVC = (MMNT_AskPhoneNumberVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"askPhoneNumber"];
        askPhoneVC.modalPresentationStyle = UIModalPresentationCustom;
        askPhoneVC.transitioningDelegate = askPhoneVC;
        self.transitioningDelegate = askPhoneVC;
        askPhoneVC.type = @"gallery";
        
        UIViewController *presenter = self.navigationController;
        [presenter presentViewController:askPhoneVC animated:YES completion:nil];
        
    }else{
        //transition
        [self performSegueWithIdentifier:@"transitionWithMessage" sender:_hiddenBtn];
    }
}

-(NSArray *)buttons{
//    NSArray *buttons = @[ _storeBtn, _messageBtn, _facebookBtn, _twitterBtn, _closeBtn];
//    return buttons;
    
    // everything except the exit button
//    NSMutableArray *views = (NSMutableArray *)self.view.subviews;
//    [views removeObject:_closeBtn];
//    return views;
    
    return self.view.subviews;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    MMNT_ShareName *toVC = segue.destinationViewController;
    
    // pressed on a share option
    [[MMNTDataController sharedInstance] setTaskDone:7];
    
    if(sender == _storeBtn){
        toVC.type = STORE;
    }else if(sender == _messageBtn || sender == _hiddenBtn){
        toVC.type = MESSAGE;
    }else if(sender == _facebookBtn){
        toVC.type = FACEBOOK;
    }else if(sender == _twitterBtn){
        toVC.type = TWITTER;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    return [MMNT_TransitionsManager transitionWithOperation:operation andTransitionType:MMNTTransitionScaleInOut];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)pressedCloseBtn:(id)sender {
//    [_closeBtn pop_removeAllAnimations];
//    POPSpringAnimation *a = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
//    a.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0,1.0)];
//    a.springBounciness = 15;
//    a.springSpeed = 10;
//    a.completionBlock = ^(POPAnimation *animation, BOOL finished){
//        
//        
//    };
//    [_closeBtn pop_addAnimation:a forKey:@"scale"];
    
    [self.navigationController.parentViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];

    
}
@end
