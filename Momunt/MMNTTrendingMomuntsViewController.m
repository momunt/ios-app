//
//  MMNTTrendingMomuntsViewController.m
//  Momunt
//
//  Created by Masha Belyi on 11/25/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNTTrendingMomuntsViewController.h"
#import "AMWaveTransition.h"
#import "MMNT_SavedMomunt_Cell.h"
#import "MMNTAccountManager.h"
#import "MMNTViewController.h"

@interface MMNTTrendingMomuntsViewController () <UINavigationControllerDelegate>


@end

@implementation MMNTTrendingMomuntsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // subscribe to location updates
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatedTrendingMomunts:)
                                                 name:@"updatedTrendingMomunts"
                                               object:nil];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray*)visibleCells
{
    return [self.tableView visibleCells];
    
}

// Do something when updated user stored momunts
-(void) updatedTrendingMomunts:(NSNotification*)notif {
    // Reload galleries!
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
    return 110;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //    return self.storedMomunts.count;
    return [[MMNTAccountManager sharedInstance].trendingMomunts count];
}


- (MMNT_SavedMomunt_Cell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StoredMomuntRow";
    
    //    MMNT_SavedMomunt_Cell *cell = (MMNT_SavedMomunt_Cell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //    if(!cell){
//    MMNT_SavedMomunt_Cell *cell = [[MMNT_SavedMomunt_Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier cellData:[[MMNTAccountManager sharedInstance].trendingMomunts objectAtIndex:indexPath.row]];
//
    
    MMNT_SavedMomunt_Cell *cell = [[MMNT_SavedMomunt_Cell alloc] init];
    return cell;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    
    return [AMWaveTransition transitionWithOperation:operation andTransitionType:AMWaveTransitionTypeNervous andDirection:@"right"];
    
}


@end
