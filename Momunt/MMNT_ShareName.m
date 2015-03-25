//
//  MMNT_ShareName.m
//  Momunt
//
//  Created by Masha Belyi on 8/25/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>

#import "Amplitude.h"

#import "MMNT_ShareName.h"
#import "AMWaveTransition.h"
#import "MMNT_TransitionsManager.h"
#import "MMNTDataController.h"
#import "MMNT_SharedVars.h"
#import "POPSpringAnimation.h"
#import "MMNT_SelectContactController.h"

//#import "MMNTAccountManager.h"
//#import "MMNT_AskPhoneNumberVC.h"


@interface MMNT_ShareName ()  <UINavigationControllerDelegate, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@end

@implementation MMNT_ShareName

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
    self.view.backgroundColor = [UIColor colorWithRed:(0 / 255.0) green:(0 / 255.0) blue:(0 / 255.0) alpha:0]; // clear background
    [self.navigationController setDelegate:self];
    
    MMNTDataController *mmntDataController = [MMNTDataController sharedInstance];
    // set name
    NSString *name = [[mmntDataController toShareMomunt].name stringByRemovingPercentEncoding];
    self.nameText.placeholder = name;
    self.nameText.text = name;
    self.nameText.delegate = self;
    
    [[UITextField appearance] setTintColor:[UIColor colorWithRed:254.0/255.0 green:126.0/255.0 blue:0 alpha:1.0]]; // make cursor and selection orange
    
    // set date and time
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"M/d/yy"];
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"a"];
    NSString *ampm = [[timeFormat stringFromDate:[mmntDataController toShareMomunt].timestamp] isEqualToString:@"AM"] ? @"a" : @"p";

    [timeFormat setDateFormat:@"h:mm"];
    NSString *theDate = [dateFormat stringFromDate:[mmntDataController toShareMomunt].timestamp];
    NSString *theTime = [NSString stringWithFormat:@"%@%@" , [timeFormat stringFromDate:[mmntDataController toShareMomunt].timestamp ], ampm];
    
    self.dateText.text = theDate;
    self.timeText.text = theTime;
    
    // hide saved prompt offscreen
    _savedPrompt.center = CGPointMake(_savedPrompt.center.x, _savedPrompt.center.y+200);
    
    // GESTURE HANDLER - to block gesture handlers on parent view
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                          initWithTarget:self
                                                          action:@selector(tappedOnce:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    singleTapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:singleTapGestureRecognizer];
    
    // subscribe to new chats notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(exit)
                                                 name:@"returnedFromFacebookShare"
                                               object:nil];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [Amplitude logEvent:@"went to share_name"];
    
//    if(_type==MESSAGE && [MMNTAccountManager sharedInstance].phone.length<1){
//        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//        MMNT_AskPhoneNumberVC *askPhoneVC = (MMNT_AskPhoneNumberVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"askPhoneNumber"];
//        askPhoneVC.modalPresentationStyle = UIModalPresentationCustom;
//        askPhoneVC.transitioningDelegate = askPhoneVC;
//        self.transitioningDelegate = askPhoneVC;
//        askPhoneVC.type = @"gallery";
//        
//        UIViewController *presenter = self.navigationController;
//        [presenter presentViewController:askPhoneVC animated:YES completion:nil];
//        
//    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if(gestureRecognizer.view != otherGestureRecognizer.view){
        return NO;
    }
    return YES;

}

-(void)close:(UITapGestureRecognizer *)recognizer {
    [self.navigationController.parentViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
-(void)exit{
    [self.navigationController.parentViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tappedOnce:(UITapGestureRecognizer *)recognizer{
//    [[MMNTDataController sharedInstance] setName:self.nameText.text];
    [MMNTDataController sharedInstance].toShareMomunt.name = self.nameText.text;
    [self.nameText resignFirstResponder]; // close name Text keyboard if it is open.
}


/* ------------------- <UINavigationControllerDelegate> ------------------- */

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    // from naming view to Contacts view
    return [MMNT_TransitionsManager transitionWithOperation:operation andTransitionType:MMNTTransitionFadeOutSlideUp];
    
}


- (IBAction)touchedDownInsideName:(id)sender {
}

- (IBAction)editedName:(id)sender {
//    [[MMNTDataController sharedInstance] setName:self.nameText.text];
    [MMNTDataController sharedInstance].toShareMomunt.name = self.nameText.text;
//    [self.nameText.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (IBAction)prossedClose:(id)sender {
    [self.navigationController.parentViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pressedCheck:(id)sender {
    if(_type==MESSAGE){
//        [self performSegueWithIdentifier:@"namingToContacts" sender:self];
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        MMNT_SelectContactController *contactsController = (MMNT_SelectContactController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"ChatContacts"];
        contactsController.type = @"share";
        [self.navigationController pushViewController:contactsController animated:YES];
    }
    else if(_type == STORE){
        // 1) store momunt async
        
//        dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
//        dispatch_async(sessionQueue, ^{
            [[MMNTDataController sharedInstance] storeMomunt: [MMNTDataController sharedInstance].toShareMomunt ];
//        });

        // 2) storing animation
        [[MMNT_SharedVars sharedVars] scaleDown:_checkButton];
        [[MMNT_SharedVars sharedVars] scaleDown:_xButton];
        
        POPSpringAnimation *slideUp = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
        slideUp.toValue = [NSValue valueWithCGPoint:CGPointMake(_savedPrompt.center.x, _savedPrompt.center.y-200)];
        slideUp.springBounciness = 15;
        slideUp.springSpeed = 10;
        slideUp.completionBlock = ^(POPAnimation *animation, BOOL finished){
            [self.navigationController.parentViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        };
        [_savedPrompt pop_addAnimation:slideUp forKey:@"center"];
        
//        [Amplitude logEvent:@"saved momunt"];
        
        

    }
    else if(_type == FACEBOOK){
        [self performFacebookShare];
    }
    else if(_type == TWITTER){
        [self performTwitterShare];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSUInteger bytes = [textField.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if(bytes > 20 && ![textField.text isEqualToString:@""]){
        return NO;
    }
    return YES;
}

-(void)performFacebookShare{
    // share the momunt. But wait for it to save&share before presenting the dialog
     NSArray *recipients = @[@"facebook"];    // do the actual sharing=

    [[MMNTDataController sharedInstance] shareMomuntViaText: [MMNTDataController sharedInstance].toShareMomunt with:recipients];
    [[MMNTApiCommuniator sharedInstance] shareMomunt:[MMNTDataController sharedInstance].toShareMomunt with:recipients willPost:NO completion:^(NSArray *messages) {
        //
     
    
    
    // Check if the Facebook app is installed and we can present the share dialog
    
    NSString *urlString = [NSString stringWithFormat:@"http://www.momunt.com/%@", [MMNTDataController sharedInstance].toShareMomunt.momuntId];
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:urlString];
    
    dispatch_async(dispatch_get_main_queue(), ^{

    
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        
        // Present share dialog
        [FBDialogs presentShareDialogWithLink:params.link
                                        handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                            if(error) {
                                                // An error occurred, we need to handle the error
                                                // See: https://developers.facebook.com/docs/ios/errors
                                                NSLog(@"Error publishing story: %@", error.description);
                                            } else {
                                                // Success
                                                NSLog(@"result %@", results);
                                            }
                                            [self dismissViewControllerAnimated:YES completion:nil];
                                        }];

    } else {
        // Present the feed dialog
        
        // Put together the dialog parameters
        NSMutableDictionary *paramsFD = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [MMNTDataController sharedInstance].toShareMomunt.name, @"name",
                                       urlString, @"link",
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:paramsFD
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User cancelled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                          // dismiss naming view
                                                          [self exit];
                                                      }
                                                  }];
    }
    });
    }];
   

}

// A function for parsing URL parameters returned by the Feed Dialog.
-(NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

-(void)performTwitterShare{
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        // share the momunt. But wait for it to save&share before presenting the dialog
        NSArray *recipients = @[@"twitter"];    // do the actual sharing=
//        [[MMNTDataController sharedInstance] shareMomunt: [MMNTDataController sharedInstance].toShareMomunt with:recipients];
        [[MMNTDataController sharedInstance] shareMomuntViaText: [MMNTDataController sharedInstance].toShareMomunt with:recipients];
        
        SLComposeViewController *tweetSheetOBJ = [SLComposeViewController
                                                  composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *urlString = [NSString stringWithFormat:@"http://www.momunt.com/%@", [MMNTDataController sharedInstance].toShareMomunt.momuntId];
        
        [tweetSheetOBJ setInitialText:@"Check out my momunt!"];
        [tweetSheetOBJ addURL:[NSURL URLWithString:urlString]];
        
        // Sets the completion handler.  Note that we don't know which thread the
        // block will be called on, so we need to ensure that any UI updates occur
        // on the main queue
        tweetSheetOBJ.completionHandler = ^(SLComposeViewControllerResult result) {
            switch(result) {
                    //  This means the user cancelled without sending the Tweet
                case SLComposeViewControllerResultCancelled:
                    break;
                    //  This means the user hit 'Send'
                case SLComposeViewControllerResultDone:
                    break;
            }
            
            //  dismiss the Tweet Sheet
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:NO completion:^{
                    NSLog(@"Tweet Sheet has been dismissed.");
                    
                }];
            });
            // dismiss naming view
            [self exit];
        };
        
        [self presentViewController:tweetSheetOBJ animated:YES completion:nil];
        
    }
}


@end
