//
//  MMNTMessages.m
//  Momunt
//
//  Created by Masha Belyi on 10/4/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNTMessages.h"
#import "AMWaveTransition.h"
#import "MMNTMessagesController.h"
#import "MMNT_BubbleTableCell.h"
#import "MMNTMessageObj.h"
#import "MMNTAccountManager.h"
#import "MMNTDataController.h"
#import "MMNTNavigationController.h"
#import "MMNT_SharedVars.h"
#import "LocationController.h"
#import "MMNT_SavedMomunt_Cell.h"
#import "Amplitude.h"

@interface MMNTMessages (){
    CGPoint lastOffset;
    NSTimeInterval lastOffsetCapture;
    BOOL isScrollingFast;
}
@property BOOL openedNew;
@property BOOL reloading;
@property BOOL exiting;
@property CGPoint originalCenter;
@property CGPoint originalTableCenter;
@property CGRect originalInputViewFrame;
@property CGRect originalInputFieldFrame;
@property CGFloat tableKeyboardOffset;
@property BOOL isPlaceholder;
@property CGFloat kbHeight;
@property BOOL isKbOpen;
@property BOOL loadedAllMessages;
@property BOOL scrollingAfterReload;

@property CGFloat numLocationFetch;
@property CLLocation *fetchedLocation;

@end

@implementation MMNTMessages

#if !defined(MIN)
#define MIN(A,B)((A) < (B) ? (A) : (B))
#endif

#if !defined(MAX)
#define MAX(A,B)((A) > (B) ? (A) : (B))
#endif

#define KEYBOARD_H 150.0


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
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.separatorColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.delaysContentTouches = NO;
    
    self.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0]; // clear background
    [self.navigationController setDelegate:self];

    _messageInput.delegate = self;
    [self resetTextView:_messageInput];
    _messageInput.scrollEnabled = NO;

    _originalTableCenter = CGPointMake(-1, -1);
    
    CGRect frame = _messageInput.frame;
    frame.size.height = [_messageInput sizeThatFits:CGSizeMake(_messageInput.frame.size.width, CGFLOAT_MAX)].height;
    [_messageInput setFrame:frame];

    _locationPin.tintColor = [UIColor colorWithWhite:1 alpha:1];
    UIImage *img = [_locationPin imageForState:UIControlStateNormal];
    UIImage *tintedImg = [self tintImage:img WithColor:[UIColor colorWithWhite:1 alpha:1] ];
    [_locationPin setImage:tintedImg forState:UIControlStateNormal];
    
    // listen for the keyboard slide up/down
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _isPlaceholder = YES;
    
    _checkButton.hidden = YES;
    _checkButton.transform = CGAffineTransformMakeScale(0.0001, 0.00001);
    
    if([_messages count]<20){
        _loadedAllMessages = YES;
    }
    
    // subscribe to new chats notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatedChatWithId:)
                                                 name:@"updatedChatWithId"
                                               object:nil];
    
    // Resign keyboard when click out of textfield
    UITapGestureRecognizer *clickout = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedOut:)];
    [self.view addGestureRecognizer:clickout];
    
//    
//    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
//    panGesture.delegate = self;
//    [_tableView addGestureRecognizer:panGesture];
}
-(void)updatedChatWithId:(NSNotification*)notif {
    NSInteger chatId = [(NSString *)[[notif userInfo] valueForKey:@"chatId"] integerValue];
    if(chatId == self.chatObj.chatId){
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
            [_tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: [_messages count]-1 inSection: 0] atScrollPosition: UITableViewScrollPositionTop animated: YES]; // WAS animated:NO - not sure why?? 11/29/14
        });
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setDelegate:self];
    
    if([_messages count]<20){
        _loadedAllMessages = YES;
    }
    
}
-(void)showKeyboard{
    [_messageInput becomeFirstResponder];
}
- (void)dismissKeyboard {
    [_messageInput resignFirstResponder];
}
-(void)clickedOut:(UITapGestureRecognizer *)recognizer{
    CGPoint touchPoint = [recognizer locationInView: self.view];
    //if(touchPoint.y < self.view.frame.size.height-(_isKbOpen ? _kbHeight : 0) -60){
    if(touchPoint.y < _messageInputView.frame.origin.y-40){
        [_messageInput resignFirstResponder];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    _openedNew = YES;
//    _messageInputView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.28];
    _messageInputView.backgroundColor = [UIColor clearColor];
    _messageInputView.frame = CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50);
    
    _originalCenter = self.view.center;
    _originalInputViewFrame = _messageInputView.frame;
    _originalInputFieldFrame = _messageInput.frame;
    
    _originalTableCenter = _tableView.center;
    [self verticallyPositionTable];
    
    // scroll to bottom
//    [self reloadedTableView];
    NSIndexPath* ipath = [NSIndexPath indexPathForRow: [_messages count]-1 inSection: 0];
    [_tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: NO];
    
    // update chat thumbnail
    MMNTNavigationController *nav  = self.navigationController;
    [nav.navBar.chatThumbnailView setImageFromImages:_chatObj.memberImages];
    
    // subscribe to message notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedMessage:)
                                                 name:@"receivedMessage"
                                               object:nil];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
//    [_messageInput resignFirstResponder];
    
    [super viewWillDisappear:animated];
    
    // update num unread
    [[MMNTAccountManager sharedInstance] countTotalUnread];
}

-(void)updateChat:(MMNTChatObj *)chat{
    self.messages = chat.messages;
    self.chatObj = chat;
    
    [_tableView reloadData];
    
    MMNTNavigationController *nav  = self.navigationController;
    [nav.navBar.chatThumbnailView setImageFromImages:chat.memberImages];
    
}

- (UIImage *)tintImage:(UIImage *)image WithColor:(UIColor *)tintColor
{
    // It's important to pass in 0.0f to this function to draw the image to the scale of the screen
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    UIRectFill(bounds);
    [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

// reload data if received message for this chatID
-(void) receivedMessage:(NSNotification*)notif {
    MMNTMessageObj* message = (MMNTMessageObj*)[[notif userInfo] valueForKey:@"message"];
    if(message.chatId == _chatObj.chatId){
//        [_messages addObject:message];
        // and reload table
        _reloading = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
            [self reloadedTableView];
        });
        
    }
}
-(void)reloadedTableView{
//    // only scroll if was at the bottom of the chat??????
//    float bottomEdge = _tableView.contentOffset.y + _tableView.frame.size.height;
//    if (bottomEdge < scrollView.contentSize.height) { // means user is scrolling through chat
//         // adjust content offset
//        return;
//    }
   
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: [_messages count]-1 inSection: 0];
        [UIView animateWithDuration:0.2 animations:^{
            [_tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: NO];
            [self verticallyPositionTable];
        } completion:^(BOOL finished) {
            if([_messages count] > 20){
                _scrollingAfterReload = YES;
                
                NSRange r;
                r.location = 0;
                r.length = [_messages count] -20;
                [_messages removeObjectsInRange:r];
                [_tableView reloadData];
                [_tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: [_messages count]-1 inSection: 0] atScrollPosition: UITableViewScrollPositionTop animated: NO];
                
            }
        }
         ];
        _tableKeyboardOffset = _tableView.contentOffset.y;
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)turnBackToAnOldViewController{
    
    for (UIViewController *controller in self.navigationController.viewControllers) {
        
        //Do not forget to import AnOldViewController.h
        if ([controller isKindOfClass:[MMNTMessagesController class]]) {
            
            [self.navigationController popToViewController:controller
                                                  animated:YES];
            break;
        }
    }
    
}

- (NSArray*)visibleCells
{
    NSMutableArray *animated = [[self.tableView visibleCells] mutableCopy];
    [animated addObject:_messageInputView];
    return [NSArray arrayWithArray:animated];
    
}
-(UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.tableView cellForRowAtIndexPath:indexPath];
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _scrollingAfterReload = NO;
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{

}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y == 0 && [_messages count]>=20 && !_loadedAllMessages){
        [self loadMoreChats];
    }
    
    // Measure speed
    CGPoint currentOffset = scrollView.contentOffset;
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    
    NSTimeInterval timeDiff = currentTime - lastOffsetCapture;
    if(timeDiff > 0.1) {
        CGFloat distance = currentOffset.y - lastOffset.y;
        //The multiply by 10, / 1000 isn't really necessary.......
        CGFloat scrollSpeedNotAbs = (distance * 10) / 1000; //in pixels per millisecond
        
        CGFloat scrollSpeed = fabsf(scrollSpeedNotAbs);
        if (scrollSpeed > 0.7 && scrollSpeedNotAbs<0 && ! _scrollingAfterReload) {
            isScrollingFast = YES;
            [_messageInput resignFirstResponder];
        } else {
            isScrollingFast = NO;
        }
        
        lastOffset = currentOffset;
        lastOffsetCapture = currentTime;
    }
}
-(void)loadMoreChats{
    MMNTMessageObj *lastMsg = [_messages objectAtIndex:0];
    NSInteger maxId = lastMsg.messageId;
    
    [[MMNTApiCommuniator sharedInstance] fetchMessagesForChat:_chatObj.chatId maxMessage:maxId completion:^(NSMutableArray *obj) {
        if([obj count] == 0){
            // reached beginning of chat
            _loadedAllMessages = YES;
            [_tableView reloadData];
            return;
        }
        _messages = [NSMutableArray arrayWithArray: [obj arrayByAddingObjectsFromArray:_messages] ];
        CGSize beforeContentSize = _tableView.contentSize;
        [_tableView reloadData];
        CGSize afterContentSize = _tableView.contentSize;
        CGFloat yOffset = afterContentSize.height-beforeContentSize.height;
        _tableView.contentOffset = CGPointMake(0, yOffset);
        

        
    }];
}

/*
 Send Message
 */
- (IBAction)pressedSend:(id)sender {
//    [_checkButton onTouchUp];
    // post message
    NSString *text = _messageInput.text;
    if([text length] > 0 && !_isPlaceholder){
        
        // post message
        NSDictionary *msg = @{ @"text"     : text};
        NSData *msgData = [NSJSONSerialization dataWithJSONObject:msg options:0 error:nil];
        NSString *msgString = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
        
        NSDictionary *data = @{ @"message"     : msgString,
                                @"username" : [MMNTAccountManager sharedInstance].username,
                                @"profileUrl" : [MMNTAccountManager sharedInstance].profileURl,
                                @"chatId" : [NSString stringWithFormat:@"%i",_chatObj.chatId] ,
                                @"isRead" : [NSNumber numberWithBool:YES],
                                @"timestamp" : [NSString stringWithFormat:@"%f",[[NSDate new] timeIntervalSince1970]]
                                };
        MMNTMessageObj *newMessage = [[MMNTMessageObj alloc] initWithDict:data];

        // update tableview
        [_messages addObject:newMessage];
        

         // reset input field
        [self clearTextView:_messageInput];
        
        [[MMNTAccountManager sharedInstance] addOrUpdate:_chatObj atIdx:0];
        
        // hide SEND button
        [[MMNT_SharedVars sharedVars] scaleDown:_checkButton completion:^(BOOL finished) {
            _checkButton.hidden = YES;
            
            // and reload table
            _reloading = YES;
            [_tableView reloadData];
            [self reloadedTableView];

        }];
        
        // post the message
        NSMutableArray *recipients = [[NSMutableArray alloc] init];
        for (int i = 0; i < [_chatObj.members count]; i++) {
            NSDictionary *member = _chatObj.members[i];
            [recipients addObject:[member objectForKey:@"userId"]];
        }
        [[MMNTDataController sharedInstance] postChatMessage:newMessage toRecipients:recipients];
        
        
        // if didnt allow notifications - ask again here
        [self performSelector:@selector(checkPushNotifications) withObject:nil afterDelay:0.5];
        
        
    }
    
}

-(void)postMessage:(MMNTMessageObj *) message{
    [[MMNTDataController sharedInstance] postChatMessage:message toRecipients:_chatObj.members];
    
    // update tableview
    [_messages addObject:message];
    
    // update chats data
    [[MMNTAccountManager sharedInstance] addOrUpdate:_chatObj atIdx:0];
    
    // reset input field
    [self resetTextView:_messageInput];
    
    // and reload table
    _reloading = YES;
    [_tableView reloadData];
    [self reloadedTableView];

    // if didnt allow notifications - ask again here
    [self performSelector:@selector(checkPushNotifications) withObject:nil afterDelay:0.5];
}

/*
 NOTIFICATION PERMISSIONS
 ----------------------------------------------------------------------------------------------------------------------------------------------------------------
  */
-(void)checkPushNotifications{
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"allowNotifications"] isEqualToString:@"NO"]){
        // 1) show alert to allow push notifications
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Let Momunt Send You Push Notifications?"
                                                        message:@"Would you like to be alerted when your friend responds to you?"
                                                       delegate:self
                                              cancelButtonTitle:@"No Thanks"
                                              otherButtonTitles:@"Notify Me", nil];
        [alert show];
        
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        // store user preference, don't try again
        [[NSUserDefaults standardUserDefaults] setObject:@"NEVER" forKey:@"allowNotifications"];
        
    }else{
        // store user preference
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"allowNotifications"];
    }
    
    // show real push notification permissions dialog, no matter what the user selected before. This is their last chance
    [[MMNTDataController sharedInstance] askNotificationsPermission];
    
}
/* ---------------------------------------------------------------------------------------------------------------------------------------------------------------- */

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self killScroll];
//    [_messageInputView resignFirstResponder];
    [super prepareForSegue:segue sender:sender];
    _exiting = YES;
    _chatObj.numUnread = 0;
    
    
    
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    return [AMWaveTransition transitionWithOperation:operation andTransitionType:AMWaveTransitionTypeNervous andDirection:@"right"];
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // update data
    _messagesWithTime = [self messagesWithTstamps];
    // Return the number of rows in the section.
    return [_messages count] > 0 ? [_messages count]+2 : 1; // add a blank spacer row at the end & loader row at the beginning
}

// to remove lines between empty cells:
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        return _loadedAllMessages ? 10.0f : 30.0f;
    }
    if(indexPath.row == [_messages count]+1){
        return 15.0f;
    }
    else{
    
        // height depends on message length
        MMNTMessageObj *msg = [_messagesWithTime objectAtIndex:indexPath.row-1];
        
//        NSDate *t = msg.timestamp;
//        NSDate *now = [NSDate new];
        
        
        CGFloat height = [msg.message objectForKey:@"momuntId"] ? 125.00 : [MMNT_ChatBubble getHeightForMessage:msg.message];
    
        CGFloat add = 4.0;
        if(indexPath.row <= [_messages count]-0){
            if(indexPath.row == [_messages count]){
                return height + (msg.needsTimestamp ? 30 : 0);
            }
            MMNTMessageObj *msg = [_messages objectAtIndex:indexPath.row-1];
            MMNTMessageObj *next = [_messages objectAtIndex:indexPath.row];

//            if(msg.needsTimestamp){
//                
//                add =  ([msg.message objectForKey:@"momuntId"] && [next.message objectForKey:@"momuntId"]) ? 30.0 : 34.0;
//            }
            
            if([msg.message objectForKey:@"momuntId"] && [next.message objectForKey:@"momuntId"]){
                add = 0 + (msg.needsTimestamp ? 30 : 0);
            }
            else if( ([msg.message objectForKey:@"momuntId"] && ![next.message objectForKey:@"momuntId"]) ||
                    (![msg.message objectForKey:@"momuntId"] && [next.message objectForKey:@"momuntId"]) ){
                add = 15.0 + (msg.needsTimestamp ? 30 : 0);
            }
            else if([msg.username isEqualToString:next.username]){ //text chats
                add = 4.0 + (msg.needsTimestamp ? 30 : 0);
            }
            else{ // text chats from different users
                add = 15.0  + (msg.needsTimestamp ? 30 : 0);
            }

        }
        
        return height + add;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *messagesWithTime = [self messagesWithTstamps];
    
    if(indexPath.row == [_messages count]+1 || [_messages count]==0){
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chatcell"];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }

    if(indexPath.row == 0){ // first cell - loading
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chatcell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.text = @"loading more chats...";
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
        cell.textLabel.textColor = _loadedAllMessages ? [UIColor colorWithWhite:1.0 alpha:0.0] : [UIColor colorWithWhite:1.0 alpha:0.5];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        return cell;

    }
    else{
        static NSString *CellIdentifier = @"MessageRow";
        BOOL needProfile  = YES;
        if(indexPath.row > 1){
            MMNTMessageObj *msg = [_messages objectAtIndex:indexPath.row-1];
            MMNTMessageObj *prev = [_messages objectAtIndex:indexPath.row-2];
            needProfile  = ![msg.username isEqualToString:prev.username];
        }
        MMNTMessageObj *msg = [messagesWithTime objectAtIndex:indexPath.row-1];
        if([msg.message objectForKey:@"momuntId"]){
            static NSString *CellIdentifier = @"StoredMomuntRow";
            
            MMNT_SavedMomunt_Cell *cell = [[MMNT_SavedMomunt_Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier messageData:msg];
            cell.tableView = _tableView;
            cell.indexPath = indexPath;
            cell.parentVC = self;
            return cell;
        }else{
            
//            MMNT_BubbleTableCell *cell = (MMNT_BubbleTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//            if(cell==nil){
                MMNT_BubbleTableCell *cell = [[MMNT_BubbleTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier cellData:msg profile:needProfile];
//                cell = [[MMNT_BubbleTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier cellData:msg profile:needProfile];
//            }
            return cell;
        }
    
        
    }
}


#pragma mark - UITextField Delegate

//- (BOOL)textFieldShouldReturn:(UITextField *)textField { // return on return keypress
//    [textField resignFirstResponder];
//    return NO;
//}
-(void)resetTextView:(UITextView *)textView{
    [textView setText:@"Write something awesome"];
    textView.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    _isPlaceholder = YES;
//    [textView setTextColor:[UIColor darkGrayColor]];
}
-(void)clearTextView:(UITextView *)textView{
    _isPlaceholder = NO;
    textView.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    
    [textView setText:@""];
    [UIView animateWithDuration:0.2 animations:^{
        textView.frame = _originalInputFieldFrame;
        
        CGRect viewFrame = _originalInputViewFrame;
        viewFrame.origin.y = _originalInputViewFrame.origin.y - _kbHeight;
        _messageInputView.frame = viewFrame;
        
        if(_tableView.contentSize.height < _tableView.frame.size.height){
            CGFloat emptyH =  _tableView.frame.size.height - _tableView.contentSize.height;
            if(_kbHeight-emptyH > 0){
                _tableView.center = CGPointMake(_originalTableCenter.x, _originalTableCenter.y-(_kbHeight-emptyH));
            }
        }else{
            _tableView.center = CGPointMake(_originalTableCenter.x, _originalTableCenter.y-_kbHeight);
        }
    }];
}

-(void)verticallyPositionTable{
    if(_originalTableCenter.x==-1){
        return;
    }
    
    if(_tableView.contentSize.height < _tableView.frame.size.height){
        CGFloat emptyH =  _tableView.frame.size.height - _tableView.contentSize.height;
        if(_kbHeight-emptyH > 0){
            _tableView.center = CGPointMake(_originalTableCenter.x, _originalTableCenter.y-(_kbHeight-emptyH));
        }
    }else{
        _tableView.center = CGPointMake(_originalTableCenter.x, _originalTableCenter.y-_kbHeight - (_messageInputView.frame.size.height - _originalInputViewFrame.size.height));
    }
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if (_isPlaceholder) {
//    if(textView.alpha == 0.9){
        textView.text = @"";
        textView.textColor = [UIColor whiteColor];
//        [textView setAlpha:1.0];
        _isPlaceholder = NO;
        _originalTableCenter = _tableView.center;
    }
    
    return YES;
}

//-(void) textViewDidChange:(UITextView *)textView
//{
//    if(textView.text.length == 0){
//        _isPlaceholder = YES;
//        textView.text = @"Write something awesome";
//        [textView resignFirstResponder];
//    }
//}

/*
 Slide view up when keyboard appears
 */
- (void)keyboardWillShow:(NSNotification *)note
{
    // check if KB ON?
    if(_isKbOpen){return;}
    if(!_kbHeight){
        NSDictionary* info = [note userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        _kbHeight = kbSize.height - 50;
    }
    _tableKeyboardOffset = _tableView.contentOffset.y;
    _originalTableCenter = _tableView.center;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        _tableKeyboardOffset = 0;
        CGFloat a = _tableView.frame.size.height-_kbHeight;
        if(_tableView.contentSize.height > (_tableView.frame.size.height-_kbHeight)){
            
            if(_tableView.contentSize.height < _tableView.frame.size.height){
                CGFloat emptyH =  _tableView.frame.size.height - _tableView.contentSize.height;
                _tableView.center = CGPointMake(_tableView.center.x, _tableView.center.y-(_kbHeight-emptyH));
            }else{
                _tableView.center = CGPointMake(_tableView.center.x, _tableView.center.y-_kbHeight);
            }
        }
        self.messageInputView.center = CGPointMake(self.messageInputView.center.x, self.messageInputView.center.y-_kbHeight);
//        _checkButton.transform = CGAffineTransformIdentity;
        
    }completion:nil];
    _isKbOpen = YES;
    
    
}
- (void)keyboardWillHide:(NSNotification *)note
{
    _isKbOpen = NO;
    if([_messageInput.text isEqualToString:@""]){
        [self resetTextView:_messageInput];
    }
    [UIView animateWithDuration:(_exiting ? 0 : 0.3) animations:^{
        if(_tableView.contentSize.height > _tableView.bounds.size.height-_kbHeight){
            _tableView.center = _originalTableCenter;
//            _tableView.center = CGPointMake(_tableView.center.x, _tableView.center.y+_kbHeight);
        }
        self.messageInputView.center = CGPointMake(self.messageInputView.center.x, self.messageInputView.center.y+_kbHeight);
        self.messageInput.frame = _originalInputFieldFrame;
//        _checkButton.transform = CGAffineTransformMakeTranslation(100, 0);
    }];
    
    
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    // scroll up table view and input filed if needed. React to text view height changes
    NSString *newString = [_messageInput.text stringByReplacingCharactersInRange:range withString:text];
    if([newString isEqualToString:@""]){
        //hide send
        [[MMNT_SharedVars sharedVars] scaleDown:_checkButton completion:^(BOOL finished) {
            _checkButton.hidden = YES;
        }];
//        [UIView animateWithDuration:0.3 animations:^{
//             _checkButton.transform = CGAffineTransformMakeTranslation(100, 0);
//        }];
        
    }
    else{
        // show send
        _checkButton.hidden = NO;
        [[MMNT_SharedVars sharedVars] scaleUp:_checkButton];
        
//        [UIView animateWithDuration:0.3 animations:^{
//            _checkButton.transform = CGAffineTransformIdentity;
//        }];
    }
    
    NSUInteger bytes = [_messageInput.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if(bytes > 235 && ![text isEqualToString:@""]){
        return NO;
    }
    
    CGFloat offsetHeight = 0.0;
    if ([text isEqualToString:@"\n"]) {
        offsetHeight = 20.0;
    }
    
    else if ([text isEqualToString:@""] && ![_messageInput.text isEqualToString:@""]){
        // backspace
        char sub = [_messageInput.text characterAtIndex:range.location];
        // if deleted new line:
        if((int)sub==10){
            offsetHeight = -20.0;
        }
        
    }
    [UIView animateWithDuration:0.2 animations:^{
        
        // update textView height and messageInputView height
        CGRect frame = _messageInput.frame;
        CGFloat prevH = frame.size.height;
        frame.size.height = [_messageInput sizeThatFits:CGSizeMake(_messageInput.frame.size.width, CGFLOAT_MAX)].height + offsetHeight;
        [_messageInput setFrame:frame];
        CGFloat deltaH = frame.size.height - prevH;
    
        // update _messageInputView frame
        CGRect viewFrame = _messageInputView.frame;
        viewFrame.size.height = viewFrame.size.height + deltaH;
        viewFrame.origin = CGPointMake(0, viewFrame.origin.y - deltaH);

        [_messageInputView setFrame:viewFrame];

        _tableView.center = CGPointMake(_tableView.center.x, _tableView.center.y - deltaH);
    }];
    
//    CGPoint bottomOffset = CGPointMake(0, _tableView.contentOffset.y + deltaH);
//    [_tableView setContentOffset:bottomOffset animated:NO];
//    NSLog(@"set offset to %f", _tableView.contentOffset.y);
    
    return YES;
    
    
}

-(void)killScroll
{
    CGPoint offset = _tableView.contentOffset;
    [_tableView setContentOffset:offset animated:NO];
}


/*------------------ SEND CURRENT MOMUNT METHODS -------------------*/
/*
 Pressed pin to send a current momunt
 */
- (IBAction)pressedPin:(id)sender {
    [Amplitude logEvent:@"pressed present"];
    _fetchedLocation = nil;
    _numLocationFetch = 0;
    
    // start fetching user location
    [self listenForLocation];
    [[LocationController sharedInstance] startUpdatingLocation];
    
}


-(void)listenForLocation{
    // subscribe to location updates
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatedLocation:)
                                                 name:@"newLocationFound"
                                               object:nil];
    
}
-(void)stopListenForLocation{
    // subscribe to location updates
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"newLocationFound" object:nil];
}

// Do something when location updates
-(void) updatedLocation:(NSNotification*)notif {
    
    // current location
    CLLocation* location = (CLLocation*)[[notif userInfo] valueForKey:@"newLocationResult"];
    NSLog(@"updated location: %@", location);
    
    
    if(_numLocationFetch == 0){
        _fetchedLocation = location;
    }
    if(_numLocationFetch > 1 && location.horizontalAccuracy<_fetchedLocation.horizontalAccuracy){
        _fetchedLocation  = location;
    }
    if(_numLocationFetch < 5 && _fetchedLocation.horizontalAccuracy > 100 ){ // try 5 times, get the most accurat value. Unless got < 100m already
        _numLocationFetch = _numLocationFetch + 1;
        return;
    }
//    // if uncertainty is > 200m, return When not on wifi - location can be very off.
//    if(location.horizontalAccuracy > 200.0f){
//        return;
//    }
    
    // stop listening for locaton
    [self stopListenForLocation];
    
    // stop location manager
    [[LocationController sharedInstance] stopUpdatingLocation];
    
    // generate temp momunt Object
    MMNTObj *momunt = [[MMNTObj alloc] init];
    
    momunt.lat          = location.coordinate.latitude;
    momunt.lng          = location.coordinate.longitude;
    momunt.timestamp    = [NSDate date];
    momunt.ownerId      = [[MMNTAccountManager sharedInstance] userId];
    momunt.momuntId     = [[MMNTDataController sharedInstance] uniqueId];
    momunt.uploadId     = [[MMNTDataController sharedInstance] uniqueId];
//    momunt.name         = @"momunt";
//    [momunt nameFromLocation];
    
    NSMutableArray *recipients = [[NSMutableArray alloc] init];
    for (int i = 0; i < [_chatObj.members count]; i++) {
        NSDictionary *member = _chatObj.members[i];
        [recipients addObject:[member objectForKey:@"userId"]];
    }
    
    // share this momunt
    [[MMNTDataController sharedInstance] shareMomunt:momunt with:recipients];
}

-(NSArray *)messagesWithTstamps{
    NSDate     *now      = [NSDate new];
    CGFloat  threshold = 1*60*60;// time throshold in seconds
    CGFloat  msgthreshold = 2*60*60;// time throshold in seconds - between messages
    
    for(int i=[_messages count]-1; i>=0; i--){
//    [_messages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MMNTMessageObj *msg, NSUInteger idx, BOOL *stop) {
        MMNTMessageObj *msg = [_messages objectAtIndex:i];
        MMNTMessageObj *prev;
        if(i >0){
            prev = [_messages objectAtIndex:i-1];
        }
        
        NSDate *t = msg.timestamp;
        CGFloat diff = [now timeIntervalSince1970] - [t timeIntervalSince1970];
        
        if(diff>threshold || (i>0 && [msg.timestamp timeIntervalSince1970]-[prev.timestamp timeIntervalSince1970]>msgthreshold )){
            now = msg.timestamp;
            threshold = 10*60*60; // threshold == 5 hours after the 1st time
//            threshold = diff + 5*60*60; //increase threshold by 12 hours
            
            msg.needsTimestamp = YES;
            msg.timeString = [MMNT_SharedVars getTimeString:msg.timestamp];
            
        }

    }
    return _messages;
    
}


@end
