//
//  MMNT_SlideUpTransition.h
//  Momunt
//
//  Created by Masha Belyi on 2/2/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMNT_SlideUpTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property CGRect myFrame;
@property (assign, nonatomic) NSString *type;
@property (assign, nonatomic) NSString *operation;
//+ (instancetype)transitionWithOperation:(NSString *)operation;
- (instancetype)initWithOperation:(NSString *)operation;
- (instancetype)initWithOperation:(NSString *)operation andFrame:(CGRect)frame;


@end
