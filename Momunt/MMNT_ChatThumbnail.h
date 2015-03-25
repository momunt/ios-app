//
//  MMNT_ChatThumbnail.h
//  Momunt
//
//  Created by Masha Belyi on 10/3/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNT_AsyncImage.h"

@interface MMNT_ChatThumbnail : UIView

-(id)initWithFrame:(CGRect)frame withImages:(NSArray *)images;
-(void)setImageFromImages:(NSArray *)images;

@end
