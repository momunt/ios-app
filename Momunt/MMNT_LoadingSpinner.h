//
//  MMNT_LoadingSpinner.h
//  Momunt
//
//  Created by Masha Belyi on 9/25/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMNT_LoadingSpinner : UIView{
    UIImageView *_pin1;
    UIImageView *_pin2;
    UIImageView *_pin3;
    UIImageView *_pin4;
    UIImageView *_pin5;
    UIImageView *_pin6;
    
    CGPoint _center;

}

-(id)initWithFrame:(CGRect)frame withLogoImageNamed:(NSString *)logoImage andPinImageNamed:(NSString *)pinImage;
-(void)startLoading;
-(void)stopLoading;
-(void)updateFrame:(CGRect)frame;

@end
