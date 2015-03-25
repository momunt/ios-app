//
//  MMNTSavedTrendingViewController.m
//  Momunt
//
//  Created by Masha Belyi on 11/25/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNTSavedTrendingViewController.h"
#import "MMNT_NavigationChild_ViewController.h"
#import "MMNTNavigationController.h"
#import "AMWaveTransition.h"
#import "MMNTAccountManager.h"
#import "MMNT_HelpTasksController.h"
#import "MMNT_MomuntsList.h"
#import "Amplitude.h"

@interface MMNTSavedTrendingViewController () <UINavigationControllerDelegate, UIScrollViewDelegate>{

    int _prevIdx;
    BOOL _dragged;
    BOOL _settingUp;
    
}

@end

@implementation MMNTSavedTrendingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // subscribe to location updates
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatedTrendingMomunts:)
                                                 name:@"updatedTrendingMomunts"
                                               object:nil];

    self.view.clipsToBounds = YES;
    self.view.layer.masksToBounds = YES;
    
    
    _childNavController.delegate = self;
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                          initWithTarget:self
                                                          action:@selector(onTap:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    [_carouselHitView addGestureRecognizer:singleTapGestureRecognizer];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [self setup];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setDelegate:self];
    //    [self.navigationController setDelegate:self.navigationController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Do something when updated user stored momunts
-(void) updatedTrendingMomunts:(NSNotification*)notif {
    // Reload tabs
//    [self setup];
//    [self setTab:_prevIdx];
    
//    MMNT_MomuntsList *vc = (MMNT_MomuntsList *)_childNavController.visibleViewController;
//    [vc.tableView reloadData];
}


-(void)setup{
    // clear subviews
    [[_carouselTab subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self.navigationController setDelegate:self];
    
    // _navigationController contains myMomunts and trendingMomunts table views
    _childNavController = [[self childViewControllers] objectAtIndex:0];
    _childNavController.delegate = self;
    
    // INSERT TAB BUTTONS
    [_carouselTab setFrame:CGRectMake(0, 0, self.view.frame.size.width/3, 50)];
    
    float W = self.view.frame.size.width;
    float H = _carouselTab.frame.size.height;
    
//    UIButton *meBtn = [self addButton:@"me"];
//    [meBtn setCenter:CGPointMake(W*5/6, H/2)];
    
    NSMutableArray *tabNames = [[NSMutableArray alloc] init];
    for(NSString *key in [MMNTAccountManager sharedInstance].trendingMomunts) {
//        if(![key isEqualToString:@"trending"]){
            [tabNames addObject:key];
//        }
    }
    
    // insert 2 repeating at the beginning and end
//    [tabNames insertObject:@"trending" atIndex:0];
    [tabNames insertObject:@"me" atIndex:0];
    
    
    
//    // calcualte current idx
//    MMNTNavigationController *mainNC = (MMNTNavigationController *)self.navigationController;
//    if(!mainNC.trendingCategory){
//        mainNC.trendingCategory = @"me";
//    }
//    int setIdx = [tabNames indexOfObject:mainNC.trendingCategory];
//    if(setIdx<0){
//        setIdx = 3;
//    }else{
//        setIdx = setIdx+2;
//    }
    
    int numtabs = [tabNames count];
    [tabNames insertObject:[tabNames objectAtIndex:numtabs-1] atIndex:0];
    [tabNames insertObject:[tabNames objectAtIndex:numtabs-1] atIndex:0];
    numtabs = [tabNames count];
    [tabNames insertObject:[tabNames objectAtIndex:2] atIndex:numtabs];
    [tabNames insertObject:[tabNames objectAtIndex:3] atIndex:numtabs+1];
    
    int idx = 0;
    for(NSString *key in tabNames) {
        UIButton *btn = [self addButton:key];
        [btn setCenter:CGPointMake(W*(1+idx*2)/6, H/2)];
        idx++;
    }
    
    _carouselTab.clipsToBounds = NO;
    _carouselTab.backgroundColor = [UIColor clearColor];
    _carouselTab.contentSize = CGSizeMake(W*[tabNames count]/3, _carouselTab.frame.size.height);
    _carouselTab.pagingEnabled = YES;
    _carouselTab.bounces = YES;
    _carouselTab.showsHorizontalScrollIndicator = NO;
    _carouselTab.delegate = self;
    _carouselTab.contentOffset = CGPointMake(W*2/3, 0);
    
    [_carouselHitView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    _carouselHitView.bounds = CGRectMake(0, 0, self.view.frame.size.width, 50);
    _carouselHitView.clipsToBounds = YES;
    _carouselHitView.layer.masksToBounds = YES;
    
    
    MMNT_MomuntsList *rootVC = [_childNavController.viewControllers objectAtIndex:0];
    rootVC.data = [MMNTAccountManager sharedInstance].userMomunts;
    rootVC.category = @"me";
    
//    [self setTab:setIdx animated:NO];
    _settingUp = YES;
    [self setTab:2 animated:NO];
    
}
-(UIButton *)addButton:(NSString *)text{
    
    UIButton *btn = [[UIButton alloc] init];
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitle:text forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:21.0];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btn setFrame:CGRectMake(0, 0, _carouselTab.frame.size.width, 50)];
    [_carouselTab addSubview:btn];
    
    return btn;
}

-(void)view:(UIView *)view roundCorners:(UIRectCorner)corners radius:(CGFloat)radius
{
    CGRect bounds = view.bounds;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    
    view.layer.mask = maskLayer;
    
    CAShapeLayer*   frameLayer = [CAShapeLayer layer];
    frameLayer.lineWidth = 1.0f;
    frameLayer.frame = bounds;
    frameLayer.path = maskPath.CGPath;
    frameLayer.strokeColor = [[UIColor colorWithRed:216 green:216 blue:216 alpha:0.3] CGColor];
    frameLayer.fillColor = nil;
    
    [view.layer addSublayer:frameLayer];
}


-(void)setIdx:(int)idx{
    // move carousel tab to correct position
    float W = self.view.frame.size.width;
    [UIView animateWithDuration:0.5 animations:^{
        _carouselTab.contentOffset = CGPointMake((W*(idx-1)/3), 0);
    }];
}
-(void)setTab:(int)idx animated:(BOOL)animated{

    NSString *direction;
    
    if(_prevIdx<idx){ // moved right
        direction = @"right";
    }else{
        direction = @"left";
    }
   
    
    NSArray *buttons = _carouselTab.subviews;
    for(int i=0; i<[buttons count]; i++){
        UIButton *thisBtn = buttons[i];
        if(i == idx){
            [UIView animateWithDuration:0.3 animations:^{
                thisBtn.alpha = 1.0;
            }];
        }else{
            [UIView animateWithDuration:0.3 animations:^{
                thisBtn.alpha = 0.35;
            }];
        }
    }
    
    _carouselTab.contentOffset = CGPointMake((idx-1)*_carouselTab.frame.size.width, 0);
    
    UIButton *thisBtn = buttons[idx];
    NSString *category = thisBtn.titleLabel.text;
    
    MMNTNavigationController *mainNC = (MMNTNavigationController *)self.navigationController;
    mainNC.trendingCategory = category;
    
    if(_prevIdx==idx){
        return;
    }
     _prevIdx = idx;
    
    if(!_settingUp){
        [Amplitude logEvent:[NSString stringWithFormat:@"went to %@", category]];
    }else{
        _settingUp = NO;
    }
    
    if([category isEqualToString:@"me"]){
        if([direction isEqualToString:_scrollDirection]){
            _scrollDirection = [direction isEqualToString:@"right"] ? @"left" : @"right";
        }
        [_childNavController popToRootViewControllerAnimated:YES];
    }
    else{
        // go through the stack, see if can pop
        for (MMNT_MomuntsList *controller in _childNavController.viewControllers){
            
            if(controller.category==category){
                [_childNavController popToViewController:controller animated:animated];
                return;
            }
        }
    
        _scrollDirection = direction;
    
//        if([category isEqualToString:@"me"]){
////            MMNTSavedMomuntsViewController *toVC = [[MMNTSavedMomuntsViewController alloc] init];
//            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//            MMNTSavedMomuntsViewController *toVC = (MMNTSavedMomuntsViewController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"myMomunts"];
//
//            toVC.category = @"me";
//            [_childNavController pushViewController:toVC animated:YES];
//            
//            return;
//        }
    
    
        
        MMNT_MomuntsList *toVC = [[MMNT_MomuntsList alloc] init];
        if([category isEqualToString:@"me"]){
            toVC.data = [MMNTAccountManager sharedInstance].userMomunts;
        }
        else if([category isEqualToString:@"places"]){
            toVC.data = [MMNTAccountManager sharedInstance].userFollows;
//            toVC.data = [[MMNTAccountManager sharedInstance].userFollows arrayByAddingObjectsFromArray:[[MMNTAccountManager sharedInstance].trendingMomunts valueForKey:@"places"]];
        }
        else{
            toVC.data = [[MMNTAccountManager sharedInstance].trendingMomunts valueForKey:category];
        }
        toVC.category = category;
        [_childNavController pushViewController:toVC animated:animated];

    }

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
}

-(NSArray *)visibleCells{
//    MMNT_NavigationChild_ViewController *current = (MMNT_NavigationChild_ViewController *)_childNavController.visibleViewController;
    UITableViewController *current = (UITableViewController *)_childNavController.visibleViewController;
    NSMutableArray *cells = [current.tableView.visibleCells mutableCopy];
    [cells insertObject:_carouselHitView atIndex:0];
    return cells;
}

- (IBAction)selectedMyMomunts:(id)sender {
//    [self setTab:_myButton];
    [_childNavController popToRootViewControllerAnimated:YES];
    
    MMNTNavigationController *mainNC = (MMNTNavigationController *)self.navigationController;
    mainNC.onMyMomunts = YES;
    mainNC.onTrending = NO;
    
}

-(UITableView *)tableView{
    UITableViewController *vc = (UITableViewController *)_childNavController.visibleViewController;
    if([vc respondsToSelector:@selector(tableView)]){
        return vc.tableView;
    }else{
        return nil;
    }
}


- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    if(navigationController==_childNavController){
        return [AMWaveTransition transitionWithOperation:operation andTransitionType:AMWaveTransitionTypeNervous andDirection:_scrollDirection];
    }else{
        if([toVC.restorationIdentifier isEqualToString:@"Settings"]){
            return [AMWaveTransition transitionWithOperation:operation andTransitionType:AMWaveTransitionTypeNervous andDirection:@"left"]; 
        }else{
           return [AMWaveTransition transitionWithOperation:operation andTransitionType:AMWaveTransitionTypeNervous andDirection:@"right"];
        }
        
    }
    
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [_carouselHitView hideTriangle];
    _dragged = YES;
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(_dragged){
        [_carouselHitView showTriangle];
        _dragged = NO;
    }
    
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    
    
    // check if reached left/right end
    int numtabs = [_carouselTab.subviews count];
    float W = _carouselTab.frame.size.width;
    if(page==0){
        // reposition
        _carouselTab.contentOffset = CGPointMake((numtabs-4)*W, 0);
        _prevIdx = numtabs-2;
        [self setTab:(numtabs-3) animated:YES];
    
    }
    else if(page==numtabs-3){
        _carouselTab.contentOffset = CGPointMake(W, 0);
        _prevIdx = 1;
        [self setTab:2 animated:YES];
    }else{
        if(page >= numtabs-1){
            page = numtabs-2;
        }
        [self setTab:page+1 animated:YES];
    }
}

-(void)clickedBtn:(id)sender{
    NSLog(@"here");
}
- (void)onTap:(UITapGestureRecognizer *)recognizer {
    float pX = [recognizer locationInView:_carouselHitView].x;
    float frameW = self.view.frame.size.width;
    NSInteger page = _prevIdx;
    int dir = 0;
    if(pX > frameW*2/3){
        page = _prevIdx+1;
        dir = 1;
    }
    else if(pX < frameW*1/3){
        page = _prevIdx-1;
        dir = -1;
    }else{
        return;
    }
    
    [_carouselHitView hideTriangle];

    
    [UIView animateWithDuration:0.3 animations:^{
        CGPoint currOffset = _carouselTab.contentOffset;
        _carouselTab.contentOffset = CGPointMake(currOffset.x + dir*_carouselTab.frame.size.width, currOffset.y);
    } completion:^(BOOL finished) {
        [_carouselHitView showTriangle];
    }];
    // check if reached left/right end
    int numtabs = [_carouselTab.subviews count];
    float W = _carouselTab.frame.size.width;
    if(page==0){
        // reposition
        _carouselTab.contentOffset = CGPointMake((numtabs-4)*W, 0);
        _prevIdx = numtabs-2;
        [self setTab:(numtabs-3) animated:YES];
        
    }
    else if(page==numtabs-3){
        _carouselTab.contentOffset = CGPointMake(W, 0);
        _prevIdx = 1;
        [self setTab:2 animated:YES];
    }else{
        [self setTab:page animated:YES];
    }
    
    
}

@end