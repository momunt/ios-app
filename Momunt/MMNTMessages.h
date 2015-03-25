//
//  MMNTMessages.h
//  Momunt
//
//  Created by Masha Belyi on 10/4/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNTChatObj.h"
#import "MMNTMessageObj.h"
#import "MMNT_checkButton.h"

@interface MMNTMessages : UIViewController <UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property Class popToController; // class of controller to pop to
@property (nonatomic) NSMutableArray *messages;
@property (nonatomic) NSMutableArray *messagesWithTime;
@property (nonatomic) MMNTChatObj *chatObj;
@property (strong, nonatomic) IBOutlet UIView *messageInputView;
@property (strong, nonatomic) IBOutlet UITextView *messageInput;
@property (strong, nonatomic) IBOutlet UIButton *locationPin;
@property (strong, nonatomic) IBOutlet UIButton *checkButton;

@property BOOL willDropDown;

-(NSArray*)visibleCells;
-(void)turnBackToAnOldViewController;
-(UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (IBAction)pressedPin:(id)sender; // pressed pin to send the current momunt
- (IBAction)pressedSend:(id)sender;
- (void)postMessage:(MMNTMessageObj *)message;
-(void)updateChat:(MMNTChatObj *)chat;

@end
