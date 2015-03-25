//
//  MMNTTrendingMomuntsViewController.h
//  Momunt
//
//  Created by Masha Belyi on 11/25/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MMNT_NavigationChild_ViewController.h"

@interface MMNTTrendingMomuntsViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (NSArray*)visibleCells;

@end
