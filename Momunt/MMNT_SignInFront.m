//
//  MMNT_SignInFront.m
//  Momunt
//
//  Created by Masha Belyi on 9/23/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_SignInFront.h"
#import "AMWaveTransition.h"
#import "MMNT_SignIn.h"
#import "MMNT_HelpScreen.h"

@interface MMNT_SignInFront ()  <UINavigationControllerDelegate, UIScrollViewDelegate>

@end

@implementation MMNT_SignInFront

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setDelegate:self];// transitioning delegate
    
    _animatedSubViews = [[NSArray alloc] initWithObjects: _dotsContainer, _btn1, _btn2, nil];
    _animatedViews = self.view.subviews;
    
    [self setupDots];
    [self setupHelpSlides];
    [self setSlide:0];
    
    _darkOverlay.alpha = 0;
    
}
-(void)viewWillAppear:(BOOL)animated{
//    NSLog(@"here");
    [_btn1 setAlpha:1.0f];
    [_btn2 setAlpha:1.0f];
}
-(void)viewDidAppear:(BOOL)animated{
    _darkOverlay.alpha = 0;
    [UIView animateWithDuration:0.3 delay:0.6 options:UIViewAnimationOptionCurveLinear animations:^{
        _launchPic.alpha = 0.0f;
    } completion:^(BOOL finished) {
        //
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSArray*)visibleCells{
//    return self.view.subviews;
        return self.animatedViews;
}

/*
 <UINavigationControllerDelegate>
 */

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    return [AMWaveTransition transitionWithOperation:operation andTransitionType:AMWaveTransitionTypeNervous andDirection:@"right"];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [super prepareForSegue:segue sender:sender];
    _launchPic.hidden = YES;
    if([segue.destinationViewController isKindOfClass:[MMNT_SignIn class] ]){
        _animatedViews = _animatedSubViews;
    }else{
        _animatedViews = self.view.subviews;
    }
    
}

-(void)setupDots{
    // ADD DOTS
    int s = 10;
    UIView *d1 = [[UIView alloc] initWithFrame:CGRectMake(0,0,s,s)];
    d1.backgroundColor = [UIColor whiteColor];
    d1.layer.cornerRadius = s/2;
    d1.clipsToBounds = YES;
    [_dotsContainer addSubview:d1];
    
    UIView *d2 = [[UIView alloc] initWithFrame:CGRectMake(0,0,s,s)];
    d2.backgroundColor = [UIColor whiteColor];
    d2.layer.cornerRadius = s/2;
    d2.clipsToBounds = YES;
    [_dotsContainer addSubview:d2];
    
    UIView *d3 = [[UIView alloc] initWithFrame:CGRectMake(0,0,s,s)];
    d3.backgroundColor = [UIColor whiteColor];
    d3.layer.cornerRadius = s/2;
    d3.clipsToBounds = YES;
    [_dotsContainer addSubview:d3];
    
    UIView *d4 = [[UIView alloc] initWithFrame:CGRectMake(0,0,s,s)];
    d4.backgroundColor = [UIColor whiteColor];
    d4.layer.cornerRadius = s/2;
    d4.clipsToBounds = YES;
    [_dotsContainer addSubview:d4];
    
    
    d1.center = CGPointMake( _dotsContainer.frame.size.width/2 - 3*s, _dotsContainer.frame.size.height/2);
    d2.center = CGPointMake( _dotsContainer.frame.size.width/2 - 1*s, _dotsContainer.frame.size.height/2);
    d3.center = CGPointMake( _dotsContainer.frame.size.width/2 + 1*s, _dotsContainer.frame.size.height/2);
    d4.center = CGPointMake( _dotsContainer.frame.size.width/2 + 3*s, _dotsContainer.frame.size.height/2);

}
-(void)setSlide:(int)idx{
    for (int i=0; i<4; i++) {
        UIView *dot = [_dotsContainer.subviews objectAtIndex:i];
        MMNT_HelpScreen *screen = [_scrollView.subviews objectAtIndex:i];
        if(i==idx){
            dot.alpha = 1.0;
            if(i>0){
                [screen.vidVC play];
            }
        }else{
            dot.alpha = 0.5;
            if(i>0 && [screen.vidVC respondsToSelector:@selector(pause)]){
                [screen.vidVC stop];
            }
        }
    }
}

-(void)setupHelpSlides{
    //set up scroll view
    

    MMNT_HelpScreen *h2 = [[MMNT_HelpScreen alloc] initWithFrame:CGRectMake(2*_scrollView.frame.size.width,0,_scrollView.frame.size.width,_scrollView.frame.size.height )
                                                            text:@"Post public photos for the world to see."
                                                         vidFile:@"video2_crop"];

    MMNT_HelpScreen *h3 = [[MMNT_HelpScreen alloc] initWithFrame:CGRectMake(3*_scrollView.frame.size.width,0,_scrollView.frame.size.width,_scrollView.frame.size.height )
                                                            text:@"Create and share collections of the best photos nearby."
                                                         vidFile:@"video3_crop"];
    
    MMNT_HelpScreen *h1 = [[MMNT_HelpScreen alloc] initWithFrame:CGRectMake(_scrollView.frame.size.width,0,_scrollView.frame.size.width,_scrollView.frame.size.height )
                                                            text:@"See the photos being shared around your location."
                                                         vidFile:@"video1_crop"];

    
    [_scrollView addSubview:h1];
    [_scrollView addSubview:h2];
    [_scrollView addSubview:h3];
    
    
    _scrollView.frame = CGRectMake(0,0,_scrollView.frame.size.width, _scrollView.frame.size.height);
    _scrollView.contentSize = CGSizeMake(4*_scrollView.frame.size.width, _scrollView.frame.size.height);
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
}

#pragma mark UISCrollVIewDelegate

//-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    
    if(page>0){
        [UIView animateWithDuration:0.4 animations:^{
            _darkOverlay.alpha = 1.0;
        }];
    }else{
        [UIView animateWithDuration:0.4 animations:^{
            _darkOverlay.alpha = 0.0;
        }];
    }
    
    [self setSlide:page];
}

@end
