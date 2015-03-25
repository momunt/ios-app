//
//  MMNTPullRefreshHeader.h
//  Momunt
//
//  Created by Masha Belyi on 7/24/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>

typedef enum{
    MMNTPullRefreshNormal,
    MMNTPullRefreshLoading,
    MMNTPullRefreshPulling
} MMNTPullRefreshState;

@protocol MMNTPullRefreshHeaderDelegate;

@interface MMNTPullRefreshHeader : UIView{
    
    UIImageView *_pin1;
    UIImageView *_pin2;
    UIImageView *_pin3;
    UIImageView *_pin4;
    UIImageView *_pin5;
    UIImageView *_pin6;
    
    UILabel *_tooltip;
    
    CGPoint _center;
    
}

@property(nonatomic, assign) MMNTPullRefreshState state;
@property(nonatomic, assign) BOOL *spinning;
@property(nonatomic, assign) id <MMNTPullRefreshHeaderDelegate> delegate;

-(void) PullRefreshScrollViewDidScroll:(UIScrollView *) scrollView force:(BOOL)force;
-(void) PullRefreshScrollViewDidEndDragging:(UIScrollView *) scrollView;
-(void) PullRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end

@protocol MMNTPullRefreshHeaderDelegate

- (void) PullRefreshHeaderDidTriggerRefresh:(MMNTPullRefreshHeader*)view;
- (void) PullRefreshHeaderDidFinishLoading:(MMNTPullRefreshHeader*)view;
- (BOOL) PullRefreshHeaderDataSourceIsLoading:(MMNTPullRefreshHeader*)view;

@end
