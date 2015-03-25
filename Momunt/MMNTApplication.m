//
//  MMNTApplication.m
//  Momunt
//
//  Created by Masha Belyi on 2/4/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import "MMNTApplication.h"

@implementation MMNTApplication

//here we are listening for any touch. If the screen receives touch, the timer is reset
-(void)sendEvent:(UIEvent *)event
{
    [super sendEvent:event];
    
    if (!myidleTimer)
    {
        [self resetIdleTimer];
    }
    
    NSSet *allTouches = [event allTouches];
    if ([allTouches count] > 0 || event==nil)
    {
        UITouchPhase phase = ((UITouch *)[allTouches anyObject]).phase;
        if (phase == UITouchPhaseBegan)
        {
            [self resetIdleTimer];
        }
        
    }
}

//as labeled...reset the timer
-(void)resetIdleTimer
{
//    NSLog(@"resetTimer");
    if (myidleTimer)
    {
        [myidleTimer invalidate];
    }
    //convert the wait period into minutes rather than seconds
//    int timeout = kApplicationTimeoutInMinutes * 60;
    myidleTimer = [NSTimer scheduledTimerWithTimeInterval:kApplicationTimeoutInSeconds target:self selector:@selector(idleTimerExceeded) userInfo:nil repeats:NO];
    
}
//if the timer reaches the limit as defined in kApplicationTimeoutInMinutes, post this notification
-(void)idleTimerExceeded
{
//    NSLog(@"timed out!");
    [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationDidTimeoutNotification object:nil];
}

@end
