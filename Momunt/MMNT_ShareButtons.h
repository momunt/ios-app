//
//  MMNT_ShareButtons.h
//  Momunt
//
//  Created by Masha Belyi on 8/25/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNT_PassTouches.h"

@interface MMNT_ShareButtons : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *facebookBtn;
@property (strong, nonatomic) IBOutlet UIButton *storeBtn;
@property (strong, nonatomic) IBOutlet UIButton *messageBtn;
@property (strong, nonatomic) IBOutlet UIButton *twitterBtn;
@property (strong, nonatomic) MMNT_PassTouches *sharePromptView;
@property (strong, nonatomic) UITextView *sharePrompt;
@property (strong, nonatomic) IBOutlet UIButton *hiddenBtn;

@property (strong, nonatomic) IBOutlet UIButton *closeBtn;
- (IBAction)pressedCloseBtn:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *l1;
@property (strong, nonatomic) IBOutlet UILabel *l2;


@property (strong, nonatomic) IBOutlet UILabel *saveLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *postLabel;
@property (strong, nonatomic) IBOutlet UILabel *tweetLabel;

- (IBAction)pressedMessage:(id)sender;

-(NSArray *)buttons;



@end
