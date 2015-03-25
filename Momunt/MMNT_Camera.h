//
//  MMNT_Camera.h
//  Momunt
//
//  Created by Masha Belyi on 9/6/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GPUImage.h"

#import "MMNT_xButton.h"
#import "MMNT_checkButton.h"
#import "MMNT_interactiveButton.h"
#import "MMNT_TransparentView.h"

@interface MMNT_Camera : UIViewController <CLLocationManagerDelegate>

@property GPUImageStillCamera *stillCamera;
@property GPUImageGammaFilter *filter;
@property AVCaptureSession *session;
@property GPUImageView *cameraFeed;
@property GPUImageView *camerBackground;
@property UIImageView *focusIcon;
@property GPUImageFilterGroup *backgroundFilter;


-(void)wakeUp;
-(void)sleep;


@property (strong, nonatomic) IBOutlet UIButton *camButton;
- (IBAction)capturePhoto:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *previewImageView;

@property (strong, nonatomic) IBOutlet MMNT_xButton *cancelButton;
- (IBAction)cancelPhoto:(id)sender;

@property (strong, nonatomic) IBOutlet MMNT_checkButton *acceptButton;
- (IBAction)submitPhoto:(id)sender;

@property (strong, nonatomic) IBOutlet MMNT_interactiveButton *flashButton;
- (IBAction)pressedFlash:(id)sender;

@property (strong, nonatomic) IBOutlet MMNT_interactiveButton *selfieButton;
- (IBAction)pressedSelfie:(id)sender;

@property (strong, nonatomic) IBOutlet MMNT_interactiveButton *closeButton;
- (IBAction)pressedClose:(id)sender;


@property (strong, nonatomic) IBOutlet UIImageView *blurSnapshot;

@property (strong, nonatomic) IBOutlet MMNT_TransparentView *reloadView;
@property (strong, nonatomic) IBOutlet MMNT_xButton *reloadX;
@property (strong, nonatomic) IBOutlet UIButton *reloadCheck;
- (IBAction)pressedYesReload:(id)sender;
- (IBAction)pressedNoReload:(id)sender;


@end
