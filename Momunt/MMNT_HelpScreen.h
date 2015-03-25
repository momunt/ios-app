//
//  MMNT_HelpScreen.h
//  Momunt
//
//  Created by Masha Belyi on 1/26/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MMNT_HelpScreen : UIView

@property MPMoviePlayerController *vidVC;
@property UIImageView *poster;
-(id)initWithFrame:(CGRect)frame text:(NSString *)text vidFile:(NSString *)vidFile;
@end
