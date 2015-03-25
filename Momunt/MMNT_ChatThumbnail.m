//
//  MMNT_ChatThumbnail.m
//  Momunt
//
//  Created by Masha Belyi on 10/3/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_ChatThumbnail.h"

@implementation MMNT_ChatThumbnail

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame withImages:(NSArray *)images{
    self = [super initWithFrame:frame];
    if (self) {
        // just use the first image for now (no group chat images)
        MMNT_AsyncImage *pic = [[MMNT_AsyncImage alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        pic.layer.cornerRadius =  frame.size.width/2;
        pic.clipsToBounds = YES;
        pic.imageURL = [NSURL URLWithString:images[0]];
        [self addSubview:pic];
        
    }
    return self;
}
-(void)setImageFromImages:(NSArray *)images{
    // clear all subviews
//    for (UIView *v in self.subviews) {
//        [v removeFromSuperview];
//    }
    MMNT_AsyncImage *pic;
    if(self.subviews.count > 0){
        pic = [self.subviews objectAtIndex:0];
    }else{
        pic = [[MMNT_AsyncImage alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:pic];
    }
    
    // just use the first image for now (no group chat images)
//    AsyncImageView *pic = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    pic.layer.cornerRadius =  self.frame.size.width/2;
    pic.clipsToBounds = YES;
    pic.imageURL = [NSURL URLWithString:images[0]];
//    [self addSubview:pic];
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
