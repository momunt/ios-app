//
//  MMNT_SpinnerCell.m
//  Momunt
//
//  Created by Masha Belyi on 2/3/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import "MMNT_SpinnerCell.h"

#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)

@implementation MMNT_SpinnerCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
//        self.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
        _spinner = [[MMNT_LoadingSpinner alloc] initWithFrame:CGRectMake(0,0,(SCREEN_WIDTH*1/3)*2/3, (SCREEN_WIDTH*1/3)*2/3) withLogoImageNamed:@"Logo Icon" andPinImageNamed:@"pin.png"];
        _spinner.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:_spinner];
    }
    return self;
}

-(void)prepareForReuse{
    _spinner.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
//    [_spinner updateFrame:self.frame];
    
    
}


@end
