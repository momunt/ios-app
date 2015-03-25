//
//  MMNT_HelpScreen.m
//  Momunt
//
//  Created by Masha Belyi on 1/26/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import "MMNT_HelpScreen.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation MMNT_HelpScreen

- (id)initWithFrame:(CGRect)frame text:(NSString *)text vidFile:(NSString *)vidFile
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // help text
        UITextView *helpText = [[UITextView alloc] initWithFrame:CGRectMake((self.frame.size.width-260)/2,10,260,80) ];
        helpText.backgroundColor = [UIColor clearColor];
        helpText.text = text;
        helpText.textColor = [UIColor colorWithWhite:1 alpha:1];
        helpText.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
        helpText.textAlignment = NSTextAlignmentCenter;
        [self addSubview:helpText];
        
        // phone image
        UIImageView *device = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, self.frame.size.width, self.frame.size.height-100 )];
        device.contentMode = UIViewContentModeScaleAspectFit;
        device.image = [UIImage imageNamed:@"Device"];
        [self addSubview:device];
        
        // video
        
        NSURL *movieURL;
        NSBundle *bundle = [NSBundle mainBundle];
        if(bundle != nil)
        {
            NSString *moviePath = [bundle pathForResource:vidFile ofType:@"mp4"];
            if (moviePath)
            {
                movieURL = [NSURL fileURLWithPath:moviePath];
                
            }
        }
        
        
//        NSString *path1 = [NSString stringWithFormat:@"%@/%@.mp4", [[NSBundle mainBundle] resourcePath], vidFile];
        NSString *path1 = [[NSBundle mainBundle] pathForResource:vidFile ofType:@"mp4"];
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.mp4", vidFile] ];
        
//        NSURL *url = [NSURL fileURLWithPath:path1];
        _vidVC = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
//        _vidVC = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:path1]];; //[[MPMoviePlayerController alloc] initWithContentURL:url];
        _vidVC.view.frame = CGRectMake(70, 149, self.frame.size.width-140, self.frame.size.height-149);
        _vidVC.controlStyle = MPMovieControlStyleNone;
        [_vidVC setScalingMode:MPMovieScalingModeAspectFit];
        [_vidVC setFullscreen:FALSE];
        
        _vidVC.repeatMode = MPMovieRepeatModeOne;
        _vidVC.view.backgroundColor = [UIColor clearColor];
        _vidVC.movieSourceType = MPMovieSourceTypeFile;
        
        for(UIView* subV in _vidVC.view.subviews) {
            subV.backgroundColor = [UIColor clearColor];
        }
        
        
        [self addSubview:_vidVC.view];
        
//        [_vidVC prepareToPlay];
//        [_vidVC play];
        

        _poster = [[UIImageView alloc] initWithFrame:_vidVC.view.frame];
        _poster.contentMode = UIViewContentModeScaleAspectFit;
        _poster.image = [UIImage imageNamed:@"videoPoster.jpg"];
        [self addSubview:_poster];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(MPMoviePlayerPlaybackStateDidChange:)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                   object:_vidVC];
        

    }
    return self;
}

- (void)MPMoviePlayerPlaybackStateDidChange:(NSNotification *)notification
{
    MPMoviePlayerController *player = [notification object];
    
    if(player==_vidVC){
        if (player.playbackState == MPMoviePlaybackStatePlaying)
        { //playing
        
            [UIView animateWithDuration:0.3 delay:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
                _poster.alpha = 0.0;
            } completion:nil];

        }
        if (player.playbackState == MPMoviePlaybackStateStopped)
        { //stopped
            _poster.alpha = 1.0;
        }
        
        if (player.playbackState == MPMoviePlaybackStatePaused)
        { //paused
            _poster.alpha = 1.0;
        }
        
        if (player.playbackState == MPMoviePlaybackStateInterrupted)
        { //interrupted
        }
        
        if (player.playbackState == MPMoviePlaybackStateSeekingForward)
        { //seeking forward
        }
        
        if (player.playbackState == MPMoviePlaybackStateSeekingBackward)
        { //seeking backward
        }
    }

    
}

@end
