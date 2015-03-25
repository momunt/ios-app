//
//  MMNT_PassTouches.h
//  Momunt
//
//  Created by Masha Belyi on 12/16/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MMNT_PassTouchesDelegate;

@interface MMNT_PassTouches : UIView

@property(nonatomic, assign) id <MMNT_PassTouchesDelegate> delegate;

-(id)initWithFrame:(CGRect)frame passRect:(CGRect)passRect;
@property CGRect passRect; // define a rect inside view that will be pass-through. if not defined - everything is passothrough
@property BOOL setPassRect;

@end

@protocol MMNT_PassTouchesDelegate
-(void) MMNTPassTouchesView:(MMNT_PassTouches *)view passedPoint:(CGPoint)point;
@end