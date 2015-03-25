//
//  MMNT_ZoomIn_Transition.h
//  Momunt
//
//  Created by Masha Belyi on 7/23/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMNT_ZoomIn_Transition : NSObject <UIViewControllerAnimatedTransitioning>

/** Animation state
 *
 * True/false. Presenting of hiding view
 *
 */
@property (nonatomic, assign, getter = isPresenting) BOOL presenting;

/** Animation duration
 *
 * Sets the duration of the animation. The whole duration accounts for the maxDelay property.
 *
 */
@property (assign, nonatomic) CGFloat duration;

@property (assign, nonatomic) UICollectionViewCell *selectedCell;
+(instancetype)transitionWithSelectedCell:(UICollectionViewCell *)cell;
-(instancetype)initnWithSelectedCell:(UICollectionViewCell *)cell;

@end
