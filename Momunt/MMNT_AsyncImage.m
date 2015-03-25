//
//  MMNT_AsyncImage.m
//  Momunt
//
//  Created by Masha Belyi on 11/23/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_AsyncImage.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation MMNT_AsyncImage

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        // extra setup..
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        // extra setup..
    }
    return self;
}

- (void)setImage:(UIImage *)image{
    if(_shouldCenter){
        CGFloat h = image.size.width * self.frame.size.height / self.frame.size.width;
        CGFloat offset = (image.size.width - h)/2;
        
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, offset, image.size.width, h));
        image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        super.image = image;
    }else{
        super.image = image;
    }
}

-(void)setImageURL:(NSURL *)imageURL{
    [self asyncDownloadUrl:imageURL completionBlock:^(BOOL succeeded, UIImage *image, NSURL *url) {
        if(succeeded){
            self.image = image;
        }else{
            self.image = [UIImage imageNamed:@"failApp"];
        }
    }];

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

@end
