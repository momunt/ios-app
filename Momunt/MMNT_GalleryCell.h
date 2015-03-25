//
//  MMNT_GalleryCell.h
//  Momunt
//
//  Created by Masha Belyi on 9/28/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface MMNT_GalleryCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic) BOOL shouldAnimate;
@property (nonatomic) CGFloat animationDelay;

@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) UICollectionView *collectionView;

- (void)setImage:(UIImage *)image;
- (void)setUrl:(NSURL *)url;

@end
