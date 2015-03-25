//
//  MMNT_NavigationChild_ViewController.h
//  Momunt
//
//  Created by Masha Belyi on 7/20/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNTNavigationController.h"

@class MMNTNavigationController;

@interface MMNT_NavigationChild_ViewController : UITableViewController

//@property MMNTNavigationController *navigationController;

@property Class popToController; // class of controller to pop to
@property NSString *pushTo; // identifier of Controller to push to from this VC
@property UIButton *backBtn; //button thtat calls Pop segue
@property UIButton *settingsBtn; //button thtat returns(pops) to settings page
@property NSString *currSegue; // Identifier of the curernt segue

- (NSArray*)visibleCells;
-(UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)turnBackToAnOldViewController;

@end
