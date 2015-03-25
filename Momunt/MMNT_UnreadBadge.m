//
//  MMNT_UnreadBadge.m
//  Momunt
//
//  Created by Masha Belyi on 10/7/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_UnreadBadge.h"

@implementation MMNT_UnreadBadge

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame num:(NSInteger)num{
    self = [super initWithFrame:frame];
    if (self) {
        // orange circle
        self.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:139.0/255.0 blue:0.0 alpha:1.0];
        self.layer.cornerRadius = frame.size.width/2;
        self.clipsToBounds = YES;
        
        // add label
        _l = [[UILabel alloc] initWithFrame:CGRectMake(0,0,frame.size.width, frame.size.height)];
        _l.text = [NSString stringWithFormat:@"%i", num];
        _l.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        _l.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:frame.size.height*0.8];
        _l.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_l];

    }
    return self;
}
-(void)setCount:(NSInteger)num{
    _l.text = [NSString stringWithFormat:@"%i", num];
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
