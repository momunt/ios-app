//
//  MMNT_MapToGalleryTransition.h
//  Momunt
//
//  Created by Masha Belyi on 12/16/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMNT_MapToGalleryTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic) NSString *operation;
+ (instancetype)transitionWithOperation:(NSString *)operation;
- (instancetype)initWithOperation1:(NSString *)operation;

@end
