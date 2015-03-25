//
//  MMNTNavigationController.m
//  Momunt
//
//  Created by Masha Belyi on 7/10/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNTNavigationController.h"
//#import "MMNTStoredMomuntsController.h"
#import "MMNTSavedTrendingViewController.h"
#import "MMNT_NavBar_View.h"
#import "MMNT_NavigationChild_ViewController.h"
#import "AMWaveTransition.h"
#import "MMNT_RowSelection_Transition.h"
#import "MMNTObj.h"
#import "MMNTChatObj.h"
#import "MMNTDataController.h"
#import "MMNTMessages.h"
#import "MMNTMessagesController.h"
#import "MMNTAccountManager.h"
#import "MMNTViewController.h"
#import "MMNT_SelectContactController.h"


@interface MMNTNavigationController () <UINavigationControllerDelegate>

@end

@implementation MMNTNavigationController

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
    [self setDelegate:self];
    // Push To Stored Momunts
//    [self pushViewController:[self getCurrentView] animated:NO];

    
    
    // subscribe to show chat notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showChat:)
                                                 name:@"showChat"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showMessages:)
                                                 name:@"showMessages"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showContacts:)
                                                 name:@"showContacts"
                                               object:nil];

    
    // subscribe to shared momunts
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sharedMomunt:)
                                                 name:@"sharedMomunt"
                                               object:nil];
    
    // subscribe to open from push notificaton
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openedNotification:)
                                                 name:@"openedNotification"
                                               object:nil];
    
    if([MMNTDataController sharedInstance].openedFromNotification){
        // push chat view
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        MMNTMessages *toVC = (MMNTMessages *)[mainStoryboard instantiateViewControllerWithIdentifier: @"Chat"];
        self.currentViewController = toVC;
        [self pushViewController:toVC animated:NO];
        
        // when ready - display correct chat
        CGFloat chatId = [[MMNTDataController sharedInstance].openChatId floatValue];
        MMNTChatObj *theChat = [[MMNTAccountManager sharedInstance] getChatById:chatId];
        [toVC updateChat:theChat];
    }
    
    self.onMyMomunts = YES;
    
    
}

-(void)sharedMomunt:(NSNotification*)notif {
    NSArray *recipients = [[notif userInfo] valueForKey:@"recipients"];
    MMNTObj *momunt = [[notif userInfo] valueForKey:@"momunt"];
    
    // create chat
    MMNTChatObj *theChat = [[MMNTDataController sharedInstance] startChat:recipients];
    
    // post new message to chat
    NSString *dateString;
    if(momunt.live){
        dateString = @"live";
    }else{
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormat setDateFormat:@"MMMM dd, yyyy"];
        dateString = [dateFormat stringFromDate:momunt.timestamp];
    }
    
    NSDictionary *msg = @{ @"text"         : @" ",
                           @"momuntId"     : momunt.momuntId,
                           @"momuntPoster" : momunt.poster,
                           @"momuntName"   : momunt.name,
                           @"momuntDate"   : dateString
                        };
    NSData *msgData = [NSJSONSerialization dataWithJSONObject:msg options:0 error:nil];
    NSString *msgString = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
    
    NSDictionary *data = @{ @"message"     : msgString,
                            @"username" : [MMNTAccountManager sharedInstance].username,
                            @"profileUrl" : [MMNTAccountManager sharedInstance].profileURl,
                            @"chatId" : [NSString stringWithFormat:@"%i",theChat.chatId] ,
                            @"isRead" : [NSNumber numberWithBool:YES]
                            };
    MMNTMessageObj *newMessage = [[MMNTMessageObj alloc] initWithDict:data];
    
    
    // push to chat messages view
    [self goChatWith:theChat addMessage:newMessage];
}
-(void)openedNotification:(NSNotification*)notif {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MMNTMessages *toVC = (MMNTMessages *)[mainStoryboard instantiateViewControllerWithIdentifier: @"Chat"];
    toVC.view.frame = self.view.frame;
//    [_navBar.chatThumbnailView setImageFromImages:theChat.memberImages];
    
    
    self.currentViewController = toVC;
    [self pushViewController:toVC animated:NO];
    
    // when ready - display correct chat
    CGFloat chatId = [[[notif userInfo] valueForKey:@"chatId"] floatValue];
    MMNTChatObj *theChat = [[MMNTAccountManager sharedInstance] getChatById:chatId];
//    MMNTChatObj *theChat = [[[MMNTDataController sharedInstance] APIcommunicator] fetchChatById:chatId];
    [toVC updateChat:theChat];

}

- (void)goChatWith:(MMNTChatObj *)theChat addMessage:(MMNTMessageObj  *)message{
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MMNTMessages *toVC = (MMNTMessages *)[mainStoryboard instantiateViewControllerWithIdentifier: @"Chat"];
    toVC.messages = theChat.messages;
    toVC.chatObj = theChat;
    toVC.view.frame = self.view.frame;
    [_navBar.chatThumbnailView setImageFromImages:theChat.memberImages];
    
    [toVC postMessage:message];
    toVC.willDropDown = YES;
    self.currentViewController = toVC;
    [self pushViewController:toVC animated:NO];
    
    // POST NOTIFICATION to show chat view
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showChat"
                                                        object:self
                                                      userInfo:nil];
    
}

-(void)showChat:(NSNotification*)notif {
    MMNTChatObj *chat = (MMNTChatObj *)[[notif userInfo] objectForKey:@"chatObj"];

    if([self.visibleViewController.restorationIdentifier isEqualToString:@"Chat"]){
        MMNTMessages *VC = (MMNTMessages *)self.visibleViewController;
        if(VC.chatObj.chatId == chat.chatId){
            return;
        }
        VC.chatObj = chat;
        VC.messages = chat.messages;
        [_navBar.chatThumbnailView setImageFromImages:chat.memberImages];
        VC.willDropDown = YES;
        [VC.tableView reloadData];
    }
    else{
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        MMNTMessages *VC = (MMNTMessages *)[mainStoryboard instantiateViewControllerWithIdentifier: @"Chat"];
        VC.messages = chat.messages;
        VC.chatObj = chat;
        VC.view.frame = self.view.frame;
        [_navBar.chatThumbnailView setImageFromImages:chat.memberImages];
        VC.willDropDown = YES;
        [VC.tableView reloadData];
        self.currentViewController = VC;
        [self pushViewController:VC animated:NO];
    }
}
-(void)showMessages:(NSNotification*)notif {
    if([self.visibleViewController.restorationIdentifier isEqualToString:@"Messages"]){
        MMNTMessagesController *VC = (MMNTMessagesController *)self.visibleViewController;
        [VC.tableView reloadData];
        [_navBar setMessages];
    }
    else{
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        [_navBar setMessages];
        
        MMNTMessagesController *VC = (MMNTMessagesController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"Messages"];
        [self pushViewController:VC animated:NO];

    }
}

-(void)showContacts:(NSNotification*)notif {
//    _navBar
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MMNT_SelectContactController *contactsController = (MMNT_SelectContactController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"ChatContacts"];
    contactsController.type = @"share";
    contactsController.source = @"menu";
    contactsController.prevVcClass = self.currentViewController ? [self.currentViewController class] : [[self.viewControllers firstObject] class];
    self.delegate = contactsController;
    [self pushViewController:contactsController animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
//    [self.navigationController get
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(MMNT_NavigationChild_ViewController *)getCurrentView{
    if(self.currentViewController == NULL){
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        MMNTSavedTrendingViewController *myController = (MMNTSavedTrendingViewController *)[mainStoryboard
                                                              instantiateViewControllerWithIdentifier:@"SavedTrending"];
        
//        MMNTSavedTrendingViewController *myController = [[MMNTSavedTrendingViewController alloc] init];
        myController.childNavController.delegate = myController;
        
        self.currentViewController = myController;
    }
    
    return self.currentViewController;
}
//-(void) setCurrentViewController:(UIViewController *)vc{
//    NSLog(@"Setting new current vc");
//    self.currentViewController = vc;
//}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    NSLog(@"popped controller");
    UIViewController *poppedCtrl = [super popViewControllerAnimated:NO];
    return poppedCtrl;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [super pushViewController :viewController animated:animated];
    
    UIViewController *fromVC = self.currentViewController;
    self.currentViewController = viewController;
    [self.navBar transitionFrom:fromVC to:self.currentViewController];
    
    MMNTViewController *mainVC = self.parentViewController;
//    [mainVC restartTipTimer]; // reset tip timer
    


}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    MMNT_NavigationChild_ViewController *fromVC = self.currentViewController;
    self.currentViewController = viewController;
    [self.navBar transitionFrom:fromVC to:self.currentViewController];
    
    NSArray *poppedCtrls = [super popToViewController:viewController animated:animated];
    return poppedCtrls;
    
    MMNTViewController *mainVC = self.parentViewController;
//    [mainVC restartTipTimer]; // reset tip timer
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated{
//    MMNT_NavigationChild_ViewController *fromVC = self.currentViewController;
    UIViewController *fromVC = self.currentViewController;
    self.currentViewController = [self.viewControllers objectAtIndex:0];
    [self.navBar transitionFrom:fromVC to:self.currentViewController];
    
    NSArray *poppedCtrls = [super popToRootViewControllerAnimated:animated];
    return poppedCtrls;
    
    MMNTViewController *mainVC = self.parentViewController;
    [mainVC restartTipTimer]; // reset tip timer
}


- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{

    NSArray *sT = [NSArray arrayWithObjects: @"MMNT_ConnectWithSocial_ViewController", @"MMNT_Password_ViewController", @"MMNT_Feedback_ViewController",nil];
    NSArray *ids = [NSArray arrayWithObjects: @"1", @"4", @"0", nil];
    BOOL fromSelection = [sT containsObject:fromVC.restorationIdentifier];
    BOOL toSelection = [sT containsObject:toVC.restorationIdentifier];
    
    
    if(fromSelection || toSelection){
//        NSArray* parts = [self.currSegue componentsSeparatedByString: @"_"];
//        NSString* idStr = [parts objectAtIndex: 2];
//        
//        NSInteger id = [idStr intValue];
        NSInteger idx = [ids objectAtIndex:[sT indexOfObject: operation==UINavigationControllerOperationPush ? toVC.restorationIdentifier : fromVC.restorationIdentifier]];
        
        return [MMNT_RowSelection_Transition transitionWithOperation:operation andRowIndex:&idx andDirection:@"left"];
    }else{
        return [AMWaveTransition transitionWithOperation:operation andTransitionType:AMWaveTransitionTypeNervous andDirection:@"right"];
    }
    
    
    
    
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

@end
