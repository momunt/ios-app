//
//  MMNTMessagesController.m
//  Momunt
//
//  Created by Masha Belyi on 7/10/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNTMessagesController.h"
#import "MMNTSavedTrendingViewController.h"
#import "AMWaveTransition.h"
#import "MMNTMessages.h"
#import "MMNTDataController.h"

#import "MMNTAccountManager.h"
#import "MMNT_Chat_Cell.h"

#import "MMNT_AskPhoneNumberVC.h"

@interface MMNTMessagesController ()

@end


@implementation MMNTMessagesController

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0];

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.popToController = [MMNTSavedTrendingViewController class];
    _navC = self.navigationController;
    _navBar = _navC.navBar;
    
    // subscribe to new chats notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatedChatData:)
                                                 name:@"updatedChatData"
                                               object:nil];
    
}
-(void) updatedChatData:(NSNotification*)notif {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData]; // reload tableview to show any new messages
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData]; // reload tableview to show any new messages

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // 0) Check if need phone number
    if([MMNTAccountManager sharedInstance].phone.length<1){
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        MMNT_AskPhoneNumberVC *askPhoneVC = (MMNT_AskPhoneNumberVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"askPhoneNumber"];
        askPhoneVC.modalPresentationStyle = UIModalPresentationCustom;
        askPhoneVC.transitioningDelegate = askPhoneVC;
        self.transitioningDelegate = askPhoneVC;
        
        UIViewController *presenter = self.navigationController.parentViewController;
        [presenter presentViewController:askPhoneVC animated:YES completion:nil];
        
    }
    else{
    
        // 1) show alert to allow push notifications
        if( ![ [[NSUserDefaults standardUserDefaults] valueForKey:@"askedAboutNotifications"] isEqualToString:@"YES"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Let Momunt Send You Push Notifications?"
                                                    message:@"You will be alerted when your friends share momunts with you."
                                                   delegate:self
                                          cancelButtonTitle:@"No Thanks"
                                          otherButtonTitles:@"Notify Me", nil];
            [alert show];
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"askedAboutNotifications"];
        }
    }

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        // store user preference, try again later
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"allowNotifications"];
        
    }else{
        // store user preference
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"allowNotifications"];
        
        // show real push notification permissions dialog
        [[MMNTDataController sharedInstance] askNotificationsPermission];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
//to remove lines between empty cells:
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[MMNTAccountManager sharedInstance] activeChats] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChatRow";
    MMNT_Chat_Cell *cell = [[MMNT_Chat_Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier cellData:[[[MMNTAccountManager sharedInstance] activeChats] objectAtIndex:indexPath.row]];
    cell.delegate = self;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//    MMNTMessages *toVC = (MMNTMessages *)[mainStoryboard instantiateViewControllerWithIdentifier: @"Chat"];
//    MMNTChatObj *chat = [[MMNTAccountManager sharedInstance].Chats objectAtIndex:indexPath.row];
//    toVC.messages = chat.messages;
//    toVC.chatObj = chat;
//    toVC.view.frame = self.view.frame;
//    [_navBar.chatThumbnailView setImageFromImages:chat.memberImages];
//    
//    [self.navigationController pushViewController:toVC animated:YES];
    
}

- (void)dealloc
{
//    [self.navigationController setDelegate:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    MMNTChatController *toVC = [segue destinationViewController];
//    toVC.chatObj = _data;
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


-(void)selectedChat:(MMNTChatObj *)chat{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MMNTMessages *toVC = (MMNTMessages *)[mainStoryboard instantiateViewControllerWithIdentifier: @"Chat"];
//    MMNTChatObj *chat = [[MMNTAccountManager sharedInstance].Chats objectAtIndex:indexPath.row];
    toVC.messages = chat.messages;
    toVC.chatObj = chat;
    toVC.view.frame = self.view.frame;
    [_navBar.chatThumbnailView setImageFromImages:chat.memberImages];
    
    [self.navigationController pushViewController:toVC animated:YES];
}

@end
