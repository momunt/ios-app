//
//  MMNTNavigationController.h
//  Momunt
//
//  Created by Masha Belyi on 7/10/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMNT_NavBar_View;
@class MMNT_NavigationChild_ViewController;

@interface MMNTNavigationController : UINavigationController <UINavigationControllerDelegate>

@property MMNT_NavBar_View *navBar;
@property MMNT_NavigationChild_ViewController *currentViewController;
@property BOOL animating;
@property NSString *currSegue; // Identifier of the curernt segue
@property BOOL onTrending;
@property BOOL onMyMomunts;
@property NSString *trendingCategory;

-(MMNT_NavigationChild_ViewController *)getCurrentView;
-(void)setCurrentViewController:(UIViewController *)vc;

@end
