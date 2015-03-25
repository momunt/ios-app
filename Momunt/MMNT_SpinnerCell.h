//
//  MMNT_SpinnerCell.h
//  Momunt
//
//  Created by Masha Belyi on 2/3/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNT_LoadingSpinner.h"

@interface MMNT_SpinnerCell : UICollectionViewCell

- (id)init;

@property MMNT_LoadingSpinner *spinner;

@end
