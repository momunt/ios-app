//
//  MMNT_checkButton.m
//  Momunt
//
//  Created by Masha Belyi on 9/7/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_checkButton.h"

@implementation MMNT_checkButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImage *img = [UIImage imageNamed:@"Check"];
        UIImage *imgWhite = [self tintImage:img WithColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
        self.imageView.image = imgWhite;
        self.imageView.frame = CGRectMake((frame.size.width-43)/2, (frame.size.height-33)/2, 43, 33);
    }
    return self;
}
-(void)layoutSubviews{
    if(self.layoutDone)
        return;
    
    UIImage *img = [UIImage imageNamed:@"Check"];
    UIImage *imgWhite = [self tintImage:img WithColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
    self.imageView.image = imgWhite;
    self.imageView.frame = CGRectMake((self.frame.size.width-43)/2, (self.frame.size.height-33)/2, 43, 33);
    self.layoutDone = YES;
}
-(void)setWidthPercent:(CGFloat)p{
    CGFloat W = self.frame.size.width*p;
    CGFloat H = W*33/43;
    self.imageView.frame = CGRectMake((self.frame.size.width-W)/2, (self.frame.size.height-H)/2, W, H);
}
-(void)setHeightPercent:(CGFloat)p{
    CGFloat H = self.frame.size.height*p;
    CGFloat W = H*43/33;
    self.imageView.frame = CGRectMake((self.frame.size.width-W)/2, (self.frame.size.height-H)/2, W, H);
}
-(void)setSizePercent:(CGFloat)p{
    if(self.frame.size.width > self.frame.size.height){
        [self setHeightPercent:p];
    }else{
        [self setWidthPercent:p];
    }
}

- (UIImage *)tintImage:(UIImage *)image WithColor:(UIColor *)tintColor
{
    // It's important to pass in 0.0f to this function to draw the image to the scale of the screen
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    UIRectFill(bounds);
    [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
