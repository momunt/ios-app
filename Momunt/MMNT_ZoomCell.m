//
//  MMNT_ZoomCell.m
//  Momunt
//
//  Created by Masha Belyi on 9/12/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//


#import "MMNT_ZoomCell.h"
#import "POPSpringAnimation.h"
#import "POPBasicAnimation.h"
#import <SDWebImage/UIImageView+WebCache.h>


@implementation MMNT_ZoomCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.imageView];
        self.imageView.userInteractionEnabled = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        // long press gesture
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [self.imageView addGestureRecognizer:longPress];

    }
    return self;
}
- (void)setImage:(UIImage *)image{
    self.imageView.image = image;
}
- (void)setUrl:(NSURL *)url{
    _imageURL = url;
    
    [self asyncDownloadUrl:url completionBlock:^(BOOL succeeded, UIImage *image, NSURL *url) {
        if(succeeded && _imageURL == url){
            _imageView.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
            _imageView.image = image;
        }else if(!succeeded){
            _imageView.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
            _imageView.image = [UIImage imageNamed:@"failApp"];
        }
    }];
}

-(void)prepareForReuse{
    _imageURL = nil;
    
}

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

/*
 handleLongPress
 Save image to iphone gallery on long press
 */
-(void)handleLongPress:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state != UIGestureRecognizerStateBegan){
        return;
    }
    
    // simple bounce animation...
    POPSpringAnimation *popUp = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    popUp.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
    popUp.springBounciness = 15;
    popUp.springSpeed = 20;
    
    POPBasicAnimation *scaleDown = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleDown.toValue = [NSValue valueWithCGPoint:CGPointMake(0.8, 0.8)];
    scaleDown.duration = 0.1;
    scaleDown.completionBlock = ^(POPAnimation *animation, BOOL finished){
        [self.parentContainer pop_addAnimation:popUp forKey:@"scale"];
    };
    [self.parentContainer pop_addAnimation:scaleDown forKey:@"scale"];
    
    // save to gallery
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, nil, nil, nil);
}
@end
