//
//  MMNT_InstagramRegistrationViewController.m
//  Momunt
//
//  Created by Masha Belyi on 1/20/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import "MMNT_InstagramRegistrationViewController.h"
#import "MMNT_InstagramSignInViewController.h"
#import "MMNT_VerificationVC.h"
#import "MMNTDataController.h"
#import "MMNTApiCommuniator.h"
#import "MMNT_SharedVars.h"
#import "JNKeychain.h"
#import "MMNTAccountManager.h"
#import "MMNT_SignInController.h"


@interface MMNT_InstagramRegistrationViewController () <UITextFieldDelegate, CountryPickerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>{
    UIImagePickerController *mediaPicker;
    UIActionSheet *actionSheet;
    MMNTApiCommuniator *_apicommunicator;
}
@property BOOL inCountryPicker;
@property NSString *callCode;
@property BOOL keyboardActive;
@property UITextField *errorField;
@end

@implementation MMNT_InstagramRegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set up API communicator
    _apicommunicator = [[MMNTApiCommuniator alloc] init];
    _apicommunicator.delegate = self;

    
    _usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"username" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.45]}];
    _phoneField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"phone number" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.45]}];
    
    _usernameField.delegate = self;
    _phoneField.delegate = self;
    
    [[_usernameField.superview.subviews objectAtIndex:0] setAlpha:0.45f];
    [[_phoneField.superview.subviews objectAtIndex:0] setAlpha:0.45f];
    
    _profile.layer.cornerRadius = _profile.frame.size.width/2;
    _profile.clipsToBounds = YES;
    _profile.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.24].CGColor;
    _profile.layer.borderWidth = 2.0;
    _profile.image = _profileImg;
    _profile.userInteractionEnabled = YES;
    
    _errorMsg.center = CGPointMake(_errorMsg.center.x, _errorMsg.center.y+40);
    _errorMsg.hidden = YES;
    
    _callCodeField.enabled = NO;
    
    if(_username.length>0){
        _usernameField.text = _username;
        [[_usernameField.superview.subviews objectAtIndex:0] setAlpha:1.0f];
    }
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressedCameraButton:)];
    tap.numberOfTapsRequired = 1;
    [_profile addGestureRecognizer:tap];
    
    // listen for when keyboard slides up
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _animatedViews = [[NSArray alloc] initWithObjects:_textLabel, _profile, _usernameField.superview, _phoneField.superview, _termsText ,nil]; // _phoneField.superview
    
    // TERMS AND PRIVACY
    NSURL *termsURL = [NSURL URLWithString: @"http://www.momunt.com/docs/momunt_terms.pdf"];
    NSURL *privacyURL = [NSURL URLWithString: @"http://www.momunt.com/docs/Momunt_PrivacyPolicy.pdf"];
    NSString *text = @"By creating an account, you agree to the Terms of Use and you acknowledge that you have read the Privacy Policy";
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:11] range:NSMakeRange(0, str.length)];
    // links
    [str addAttribute: NSLinkAttributeName value:termsURL range: [text rangeOfString:@"Terms of Use"] ];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:11] range: [text rangeOfString:@"Terms of Use"] ];
    [str addAttribute: NSLinkAttributeName value:privacyURL range: [text rangeOfString:@"Privacy Policy"] ];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:11] range: [text rangeOfString:@"Privacy Policy"] ];
    // color
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, str.length)];
    
    _termsText.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    _termsText.editable = NO;
    _termsText.attributedText = str;

    
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
    if(textField.text.length==0){
        [_exitOrSubmit setTitle:@"exit" forState:UIControlStateNormal];
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
    _keyboardActive = YES;
    _countryPicker.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height+100);
    
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGFloat offset = kbSize.height+3;
    CGFloat newY = self.view.frame.size.height-(kbSize.height+3)-123;
    CGFloat correction = newY - _currentView.frame.origin.y;
    
    if(_currentView==_usernameField.superview){
        _phoneField.superview.alpha = 0.0;
    }
    else if(_currentView==_phoneField.superview){
        _usernameField.superview.alpha = 0.0;
    }

    
    _currentView.transform = CGAffineTransformTranslate(_currentView.transform, 0, correction); //CGAffineTransformMakeTranslation(0, correction);
    _exitOrSubmit.transform = CGAffineTransformMakeTranslation(0, -offset);
    
    // may need to move the profile pic and prompt up
    _textLabel.transform = CGAffineTransformMakeTranslation(0, -30);
    _profile.transform = CGAffineTransformMakeTranslation(0, -30);
    
//    _textLabel.transform = CGAffineTransformMakeTranslation(0, -offset/2);
//    _profile.transform = CGAffineTransformMakeTranslation(0, -offset/2);
//    
}

-(void)keyboardWillHide:(NSNotification *)note{
    _keyboardActive = NO;
    _usernameField.superview.transform = CGAffineTransformIdentity;
    _phoneField.superview.transform = CGAffineTransformIdentity;
    _exitOrSubmit.transform =  CGAffineTransformIdentity;
    _textLabel.transform = CGAffineTransformIdentity;
    _profile.transform = CGAffineTransformIdentity;

    _usernameField.superview.alpha = 1.0;
    _phoneField.superview.alpha = 1.0;
    
    if(![_usernameField.text isEqualToString:@""]){
        [_exitOrSubmit setTitle:@"submit" forState:UIControlStateNormal];
    }else{
        [_exitOrSubmit setTitle:@"exit" forState:UIControlStateNormal];
    }
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [super prepareForSegue:segue sender:sender];
    
    if([segue.destinationViewController isKindOfClass: [MMNT_InstagramSignInViewController class] ] || [segue.sourceViewController isKindOfClass: [MMNT_InstagramSignInViewController class] ]){
        _animatedViews = [[NSArray alloc] initWithObjects:_textLabel, _profile, _phoneField.superview ,nil];
        
    }else{
        _animatedViews = self.view.subviews;
    }
    
    if([segue.destinationViewController isKindOfClass: [MMNT_VerificationVC class] ]){
        
        MMNT_VerificationVC *toVC = segue.destinationViewController;
        toVC.profilePic = _profile.image;// [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_profileImg]]];
        toVC.phoneStr = [NSString stringWithFormat:@"+%@ %@",_callCode, _phoneField.text];
        toVC.phoneStrNospaces = [NSString stringWithFormat:@"%@%@",_callCode, _phoneField.text];
        
        
    }
    
}

- (IBAction)pressedCountryPicker:(id)sender {
    _inCountryPicker = YES;
//    [_phoneField resignFirstResponder];
    
    [_exitOrSubmit setTitle:@"submit" forState:UIControlStateNormal];
    _usernameField.superview.alpha = 0.0;
    
    CGFloat offset = _countryPicker.frame.size.height+3;
    CGFloat newY = self.view.frame.size.height-(_countryPicker.frame.size.height+3) - 123;
    CGFloat correction = newY - _phoneField.superview.frame.origin.y;
    
    [UIView animateWithDuration:0.3 animations:^{
        _termsText.alpha = 0.0;
        _usernameField.superview.alpha = 0.0;

        _phoneField.superview.transform = CGAffineTransformMakeTranslation(0, correction);
        _exitOrSubmit.transform = CGAffineTransformMakeTranslation(0, -offset);
        
        _countryPicker.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-100);
    }];
}

- (IBAction)presedExitOrSubmit:(id)sender {
    
    NSString *action = _exitOrSubmit.currentTitle;
    if([action isEqualToString:@"exit"]){
        if(_keyboardActive){
            [_usernameField resignFirstResponder];
            [_phoneField resignFirstResponder];
            return;
        }

        // pop to root controller
        _animatedViews = self.view.subviews;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self dismissKeyboard];
        
        if(![_usernameField.text isEqualToString:@""] && _phoneField.text.length==0 && _keyboardActive){
            // filled out everything exept for optional phone number. Slide down keyboard
            [self dismissKeyboard];
        }
        else if(![_usernameField.text isEqualToString:@""] && _phoneField.text.length==0 && !_keyboardActive){
            // filled out everything exept for optional phone number. Confirm if want to enter phone number
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Without a phone number your friends can't find you."
                                                            message:@"We will not display your number to other users."
                                                           delegate:self
                                                  cancelButtonTitle:@"Enter phone number"
                                                  otherButtonTitles:@"Register without phone number", nil];
            alert.tag = 100;
            [alert show];
        }

        else if(![_usernameField.text isEqualToString:@""] && ![_phoneField.text isEqualToString:@""]){
            // submit with phone verification
            dispatch_async(dispatch_get_main_queue(), ^{
                [_exitOrSubmit setTitle:@"creating your account" forState:UIControlStateNormal];
            });
            // phone string
            NSString *phoneStrNospaces = [NSString stringWithFormat:@"%@%@",_callCode, _phoneField.text];
            // send to server
            [_apicommunicator registerUser:_usernameField.text password:_password phone:phoneStrNospaces profile:_profile.image instagramToken:_token fullName:_fullName completion:^(NSDictionary *result) {
                
                NSInteger status = [[result objectForKey:@"status"] integerValue];
                if(status==300){
                    [_exitOrSubmit setTitle:@"submit" forState:UIControlStateNormal];
                    [self setError:@"Oops, another user has that name" onField:_usernameField];
                }
                else if(status==320){
                    [_exitOrSubmit setTitle:@"submit" forState:UIControlStateNormal];
                    [self setError:@"Oops, this number is registered" onField:_phoneField];
                }

                else if(status==210){
                    [_exitOrSubmit setTitle:@"thanks!" forState:UIControlStateNormal];
                    
                    NSString *usrId = [result valueForKey:@"userId"];
                    [[MMNTAccountManager sharedInstance] setUserId:[usrId integerValue]];
                    // transition to verification
                    [self performSegueWithIdentifier:@"goToVerification" sender:self];
                    
//                    NSString *usrId = [result valueForKey:@"userId"];
//                    NSString *token = [result valueForKey:@"token"];
//                    // save user Id
//                    [[MMNTAccountManager sharedInstance] setUserId:[usrId integerValue]];
//                    // transition into app
//                    [self enterAppWithToken:token];
                }
            }];

        }
        
    }

}

-(void)enterAppWithToken:(NSString *)token{
    NSLog(@"YAY! Got token: %@", token);
    
    // store token in keychain
    [JNKeychain saveValue:token forKey:@"AccessToken"];
    
    // grab user info
    [_apicommunicator getUserInfo];
    [_apicommunicator fetchUserChats];
    [_apicommunicator getTrendingMomunts];
    
    //transition to gallery
    MMNT_SignInController *parent = (MMNT_SignInController *)[self.navigationController parentViewController];
    [parent performSegueWithIdentifier:@"LoadingToGallery" sender:self];
    
}

- (void)dismissKeyboard {
    if(_inCountryPicker){
        
        [UIView animateWithDuration:0.3 animations:^{
            _phoneField.superview.transform = CGAffineTransformIdentity;
            _exitOrSubmit.transform = CGAffineTransformIdentity;
            
            _textLabel.transform = CGAffineTransformIdentity;
            _profile.transform = CGAffineTransformIdentity;
            
            _countryPicker.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height+100);
            _termsText.alpha = 1.0;
            _usernameField.superview.alpha = 1.0f;
        }completion:^(BOOL finished) {
            _inCountryPicker = NO;
            
            
        }];
        
    }else{
        _termsText.alpha = 1.0;
        _usernameField.superview.alpha = 1.0f;
        [_usernameField resignFirstResponder];
        [_phoneField resignFirstResponder];
        
    }
    
    if(![_usernameField.text isEqualToString:@""]){
        [_exitOrSubmit setTitle:@"submit" forState:UIControlStateNormal];
    }else{
        [_exitOrSubmit setTitle:@"exit" forState:UIControlStateNormal];
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

#pragma mark Image Picker

- (void)pressedCameraButton:(UITapGestureRecognizer *)recognizer {
    //    if (recognizer.state == UIGestureRecognizerStateEnded){
    //code here
    NSLog(@"clicked camera");
    
    mediaPicker = [[UIImagePickerController alloc] init];
    [mediaPicker setDelegate:self];
    mediaPicker.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"Take photo", @"Choose Existing", nil];
        [actionSheet showInView:self.view];
        //            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    } else {
        mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:mediaPicker animated:YES completion:nil];
    }
    
    //    }
}



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    _profile.layer.borderColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0].CGColor;
    //    self.promptLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    
    if(buttonIndex==2){
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    if (buttonIndex == 0) {
        mediaPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        mediaPicker.cameraDevice=UIImagePickerControllerCameraDeviceFront;
        
        //        UIView *overlay = mediaPicker.cameraOverlayView;
        //        UIButton *emptyBlackButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 35.0f)];
        //        [emptyBlackButton setBackgroundColor:[UIColor blackColor]];
        //        [emptyBlackButton setEnabled:YES];
        //        [overlay addSubview:emptyBlackButton];
        //
        //        mediaPicker.cameraOverlayView = overlay;
        
    } else if (buttonIndex == 1) {
        mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:mediaPicker animated:YES completion:nil];
    //    [actionSheet release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==100){
        if(buttonIndex==0)
        {
            // return, focus on phone input
            [_phoneField becomeFirstResponder];
        }else{
            // submit with phone verification
            dispatch_async(dispatch_get_main_queue(), ^{
                [_exitOrSubmit setTitle:@"creating your account" forState:UIControlStateNormal];
            });
            
            // submit without phone number
            [_apicommunicator registerUser:_usernameField.text password:_password phone:nil profile:_profile.image instagramToken:_token fullName:_fullName completion:^(NSDictionary *result) {
                
                NSInteger status = [[result objectForKey:@"status"] integerValue];
                if(status==300){
                    [self setError:@"Oops, another user has that name" onField:_usernameField];
                }else if(status==200){
                    NSString *usrId = [result valueForKey:@"userId"];
                    NSString *token = [result valueForKey:@"token"];
                    // save user Id
                    [[MMNTAccountManager sharedInstance] setUserId:[usrId integerValue]];
                    // transition into app
                    [self enterAppWithToken:token];
                }
            }];
            
        }
    }
    
    
}

/*
 Selected profile img
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *imgLarge = [info objectForKey:UIImagePickerControllerEditedImage];
    if(!imgLarge) imgLarge = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    UIImage *img = [self imageWithImage:imgLarge scaledToSize:CGSizeMake(150,150)];
    
    // flipped image
    //    UIImage * flippedImage = [UIImage imageWithCGImage:img.CGImage scale:img.scale orientation:UIImageOrientationLeftMirrored];
    
    [_profile setImage:img];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/*
 Set error
 */
-(void)setError:(NSString *)errorMsg onField:(UITextField *)textField{
    if(!_errorMsg.hidden){
        return;
    }
    _errorMsg.alpha = 0.0;
    _errorMsg.hidden = NO;
    _errorMsg.text = errorMsg;
    
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _errorMsg.center = CGPointMake(_errorMsg.center.x, _errorMsg.center.y-40);
                         _errorMsg.alpha = 1.0;
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
                     }
                     completion:^(BOOL finished) {
                         _errorMsg.hidden = YES;
                         _errorMsg.center = CGPointMake(_errorMsg.center.x, _errorMsg.center.y+40);
                     }];
    
    _errorField = nil;
    textField.textColor = [UIColor whiteColor];
    UIImageView *icon = [textField.superview.subviews objectAtIndex:0];
    UIImage *redIcon = [MMNT_SharedVars tintImage:icon.image WithColor:[UIColor whiteColor]];
    icon.image = redIcon;
    
    
}

@end
