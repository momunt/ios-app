//
//  MMNT_RowSelection_Transition.h
//  Momunt
//
//  Created by Masha Belyi on 7/22/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMWaveTransitioning <NSObject>

- (NSArray*)visibleCells;
-(UITableViewCell*)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@property CGFloat currentOffsetY;

@end

@interface MMNT_RowSelection_Transition : NSObject <UIViewControllerAnimatedTransitioning>

/** New transition
 *
 * Returns a MMNT_RowSelection_Transition instance.
 *
 * @param operation The UINavigationControllerOperation that determines the transition type (push or pop)
 */
+ (instancetype)transitionWithOperation:(UINavigationControllerOperation)operation andRowIndex:(NSInteger)idx andDirection:(NSString*)direction;

/** New transition
 *
 * Returns a MMNT_RowSelection_Transition instance.
 *
 * @param operation The UINavigationControllerOperation that determines the transition type (push or pop)
 */
- (instancetype)initWithOperation:(UINavigationControllerOperation)operation andRowIndex:(NSInteger)idx andDirection:(NSString*)direction;

/**-----------------------------------------------------------------------------
 * @name AMWaveTransition Properties
 * -----------------------------------------------------------------------------
 */

/** Operation type
 *
 * Sets the operation type (push or pop)
 *
 */
@property (assign, nonatomic) UINavigationControllerOperation operation;

/** Animation duration
 *
 * Sets the duration of the animation. The whole duration accounts for the maxDelay property.
 *
 */
@property (assign, nonatomic) CGFloat duration;

/** Slideup duration
 *
 * Sets the duration of the slide up animation
 *
 */
@property (assign, nonatomic) CGFloat tSlideup;

/** Row index
 *
 * Identifies row that has to slide up
 *
 */
@property (assign, nonatomic) NSInteger rowIdx;

/** Maximum animation delay
 *
 * Sets the max delay that a cell will wait beofre animating.
 *
 */
@property (assign, nonatomic) CGFloat maxDelay;

/** Direction of transition
 *
 * Sets the direction from which the new view flies in
 *
 */
@property (assign, nonatomic) NSString* direction;

@end
