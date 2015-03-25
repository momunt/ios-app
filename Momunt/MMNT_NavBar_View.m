//
//  MMNT_NavBar_View.m
//  Momunt
//
//  Created by Masha Belyi on 7/31/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_NavBar_View.h"
#import "MMNTNavigationController.h"
#import "MMNT_NavigationChild_ViewController.h"
#import "AsyncImageView.h"
#import "MMNTAccountManager.h"
#import "MMNT_SharedVars.h"
#import "MMNTMessages.h"
#import "POPSpringAnimation.h"
#import "MMNT_SharedVars.h"
#import "MMNT_SelectContactController.h"
#import "Amplitude.h"

@implementation MMNT_NavBar_View

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:0.3];  // white background
        
        
        // Stroke
        UIView *stroke = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-1, frame.size.width, 1)];
        stroke.backgroundColor = [UIColor colorWithRed:160.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:0.6];
        stroke.alpha = 0.5f;
        [self addSubview:stroke];
        
        // Shadow
        stroke.layer.shadowOffset = CGSizeMake(0, 1);
        stroke.layer.shadowRadius = 1;
        stroke.layer.shadowOpacity = 0.5;

        
        // 1a) Settings circle
        _settingsOutline = [[UIView alloc] initWithFrame:CGRectMake(0,0,60,60)];
        _settingsOutline.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
        _settingsOutline.center = CGPointMake(40, frame.size.height/2);
        _settingsOutline.layer.cornerRadius = 30;
        _settingsOutline.clipsToBounds = YES;
        _settingsOutline.transform = CGAffineTransformMakeScale(0.0001,0.0001);
        [self addSubview:_settingsOutline];
        
        // 1b) Profile Image outline circle
        _profileOutline = [[UIView alloc] initWithFrame:CGRectMake(0,0,60,60)];
        _profileOutline.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        _profileOutline.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        _profileOutline.layer.cornerRadius = 30;
        _profileOutline.clipsToBounds = YES;
        _profileOutline.transform = CGAffineTransformMakeScale(1.08, 1.08);
        [self addSubview:_profileOutline];

        
        // 1b) Profile Image Button
        _profileImgView = [[MMNT_AsyncImage alloc] initWithFrame:CGRectMake(frame.size.width/2-30, 10, 60, 60)];
        _profileImgView.userInteractionEnabled = YES;
        NSString *url = [MMNTAccountManager sharedInstance].profileURl;
        _profileImgView.imageURL = [NSURL URLWithString: url];
        _profileImgView.layer.cornerRadius = 30;
        _profileImgView.clipsToBounds = YES;
//        _profileImgView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.7].CGColor;
//        _profileImgView.layer.borderWidth = 2.0;
        [self addSubview:_profileImgView];
        
        
        _profileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_profileBtn addTarget:self action:@selector(goToStoredMomunts) forControlEvents:UIControlEventTouchUpInside];
        _profileBtn.frame = CGRectMake(frame.size.width/2-50, 0, 100,80);
        _profileBtn.adjustsImageWhenHighlighted = NO;
        [self addSubview:_profileBtn];
 
        _chatThumbnailView = [[MMNT_ChatThumbnail alloc] initWithFrame:CGRectMake(frame.size.width*1.5-30,10,60,60)];
        [self addSubview:_chatThumbnailView];
        
        // 4) Messages Button
        _messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_messageBtn addTarget:self action:@selector(goToMessages) forControlEvents:UIControlEventTouchUpInside];
        _messageBtn.frame = CGRectMake(240, 0, 80, 80);
        UIImage *msgImg = [UIImage imageNamed:@"messages"];
        [_messageBtn setImage:msgImg forState:UIControlStateNormal];
        [_messageBtn setImageEdgeInsets:UIEdgeInsetsMake(20,20,20,20)];
        _messageBtn.adjustsImageWhenHighlighted = NO;
        _messageBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_messageBtn];
        
        // +) Plus button - start a new chat
        _plusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_plusBtn addTarget:self action:@selector(startNewChat) forControlEvents:UIControlEventTouchUpInside];
        _plusBtn.frame = CGRectMake(240, 0, 80, 80);
        UIImage *plusImg = [UIImage imageNamed:@"addMessage"];
        [_plusBtn setImage:plusImg forState:UIControlStateNormal];
        [_plusBtn setImageEdgeInsets:UIEdgeInsetsMake(25, 25, 25, 25)];
        _messageBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _plusBtn.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
        [self addSubview:_plusBtn];

        
        // 5) Settings Button - always go to Settings page
        _settingsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_settingsBtn addTarget:self action:@selector(goToSettingsPage) forControlEvents:UIControlEventTouchUpInside];
        _settingsBtn.frame = CGRectMake(0, 0, 80, 80);
        _settingsBtn.adjustsImageWhenHighlighted = NO;
        UIImage *settingsImg = [UIImage imageNamed:@"Settings"];
        [_settingsBtn setImage:settingsImg forState:UIControlStateNormal];
        [_settingsBtn setImageEdgeInsets:UIEdgeInsetsMake(25, 25, 25, 25)];
        _settingsBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_settingsBtn];
        [_settingsBtn setNeedsLayout];
        
        
        
        // Go Back Button - on Chat Page
        _goBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_goBackBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        _goBackBtn.frame = CGRectMake(frame.size.width, 0, 80, 80);
        _goBackBtn.adjustsImageWhenHighlighted = NO;
        _goBackBtn.hidden = YES;
        // GoBack ImageView
        UIImage *goBackImg = [UIImage imageNamed:@"GoBack"];
        [_goBackBtn setImage:goBackImg forState:UIControlStateNormal];
        [_goBackBtn setImageEdgeInsets:UIEdgeInsetsMake(0,0,0,0)];
        [self addSubview:_goBackBtn];
        
        
        // subscribe to unread count updates
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updatedCount:)
                                                     name:@"updatedTotalUnreadCount"
                                                   object:nil];
        
        _shouldShowBadge = YES;
        _unreadBadge = [[MMNT_UnreadBadge alloc] initWithFrame:CGRectMake(290,25,15,15) num: [MMNTAccountManager sharedInstance].numUnread ];
        [self addSubview:_unreadBadge];
        [UIApplication sharedApplication].applicationIconBadgeNumber = [MMNTAccountManager sharedInstance].numUnread;
        _unreadCount = [MMNTAccountManager sharedInstance].numUnread;
//        [_unreadBadge setCount:_unreadCount];
        [self showBadge];
        
    }
    
        
    return self;
}
-(void) updatedCount:(NSNotification*)notif {
    NSString *num = [[notif userInfo] valueForKey:@"count"];
    _unreadCount = [num integerValue];
    [_unreadBadge setCount:_unreadCount];
    [self showBadge];
//    if(_unreadCount>0 && !_messageBtn.hidden){
//        [_unreadBadge setCount:_unreadCount];
//        _unreadBadge.hidden = NO;
//    }else{
//        _unreadBadge.hidden = YES;
//    }
}

-(void) receivedUserData:(NSDictionary *)user{
    // insert user info into view
    // user: ;, userName, numMomunts, numLocations
}

-(void) goToStoredMomunts{
    [Amplitude logEvent:@"went to home"];
    
    [_navigationController popToRootViewControllerAnimated:YES];
    
    [MMNT_SharedVars runPOPSpringAnimation:kPOPViewScaleXY onView:_profileOutline toValue:[NSValue valueWithCGPoint:CGPointMake(1.08, 1.08)] springBounciness:15 springSpeed:20 delay:0 forKey:@"scale" completion:nil];
    
}
-(void)goBack{
    // return from Chat to messages
    MMNT_NavigationChild_ViewController *vc = _navigationController.currentViewController;
    [vc turnBackToAnOldViewController];
}
// Pop to settings page
-(void) goToSettingsPage{
    [Amplitude logEvent:@"went to settings"];
    
    [MMNT_SharedVars runPOPSpringAnimation:kPOPViewScaleXY onView:_profileOutline toValue:[NSValue valueWithCGPoint:CGPointMake(0.9,0.9)] springBounciness:5 springSpeed:10 delay:0 forKey:@"scale" completion:nil];
//    [MMNT_SharedVars runPOPSpringAnimation:kPOPViewScaleXY onView:_settingsOutline toValue:[NSValue valueWithCGPoint:CGPointMake(0.95,0.95)] springBounciness:5 springSpeed:10 delay:0 forKey:@"scale" completion:^(BOOL finished) {
//        
//        [MMNT_SharedVars runPOPSpringAnimation:kPOPViewScaleXY onView:_settingsOutline toValue:[NSValue valueWithCGPoint:CGPointMake(0,0)] springBounciness:5 springSpeed:10 delay:0 forKey:@"scale" completion:nil];
//    }];
//    
    [[MMNT_SharedVars sharedVars] scaleView:_settingsOutline toVal:CGPointMake(0.95,0.95) withDuration:0.2 completion:^(BOOL done) {
        [[MMNT_SharedVars sharedVars] scaleView:_settingsOutline toVal:CGPointMake(0,0) withDuration:0.2];
    }];
    
    for (UIViewController *controller in self.navigationController.viewControllers) {
        
        //Do not forget to import AnOldViewController.h
        if ([controller.restorationIdentifier isEqualToString:@"Settings"]) {
            [self.navigationController popToViewController:controller animated:YES];
            return;
        }
        
    }
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController *settingsController = (UIViewController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"Settings"];
    [_navigationController pushViewController:settingsController animated:YES];
    
    UIViewController *mmntsController = [_navigationController.viewControllers objectAtIndex:0];
//    UIViewController *settingsController = (UIViewController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"Settings"];
    NSArray *stack = [NSArray arrayWithObjects: mmntsController, settingsController, nil];
    [_navigationController setViewControllers:stack animated:NO];

    
}
-(void)goToMessages{
    [Amplitude logEvent:@"went to messages"];
    
    [MMNT_SharedVars runPOPSpringAnimation:kPOPViewScaleXY onView:_profileOutline toValue:[NSValue valueWithCGPoint:CGPointMake(0.9,0.9)] springBounciness:5 springSpeed:10 delay:0 forKey:@"scale" completion:nil];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController *msgController = (UIViewController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"Messages"];
    [_navigationController pushViewController:msgController animated:YES];
    
    UIViewController *mmntsController = [_navigationController.viewControllers objectAtIndex:0];
////    UIViewController *settingsController = (UIViewController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"Settings"];
    NSArray *stack = [NSArray arrayWithObjects: mmntsController, msgController, nil];
    [_navigationController setViewControllers:stack animated:NO];
    
//    [MMNT_SharedVars runPOPSpringAnimation:kPOPLayerBorderWidth onLayer:_profileImgView.layer toValue:@(0.0) springBounciness:10 springSpeed:15 delay:0 forKey:@"border" completion:nil];
    
}

-(void)goToChatController:(MMNTMessages *)chatVC{
    // make sure we have the correct controllers stack so you can exit from chat
    [Amplitude logEvent:@"went to chat"];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController *msgController = (UIViewController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"Messages"];
//    UIViewController *chatController = (UIViewController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"Chat"];
    
    UIViewController *mmntsController = [_navigationController.viewControllers objectAtIndex:0];
    UIViewController *settingsController = (UIViewController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"Settings"];
    NSArray *stack = [NSArray arrayWithObjects: mmntsController, msgController, chatVC, nil];
    [_navigationController setViewControllers:stack animated:NO];
    
}

-(void)startNewChat{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MMNT_SelectContactController *contactsController = (MMNT_SelectContactController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"ChatContacts"];
    contactsController.type = @"chat";
    contactsController.source = @"menu";
    contactsController.prevVcClass = [_navigationController.currentViewController class];
    
    [_navigationController pushViewController:contactsController animated:YES];

}

// Pop to controller
-(void) popController{
    MMNT_NavigationChild_ViewController *vc = _navigationController.currentViewController;
    [vc turnBackToAnOldViewController];
}

// Present new controller
-(void) presentController{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController *myController = (UIViewController *)[mainStoryboard instantiateViewControllerWithIdentifier: _navigationController.currentViewController.pushTo];
    [_navigationController pushViewController:myController animated:YES];
}

-(void)transitionFrom:(MMNT_NavigationChild_ViewController *)fromVC to:(MMNT_NavigationChild_ViewController *)toVC{
    
    //
    // Settings -> Stored Momunts
    //
//    if([toVC.restorationIdentifier isEqualToString:@"StoredMomunts"]){
    if([toVC.restorationIdentifier isEqualToString:@"SavedTrending"]){
        if([fromVC.restorationIdentifier isEqualToString:@"Settings"]){
           fromVC.currSegue = @"AMWave_right";
        }
        
//        [self showButton:_messageBtn withSpeed:0.2];
        [self showBadge];
        
    }
    //
    // Messages -> *
    //
    if([fromVC.restorationIdentifier isEqualToString:@"Messages"] && ![toVC.restorationIdentifier isEqualToString:@"Chat"]){
        
        //
        // * -> Chat Contacts
        //
        if([toVC.restorationIdentifier isEqualToString:@"ChatContacts"]){
            [[MMNT_SharedVars sharedVars] scaleDown:_plusBtn];
            
        }
        else{
            [self showMessageBtn];
        }
        
    }
    
    //
    // * -> Stored Momunts
    //
      if([toVC.restorationIdentifier isEqualToString:@"SavedTrending"]){
        if(![fromVC.restorationIdentifier isEqualToString:@"Messages"]){
            [self showMessageBtn];
        }
  
    }
    
    
    //
    // * -> Settings
    //
    else if([toVC.restorationIdentifier isEqualToString:@"Settings"]){

        [self showBadge];
        if(![fromVC.restorationIdentifier isEqualToString:@"Messages"]){
            [self showMessageBtn];
        }
        

        
    }
    //
    // Settings -> *
    //
//    else if([fromVC.restorationIdentifier isEqualToString:@"Settings"] && ![toVC.restorationIdentifier isEqualToString:@"StoredMomunts"]){
    else if([fromVC.restorationIdentifier isEqualToString:@"Settings"] && ![toVC.restorationIdentifier isEqualToString:@"SavedTrending"]){
//        _presentBtn.hidden = YES;
        
        if([toVC.restorationIdentifier isEqualToString:@"Messages"]){
            [[MMNT_SharedVars sharedVars] scaleDown:_messageBtn completion:^(BOOL finished) {
                _plusBtn.hidden = NO;
                [[MMNT_SharedVars sharedVars] scaleUp:_plusBtn];
                _messageBtn.hidden = YES;
                [self hideBadge];
            }];
        }
        
    }
    
    //
    // *[!Chat] -> Messages
    //
    else if(![fromVC.restorationIdentifier isEqualToString:@"Chat"] && [toVC.restorationIdentifier isEqualToString:@"Messages"]){
        _shouldShowBadge = NO;
//        _presentBtn.hidden = YES;
        [self hideBadge];
        
        [[MMNT_SharedVars sharedVars] scaleDown:_messageBtn completion:^(BOOL finished) {
            _plusBtn.hidden = NO;
            [[MMNT_SharedVars sharedVars] scaleUp:_plusBtn];
            _messageBtn.hidden = YES;
        }];
        

    }
    //
    // * -> Chat
    //
    else if([toVC.restorationIdentifier isEqualToString:@"Chat"]){
        
        _goBackBtn.hidden = NO;
        _settingsBtn.hidden = YES;
        _plusBtn.hidden = YES;
        _shouldShowBadge = NO;
        
        _messageBtn.hidden = YES;
        [[MMNT_SharedVars sharedVars] scaleDown:_messageBtn];
        _unreadBadge.hidden = YES;
        [self hideBadge];
        
        [UIView animateWithDuration:0.8
                              delay:0
             usingSpringWithDamping:0.6
              initialSpringVelocity:1
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             // move everything left
                             _profileBtn.transform = CGAffineTransformMakeTranslation(-self.frame.size.width, 0);
                             _profileImgView.transform = CGAffineTransformMakeTranslation(-self.frame.size.width, 0);
                             _profileOutline.transform = CGAffineTransformMakeTranslation(-self.frame.size.width, 0);
                             _settingsBtn.transform = CGAffineTransformMakeTranslation(-self.frame.size.width, 0);
                             _plusBtn.transform = CGAffineTransformMakeTranslation(-self.frame.size.width, 0);
                             
                             _goBackBtn.transform = CGAffineTransformMakeTranslation(-self.frame.size.width, 0);
                             _chatThumbnailView.transform = CGAffineTransformMakeTranslation(-self.frame.size.width, 0);
                             
                         } completion:^(BOOL finished) {
                             [self goToChatController:toVC];
                         }];
    }
    //
    // Chat -> Messages
    //
    else if([fromVC.restorationIdentifier isEqualToString:@"Chat"] && [toVC.restorationIdentifier isEqualToString:@"Messages"]){
        _goBackBtn.hidden = YES;
        _settingsBtn.hidden = NO;
        _plusBtn.hidden = NO;
        _messageBtn.hidden = YES;
        
        [UIView animateWithDuration:0.8
                              delay:0
             usingSpringWithDamping:0.6
              initialSpringVelocity:1
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             // move everything right
                             _profileBtn.transform = CGAffineTransformIdentity;
                             _profileImgView.transform = CGAffineTransformIdentity;
                             _profileOutline.transform = CGAffineTransformIdentity;
                             _settingsBtn.transform = CGAffineTransformIdentity;
//                             _messageBtn.transform = CGAffineTransformIdentity;
//                             _unreadBadge.transform = CGAffineTransformIdentity;
                             _plusBtn.transform = CGAffineTransformIdentity;
                             
                             _goBackBtn.transform = CGAffineTransformIdentity;
                             _chatThumbnailView.transform = CGAffineTransformIdentity;
                             
                         } completion:^(BOOL finished) {
                             //
                         }];

    }
}

-(void)showBtnImg:(UIImageView *)imageView withSpeed:(float)t{
    if(![imageView isEqual:_msgImgView]){
        [UIView animateWithDuration:t delay:0 options:UIViewAnimationOptionCurveLinear animations:^{[_settingsImgView setAlpha:0.5f];[_profileImgView setAlpha:0.5f];} completion:nil];
    }
    if(![imageView isEqual:_settingsImgView]){
        [UIView animateWithDuration:t delay:0 options:UIViewAnimationOptionCurveLinear animations:^{[_msgImgView setAlpha:0.5f];[_profileImgView setAlpha:0.5f];} completion:nil];
    }
    if(![imageView isEqual:_profileImgView]){
        [UIView animateWithDuration:t delay:0 options:UIViewAnimationOptionCurveLinear animations:^{[_settingsImgView setAlpha:0.5f];[_msgImgView setAlpha:0.5f];} completion:nil];
    }
    
    [UIView animateWithDuration:t delay:t options:UIViewAnimationOptionCurveLinear animations:^{[imageView setAlpha:1.0f];} completion:nil];
}

-(void)showButton:(UIButton *)button withSpeed:(float)t{
    if(![button isEqual:_messageBtn]){
        [UIView animateWithDuration:t delay:0 options:UIViewAnimationOptionCurveLinear animations:^{[_settingsBtn setAlpha:0.5f];[_profileImgView setAlpha:0.5f];} completion:nil];
    }
    if(![button isEqual:_settingsBtn]){
        [UIView animateWithDuration:t delay:0 options:UIViewAnimationOptionCurveLinear animations:^{[_messageBtn setAlpha:0.5f];[_profileImgView setAlpha:0.5f];} completion:nil];
    }
    if(![button isEqual:_profileBtn]){
        [UIView animateWithDuration:t delay:0 options:UIViewAnimationOptionCurveLinear animations:^{[_settingsBtn setAlpha:0.5f];[_messageBtn setAlpha:0.5f];} completion:nil];
        [UIView animateWithDuration:t delay:t options:UIViewAnimationOptionCurveLinear animations:^{[_profileImgView setAlpha:1.0f];} completion:nil];
    }
    
    [UIView animateWithDuration:t delay:t options:UIViewAnimationOptionCurveLinear animations:^{[button setAlpha:1.0f];} completion:nil];
}
-(void)showBadge{
    if(_unreadCount>0 && _shouldShowBadge){
        _unreadBadge.hidden = NO;
        [[MMNT_SharedVars sharedVars] scaleUp:_unreadBadge];
    }else{
        [[MMNT_SharedVars sharedVars] scaleDown:_unreadBadge completion:^(BOOL finished) {
            _unreadBadge.hidden = YES;;
        }];
        
    }
}
-(void)hideBadge{
    [[MMNT_SharedVars sharedVars] scaleDown:_unreadBadge completion:^(BOOL finished) {
        _unreadBadge.hidden = YES;
    }];
}
-(void)showMessageBtn{
    [[MMNT_SharedVars sharedVars] scaleDown:_plusBtn completion:^(BOOL finished) {
        _shouldShowBadge = YES;
        _messageBtn.hidden = NO;
        [[MMNT_SharedVars sharedVars] scaleUp:_messageBtn];
        [self showBadge];
        _plusBtn.hidden = YES;
    }];
}

-(void)setMessages{
    _goBackBtn.hidden = YES;
    _settingsBtn.hidden = NO;
    _plusBtn.hidden = NO;
    _messageBtn.hidden = YES;
    
    _profileBtn.transform = CGAffineTransformIdentity;
    _profileImgView.transform = CGAffineTransformIdentity;
    _profileOutline.transform = CGAffineTransformIdentity;
    _settingsBtn.transform = CGAffineTransformIdentity;
    _plusBtn.transform = CGAffineTransformIdentity;
                         
    _goBackBtn.transform = CGAffineTransformIdentity;
    _chatThumbnailView.transform = CGAffineTransformIdentity;

}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
