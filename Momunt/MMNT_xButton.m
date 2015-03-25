//
//  MMNT_xButton.m
//  Momunt
//
//  Created by Masha Belyi on 9/7/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_xButton.h"

@implementation MMNT_xButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImage *xImg = [UIImage imageNamed:@"X"];
        self.imageView.image = xImg;
        self.imageView.frame = CGRectMake((frame.size.width-33)/2, (frame.size.height-33)/2, 33, 33);
        
    }
    return self;
}
-(void)layoutSubviews{
    if(self.layoutDone)
        return;
    UIImage *img = [UIImage imageNamed:@"X"];
    self.imageView.image = img;
    self.imageView.frame = CGRectMake((self.frame.size.width-33)/2, (self.frame.size.height-33)/2, 33, 33);
    self.layoutDone = YES;
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
