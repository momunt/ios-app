//
//  MMNT_UnreadBadge.h
//  Momunt
//
//  Created by Masha Belyi on 10/7/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMNT_UnreadBadge : UIView
@property (nonatomic) UILabel *l;
- (id)initWithFrame:(CGRect)frame num:(NSInteger)num;
-(void)setCount:(NSInteger)num;
@end
