//
//  MMNT_NavigationChild_ViewController.m
//  Momunt
//
//  Created by Masha Belyi on 7/20/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_NavigationChild_ViewController.h"
#import "AMWaveTransition.h"
#import "MMNTNavigationController.h"
#import "MMNT_RowSelection_Transition.h"
#import "MMNT_TransitionsManager.h"
#import "MMNT_PDFWebViewViewController.h"

@interface MMNT_NavigationChild_ViewController ()  <UINavigationControllerDelegate>

@end

@implementation MMNT_NavigationChild_ViewController

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0];

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // don't show empty cells
    
    self.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0]; // clear background
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setDelegate:self];
//    [self.navigationController setDelegate:self.navigationController];
}

- (void)dealloc
{
    [self.navigationController setDelegate:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)turnBackToAnOldViewController{
    
    for (UIViewController *controller in self.navigationController.viewControllers) {
        
        //Do not forget to import AnOldViewController.h
        if ([controller isKindOfClass:self.popToController]) {
            
            [self.navigationController popToViewController:controller
                                                  animated:YES];
            break;
        }
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    self.currSegue = [segue identifier];
//    self.navigationController.currSegue = [segue identifier];

    
}

- (NSArray*)visibleCells
{
    return [self.tableView visibleCells];
    
}
-(UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.tableView cellForRowAtIndexPath:indexPath];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    //    BOOL pushFromLeft = [fromVC.restorationIdentifier isEqualToString:@"Settings"] && ([toVC.restorationIdentifier isEqualToString:@"StoredMomunts"] || ;
    NSArray *identifiers = [NSArray arrayWithObjects: @"MMNT_Feedback_ViewController", @"MMNT_Password_ViewController", @"", @"",  nil];
//    NSArray *ids = [NSArray arrayWithObjects: @"1", @"4", @"0", nil];
    BOOL fromSelection = NO;
    BOOL toSelection = NO;
    NSInteger idx;
    if([identifiers indexOfObject:toVC.restorationIdentifier] != NSNotFound ){
        toSelection = YES;
        idx = [identifiers indexOfObject:toVC.restorationIdentifier];
    }
    else if([identifiers indexOfObject:fromVC.restorationIdentifier] != NSNotFound ){
        fromSelection = YES;
        idx = [identifiers indexOfObject:fromVC.restorationIdentifier];
    }
    
//    BOOL fromSelection = [sT containsObject:fromVC.restorationIdentifier];
//    BOOL toSelection = [sT containsObject:toVC.restorationIdentifier];
    
    
    if( (fromSelection && [toVC.restorationIdentifier isEqualToString:@"Settings"]) || toSelection){
        return [MMNT_RowSelection_Transition transitionWithOperation:operation andRowIndex:idx andDirection:@"left"];
    }else if([toVC.restorationIdentifier isEqualToString:@"ChatContacts"]){
        return [MMNT_TransitionsManager transitionWithOperation:operation andTransitionType:MMNTTransitionFadeOutSlideUp];
    }
    else if([toVC class] == [MMNT_PDFWebViewViewController class]
            || [toVC.restorationIdentifier isEqualToString:@"Settings"]
            || ([fromVC class] == [MMNT_PDFWebViewViewController class] && [toVC.restorationIdentifier isEqualToString:@"Settings"])
            || ( ([fromVC.restorationIdentifier isEqualToString:@"Settings"] || fromSelection) && [toVC.restorationIdentifier isEqualToString:@"SavedTrending"])
    ){
//    else if([toVC class] == [MMNT_PDFWebViewViewController class] || [toVC.restorationIdentifier isEqualToString:@"Settings"] ){
        return [AMWaveTransition transitionWithOperation:operation andTransitionType:AMWaveTransitionTypeNervous andDirection:@"left"];
    }
    else{
        return [AMWaveTransition transitionWithOperation:operation andTransitionType:AMWaveTransitionTypeNervous andDirection:@"right"];
    }
    
    
}


@end
