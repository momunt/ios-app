//
//  MMNT_MomuntsList.m
//  Momunt
//
//  Created by Masha Belyi on 12/29/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_MomuntsList.h"
#import "AMWaveTransition.h"
#import "MMNT_SavedMomunt_Cell.h"
#import "MMNTAccountManager.h"
#import "MMNTViewController.h"
#import "MMNTSavedTrendingViewController.h"

@interface MMNT_MomuntsList () <UINavigationControllerDelegate>

@end

@implementation MMNT_MomuntsList

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationController.delegate = self;
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    
//    // subscribe to updates
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(updatedData:)
//                                                 name:@"updatedTrendingMomunts"
//                                               object:nil];

    
    // subscribe to updates
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatedData:)
                                                 name:@"updatedUserInfo"
                                               object:nil];
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray*)visibleCells
{
    return [self.tableView visibleCells];
    
}

// Do something when updated user/trending momunts
-(void) updatedData:(NSNotification*)notif {
    // Reload galleries!
    if([self.category isEqualToString:@"me"]){
        self.data = [MMNTAccountManager sharedInstance].userMomunts;
    }
    else if([self.category isEqualToString:@"places"]){
        self.data = [MMNTAccountManager sharedInstance].userFollows;
//        self.data = [[MMNTAccountManager sharedInstance].userFollows arrayByAddingObjectsFromArray:[[MMNTAccountManager sharedInstance].trendingMomunts valueForKey:@"places"]];
    }
    else{
        self.data = [[MMNTAccountManager sharedInstance].trendingMomunts valueForKey:self.category];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 125;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //    return self.storedMomunts.count;
    return [_data count];
}


- (MMNT_SavedMomunt_Cell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StoredMomuntRow";

    MMNT_SavedMomunt_Cell *cell = [[MMNT_SavedMomunt_Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier cellData:[_data objectAtIndex:indexPath.row] type:_category];
    
    cell.tableView = self.tableView;
    cell.indexPath = indexPath;
    cell.parentArray = self.data;
    cell.parentVC = self;
    return cell;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    MMNTSavedTrendingViewController * vc = (MMNTSavedTrendingViewController *)self.navigationController.parentViewController;
    return [AMWaveTransition transitionWithOperation:operation andTransitionType:AMWaveTransitionTypeNervous andDirection:vc.scrollDirection];
    
}


@end
