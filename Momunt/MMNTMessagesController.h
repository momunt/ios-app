//
//  MMNTMessagesController.h
//  Momunt
//
//  Created by Masha Belyi on 7/10/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNT_NavigationChild_ViewController.h"
#import "MMNTNavigationController.h"
#import "MMNT_NavBar_View.h"
#import "MMNT_Chat_Cell.h"

@interface MMNTMessagesController : MMNT_NavigationChild_ViewController <ChatCellDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) MMNTNavigationController *navC;
@property (nonatomic) MMNT_NavBar_View *navBar;
- (NSArray*)visibleCells;

@end
