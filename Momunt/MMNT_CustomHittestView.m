//
//  MMNT_CustomHittestView.m
//  Momunt
//
//  Created by Masha Belyi on 9/7/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//
//
//  Allows assigning Gesture Recognizers to views outside of the Main View boundary
//  From: http://stackoverflow.com/questions/7622770/how-access-an-uiview-subview-partially-outside-of-his-parent-uiview
//

#import "MMNT_CustomHittestView.h"

@implementation MMNT_CustomHittestView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    for(UIView *subview in [[self.subviews reverseObjectEnumerator] allObjects])
//    for(UIView *subview in self.subviews)
    {
        UIView *view = [subview hitTest:[self convertPoint:point toView:subview] withEvent:event];
        if(view && view.userInteractionEnabled) return view;
    }
    return [super hitTest:point withEvent:event];
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
