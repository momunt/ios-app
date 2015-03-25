//
//  MMNT_CarouselHitTestView.m
//  Momunt
//
//  Created by Masha Belyi on 12/29/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_CarouselHitTestView.h"
#import "MMNT_SharedVars.h"
#import "POPSpringAnimation.h"

@implementation MMNT_CarouselHitTestView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        self.clipsToBounds = YES;
        [self setup];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:(NSCoder *)aDecoder];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        self.clipsToBounds = YES;
        [self setup];
        
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    _scrollView = [self.subviews objectAtIndex:0];
    return [self pointInside:point withEvent:event] ? _scrollView : nil;
}

-(void)setup{
    _triangle = [[UIView alloc] initWithFrame:CGRectMake(0,0,15,15)];
    _triangle.backgroundColor = [UIColor whiteColor];
    // rotate 45deg
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, 1, 1);
    transform = CGAffineTransformRotate(transform, M_PI_4);
    _triangle.transform = transform;
    
//    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_4);
//    triangle.transform = transform;
    // place at the bottom
    _triangle.center = CGPointMake(self.frame.size.width/2, self.frame.size.height+5);
    
    [self addSubview:_triangle];
}

-(void)hideTriangle{
    [UIView animateWithDuration:0.2 animations:^{
        _triangle.center = CGPointMake(self.frame.size.width/2, self.frame.size.height+25);
    }];
}
-(void)showTriangle{
    [MMNT_SharedVars runPOPSpringAnimation:kPOPViewCenter
                                    onView:_triangle
                                   toValue:[NSValue valueWithCGPoint:CGPointMake(self.frame.size.width/2, self.frame.size.height+5)]
                          springBounciness:12
                               springSpeed:15
                                     delay:0
                                    forKey:@"center"
                                completion:nil];
    
//    [UIView animateWithDuration:0.2 animations:^{
//        _triangle.center = CGPointMake(self.frame.size.width/2, self.frame.size.height);
//    }];
}



@end
