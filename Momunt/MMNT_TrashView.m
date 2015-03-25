//
//  MMNT_TrashView.m
//  Momunt
//
//  Created by Masha Belyi on 8/13/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_TrashView.h"

@implementation MMNT_TrashView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.4];
        self.layer.cornerRadius = 35;
        self.clipsToBounds = YES;
        
        self.trashX = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"X"] ];
        self.trashX.frame = CGRectMake(20, 22, 30, 29);
        [self addSubview:self.trashX];

        self.trashUndo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Undo"] ];
        self.trashUndo.frame = CGRectMake(20, 19, 30, 32);
        [self addSubview:self.trashUndo];
        
        UIImageView *circle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Mask"] ];
        circle.frame = CGRectMake(0,0,70,70);
        [self addSubview:circle];
        
        // button
        self.undoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.undoBtn addTarget:self action:@selector(pressedUndo) forControlEvents:UIControlEventTouchUpInside];
        self.undoBtn.frame = CGRectMake(0,0,70,70);
        self.undoBtn.adjustsImageWhenHighlighted = NO;
        self.undoBtn.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        [self addSubview:self.undoBtn];
        
    }
    return self;
}

-(void)pressedUndo{
    [self.delegate MMNTTrashViewPressedUndo:self];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
