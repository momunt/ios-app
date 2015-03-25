//
//  MMNT_LoadingSpinner.m
//  Momunt
//
//  Created by Masha Belyi on 9/25/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_LoadingSpinner.h"
#import "POPBasicAnimation.h"
#import "POPSpringAnimation.h"

@implementation MMNT_LoadingSpinner

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame withLogoImageNamed:(NSString *)logoImage andPinImageNamed:(NSString *)pinImage{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];  // clear background
        _center = self.center;
        
        float centerX = frame.size.width/2;
        float centerY = frame.size.height/2;
        float W = frame.size.width/4.35;
        float a = 0.0f; // rotation angle
        
        UIImage *pinImg = [UIImage imageNamed:pinImage];
        float imgH = W*pinImg.size.height/pinImg.size.width;
        float H = imgH;
        
        
//        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:logoImage]];
//        logo.frame = CGRectMake(0,0,frame.size.width, frame.size.height/2);
//        [self addSubview:logo];
        
        UIImageView *img1 = [[UIImageView alloc] initWithImage:pinImg];
        img1.frame = CGRectMake(0,0,W, imgH);
        img1.center = CGPointMake(centerX, -1+centerY-H/2);
        img1.transform = CGAffineTransformMakeRotation(0 * M_PI/180);
        [self addSubview:img1];
        _pin1 = img1;
        
        a = 60.0f;
        UIImageView *img2 = [[UIImageView alloc] initWithImage:pinImg];
        img2.frame = CGRectMake(0,0,W,imgH);
        img2.center = CGPointMake(2+centerX + cos(30*M_PI/180)*H/2, centerY-sin(30*M_PI/180)*H/2);
        img2.transform = CGAffineTransformMakeRotation(a * M_PI/180);
        [self addSubview:img2];
        _pin2 = img2;
        
        a = 120.0f;
        UIImageView *img3 = [[UIImageView alloc] initWithImage:pinImg];
        img3.frame = CGRectMake(0,0,W,imgH);
        img3.center = CGPointMake(2 + centerX + cos(30*M_PI/180)*H/2,  2+centerY+sin(30*M_PI/180)*H/2);
        img3.transform = CGAffineTransformMakeRotation(a * M_PI/180);
        img3.alpha = 0.0f;
        [self addSubview:img3];
        _pin3 = img3;
        
        a = 180.0f;
        UIImageView *img4 = [[UIImageView alloc] initWithImage:pinImg];
        img4.frame = CGRectMake(0,0,W,imgH);
        img4.center = CGPointMake(centerX, 3+centerY+H/2);
        img4.transform = CGAffineTransformMakeRotation(a * M_PI/180);
        [self addSubview:img4];
        img4.alpha = 0.0f;
        _pin4 = img4;
        
        a = -120.0f;
        UIImageView *img5 = [[UIImageView alloc] initWithImage:pinImg];
        img5.frame = CGRectMake(0,0,W,imgH);
        img5.center = CGPointMake(-2 + centerX - cos(30*M_PI/180)*H/2, 2+centerY+sin(30*M_PI/180)*H/2);
        img5.transform = CGAffineTransformMakeRotation(a * M_PI/180);
        [self addSubview:img5];
        img5.alpha = 0.0f;
        _pin5 = img5;
        
        a = -60.0f;
        UIImageView *img6 = [[UIImageView alloc] initWithImage:pinImg];
        img6.frame = CGRectMake(0,0,W,imgH);
        img6.center = CGPointMake(-2+centerX - cos(30*M_PI/180)*H/2, centerY-sin(30*M_PI/180)*H/2);
        img6.transform = CGAffineTransformMakeRotation(a * M_PI/180);
        [self addSubview:img6];
        _pin6 = img6;
        
        self.alpha = 1.0f;
        
    }
    return self;
}

-(void)spin{
    POPBasicAnimation *spin = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    spin.toValue = @(M_PI*2);
    spin.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    spin.duration = 2;
    spin.completionBlock = ^(POPAnimation *animation, BOOL finished){
        [self spin];
    };
    [self.layer pop_addAnimation:spin forKey:@"rotate"];
    
}
-(void)stopLoading{
    [self pop_removeAllAnimations];
}

-(void)startLoading{
    // fade in pins
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{[_pin3 setAlpha:1.0f];} completion:nil];
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveLinear animations:^{[_pin4 setAlpha:1.0f];} completion:nil];
    [UIView animateWithDuration:0.3 delay:0.6 options:UIViewAnimationOptionCurveLinear animations:^{[_pin5 setAlpha:1.0f];} completion:^(BOOL finished) {
        [self spin];
    }];
}

-(void)updateFrame:(CGRect)frame{
    self.frame = frame;
    _center = CGPointMake(frame.size.width/2, frame.size.height/2);
    
    float centerX = frame.size.width/2;
    float centerY = frame.size.height/2;
    float W = frame.size.width/4.35;
    
    UIImage *pinImg = _pin1.image;
    float imgH = W*pinImg.size.height/pinImg.size.width;
    float H = imgH;
    
    _pin1.frame = CGRectMake(0,0,W, imgH);
    _pin1.center = CGPointMake(centerX, -1+centerY-H/2);
    
    _pin2.frame = CGRectMake(0,0,W,imgH);
    _pin2.center = CGPointMake(2+centerX + cos(30*M_PI/180)*H/2, centerY-sin(30*M_PI/180)*H/2);
    
    _pin3.frame = CGRectMake(0,0,W,imgH);
    _pin3.center = CGPointMake(2 + centerX + cos(30*M_PI/180)*H/2,  2+centerY+sin(30*M_PI/180)*H/2);
    
    _pin4.frame = CGRectMake(0,0,W,imgH);
    _pin4.center = CGPointMake(centerX, 3+centerY+H/2);
    
    _pin5.frame = CGRectMake(0,0,W,imgH);
    _pin5.center = CGPointMake(-2 + centerX - cos(30*M_PI/180)*H/2, 2+centerY+sin(30*M_PI/180)*H/2);
    
    _pin6.frame = CGRectMake(0,0,W,imgH);
    _pin6.center = CGPointMake(-2+centerX - cos(30*M_PI/180)*H/2, centerY-sin(30*M_PI/180)*H/2);

}

@end
