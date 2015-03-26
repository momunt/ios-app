//
//  MMNT_DropDownView.m
//  Momunt
//
//  Created by Masha Belyi on 8/6/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_DropDownView.h"
#import "MMNT_NavBar_View.h"
#import "MMNTDataController.h"

#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)


@implementation MMNT_DropDownView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    return self;
}
-(void) setup{
    _bottomBar = [self.subviews objectAtIndex:2];
    _spacerBar = [self.subviews objectAtIndex:1];
    _logo = [_bottomBar.subviews objectAtIndex:0];
    _exit = [_bottomBar.subviews objectAtIndex:1];
    
    _exit.hidden = YES;
//    _spacerBar.alpha = 1.0f;
//    _spacerBar.hidden = NO;
    
    // tap gesture
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    tapRecognizer.delegate = self;
    [_bottomBar addGestureRecognizer:tapRecognizer];

    
    // drag gesture
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    recognizer.delegate = self;
    [_bottomBar addGestureRecognizer:recognizer];
    
    
    self.startCenter = self.center;
    
    // Do any additional setup after loading the view.
//    self.navigationController = [self.childViewControllers objectAtIndex:0];
//    self.navigationController = [self.parent.childViewControllers objectAtindex:2]
    
    // INIT NAV BAR
    if(_navBar == nil){
        _navBar = [[MMNT_NavBar_View alloc] initWithFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, 80.0f)];
        _navBar.navigationController = self.navigationController;
        self.navigationController.navBar = _navBar;
        [self addSubview:_navBar];
        
        // move this!!
        if([MMNTDataController sharedInstance].openedFromNotification){
            // open chat _navigationController.currentViewController should be the chat controller
            [_navBar transitionFrom:self.navigationController.currentViewController to:self.navigationController.currentViewController];
        }
        

    }
    
    // resize for different screens
    UIView *navContainer = [self.subviews objectAtIndex:0];
    navContainer.frame = CGRectMake(0, 80.0, SCREEN_WIDTH, SCREEN_HEIGHT-80-50);
    self.navigationController.view.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT-80-50);
    
    
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (void)didPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer translationInView:self.superview];
    self.center = CGPointMake(self.center.x, self.center.y + point.y);
    [recognizer setTranslation:CGPointZero inView:self.superview];
    
    CGPoint location = [recognizer locationInView:self.superview];
    
    // background color
    CGFloat percentage = (self.center.y-self.startCenter.y)/(SCREEN_HEIGHT/2 - self.startCenter.y);
    CGFloat white = MAX(MIN(255, 255.0*(1-percentage)), 0);
    CGFloat alpha = MAX(MIN(1, 0.1+0.9*(1-percentage)), 0);
    UIColor *newColor = [UIColor colorWithRed:(white / 255.0) green:(white / 255.0) blue:(white / 255.0) alpha:alpha];
    
    self.backgroundColor = newColor;
    
    // nav bar opacity
    CGFloat nav_alpha = MAX(MIN(0.3, 0.3*percentage), 0);
    _bottomBar.backgroundColor = [UIColor colorWithRed:(216 / 255.0) green:(216 / 255.0) blue:(216 / 255.0) alpha:nav_alpha];
    
    [self.delegate dropDownView:self dragggingWithPercentage:percentage];
    
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self.superview];

        velocity.x = 0;
        [self.delegate dropDownView:self draggingEndedWithVelocity:velocity withTouchLocation:location];
    } else if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.delegate dropDownViewBeganDragging:self];
    }
}

- (void)didTap:(UITapGestureRecognizer *)tapRecognizer{
    [self.delegate dropDownViewTapped:self];
//    [self layoutSubviews];
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
