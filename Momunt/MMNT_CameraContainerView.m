//
//  MMNT_CameraContainerView.m
//  Momunt
//
//  Created by Masha Belyi on 9/6/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_CameraContainerView.h"

@implementation MMNT_CameraContainerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void) setup{
    self.userInteractionEnabled = YES;
        // drag gesture
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    recognizer.delegate = self;
    self.panGesture = recognizer;
    [self addGestureRecognizer:recognizer];
    self.startCenter = self.center;
}

- (void)didPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer translationInView:self.superview];
    CGPoint velocity = [recognizer velocityInView:self.superview];
    CGPoint location = [recognizer locationInView:self.superview];
    
    BOOL right = velocity.x > 0; // swiped left->right?
    if(right && recognizer.state==UIGestureRecognizerStateBegan){
        return;
    }

    if(self.startedDrag){ // update position only if started dragging right->left
        CGFloat percentage = ABS(point.x) / self.frame.size.width;
        [self.delegate cameraContainer:self dragggingWithPercentage:percentage];
    }
    
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if(!self.startedDrag)
            return;
        
        velocity.y = 0;
        [self.delegate cameraContainer:self draggingEndedWithVelocity:velocity withDeltaX:point.x];
        self.startedDrag = NO;
        
    } else if (recognizer.state == UIGestureRecognizerStateBegan) {
//        [self.delegate dropDownViewBeganDragging:self];
        self.startedDrag = YES;
    }
}

// don't fire pan if not horizontal!
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isEqual:self.panGesture]) {
        if (gestureRecognizer.numberOfTouches > 0) {
            CGPoint translation = [self.panGesture velocityInView:self];
            return fabs(translation.y) < fabs(translation.x);
        } else {
            return NO;
        }
    }
    return YES;
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
