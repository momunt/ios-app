//
//  MMNT_ShareView_Transition.h
//  Momunt
//
//  Created by Masha Belyi on 7/22/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMNT_ShareView_Transition : NSObject

@property (nonatomic, assign, getter = isPresenting) BOOL presenting;

/** Animation duration
 *
 * Sets the duration of the animation. The whole duration accounts for the maxDelay property.
 *
 */
@property (assign, nonatomic) CGFloat duration;

/** Maximum animation delay
 *
 * Sets the max delay that a cell will wait beofre animating.
 *
 */
@property (assign, nonatomic) CGFloat maxDelay;

@end
