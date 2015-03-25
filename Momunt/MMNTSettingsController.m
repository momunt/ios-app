//
//  MMNTSettingsController.m
//  Momunt
//
//  Created by Masha Belyi on 7/19/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNTSettingsController.h"
#import "AMWaveTransition.h"
#import "MMNT_RowSelection_Transition.h"
#import "MMNT_SharedVars.h"
#import "JNKeychain.h"
#import "MMNT_SignInController.h"
#import "MMNTDataController.h"
#import "MMNT_PDFWebViewViewController.h"
#import "MMNTViewController.h"
#import "MMNTAccountManager.h"

@interface MMNTSettingsController ()

@end

@implementation MMNTSettingsController
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

    self.pushTo = @"SavedTrending";
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setDelegate:self];
    //[self.interactive attachInteractiveGestureToNavigationController:self.navigationController];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 6;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    self.currSegue = [segue identifier];
    
//    NSLog(@"Prepare for segue ID:%@", [segue identifier]);
}


- (NSArray*)visibleCells
{
    return [self.tableView visibleCells];
    
}

-(UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.tableView cellForRowAtIndexPath:indexPath];
}

- (IBAction)pressedPrivacy:(id)sender {
    [[MMNT_SharedVars sharedVars] scaleUp:sender];
    
    MMNT_PDFWebViewViewController *privacyVC = [[MMNT_PDFWebViewViewController alloc] init];
    privacyVC.url = [NSURL URLWithString:@"http://www.momunt.com/docs/Momunt_PrivacyPolicy.pdf"];
    
    [self.navigationController pushViewController:privacyVC animated:YES];
    
//    [self loadRemotePdfFromUrl:[NSURL URLWithString:@"http://www.momunt.com/docs/Momunt_PrivacyPolicy.pdf"]];
    
    
}

- (IBAction)pressedHelp:(id)sender {
    [[MMNT_SharedVars sharedVars] scaleUp:sender];
    
    MMNT_PDFWebViewViewController *privacyVC = [[MMNT_PDFWebViewViewController alloc] init];
    privacyVC.url = [NSURL URLWithString:@"http://www.momunt.com/docs/Momunt_help.pdf"];
    
    [self.navigationController pushViewController:privacyVC animated:YES];
}

- (IBAction)pressedSignOut:(id)sender {
    // show confirmation alert
    UIAlertView *updateAlert = [[UIAlertView alloc] initWithTitle:@"Sign out" message: @"Are you sure you want to sign out?" delegate:self cancelButtonTitle:@"Sign Out"  otherButtonTitles:@"Cancel",nil];
    
    [updateAlert show];
    
}

- (IBAction)pressedTermsOfService:(id)sender {
    [[MMNT_SharedVars sharedVars] scaleUp:sender];
    
    MMNT_PDFWebViewViewController *privacyVC = [[MMNT_PDFWebViewViewController alloc] init];
    privacyVC.url = [NSURL URLWithString:@"http://www.momunt.com/docs/momunt_terms.pdf"];
    
    [self.navigationController pushViewController:privacyVC animated:YES];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        // send logout API call
        [[MMNTApiCommuniator sharedInstance] logout];
        
        // reset authentication token
        [JNKeychain deleteValueForKey:@"AccessToken"];
        
        // CLEAR ALL USER DATA
        [[MMNTAccountManager sharedInstance] clearAll];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userInfo"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"lastMomunt"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"trendingData"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userPile"];
        
        // move to sign in view
        MMNTViewController *parentVC = (MMNTViewController *)[self.navigationController parentViewController];
        parentVC.currSegue = @"signOut";
        parentVC.transitioningDelegate = parentVC;
        MMNT_SignInController *mainVC = (MMNT_SignInController *) parentVC.presentingViewController;
        [mainVC resetToSignInScreen];
        
        
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.currentOffsetY = scrollView.contentOffset.y;
}

- (void)loadRemotePdfFromUrl:(NSURL *)url;
{
//    CGRect rect = [[UIScreen mainScreen] bounds];
    CGRect rect = self.view.frame;
    CGSize screenSize = rect.size;
    
    UIWebView *myWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,screenSize.width,screenSize.height)];
    myWebView.autoresizesSubviews = YES;
    myWebView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    NSURLRequest *myRequest = [NSURLRequest requestWithURL:url];
    
    [myWebView loadRequest:myRequest];
    
    [self.navigationController.parentViewController.view addSubview: myWebView];
//    [myWebView release];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *theCellClicked = [self.tableView cellForRowAtIndexPath:indexPath];
    if (theCellClicked == _signOutCell) {
        //Do stuff
        NSLog(@"here");
    }
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
