//
//  MMNT_InteractiveIcon.h
//  Momunt
//
//  Created by Masha Belyi on 2/14/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MMNT_InteractiveIcon;

@protocol MMNTInteractiveIconDelegate
-(void)touchedUpInside:(MMNT_InteractiveIcon *)view;
@end


@interface MMNT_InteractiveIcon : UIImageView
@property (weak, nonatomic) id<MMNTInteractiveIconDelegate> delegate;
@end
