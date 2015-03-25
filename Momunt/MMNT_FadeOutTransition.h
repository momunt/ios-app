//
//  MMNT_FadeOutTransition.h
//  Momunt
//
//  Created by Masha Belyi on 9/25/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMNT_FadeOutTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic) NSString *operation;
+ (instancetype)transitionWithOperation:(NSString *)operation;
- (instancetype)initWithOperation:(NSString *)operation;

@end
