//
//  MMNT_VerificationInputView.h
//  Momunt
//
//  Created by Masha Belyi on 9/22/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MMNTVerificationInputDelegate <NSObject>
- (void)enteredCode:(NSString *)code;
-(void)changedCode:(NSString *)code;
@end

@interface MMNT_VerificationInputView : UIView <UITextFieldDelegate>{
    UILabel *v1;
    UILabel *v2;
    UILabel *v3;
    UILabel *v4;
    UITextField *hiddeninput;
    
    NSInteger *position;
    NSArray *inputs;
}
@property (weak, nonatomic) id<MMNTVerificationInputDelegate> delegate;
-(void)showKeyboard;
-(void)hideKeyboard;
-(void)reset;

@end
