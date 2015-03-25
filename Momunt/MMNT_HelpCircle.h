//
//  MMNT_HelpCircle.h
//  Momunt
//
//  Created by Masha Belyi on 12/16/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMNT_HelpCircle : UIView

@property UIView         *circle;
@property CAShapeLayer   *outline;
@property UIImageView    *checkImage;
@property BOOL           animationOn;
@property BOOL           completed;
@property BOOL           dragging;
@property NSString       *animationType;

-(void)reset;
-(void)draggedToPoint:(CGPoint)point withPercent:(CGFloat)percent;
-(void)animateFrom:(CGPoint)from to:(CGPoint)to;
-(void)setCompleted;

@end
