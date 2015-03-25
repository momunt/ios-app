//
//  MMNT_TransparentView.m
//  Momunt
//
//  Created by Masha Belyi on 9/21/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_TransparentView.h"

@implementation MMNT_TransparentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:(NSCoder *)aDecoder];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        
    }
    return self;
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
