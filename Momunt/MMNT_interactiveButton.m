//
//  MMNT_interactiveButton.m
//  Momunt
//
//  Created by Masha Belyi on 9/8/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_interactiveButton.h"
#import "POPSpringAnimation.h"
#import "POPBasicAnimation.h"
#import "MMNT_SharedVars.h"

@implementation MMNT_interactiveButton

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
    self.layer.anchorPoint = CGPointMake(0.5,0.5);
    self.adjustsImageWhenHighlighted = NO;
    
    [self addTarget:self action:@selector(onTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(onTouchUp) forControlEvents:UIControlEventTouchCancel];
    [self addTarget:self action:@selector(onTouchUp) forControlEvents:UIControlEventTouchUpOutside];
}

-(void)onTouchDown:(id)sender{
    [self pop_removeAllAnimations];
//    self.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [[MMNT_SharedVars sharedVars] scaleView:self toVal:CGPointMake(0.8,0.8) withDuration:0.1];

}

-(void)onTouchUp{
    [[MMNT_SharedVars sharedVars] scaleUp:self];
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
