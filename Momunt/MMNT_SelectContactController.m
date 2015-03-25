//
//  MMNT_SelectContactView.m
//  Momunt
//
//  Controller used to select contacts for sharing or chat.
//
//  Created by Masha Belyi on 10/6/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_SelectContactController.h"

#import "MMNT_ContactsCell.h"
#import "MMNT_ContactsTextCell.h"
#import "MMNT_Contact.h"
#import "MMNTDataController.h"
#import "MMNTMessagesController.h"
#import "MMNTMessages.h"
#import "MMNT_TransitionsManager.h"
#import "MMNTContactsManager.h"

#import "Amplitude.h"


@interface MMNT_SelectContactController (){
    MMNTContactsManager *_contactsManager;
    CGFloat             _kbHeight;
    BOOL                _sendBtnVisible;
    BOOL                _needSendBtn;
    
    CGPoint lastOffset;
    NSTimeInterval lastOffsetCapture;
    BOOL isScrollingFast;

}
@end

@implementation MMNT_SelectContactController

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
    
    self.tableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    [self setData];
    [self performSelector:@selector(checkPermissions) withObject:nil afterDelay:0.5];
    
    _tableView.delegate = self;
    
    // listen for the keyboard slide up/down
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _recipients = [NSMutableArray new];
    
    _inputField.delegate = self;
    [[UITextField appearance] setTintColor:[UIColor colorWithRed:254.0/255.0 green:126.0/255.0 blue:0 alpha:1.0]]; // make cursor and selection orange
    UIColor *color = [UIColor colorWithWhite:1.0 alpha:0.5];
    _inputField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"search contacts" attributes:@{NSForegroundColorAttributeName: color}];
    _inputField.clearsOnBeginEditing = NO;
    
    // send button
    _sendBtn.frame = CGRectMake(0, _tableView.frame.origin.y + _tableView.frame.size.height+20, _tableView.frame.size.width, 60);
    _needSendBtn = [_type isEqualToString:@"share"];
    if(!_needSendBtn){
        _sendBtn.hidden = YES;
    }

}

-(void)setData{
//    if([_type isEqualToString:@"chat"]){
//        self.contacts = [NSMutableArray arrayWithArray:[[[MMNTContactsManager sharedInstance] momuntContacts] arrayByAddingObjectsFromArray:[[MMNTContactsManager sharedInstance] phoneContacts]]];
//                         
//        self.sercheableContacts = [[MMNTContactsManager sharedInstance]sercheableContacts];
//
//        self.allContacts = self.contacts;
//    }else{

        self.contacts = [NSMutableArray arrayWithArray:[[[MMNTContactsManager sharedInstance] momuntContacts] arrayByAddingObjectsFromArray:[[MMNTContactsManager sharedInstance] phoneContacts]]];
        self.sercheableContacts = [[MMNTContactsManager sharedInstance]sercheableContacts];

        self.allContacts = self.contacts;
//    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated{
    if([_type isEqualToString:@"chat"]){
        _navC = self.navigationController;
        _navBar = _navC.navBar;
    }
    [Amplitude logEvent:@"went to contacts"];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 Slide view up when keyboard appears
 */
- (void)keyboardWillShow:(NSNotification *)note
{
    // make _tableView frame smaller
    if(!_kbHeight){
        NSDictionary* info = [note userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        _kbHeight = kbSize.height - (_needSendBtn ? 0 : 50); // if in chat mode - there is a bottom bar 50px high
    }
    CGFloat h = self.view.frame.size.height - _kbHeight - 60 - (_sendBtnVisible && _needSendBtn ? 60 : 0);
    
    _tableView.frame = CGRectMake(0,60,self.view.frame.size.width,h);
    _sendBtn.frame = CGRectMake(0, _tableView.frame.origin.y + _tableView.frame.size.height, _tableView.frame.size.width, 60);
    NSLog(@"here");
  
}
- (void)keyboardWillHide:(NSNotification *)note
{
    CGFloat h = self.view.frame.size.height - 60 - (_sendBtnVisible && _needSendBtn ? 60 : 0);
    _tableView.frame = CGRectMake(0,60,self.view.frame.size.width,h);
    _sendBtn.frame = CGRectMake(0, _tableView.frame.origin.y + _tableView.frame.size.height, _tableView.frame.size.width, 60);

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // HIDE keyboard on scroll

    // Measure speed
    CGPoint currentOffset = scrollView.contentOffset;
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    
    NSTimeInterval timeDiff = currentTime - lastOffsetCapture;
    if(timeDiff > 0.1) {
        CGFloat distance = currentOffset.y - lastOffset.y;
        //The multiply by 10, / 1000 isn't really necessary.......
        CGFloat scrollSpeedNotAbs = (distance * 10) / 1000; //in pixels per millisecond
        
        CGFloat scrollSpeed = fabsf(scrollSpeedNotAbs);
        if (scrollSpeed > 0.5){// && scrollSpeedNotAbs<0) {
            isScrollingFast = YES;
            [_inputField resignFirstResponder];
            //            NSLog(@"Fast");
        } else {
            isScrollingFast = NO;
            //            NSLog(@"Slow");
        }
        
        lastOffset = currentOffset;
        lastOffsetCapture = currentTime;
    }
}


-(void)updatedRecipients{
    if(!_needSendBtn){
        return;
    }
    BOOL show = [_recipients count]>0;
    if(show==_sendBtnVisible)
        return;
    
    if(show){
        _sendBtnVisible= YES;
    }else{
        _sendBtnVisible = NO;
    }
    CGFloat y = show ?  _tableView.frame.origin.y + _tableView.frame.size.height - 60 :  _tableView.frame.origin.y + _tableView.frame.size.height+60;
    CGRect sendframe = CGRectMake(0, y, _tableView.frame.size.width, 60);
    CGRect tableframe = CGRectMake(0, 60, _tableView.frame.size.width, _tableView.frame.size.height + (show ? -60 : 60));
    [UIView animateWithDuration:0.3 animations:^{
        _sendBtn.frame = sendframe;
        _tableView.frame = tableframe;
    }];

}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *lastTwo = [textField.text substringWithRange:NSMakeRange([textField.text length]-2,2)];
     
    if ([string isEqualToString:@""] && [lastTwo isEqualToString:@", "]){
        // remove the last ", "
        textField.text = [textField.text substringWithRange:NSMakeRange(0, [textField.text length]-2)];
        // highlight the last recipient
        NSArray *names = [textField.text componentsSeparatedByString:@", "];
        NSString *last = [names lastObject];
        
        NSRange selectRange = NSMakeRange(textField.text.length - last.length, last.length);
        [self selectTextInTextField:textField range:selectRange];
        
        return NO;

    }else if ([string isEqualToString:@""] && range.length>1){
//        check string in range, delete selected contact
        NSString *name = [textField.text substringWithRange:range];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.name contains[c] %@) OR (SELF.username contains[c] %@)", name, name];
        NSArray *found = [_recipients filteredArrayUsingPredicate:predicate];
        for(int i=0; i<[found count]; i++){
            MMNT_Contact *contact = found[i];
            [_recipients removeObject:contact];
            [self updatedRecipients];
            [_tableView reloadData];
        }

        return YES;
    }
    return YES;
}


- (void)selectTextInTextField:(UITextField *)textField range:(NSRange)range {
    UITextPosition *from = [textField positionFromPosition:[textField beginningOfDocument] offset:range.location];
    UITextPosition *to = [textField positionFromPosition:from offset:range.length];
    [textField setSelectedTextRange:[textField textRangeFromPosition:from toPosition:to]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    self.contacts = self.allContacts;
    [_contactsTable reloadData];
    return NO;
}

#pragma mark - UITableView Delegate and Data Source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.contacts count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    id obj = [self.contacts objectAtIndex:indexPath.row];
    if([obj isKindOfClass:[NSString class]]){
        static NSString *CellIdentifier = @"ContactTextRow";
        NSString *type = @"regular";
        if([obj isEqualToString:@"Show results from iPhone contacts"]){
            type = @"bold";
        }
        MMNT_ContactsTextCell *cell = [[MMNT_ContactsTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier text:obj type:type];
        return cell;

    }else{
        // check if this contact is selected here !!!
        MMNT_Contact *contact = [self.contacts objectAtIndex:indexPath.row];
        BOOL selected = [_recipients containsObject:contact];
        static NSString *CellIdentifier = @"ContactRow";
        MMNT_ContactsCell *cell = (MMNT_ContactsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell = [[MMNT_ContactsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier cellData:contact selected:selected];
        return cell;
    }

    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id obj = [self.contacts objectAtIndex:indexPath.row];
    if([obj isKindOfClass:[NSString class]]){
        if([obj isEqualToString:@"Show results from iPhone contacts"]){
            if(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined){
                [self performSelector:@selector(askIOSContactsPermission) withObject:nil afterDelay:0.5];
            }
            else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
                // The user has previously given access
            }
            else {
                // The user has previously denied access
                // Send an alert telling user to change privacy setting in settings app
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Allow Momunt To Access Your Address Book?"
                                                                message:@"Please go to Settings and authorize Momunt to access your Contacts."
                                                               delegate:self
                                                      cancelButtonTitle:@"not now"
                                                      otherButtonTitles:@"take me to settings", nil];
                [alert show];
            }
            
        }
    }else{
        if([_type isEqualToString:@"share"]){
            if(!_recipients){
                _recipients = [NSMutableArray new];
            }
            MMNT_Contact *contact = [self.contacts objectAtIndex:indexPath.row];
            MMNT_ContactsCell *cell = (MMNT_ContactsCell*)[tableView cellForRowAtIndexPath:indexPath];
            BOOL selected = [cell toggleSelection];
            if(selected){
                [_recipients addObject:contact];
            }else{
                [_recipients removeObject:contact];
            }
            _inputField.text = [self recipientsToString];
            [self updatedRecipients];
            
            
            
//            MMNT_Contact *selectedContact = [self.contacts objectAtIndex:indexPath.row];
//            
//            if(selectedContact.momuntUser){
//                
//                // send momunt and go to chat view
//                NSMutableArray *recipients = [[NSMutableArray alloc] init];
//                NSString *number = selectedContact.phone; //[selectedContact.numbers objectAtIndex:0];
//                [recipients addObject:number];
//                
//                [self dismissViewControllerAnimated:YES completion:nil];
//                
//                
//                // do the actual sharing=
//                [MMNTDataController sharedInstance].toShareMomunt.uploadId = [[MMNTDataController sharedInstance] uniqueId];
//                [[MMNTDataController sharedInstance] shareMomunt: [MMNTDataController sharedInstance].toShareMomunt with:recipients];

//
//            }else{
//                [self sendSMS:selectedContact];
//            }

        }else{
        
            MMNT_Contact *selectedContact = [self.contacts objectAtIndex:indexPath.row];
            if(selectedContact.momuntUser){
                NSMutableArray *members = [[NSMutableArray alloc] init];
                NSInteger userId = selectedContact.userId;
                [members addObject: [NSString stringWithFormat:@"%i", userId]];
    
                // create chat
                NSArray *chats = [[MMNTDataController sharedInstance] startChat:members];
                MMNTChatObj *theChat = [chats firstObject];
    
                // push to chat messages view
                [self goChatWith:theChat];
            }else{
                // open SMS view!
                [self sendSMS:selectedContact];
            }
        }
    }
}
- (void)goChatWith:(MMNTChatObj *)theChat{
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MMNTMessages *toVC = (MMNTMessages *)[mainStoryboard instantiateViewControllerWithIdentifier: @"Chat"];
    toVC.messages = theChat.messages;
    toVC.chatObj = theChat;
    toVC.view.frame = self.view.frame;
    [_navBar.chatThumbnailView setImageFromImages:theChat.memberImages];
    
    [self.navigationController pushViewController:toVC animated:YES];
    
}
-(NSString *)recipientsToString{
    NSMutableString *str = [[NSMutableString alloc] init];
    
    for (int i=0; i<[_recipients count]; i++) {
        MMNT_Contact *contact = _recipients[i];
        NSString *nameStr = [contact.name isEqualToString:@""] ? (contact.username ? contact.username : contact.phone) : contact.name;
        [str appendString: [NSString stringWithFormat:@"%@, ", nameStr]];
    }
    return str;
}
-(NSArray *)recipientsToArray{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i=0; i<[_recipients count]; i++) {
        MMNT_Contact *contact = _recipients[i];
        if(contact.momuntUser){
            [array addObject: [NSString stringWithFormat:@"%i", contact.userId] ];
        }else{
            [array addObject:contact.phone];  // use phone number as id until this users signs up for momunt
        }
    }
    return array;
}


#pragma mark - Navigation

/* ------------------- <UINavigationControllerDelegate> ------------------- */

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    // fade out chat view and slide up contacts
    return [MMNT_TransitionsManager transitionWithOperation:operation andTransitionType:MMNTTransitionFadeOutSlideUp];
    
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (IBAction)enteredText:(id)sender {
    if([self.inputField.text  isEqual: @""]){
        self.contacts = self.allContacts;
        [_contactsTable reloadData];
        return;
    }else{
        // figure out what the search string is
        NSArray *names = [_inputField.text componentsSeparatedByString: @", "];
        NSString *searchStr = [names lastObject];
        if([searchStr length]==0){
            self.contacts = self.allContacts;
            [_contactsTable reloadData];
            return;
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.name contains[c] %@) OR (SELF.username contains[c] %@)", searchStr, searchStr];
        
        self.contacts = [self.sercheableContacts filteredArrayUsingPredicate:predicate];
    
    
        // display matching contacts
        if([self.contacts count]<1){
            self.contacts = [self.contacts mutableCopy];
            NSString *str = [NSString stringWithFormat:@"No results found for \"%@\"", searchStr];
            [self.contacts insertObject:str atIndex:0];
            [self checkContactsPermissions];
        }
    
        [_contactsTable reloadData];
    }
}

- (IBAction)pressedClose:(id)sender {
    if([_source isEqualToString:@"menu"]){
        [self turnBackToAnOldViewController];
    }else{
        [self.navigationController.parentViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)pressedSearch:(id)sender {
    [_inputField becomeFirstResponder];
}

- (IBAction)pressedSend:(id)sender {
    [MMNTDataController sharedInstance].toShareMomunt.uploadId = [[MMNTDataController sharedInstance] uniqueId];
    [[MMNTDataController sharedInstance] shareMomunt: [MMNTDataController sharedInstance].toShareMomunt with:[self recipientsToArray]];
    
    if(![_source isEqualToString:@"menu"]){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

/*
 CONTACTS PERMISSIONS
 ----------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
-(void)checkContactsPermissions{
    
//    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"allowAddressBook"] isEqualToString:@"NO"]){
    if(ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized){
        [self.contacts insertObject:@"Show results from iPhone contacts" atIndex:1];
    }
}

- (void)turnBackToAnOldViewController{
//    [self.navigationController popViewControllerAnimated: YES];
    
    for (UIViewController *controller in self.navigationController.viewControllers) {
        
        //Do not forget to import AnOldViewController.h
//        if ([controller isKindOfClass:[MMNTMessagesController class]]) {
        if ([controller isKindOfClass:_prevVcClass]) {
            
            [self.navigationController popToViewController:controller
                                                  animated:YES];
            break;
        }
    }
    
    
}

- (NSArray*)visibleCells
{
    return [self.tableView visibleCells];
    
}


/*
 SHARE METHODS
 */
/*
 Send Message result
 */
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
        {
//            NSArray *recipients = controller.recipients;
//            [[MMNTDataController sharedInstance] shareMomuntViaText: [MMNTDataController sharedInstance].toShareMomunt with:recipients];
            
            break;
        }
        default:
            break;
    }
    
//    if(result == MessageComposeResultSent){
//        [self dismissViewControllerAnimated:YES completion:^{
////            [self.navigationController.parentViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//        }];
//    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
        
//    }
}

- (void)sendSMS:(MMNT_Contact *)contact {
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSArray *recipents = [NSArray arrayWithObjects: contact.phone, nil];
    NSString *message = @"Join me on Momunt! http://www.momunt.com";//[NSString stringWithFormat:@"Check out this momunt: http://www.momunt.com/alpha/%@", [MMNTDataController sharedInstance].toShareMomunt.momuntId];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients: recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}


/*
 CONTACTS PERMISSIONS
 ----------------------------------------------------------------------------------------------------------------------------------------------------------------
 */

-(void)checkPermissions{
    
    if(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined){
        // ask permission to use address book
        // 1) CUSTOM ALERT
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Let Momunt Use Address Book?"
                                                        message:@"Sharing with friends is simple when choosing them from the address book on your phone."
                                                       delegate:self
                                              cancelButtonTitle:@"Not Now"
                                              otherButtonTitles:@"Use Address Book", nil];
        [alert show];
        
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access
        //        [self updateContacts];
    }
    else {
        // The user has previously denied access
        // Don't do anything yet. Let user see 0 contacts, then request to see iphone contacts
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:@"Let Momunt Use Address Book?"]){
        if(buttonIndex==0){
            // store user preference, try again later
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"allowAddressBook"];
            
        }else{
            // store user preference
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"allowAddressBook"];
            
            [self performSelector:@selector(askIOSContactsPermission) withObject:nil afterDelay:0.5];
            
        }
    }else{
        // alert to go to settings
        if(buttonIndex==1){
            // go to setting!
            // OPEN SETTINGS
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
            
        }
        
    }
    
}
-(void)askIOSContactsPermission{
    // show real address book permissions dialog
    BOOL allowAddressBook = [[MMNTDataController sharedInstance] askAddressBookPermission];
    if(allowAddressBook){
        [[MMNTContactsManager sharedInstance] updateContacts];
        [self setData];
        [self.tableView reloadData];
        
    }
}


/* ---------------------------------------------------------------------------------------------------------------------------------------------------------------- */

@end
