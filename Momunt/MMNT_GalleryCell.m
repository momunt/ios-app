//
//  MMNT_GalleryCell.m
//  Momunt
//
//  Created by Masha Belyi on 9/28/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_GalleryCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MMNT_SharedVars.h"

#import "POPSpringAnimation.h"

@implementation MMNT_GalleryCell


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
        [self addSubview:self.imageView];
        self.imageView.userInteractionEnabled = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
- (void)setImage:(UIImage *)image{
    
    if(_shouldAnimate){
        _shouldAnimate = NO;
        _imageView.alpha = 1.0;
        
        _animationDelay = 0.1 + 0.04*_indexPath.row;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(refreshAnimateToImage:) withObject:image afterDelay:_animationDelay];
        });
        
    }else{
        // This fixes the weird freakout layout error on refresh:
        _imageView.hidden = YES;
        CGAffineTransform t = _imageView.transform;
        _imageView.transform = CGAffineTransformIdentity;
        _imageView.frame = CGRectMake(0,0,self.frame.size.width, self.frame.size.height);
        _imageView.transform = t;
        _imageView.hidden = NO;
        
        _imageView.image = image;
        
        
        [UIView animateWithDuration:0.2 animations:^{
            _imageView.alpha = 1.0;
        }];
    }
    

}
- (void)setUrl:(NSURL *)url{
    
    _imageURL = url;
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    BOOL isCached = [manager diskImageExistsForURL:_imageURL];
    
    if (!isCached){
        _imageView.alpha = 0.0; // fade in animation for 
    }
    
    [self asyncDownloadUrl:url completionBlock:^(BOOL succeeded, UIImage *image, NSURL *url) {
        if(succeeded && _imageURL == url){
//            _imageView.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
            [self setImage:image];
        }else if(!succeeded){
//             _imageView.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
            _imageView.image = [UIImage imageNamed:@"failApp"];
        }
        
    }];
}

-(void)prepareForReuse{
    _imageURL = nil;
//    [UIView animateWithDuration:0.3 animations:^{
//        [self.imageView setAlpha:0.5];
//    }];
    if(!_shouldAnimate){
        _imageView.image = nil;
    }
    
//    if(_shouldAnimate){ // && [_collectionView cellForItemAtIndexPath:_indexPath]
//        [[MMNT_SharedVars sharedVars] scaleDown:_imageView];
//    }
    
}

-(void)refreshAnimateToImage:(UIImage *)image{
   
    // This fixes the weird freakout layout error on refresh:
    _imageView.hidden = YES;
    CGAffineTransform t = _imageView.transform;
    _imageView.transform = CGAffineTransformIdentity;
    _imageView.frame = CGRectMake(0,0,self.frame.size.width, self.frame.size.height);
    _imageView.transform = t;
    _imageView.hidden = NO;
    
    _imageView.image = image;

    [MMNT_SharedVars runPOPSpringAnimation:kPOPViewScaleXY
                                    onView:_imageView
                                   toValue:[NSValue valueWithCGPoint: CGPointMake(1, 1)]
                          springBounciness:10
                               springSpeed:10
                                     delay:0
                                    forKey:@"scale"
                                completion:^(BOOL finished) {
                                    _imageView.frame = CGRectMake(0,0,self.frame.size.width, self.frame.size.height);
                                }];
//    [[MMNT_SharedVars sharedVars] scaleUp:_imageView];
//    }];
}
     
//     [view pop_removeAllAnimations];
//     POPSpringAnimation *scaleUp = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
//     scaleUp.toValue = [NSValue valueWithCGPoint: CGPointMake(1, 1)] ;
//     scaleUp.springBounciness = 15;
//     scaleUp.springSpeed = 15;
//     scaleUp.completionBlock = ^(POPAnimation *animation, BOOL finished){
//         if(completion)
//             completion(finished);
//     };
//     [view pop_addAnimation:scaleUp forKey:@"scale"];

-(void)asyncDownloadUrl:(NSURL *)imageURL completionBlock:(void (^)(BOOL succeeded, UIImage *image, NSURL *url))completionBlock{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:imageURL options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        // progression tracking code
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image)
        {
            // do something with image
            completionBlock(YES, image, imageURL);
            return;
        }else{
            completionBlock(NO, nil, nil);
        }
    }];
    
}

@end
