//
//  MMNT_CameraContainerView.h
//  Momunt
//
//  Created by Masha Belyi on 9/6/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMNT_CameraContainerView;

/*
 CameraContainerDelegate
 Responds to pan gesture in camera view
*/
@protocol CameraContainerDelegate

-(void)cameraContainer:(MMNT_CameraContainerView *)view dragggingWithPercentage:(CGFloat)percentage;
-(void)cameraContainer:(MMNT_CameraContainerView *)view draggingEndedWithVelocity:(CGPoint)velocity withDeltaX:(CGFloat)deltaX;

@end



@interface MMNT_CameraContainerView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<CameraContainerDelegate> delegate;
@property CGPoint startCenter;
@property UIPanGestureRecognizer *panGesture;
-(void) setup;
@property BOOL startedDrag;

@end

