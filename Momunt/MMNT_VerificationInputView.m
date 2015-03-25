//
//  MMNT_VerificationInputView.m
//  Momunt
//
//  Created by Masha Belyi on 9/22/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_VerificationInputView.h"

@implementation MMNT_VerificationInputView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:(NSCoder *)aDecoder];
    if (self) {
        // Initialization code
        [self setup];
        
    }
    return self;
}

-(void)setup{
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    
    // Assume: 4*w + 3*d = frame.size.width. w = width of cell input; d = padding between cells
    NSInteger w = self.frame.size.width/5; //calculated..
    NSInteger d = self.frame.size.width/15; // calculated..
    NSInteger h = self.frame.size.height;
    NSInteger borderH = 2.0f;
    
    // add text labels, equally spaced
    v1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    v2 = [[UILabel alloc] initWithFrame:CGRectMake(w+d, 0, w, h)];
    v3 = [[UILabel alloc] initWithFrame:CGRectMake(w*2+d*2, 0, w, h)];
    v4 = [[UILabel alloc] initWithFrame:CGRectMake(w*3+d*3, 0, w, h)];
    
    // Add white bottom borders to input fields
    CALayer *border1 = [CALayer layer];
    border1.frame = CGRectMake(0.0f, h-borderH, w, borderH);
    border1.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f].CGColor;
    [v1.layer addSublayer:border1];

    CALayer *border2 = [CALayer layer];
    border2.frame = CGRectMake(0.0f, h-borderH, w, borderH);
    border2.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f].CGColor;
    [v2.layer addSublayer:border2];
    
    CALayer *border3 = [CALayer layer];
    border3.frame = CGRectMake(0.0f, h-borderH, w, borderH);
    border3.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f].CGColor;
    [v3.layer addSublayer:border3];
    
    CALayer *border4 = [CALayer layer];
    border4.frame = CGRectMake(0.0f, h-borderH, w, borderH);
    border4.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f].CGColor;
    [v4.layer addSublayer:border4];
    
    // add text
//    v1.text = @"2";
//    v2.text = @"7";
//    v3.text = @"9";
//    v4.text = @"3";
    
    // font and settings
    v1.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    v1.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:h-10];
    v1.textColor = [UIColor whiteColor];
    v1.textAlignment = NSTextAlignmentCenter;
    v2.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    v2.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:h-10];
    v2.textColor = [UIColor whiteColor];
    v2.textAlignment = NSTextAlignmentCenter;
    v3.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    v3.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:h-10];
    v3.textColor = [UIColor whiteColor];
    v3.textAlignment = NSTextAlignmentCenter;
    v4.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    v4.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:h-10];
    v4.textColor = [UIColor whiteColor];
    v4.textAlignment = NSTextAlignmentCenter;
    
    
    // add to view
    [self addSubview:v1];
    [self addSubview:v2];
    [self addSubview:v3];
    [self addSubview:v4];
    
    // hidden UITextField that will trigger the keyboard
    hiddeninput = [[UITextField alloc] initWithFrame:CGRectMake(-1000,-1000,100,50)];
    [hiddeninput setKeyboardType:UIKeyboardTypeNumberPad];
    [hiddeninput setAlpha:0];
    hiddeninput.delegate = self;
    
    [self addSubview:hiddeninput];
    
//    [self showKeyboard];
    
    // Add a "textFieldDidChange" notification method to the text field control.
    [hiddeninput addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
}
-(void)showKeyboard{
    [hiddeninput becomeFirstResponder];
}
-(void)hideKeyboard{
    [hiddeninput resignFirstResponder];
}
-(NSString *)getCode{
    return @"";
}
-(void)textFieldDidChange:(UITextField *)textField{
    
    v1.text = textField.text.length > 0 ? [textField.text substringWithRange:NSMakeRange(0, 1)] : @"";
    v2.text = textField.text.length > 1 ? [textField.text substringWithRange:NSMakeRange(1, 1)] : @"";
    v3.text = textField.text.length > 2 ? [textField.text substringWithRange:NSMakeRange(2, 1)] : @"";
    v4.text = textField.text.length > 3 ? [textField.text substringWithRange:NSMakeRange(3, 1)] : @"";
    
    if(textField.text.length == 4){
        // entered full code
        [_delegate enteredCode:textField.text];
    }else{
        [_delegate changedCode:textField.text];
    }
}
-(void)reset{
    v1.text = @"";
    v2.text = @"";
    v3.text = @"";
    v4.text = @"";
    hiddeninput.text = @"";
}

/*
 UITextFieldDelegate
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 4) ? NO : YES;

}



@end
