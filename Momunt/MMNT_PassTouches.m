//
//  MMNT_PassTouches.m
//  Momunt
//
//  Created by Masha Belyi on 12/16/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_PassTouches.h"

@implementation MMNT_PassTouches


-(id)initWithFrame:(CGRect)frame passRect:(CGRect)passRect{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _passRect = passRect;
        _setPassRect = YES;
    }
    return self;

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        _passRect = CGRectMake(0,0,frame.size.width, frame.size.height); // default to entire view pass touches
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:(NSCoder *)aDecoder];
    if (self) {
        // Initialization code
//        _passRect = CGRectMake(0,0,self.frame.size.width, self.frame.size.height); // default to entire view pass touches
        
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if(!_setPassRect){
        return NO;
    }
    if(CGRectContainsPoint(_passRect, point)){
        //    NSLog(@"Passing all touches to the next view (if any), in the view stack.");
//
//        [_delegate MMNTPassTouchesView:self passedPoint:point];
        return NO;
    }else{
        return YES;
    }
}

@end
