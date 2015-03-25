//
//  MMNTApplication.h
//  Momunt
//
//  Created by Masha Belyi on 2/4/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>

//the length of time before your application "times out". This number actually represents seconds, so we'll have to multiple it by 60 in the .m file
#define kApplicationTimeoutInSeconds 4

//the notification your AppDelegate needs to watch for in order to know that it has indeed "timed out"
#define kApplicationDidTimeoutNotification @"AppIsIdle"

@interface MMNTApplication : UIApplication
{
    NSTimer     *myidleTimer;
}

-(void)resetIdleTimer;
@end
