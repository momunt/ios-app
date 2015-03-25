//
//  MMNTSavedTrendingNavigation.m
//  Momunt
//
//  Created by Masha Belyi on 11/26/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNTSavedTrendingNavigation.h"

@interface MMNTSavedTrendingNavigation ()

@end

@implementation MMNTSavedTrendingNavigation

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"did load navigation");
    [self popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
