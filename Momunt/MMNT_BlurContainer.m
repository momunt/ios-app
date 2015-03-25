//
//  MMNT_BlurContainer.m
//  Momunt
//
//  Created by Masha Belyi on 8/11/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_BlurContainer.h"

@implementation MMNT_BlurContainer
#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.layer.position = CGPointMake(0,0);
        self.layer.anchorPoint = CGPointMake(0, 0);
        self.imageView = [[UIImageView alloc] initWithFrame:frame];
//        self.imageView.image = [UIImage imageNamed:@"LoadingBackgound"];
        [self addSubview:self.imageView];
        
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor colorWithWhite:255 alpha:0]; // clear background
        self.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
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
