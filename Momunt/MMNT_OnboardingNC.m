//
//  MMNT_OnboardingNC.m
//  Momunt
//
//  Created by Masha Belyi on 9/24/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//
#import <Security/Security.h>
#import "JNKeychain.h"

#import "MMNT_OnboardingNC.h"
#import "MMNTDataController.h"
#import "MMNTApiCommuniator.h"
#import "MMNT_SignInController.h"

@interface MMNT_OnboardingNC ()

@end

@implementation MMNT_OnboardingNC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (void)viewDidLoad
//-(void)viewWillAppear:(BOOL)animated
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    
    NSString *token = [JNKeychain loadValueForKey:@"AccessToken"];
    
    // DEV
//    NSString *token = nil;
//[JNKeychain deleteValueForKey:@"AccessToken"];
//    token = nil;
    NSDictionary *gotUser = [[MMNTApiCommuniator sharedInstance] getUserInfo];
    
    
    if(token!=nil && ![[gotUser valueForKey:@"status"] isEqualToString:@"invalid API key"] ){

        
        if([MMNTDataController sharedInstance].shouldLoadFromId){
            // go to loading screen where will load from ID
            NSLog(@"loading from ID");
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            UIViewController *loadController = (UIViewController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"loadingScreen"];
            [self pushViewController:loadController animated:NO];

            
        }else{

            NSLog(@"loading regular");
            
            // grab user info
            [[MMNTApiCommuniator sharedInstance] getUserInfo];
            [[MMNTApiCommuniator sharedInstance] fetchUserChats];
            [[MMNTApiCommuniator sharedInstance] getTrendingMomunts];

            
//            MMNT_SignInController *parent = self.parentViewController;
            [_parentVC performSegueWithIdentifier:@"LoadingToGallery" sender:self];
        }
        
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
