//
//  MMNTPullRefreshHeader.m
//  Momunt
//
//  Created by Masha Belyi on 7/24/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNTPullRefreshHeader.h"
#import "MMNTDataController.h"
#import "Amplitude.h"

@implementation MMNTPullRefreshHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:255/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];  // white background
        _center = self.center;
        
        float centerX = frame.size.width/2;
        float centerY = frame.size.height/2;
        float W = 16.0f; //18.0f;
        float H = 22.0f; //25.0f;
        float a = 0.0f;
        
        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo icon"]];
        logo.frame = CGRectMake(139,27,43,23);
        [self addSubview:logo];
        
        a = 120.0f;
        UIImageView *img3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin.png"]];
        img3.frame = CGRectMake(0,0,W,H);
        img3.center = CGPointMake(1 + centerX + cos(30*M_PI/180)*H/2, 1 + centerY+sin(30*M_PI/180)*H/2);
        img3.transform = CGAffineTransformMakeRotation(a * M_PI/180);
        img3.alpha = 0.0f;
        [self addSubview:img3];
        _pin3 = img3;
        
        a = 180.0f;
        UIImageView *img4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin.png"]];
        img4.frame = CGRectMake(0,0,W,H);
        img4.center = CGPointMake(centerX, 2+centerY+H/2);
        img4.transform = CGAffineTransformMakeRotation(a * M_PI/180);
        [self addSubview:img4];
        img4.alpha = 0.0f;
        _pin4 = img4;
        
        a = -120.0f;
        UIImageView *img5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin.png"]];
        img5.frame = CGRectMake(0,0,W,H);
        img5.center = CGPointMake(-1+centerX - cos(30*M_PI/180)*H/2, 1+centerY+sin(30*M_PI/180)*H/2);
        img5.transform = CGAffineTransformMakeRotation(a * M_PI/180);
        [self addSubview:img5];
        img5.alpha = 0.0f;
        _pin5 = img5;

        
//        _tooltip = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width, 20)];
//        _tooltip.backgroundColor = [UIColor colorWithRed:254.0/255.0 green:126.0/255.0 blue:0 alpha:1.0]; // momunt orange
//        _tooltip.textColor = [UIColor whiteColor];
//        _tooltip.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
//        _tooltip.textAlignment = NSTextAlignmentCenter;
//        _tooltip.text = @"Loading the momunt from your location.";
//        _tooltip.center = CGPointMake(self.frame.size.width/2, self.frame.size.height+10);
//        [self addSubview:_tooltip];
        
        
        self.alpha = 0.0f;
        [self setState:MMNTPullRefreshNormal];
        
        
    }
    return self;
}

- (void) spinAnimation{
    _spinning = YES;
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self setTransform:CGAffineTransformRotate(self.transform, 60*M_PI/180)];
                     } completion:^(BOOL finished) {
                         if(_state == MMNTPullRefreshLoading){
                             [self spinAnimation];
                         }else{
                             _spinning = NO;
                             [self setTransform:CGAffineTransformIdentity];
                             
                             [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{[_pin3 setAlpha:0.0f];} completion:nil];
                             [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{[_pin4 setAlpha:0.0f];} completion:nil];
                             [UIView animateWithDuration:0.1 delay:0.2 options:UIViewAnimationOptionCurveLinear animations:^{[_pin5 setAlpha:0.0f];} completion:^(BOOL finished) {
                                 [_delegate PullRefreshHeaderDidFinishLoading:self];
                             }];

                         }
                     }
     ];

}

- (void)setState:(MMNTPullRefreshState)aState{
    switch (aState){
        case MMNTPullRefreshNormal:{
            if(!_spinning){
                [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{[_pin3 setAlpha:0.0f];} completion:nil];
                [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionCurveLinear animations:^{[_pin4 setAlpha:0.0f];} completion:nil];
                [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{[_pin5 setAlpha:0.0f];} completion:nil];
            }

            break;
        }
        case MMNTPullRefreshLoading:{
            // start loading spinner
            // make all pins visible, if not faded in yet
            [_pin3 setAlpha:1.0f];
            [_pin4 setAlpha:1.0f];
            [_pin5 setAlpha:1.0f];
            [self spinAnimation];
            
            break;
        }
        default:
			break;
    }
    _state = aState;
}

#pragma mark -
#pragma mark ScrollView Methods

- (void)PullRefreshScrollViewDidScroll:(UIScrollView *)scrollView force:(BOOL)force{
    // finger is on the screen, dragging
    float offset = scrollView.contentOffset.y;
    
    self.center = CGPointMake(_center.x , _center.y+(offset<-40 ? -offset-40 : 0));
    
    if (scrollView.isDragging || force) {
        if(_state == MMNTPullRefreshNormal && offset < -30.0f){
            [self setState:MMNTPullRefreshPulling];
        }else if (_state == MMNTPullRefreshPulling){
            if(offset < -20.0f && offset > -50.0){
                [UIView animateWithDuration:0.3 animations:^{[_pin3 setAlpha:1.0f];}];
                [UIView animateWithDuration:0.3 animations:^{[_pin4 setAlpha:0.0f];}];
                [UIView animateWithDuration:0.3 animations:^{[_pin5 setAlpha:0.0f];}];
            }else if(offset <= -50.0f && offset > -80.0){
                [UIView animateWithDuration:0.3 animations:^{[_pin3 setAlpha:1.0f];}];
                [UIView animateWithDuration:0.3 animations:^{[_pin4 setAlpha:1.0f];}];
                [UIView animateWithDuration:0.3 animations:^{[_pin5 setAlpha:0.0f];}];
            }else if(offset <= -80.0f){
                [UIView animateWithDuration:0.3 animations:^{[_pin3 setAlpha:1.0f];}];
                [UIView animateWithDuration:0.3 animations:^{[_pin4 setAlpha:1.0f];}];
                [UIView animateWithDuration:0.3 animations:^{[_pin5 setAlpha:1.0f];}];
                
                // start loading
                [self setState:MMNTPullRefreshLoading];
            }
        }
    }
}

- (void)PullRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
    // lifted finger off
    BOOL _loading = NO;
    _loading = [_delegate PullRefreshHeaderDataSourceIsLoading:self];
    
    if (scrollView.contentOffset.y <= - 80.0f && !_loading) {
        [_delegate PullRefreshHeaderDidTriggerRefresh:self];
        [[MMNTDataController sharedInstance] setTaskDone:103]; // completed pull down refresh!
//        [UIView animateWithDuration:0.2 animations:^{
//            scrollView.transform = CGAffineTransformMakeTranslation(0, 40); // leave space for the orange tooltip view
//        }];
    }else if (scrollView.contentOffset.y > - 80.0f && !_loading) {
        [self setState:MMNTPullRefreshNormal];
    }
}

-(void) PullRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView{
    // animate back to top
    
    [self setState:MMNTPullRefreshNormal];
    
    
    
//    [UIView animateWithDuration:0.3
//                          delay:0.2
//         usingSpringWithDamping:0.6
//          initialSpringVelocity:2
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                        scrollView.transform = CGAffineTransformIdentity;
//                     } completion:nil];
    
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
