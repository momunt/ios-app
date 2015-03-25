//
//  MMNT_InteractiveIcon.m
//  Momunt
//
//  Created by Masha Belyi on 2/14/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import "MMNT_InteractiveIcon.h"
#import "POPSpringAnimation.h"
#import "POPBasicAnimation.h"

@implementation MMNT_InteractiveIcon

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self pop_removeAllAnimations];
    
    POPBasicAnimation *a = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    a.toValue = [NSValue valueWithCGPoint:CGPointMake(0.8,0.8)];
    a.duration = 0.1;
//    a.springBounciness = bounciness;
//    a.springSpeed = speed;
//    a.beginTime = CACurrentMediaTime() + delay;
    a.completionBlock = ^(POPAnimation *animation, BOOL finished){
        POPSpringAnimation *a = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        a.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0,1.0)];
        a.springBounciness = 12;
        a.springSpeed = 10;
        a.completionBlock = ^(POPAnimation *animation, BOOL finished){
        };
        
        [self pop_addAnimation:a forKey:@"scale"];
//
    
    };
    
    [self pop_addAnimation:a forKey:@"scale"];
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    [_delegate touchedUpInside:self];
//    [self pop_removeAllAnimations];
//    
//    POPSpringAnimation *a = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
//    a.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0,1.0)];
//    a.springBounciness = 8;
//    a.springSpeed = 10;
//    a.completionBlock = ^(POPAnimation *animation, BOOL finished){
//    };
//    
//    [self pop_addAnimation:a forKey:@"scale"];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
}

@end
