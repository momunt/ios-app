//
//  MMNT_ZoomCell.h
//  Momunt
//
//  Created by Masha Belyi on 9/12/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "AsyncImageView.h"

@interface MMNT_ZoomCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSURL *imageURL;
@property UIView *parentContainer;  // contains this cell's collection view + map view. Animates when saving image to gallery

- (void)setImage:(UIImage *)image;
- (void)setUrl:(NSURL *)url;

@end
