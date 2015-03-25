//
//  MMNT_TransitionsManager.h
//  Momunt
//
//  Created by Masha Belyi on 9/5/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MMNTScaleTransitionType) {
    MMNTTransitionScaleInOut,
    MMNTTransitionScaleOutSlideUp,
    MMNTTransitionFadeOutSlideUp,
    MMNTTransitionSlideUp
};

@interface MMNT_TransitionsManager : NSObject <UIViewControllerAnimatedTransitioning>

+ (instancetype)transitionWithOperation:(UINavigationControllerOperation)operation;
+ (instancetype)transitionWithOperation:(UINavigationControllerOperation)operation andTransitionType:(MMNTScaleTransitionType)type;
- (instancetype)initWithOperation:(UINavigationControllerOperation)operation andType:(MMNTScaleTransitionType)type;


@property (assign, nonatomic) UINavigationControllerOperation operation;
@property (assign, nonatomic) MMNTScaleTransitionType transitionType;
@property (assign, nonatomic) CGFloat duration;
@property (assign, nonatomic) CGFloat maxDelay;

@end

