//
//  MMNT_ConnectWithSocial_ViewController.m
//  Momunt
//
//  Created by Masha Belyi on 7/22/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_ConnectWithSocial_ViewController.h"
#import "MMNTSettingsController.h"
#import "MMNT_RowSelection_Transition.h"

@interface MMNT_ConnectWithSocial_ViewController ()

@end

@implementation MMNT_ConnectWithSocial_ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.popToController = [MMNTSettingsController class];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    self.currSegue = [segue identifier];
    
    NSLog(@"Prepare for segue ID:%@", [segue identifier]);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
