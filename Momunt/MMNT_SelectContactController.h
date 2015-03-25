//
//  MMNT_SelectContactView.h
//  Momunt
//
//  Created by Masha Belyi on 10/6/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNTNavigationController.h"
#import "MMNT_NavBar_View.h"
#import <MessageUI/MessageUI.h>

@interface MMNT_SelectContactController : UIViewController <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIActionSheetDelegate,MFMessageComposeViewControllerDelegate, UITextFieldDelegate>{
    NSMutableArray *_recipients;
}

@property NSString *type;
@property NSString *source;
@property Class prevVcClass;

@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSMutableArray *sercheableContacts;
@property (nonatomic, strong) NSMutableArray *allContacts;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *sendBtn;

@property (strong, nonatomic) IBOutlet UITableView *contactsTable;
@property (strong, nonatomic) IBOutlet UITextField *inputField;
- (IBAction)enteredText:(id)sender;
- (IBAction)pressedClose:(id)sender;
- (IBAction)pressedSearch:(id)sender;
- (IBAction)pressedSend:(id)sender;


@property (nonatomic) MMNTNavigationController *navC;
@property (nonatomic) MMNT_NavBar_View *navBar;

- (NSArray*)visibleCells;

@end
