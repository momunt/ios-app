//
//  MMNT_checkButton.h
//  Momunt
//
//  Created by Masha Belyi on 9/7/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNT_interactiveButton.h"

@interface MMNT_checkButton : MMNT_interactiveButton
@property BOOL layoutDone;
-(void)setWidthPercent:(CGFloat)p;
-(void)setSizePercent:(CGFloat)p;
@end
