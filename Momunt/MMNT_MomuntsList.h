//
//  MMNT_MomuntsList.h
//  Momunt
//
//  Created by Masha Belyi on 12/29/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMNT_MomuntsList : UITableViewController

@property NSArray *data;
@property NSString *category;
@property UITableView *tableView;
- (NSArray*)visibleCells;

@end
