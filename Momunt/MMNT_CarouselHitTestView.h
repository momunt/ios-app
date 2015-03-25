//
//  MMNT_CarouselHitTestView.h
//  Momunt
//
//  Created by Masha Belyi on 12/29/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMNT_CarouselHitTestView : UIView

@property UIScrollView *scrollView;
@property UIView *triangle;

-(void)hideTriangle;
-(void)showTriangle;
@end
