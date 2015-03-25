//
//  MMNT_HelpTasksController.h
//  Momunt
//
//  Created by Masha Belyi on 12/17/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNTViewController.h"

@protocol MMNTHelpTaskDelegate;


@interface MMNT_HelpTasksController : UIViewController{
    NSString *_promptPosition;
}

@property(nonatomic, assign) id <MMNTHelpTaskDelegate> delegate;
@property UIViewController *parentVC;

@property NSDictionary *taskIds;

@property NSInteger taskId;
@property NSString *taskName;
@property CGPoint fromPoint;
@property CGPoint toPoint;
@property NSString *position;
@property NSString *helpText;
@property NSString *taskType;

@property CGPoint targetMotion;
@property CGPoint targetPoint;
@property CGRect targetArea;
@property CGRect passArea;

@property CGPoint promptCenter;
@property UIImage *blurImage;

//UIViewControllerAnimatedTransitioning
@property NSString *transitionOperation;

-(void)showAnimation;
-(void)show;
-(void)hide;


@end


@protocol MMNTHelpTaskDelegate

-(void) MMNTHelpTaskStartedTaskWithId:(CGFloat)taskId;
-(void) MMNTHelpTaskId:(NSInteger)taskId completedWithPercent:(CGFloat)percent;
-(void) MMNTHelpTaskFinishedTaskWithId:(CGFloat)taskId;
-(void) MMNTHelpTaskCancelledTaskWithId:(CGFloat)taskId;
-(void) MMNTHelpTaskSkippedTaskWithId:(CGFloat)taskId;

@end