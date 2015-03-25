//
//  MMNT_HelpCircle.m
//  Momunt
//
//  Created by Masha Belyi on 12/16/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_HelpCircle.h"
#import "POPBasicAnimation.h"
#import "POPSpringAnimation.h"
#import "MMNT_SharedVars.h"
#import "MMNTApplication.h"

@implementation MMNT_HelpCircle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.hidden = YES;
        
        // ORANGE CIRCLE
        _circle = [[UIView alloc] initWithFrame:frame];
        _circle.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:139.0/255.0 blue:0.0 alpha:1.0];
        _circle.layer.cornerRadius = frame.size.width/2;
        _circle.clipsToBounds = YES;
        
        // OUTLINE
        int radius = frame.size.width/2;
        _outline = [CAShapeLayer layer];
        // Make a circular shape
        _outline.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius) cornerRadius:radius].CGPath;
        // Center the shape in self.view
        _outline.position = CGPointMake(CGRectGetMidX(frame)-radius, CGRectGetMidY(frame)-radius);
        // Configure the apperence of the circle
        _outline.fillColor = [UIColor clearColor].CGColor;
        _outline.strokeColor = [UIColor whiteColor].CGColor;
        _outline.lineWidth = 2;
        _outline.strokeStart = 0.0;
        _outline.strokeEnd = 0.0;
        
        // CHECK
        _checkImage = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width*0.2,frame.size.height*0.2,frame.size.width*0.6,frame.size.height*0.6)];
        _checkImage.image = [self tintImage:[UIImage imageNamed:@"Check"] WithColor:[UIColor whiteColor]];
        _checkImage.contentMode = UIViewContentModeScaleAspectFit;
        
        [self       addSubview:_circle];
        [self.layer addSublayer:_outline];
        [self       addSubview:_checkImage];
        
    }
    return self;
}
-(void)reset{
    _checkImage.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    _outline.strokeEnd = 0.0;
    _completed = NO;
    _dragging = NO;
}
-(void)draggedToPoint:(CGPoint)point withPercent:(CGFloat)percent{
    if(_completed){return;}
    _dragging = YES;
    
    [self pop_removeAllAnimations];
    
    self.alpha = 1.0;
    self.center = point;
    self.transform = CGAffineTransformIdentity;
    _outline.strokeEnd = percent;
    
    if(percent >= 1.0){
        [self setCompleted];
    }
}

-(void)setCompleted{
    _completed = YES;
    [self pop_removeAllAnimations];
    
    _outline.strokeEnd = 1.0;
    self.transform = CGAffineTransformIdentity;
    self.alpha = 1.0;
    // pop in check image
    [[MMNT_SharedVars sharedVars] scaleUp:_checkImage];

}

-(void)animateFrom:(CGPoint)from to:(CGPoint)to{
    if(_completed || _dragging){return;}
    
    // register this as an event - so other tooltips don't show up on top
    [[MMNTApplication sharedApplication] sendEvent:nil];
    
    // place at start point
    self.center = from;
    self.alpha = 0.0f;
    _outline.strokeEnd = 0.0f;
    
    // show
    self.hidden = NO;
    
    if([_animationType isEqualToString:@"tap"]){
        // 1) fade in
        POPBasicAnimation *fadeIn = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        fadeIn.toValue = @(0.9);
        fadeIn.duration = 0.1;
        [self pop_addAnimation:fadeIn forKey:@"opacity"];
        
        POPBasicAnimation *fadeOut = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        fadeOut.toValue = @(0.0);
        fadeOut.duration = 0.5;
        fadeOut.completionBlock = ^(POPAnimation *animation, BOOL finished){
            [self animateFrom:from to:to];
        };

        //2) scale
        POPSpringAnimation *scale = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scale.fromValue = [NSValue valueWithCGPoint: CGPointMake(0.4,0.4)];
        scale.toValue = [NSValue valueWithCGPoint: CGPointMake(1,1)];
        scale.springBounciness = 5;
        scale.springSpeed = [_animationType isEqualToString:@"tap"] ? 5 : 10;
        scale.completionBlock = ^(POPAnimation *animation, BOOL finished){
            fadeOut.beginTime = CACurrentMediaTime() + 0.3;
            [self pop_addAnimation:fadeOut forKey:@"opacity"];
        };
        
        fadeIn.beginTime = CACurrentMediaTime() + 1.0;
        scale.beginTime = CACurrentMediaTime() + 1.0;
        
        [self pop_addAnimation:fadeIn forKey:@"alpha"];
        [self pop_addAnimation:scale forKey:@"scale"];

        
    }else{
        // 1) fade in
        POPBasicAnimation *fadeIn = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        fadeIn.toValue = @(1.0);
        fadeIn.duration = 0.1;
        [self pop_addAnimation:fadeIn forKey:@"opacity"];
    
        POPBasicAnimation *fadeOut = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        fadeOut.toValue = @(0.0);
        fadeOut.duration = 0.5;
        fadeOut.completionBlock = ^(POPAnimation *animation, BOOL finished){
            [self animateFrom:from to:to];
        };
    
        // 3) move, then fade out
        POPSpringAnimation *move = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
        move.toValue = [NSValue valueWithCGPoint:to];
        move.springBounciness = 8;
        move.springSpeed = 5;
        move.beginTime = CACurrentMediaTime() + 0.1;
        move.completionBlock = ^(POPAnimation *animation, BOOL finished){
            fadeOut.beginTime = CACurrentMediaTime() + 0.3;
            [self pop_addAnimation:fadeOut forKey:@"opacity"];
        };
    
        //2) scale
        POPSpringAnimation *scale = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scale.fromValue = [NSValue valueWithCGPoint: CGPointMake(0.4,0.4)];
        scale.toValue = [NSValue valueWithCGPoint: CGPointMake(1,1)];
        scale.springBounciness = 5;
        scale.springSpeed = [_animationType isEqualToString:@"tap"] ? 5 : 10;
    
        [self pop_addAnimation:move forKey:@"center"];
        [self pop_addAnimation:scale forKey:@"scale"];
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

@end

