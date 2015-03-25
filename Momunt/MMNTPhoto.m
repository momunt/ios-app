//
//  MMNTPhoto.m
//  Momunt
//
//  Created by Masha Belyi on 6/30/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNTPhoto.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation MMNTPhoto


-(MMNTPhoto *)initWithDict:(NSDictionary *)data{
    self = [super init];
    if(self){
        _source = nil; //default
        for (NSString *key in data) {
            if ([self respondsToSelector:NSSelectorFromString(key)]) {
                [self setValue:[data valueForKey:key] forKey:key];
            }
        }
        
//        // preload thumbnail image into cache
//        NSString *imageURL = [[[self valueForKey:@"images"] valueForKey:@"thumbnail"] valueForKey:@"url"];
//        
//        SDWebImageManager *manager = [SDWebImageManager sharedManager];
//        [manager downloadImageWithURL:[NSURL URLWithString:imageURL] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//            // progression tracking code
//        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//            if (image)
//            {
//                // do something with image
//            }else{
//            }
//        }];
    }
    return self;
}

-(NSDictionary *)toNSDictionary{
    
    NSDictionary *location = [NSDictionary dictionaryWithObjectsAndKeys:
                              [self.location valueForKey:@"latitude"], @"latitude",
                              [self.location valueForKey:@"longitude"], @"longitude",
                              nil];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.created_time, @"created_time",
                          location, @"location",
                          self.images, @"images",
                          self.id, @"id",
                          self.user, @"user",
                          self.source, @"source",
                          self.link, @"link",
                          nil];
    return dict;
}

@end
