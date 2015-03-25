//
//  MMNT_ForgotPassword.m
//  Momunt
//
//  Created by Masha Belyi on 11/29/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_ForgotPassword.h"
#import "MMNTApiCommuniator.h"
#import "MMNT_SharedVars.h"
#import "POPSpringAnimation.h"
#import "MMNT_SignIn.h"
#import <MessageUI/MessageUI.h>

@interface MMNT_ForgotPassword ()<MFMailComposeViewControllerDelegate> {
    UIImagePickerController *mediaPicker;
    UIActionSheet *actionSheet;
    MMNTApiCommuniator *_apicommunicator;
}
@property BOOL selectedProfile;
@property BOOL inCountryPicker;
@property BOOL keyboardActive;
@property NSString *callCode;
@property UITextField *errorField;

@end

@implementation MMNT_ForgotPassword

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _phoneField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"phone number" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.45]}];
    _phoneField.delegate = self;
    [[_phoneField.superview.subviews objectAtIndex:0] setAlpha:0.45f];
    
    _errorMsg.editable = NO;
    _contactBtn.titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    
    // listen for when keyboard slides up
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _callCodeField.enabled = NO;
    _animatedViews = @[_errorMsg, _phoneField.superview, _contactBtn, _exitOrSubmit];
    
    // INIT COUNTRY PICKER
    _countryPicker = [[CountryPicker alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width, 200)];
    _countryPicker.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height+100);
    [self.view addSubview:_countryPicker];
    _countryPicker.delegate = self;
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *code = [locale objectForKey: NSLocaleCountryCode];
    _countryPicker.selectedLocale = locale;
    NSString *imagePath = [NSString stringWithFormat:@"CountryPicker.bundle/%@", code];
    [_countryPickerBtn setImage:[UIImage imageNamed:imagePath] forState:UIControlStateNormal];
    
    _dictCallCodes = [NSDictionary dictionaryWithObjectsAndKeys:@"972", @"IL",
                      @"93", @"AF", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
                      @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
                      @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
                      @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
                      @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
                      @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
                      @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
                      @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
                      @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
                      @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
                      @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
                      @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
                      @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
                      @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
                      @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
                      @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
                      @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
                      @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
                      @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
                      @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
                      @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
                      @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
                      @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
                      @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
                      @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
                      @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
                      @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
                      @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
                      @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
                      @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
                      @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
                      @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
                      @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
                      @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
                      @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
                      @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
                      @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
                      @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
                      @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
                      @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
                      @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
                      @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
                      @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
                      @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
                      @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
                      @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
                      @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
                      @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
                      @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
                      @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
                      @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
                      @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
                      @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
                      @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
                      @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
                      @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
                      @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
                      @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
                      @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
                      @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
    
    
    _callCode = [_dictCallCodes valueForKey:code];
    
    
    // Resign keyboard when click out of textfield
    UITapGestureRecognizer *clickout = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:clickout];
    clickout.delegate = self;

    
}

- (NSArray*)visibleCells{
    //    return self.view.subviews;
    return self.animatedViews;
}
- (NSArray*)staticCells{
    return self.view.subviews;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _currentView = textField.superview;
    if(textField == _errorField){
        [self hideErrorOnField:textField];
    }
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    _currentView = textField.superview;
    UIView *icon = [_currentView.subviews objectAtIndex:0]; // icon image
    
    if(newLength>0){
        [UIView animateWithDuration:0.3 animations:^{icon.alpha = 1.0f;}];
        [_exitOrSubmit setTitle:@"submit" forState:UIControlStateNormal];
    }else{
        [UIView animateWithDuration:0.3 animations:^{icon.alpha = 0.45f;}];
        [_exitOrSubmit setTitle:@"exit" forState:UIControlStateNormal];
    }
    
    return YES;
}
-(void)keyboardWillShow:(NSNotification *)note{
    _inCountryPicker = NO;
    _countryPicker.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height+100);
    _keyboardActive = YES;
    
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGFloat offset = kbSize.height+3;
    CGFloat newY = self.view.frame.size.height-(kbSize.height+3)-123;
    CGFloat correction = newY - _currentView.frame.origin.y;
    
    _contactBtn.hidden = YES;
    
    _errorMsg.alpha = 0.0;
    _currentView.transform = CGAffineTransformTranslate(_currentView.transform, 0, correction); //CGAffineTransformMakeTranslation(0, correction);
    _exitOrSubmit.transform = CGAffineTransformMakeTranslation(0, -offset);
    
    _logoPic.transform = CGAffineTransformMakeTranslation(0, -offset/3);
    _logoText.transform = CGAffineTransformMakeTranslation(0, -offset/3);
    _tagLine.transform = CGAffineTransformMakeTranslation(0, -offset/3);
}

-(void)keyboardWillHide:(NSNotification *)note{
    _keyboardActive = NO;
    _phoneField.superview.transform = CGAffineTransformIdentity;
    _exitOrSubmit.transform =  CGAffineTransformIdentity;
    _logoPic.transform = CGAffineTransformIdentity;
    _logoText.transform = CGAffineTransformIdentity;
    _tagLine.transform = CGAffineTransformIdentity;
    _errorMsg.alpha = 1.0;
    _contactBtn.hidden = NO;
    
    if(![_phoneField.text isEqualToString:@""]){
        [_exitOrSubmit setTitle:@"submit" forState:UIControlStateNormal];
        //        [self loginInstagram];
    }else{
        [_exitOrSubmit setTitle:@"exit" forState:UIControlStateNormal];
    }

}


- (IBAction)pressedCountryPicker:(id)sender {
    _inCountryPicker = YES;
    [_phoneField resignFirstResponder];
    _errorMsg.alpha = 1.0;
    
    [_exitOrSubmit setTitle:@"submit" forState:UIControlStateNormal];
    
    _contactBtn.hidden = YES;
    _errorMsg.alpha = 0.0;
    
    CGFloat offset = _countryPicker.frame.size.height+3;
    CGFloat newY = self.view.frame.size.height-(_countryPicker.frame.size.height+3) - 123;
    CGFloat correction = newY - _phoneField.superview.frame.origin.y;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        _phoneField.superview.transform = CGAffineTransformMakeTranslation(0, correction);
        _exitOrSubmit.transform = CGAffineTransformMakeTranslation(0, -offset);
        
        _countryPicker.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-100);
    }];
}

- (void)dismissKeyboard {
    if(_inCountryPicker){
        
        [UIView animateWithDuration:0.3 animations:^{
            _phoneField.superview.transform = CGAffineTransformIdentity;
            _exitOrSubmit.transform = CGAffineTransformIdentity;
            
            _countryPicker.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height+100);
            _errorMsg.alpha = 1.0;
        }completion:^(BOOL finished) {
            _inCountryPicker = NO;
            _contactBtn.hidden = NO;
        }];
        
    }
    else{
        [_phoneField resignFirstResponder];
    }
}

#pragma mark - CountryPicker Delegate
- (void)countryPicker:(__unused CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code{
    
    NSString *imagePath = [NSString stringWithFormat:@"CountryPicker.bundle/%@", code];
    [_countryPickerBtn setImage:[UIImage imageNamed:imagePath] forState:UIControlStateNormal];
    
    
    _callCode = [_dictCallCodes valueForKey:code];
    _callCodeField.text = [NSString stringWithFormat:@"+%@", _callCode ];
    NSLog(@"CODE: %@", _callCode);
}




- (IBAction)pressedExitOrSubmit:(id)sender {
    NSString *action = _exitOrSubmit.currentTitle;
    if([action isEqualToString:@"exit"]){
        // exit keyboard
        if(_keyboardActive){
            [_phoneField resignFirstResponder];
            return;
        }
        
        // pop to sign in controller
        MMNT_SignIn *toVC = [self.navigationController.viewControllers objectAtIndex:1];
        [toVC resetInputs];
        [self.navigationController popToViewController:toVC animated:YES];
    }
    else{
        [self dismissKeyboard];
        
        if(![_phoneField.text isEqualToString:@""]){
            NSString *phoneStr = [NSString stringWithFormat:@"+%@ %@",_callCode, _phoneField.text];
            NSString *phoneStrNospaces = [NSString stringWithFormat:@"%@%@",_callCode, _phoneField.text];
            
            [[MMNTApiCommuniator sharedInstance] resetPasswordForPhone:phoneStrNospaces completion:^(BOOL error) {
                if(!error){
                    NSString *prompt = [NSString stringWithFormat:@"Info sent to %@", phoneStr];
                    _errorMsg.text = prompt;
                    _errorMsg.hidden = NO;
                    _errorMsg.alpha = 1.0;
                    // pop to sign in controller
                    MMNT_SignIn *toVC = [self.navigationController.viewControllers objectAtIndex:1];
                    [toVC resetInputs];
                    
                    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1.0);
                    dispatch_after(delay, dispatch_get_main_queue(), ^(void){
                        // do work in the UI thread here
                        [self.navigationController popToViewController:toVC animated:YES];
                    });
                    
                }else{
                    NSString *error =  [NSString stringWithFormat:@"%@ is not a registered number", phoneStr];
                    [_exitOrSubmit setTitle:@"exit" forState:UIControlStateNormal];
                    [self setError:error onField:_phoneField];
                }
            }];
            
            
        }else{
            NSLog(@"phone not filled out");
        }
        
    }
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [super prepareForSegue:segue sender:sender];

    
    if([segue.destinationViewController isKindOfClass: [MMNT_SignIn class] ]){
        
        MMNT_SignIn *toVC = segue.destinationViewController;
        [toVC resetInputs];
        
    }
    
}

-(void)setError:(NSString *)errorMsg onField:(UITextField *)textField{

    _errorMsg.alpha = 0.0;
    _errorMsg.hidden = NO;
    _errorMsg.text = errorMsg;
    
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
//                         _errorMsg.center = CGPointMake(_errorMsg.center.x, _errorMsg.center.y-40);
                         _errorMsg.alpha = 1.0;
                         _contactBtn.titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         NSLog(@"here");
                     }];
    
    _errorField = textField;
    textField.textColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:1.0];
    UIImageView *icon = [textField.superview.subviews objectAtIndex:0];
    UIImage *redIcon = [MMNT_SharedVars tintImage:icon.image WithColor:[UIColor colorWithRed:1.0 green:0 blue:0 alpha:1.0]];
    icon.image = redIcon;
}
-(void)hideErrorOnField:(UITextField *)textField{
    
    // hide error prompt. Fade out
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _errorMsg.alpha = 0.0;
                         _contactBtn.titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
                     }
                     completion:^(BOOL finished) {
                         _errorMsg.hidden = YES;
                         
//                         _errorMsg.center = CGPointMake(_errorMsg.center.x, _errorMsg.center.y+40);
                     }];
    
    _errorField = nil;
    textField.textColor = [UIColor whiteColor];
    UIImageView *icon = [textField.superview.subviews objectAtIndex:0];
    UIImage *redIcon = [MMNT_SharedVars tintImage:icon.image WithColor:[UIColor whiteColor]];
    icon.image = redIcon;
    
    
}

- (IBAction)pressedContactBtn:(id)sender {
    // Email Subject
    NSString *emailTitle = @"I am having trouble signing in.";
    // Email Content
    NSString *messageBody = @"";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"team@momunt.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
