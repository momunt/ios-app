//
//  MMNTSavedTrendingViewController.h
//  Momunt
//
//  Created by Masha Belyi on 11/25/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNT_TransparentView.h"
#import "MMNT_CarouselHitTestView.h"

@interface MMNTSavedTrendingViewController : UIViewController

@property (strong, nonatomic) IBOutlet MMNT_CarouselHitTestView *carouselHitView;
@property (strong, nonatomic) IBOutlet UIScrollView *carouselTab;
//@property (strong, nonatomic) IBOutlet MMNT_TransparentView *tabBar;
//@property (strong, nonatomic) IBOutlet UIButton *myButton;
//@property (strong, nonatomic) IBOutlet UIButton *trendingButton;

@property UINavigationController *childNavController;
@property UITableViewController *currentVC;
@property NSString  *scrollDirection;

-(NSArray *)visibleCells;
-(UITableView *)tableView;



@end
