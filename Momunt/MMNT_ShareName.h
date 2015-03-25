//
//  MMNT_ShareName.h
//  Momunt
//
//  Created by Masha Belyi on 8/25/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNT_xButton.h"
#import "MMNT_checkButton.h"

typedef enum{
    STORE,
    MESSAGE,
    FACEBOOK,
    TWITTER
} MMNTSaveType;

@interface MMNT_ShareName : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *nameText;
@property (strong, nonatomic) IBOutlet UILabel *dateText;
@property (strong, nonatomic) IBOutlet UILabel *timeText;
@property MMNTSaveType type;

- (IBAction)touchedDownInsideName:(id)sender;
- (IBAction)editedName:(id)sender;
- (IBAction)prossedClose:(id)sender;
- (IBAction)pressedCheck:(id)sender;


@property (strong, nonatomic) IBOutlet UILabel *savedPrompt;
@property (strong, nonatomic) IBOutlet MMNT_xButton *xButton;
@property (strong, nonatomic) IBOutlet MMNT_checkButton *checkButton;

@end
