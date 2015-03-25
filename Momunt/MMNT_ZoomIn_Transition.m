//
//  MMNT_ZoomIn_Transition.m
//  Momunt
//
//  Created by Masha Belyi on 7/23/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_ZoomIn_Transition.h"
#import "MMNTViewController.h"
#import "MMNTZoomViewController.h"
#import "MMNTPhoto.h"
#import "AsyncImageView.h"
#import "POPSpringAnimation.h"

@implementation MMNT_ZoomIn_Transition
#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)

#define DURATION    0.5

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
        _selectedCell = NULL;
    }
    return self;
}

- (void)setup
{
    _duration = DURATION;
}

+(instancetype)transitionWithSelectedCell:(UICollectionViewCell *)cell
{
    return [[self alloc] initWithSelectedCell:(UICollectionViewCell *)cell];
}
-(instancetype)initWithSelectedCell:(UICollectionViewCell *)cell
{
    self = [super init];
    if (self) {
        [self setup];
        _selectedCell = cell;
    }
    return self;
    
}


- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    if (self.presenting) {
        // Grab the from and to view controllers from the context
        MMNTViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        MMNTZoomViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        [toVC setNeedsStatusBarAppearanceUpdate];
        
//        [fromVC captureBlurWithRadius:0 time:0];
//        fromVC.blurContainer.alpha = 0.0f;
//        fromVC.blurContainer.bounds = CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
        
        // 1) Prepare toVC
        CGRect source = [transitionContext initialFrameForViewController:fromVC];
        toVC.view.frame = source;
        
        fromVC.dropDownView.hidden = YES;
        
        [transitionContext.containerView addSubview:toVC.view];

//        // set frame
//        toVC.zoomContainer.transform = CGAffineTransformMakeScale(_selectedCell.frame.size.width/source.size.width, _selectedCell.frame.size.width/source.size.width);
//        toVC.zoomContainer.center = CGPointMake(_selectedCell.center.x, fromVC.galleryTopOffset+_selectedCell.center.y-fromVC.currentOffsetY);
//        
        NSIndexPath *indexPath = [fromVC.collectionView indexPathForCell:_selectedCell];
//        [toVC.carouselView setContentOffset:CGPointMake((indexPath.row+1)*320,0)];
//        toVC.currentIdx = indexPath.row;
//        
//        // update map
//        MMNTPhoto *photo = toVC.momunt[indexPath.row+1];
//        [toVC updateMapWithLatitude:[[[photo valueForKey:@"location"] valueForKey:@"latitude"] floatValue]
//                                andLongitude:[[[photo valueForKey:@"location"] valueForKey:@"longitude"] floatValue]
//         ];
        
        
        [transitionContext completeTransition:YES];
        [toVC clickedGallery:fromVC cell:_selectedCell cellId:indexPath.row withSelectedPhotos:fromVC.photosToShare];
//        // 2) animate toVC
//        CGPoint newCenter = CGPointMake(fromVC.view.center.x, fromVC.view.center.y);
//        
//        [UIView animateWithDuration: 0.6
//                              delay: 0
//             usingSpringWithDamping:0.6
//              initialSpringVelocity:1
//                            options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
//                         animations:^{
//                             toVC.zoomContainer.center = newCenter;
//                             toVC.zoomContainer.transform = CGAffineTransformMakeScale(1,1);
//                         }
//                         completion:^(BOOL finished) {
//                             [transitionContext completeTransition:YES];
//                         }
//         ];
//        
//        [UIView animateWithDuration: 0.2
//                              delay: 0
//                            options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
//                         animations:^{
//                             fromVC.blurContainer.alpha = 1.0f;
//                             fromVC.dropDownView.transform = CGAffineTransformMakeTranslation(0,-70);
//                         }
//                         completion:nil
//         ];
        
//        POPSpringAnimation *scale = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
//        scale.toValue = [NSValue valueWithCGPoint:CGPointMake(1,1)];
//        scale.springBounciness = 10;
//        scale.springSpeed = 15;
//        scale.completionBlock = ^(POPAnimation *animation, BOOL finished){
//            [transitionContext completeTransition:YES];
//        };
//        [toVC.zoomContainer.layer pop_addAnimation:scale forKey:@"scale"];

        
        
        
    }else{
        // Return
        // Grab the from and to view controllers from the context
        MMNTZoomViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        MMNTViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        toVC.photosToShare = fromVC.toShare;
        
        toVC.dropDownView.hidden = NO;
//        // zoom out on top of current image
//        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:fromVC.currentIdx inSection:0];
//        UICollectionViewCell *currCell = [toVC.collectionView dequeueReusableCellWithReuseIdentifier:@"galleryCell" forIndexPath:indexPath];
////        AsyncImageView *currImageView = (AsyncImageView *)[currCell viewWithTag:100];
////        [currImageView setAlpha:0.0f];
//        
//        CGPoint newCenter = CGPointMake(currCell.center.x, toVC.galleryTopOffset+currCell.center.y-toVC.currentOffsetY);
//        
////        [toVC unBlur];
//        [UIView animateWithDuration: 0.2
//                              delay: 0
//                            options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
//                         animations:^{
//                             toVC.blurContainer.alpha = 0.0f;
//                             toVC.dropDownView.transform = CGAffineTransformIdentity;
//                         }
//                         completion:^(BOOL finished) {
//                             toVC.blurContainer.bounds = CGRectMake(0,0,SCREEN_WIDTH,0);
//                         }
//         ];
//
//        
//        //BOOL needToScrool = NO;
//        float delay = 0;
//        
//        if(currCell.center.y < toVC.currentOffsetY || currCell.center.y > toVC.currentOffsetY+toVC.view.frame.size.height){
//            // scroll to correct position
//            CGFloat y;
//            CGFloat h = toVC.collectionView.frame.size.height;
//            CGFloat maxH = ceilf(toVC.momunt.count/3) * currCell.frame.size.height;
//            if(currCell.center.y < h/2){
//                y = 0;
//            }else if(currCell.center.y > maxH-h/2){
//                y = maxH-h;
//            }else{
//                y = currCell.center.y - h/2;
//            }
//            [toVC.collectionView scrollRectToVisible:CGRectMake(0, y, toVC.view.frame.size.width, h) animated:YES];
//            
//            newCenter = CGPointMake(currCell.center.x, toVC.galleryTopOffset+currCell.center.y-y);
//            //needToScrool = YES;
//            delay = delay+0.5;
//        }
//        if(fromVC.onMap){
//            [fromVC toggleMapView];
//            delay = delay>=0.5 ? delay : delay+0.5;
//        }
//        
////        // hide gallery cell when zoom view hits it - to avoid seeing it in the background on the bouce
////        [UIView animateWithDuration: 0
////                              delay: 0
////                            options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
////                         animations:^{
////                             [currImageView setAlpha:0.0f];
////                         }
////                         completion:nil
////         ];
//        
//        
//        [UIView animateWithDuration: 0.6
//                              delay: delay
//             usingSpringWithDamping:0.6
//              initialSpringVelocity:1
//                            options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
//                         animations:^{
//                             fromVC.zoomContainer.center = newCenter;
//                             fromVC.zoomContainer.transform = CGAffineTransformMakeScale(currCell.frame.size.width/toVC.view.frame.size.width, currCell.frame.size.width/toVC.view.frame.size.width);
//                             
//                         }
//                         completion:^(BOOL finished) {
////                             [currCell setAlpha:1.0f];
//                             [transitionContext completeTransition:YES];
//                         }
//         ];
        
        
        [transitionContext completeTransition:YES];

        
        
        

        
        
    }
}

@end
