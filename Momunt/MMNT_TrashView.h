//
//  MMNT_TrashView.h
//  Momunt
//
//  Created by Masha Belyi on 8/13/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MMNTTrashViewDelegate;

@interface MMNT_TrashView : UIView

@property UIImageView *trashX;
@property UIImageView *trashUndo;
@property UIButton *undoBtn;
@property(nonatomic, assign) id <MMNTTrashViewDelegate> delegate;

@end


@protocol MMNTTrashViewDelegate

- (void) MMNTTrashViewPressedUndo:(MMNT_TrashView*)view;

@end
