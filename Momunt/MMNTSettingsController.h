//
//  MMNTSettingsController.h
//  Momunt
//
//  Created by Masha Belyi on 7/19/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNT_NavigationChild_ViewController.h"

@interface MMNTSettingsController : MMNT_NavigationChild_ViewController <UIActionSheetDelegate>

@property CGFloat currentOffsetY;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (NSArray*)visibleCells;
@property NSString *currSegue; // Identifier of the curernt segue
-(UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@property (strong, nonatomic) IBOutlet UITableViewCell *signOutCell;

- (IBAction)pressedPrivacy:(id)sender;
- (IBAction)pressedHelp:(id)sender;
- (IBAction)pressedSignOut:(id)sender;
- (IBAction)pressedTermsOfService:(id)sender;


@end
