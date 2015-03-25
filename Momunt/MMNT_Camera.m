//
//  MMNT_Camera.m
//  Momunt
//
//  Created by Masha Belyi on 9/6/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_Camera.h"
#import "POPSpringAnimation.h"
#import "POPBasicAnimation.h"
#import "MMNT_SharedVars.h"
#import "MMNTViewController.h"

#import "LocationController.h"
#import "MMNTDataController.h"

#import "Amplitude.h"

@interface MMNT_Camera (){
    BOOL _init;
}

@property CLLocationManager *locationManager;

@property CGFloat frameWidth;
@property CGFloat frameHeight;
@property MMNT_SharedVars *sharedVars;
@property BOOL flashON;
@property BOOL selfieON;
@property BOOL uploadedPic;
@property CGFloat verticalOffset;
@property BOOL snappedPic;

@property CGSize apertureSize;
@property CGFloat apertureRatio;

@property NSDate *timePhotoTaken;
@property CLLocation *placePhotoTaken;

@property GPUImageiOSBlurFilter *blurFilter;
@property GPUImageView *blurView;

@property GPUImageFilterGroup *blurredCamStream;
@property GPUImageFilterGroup *camStream;
@property GPUImageFilterGroup *backgroundStream;

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.


@end

@implementation MMNT_Camera

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
	[self setSessionQueue:sessionQueue];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    
    self.frameWidth = self.view.frame.size.width;
    self.frameHeight = self.view.frame.size.height;
    self.sharedVars = [MMNT_SharedVars sharedVars];
    [self setup];

    
    self.view.userInteractionEnabled = YES;
    _flashON = NO;
    _selfieON = NO;
    _previewImageView.hidden = YES;
    _blurSnapshot.hidden = YES;
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        // do your logic
        [self initializeCamera];
    } else if(authStatus == AVAuthorizationStatusDenied){
        // denied
    } else if(authStatus == AVAuthorizationStatusRestricted){
        // restricted, normally won't happen
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
//        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
//            if(granted){
//                NSLog(@"Granted access to %@", mediaType);
//            } else {
//                NSLog(@"Not granted access to %@", mediaType);
//            }
//        }];
    } else {
        // impossible, unknown authorization status
    }

}

-(void)setup{
    _flashButton.imageView.frame = CGRectMake((_flashButton.frame.size.width-15)/2, (_flashButton.frame.size.height-21)/2, 15, 21);
    _flashButton.adjustsImageWhenHighlighted = NO;
    _selfieButton.imageView.frame = CGRectMake((_selfieButton.frame.size.width-25)/2, (_selfieButton.frame.size.height-21)/2, 25, 21);
    _selfieButton.adjustsImageWhenHighlighted = NO;
    
    _reloadView.hidden = YES;
    _reloadView.alpha = 0.0f;
}


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    dispatch_async([self sessionQueue], ^{
//        AVCaptureDevice *camDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        int flags = (NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew);
        [_stillCamera.inputCamera addObserver:self forKeyPath:@"adjustingFocus" options:flags context:nil];
        [_stillCamera.inputCamera addObserver:self forKeyPath:@"adjustingExposure" options:flags context:nil];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Note: I needed to stop camera capture before the view went off the screen in order to prevent a crash from the camera still sending frames
//    [_stillCamera stopCameraCapture];
//    [session stopRunning];
    
	[super viewWillDisappear:animated];
    
//    dispatch_async([self sessionQueue], ^{
////        AVCaptureDevice *camDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//        [_stillCamera.inputCamera removeObserver:self forKeyPath:@"adjustingFocus"];
//        [_stillCamera.inputCamera removeObserver:self forKeyPath:@"adjustingExposure"];
//    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// callback
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if( [keyPath isEqualToString:@"adjustingFocus"] ){
        BOOL adjustingFocus = [ [change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1] ];
//        NSLog(@"Is adjusting focus? %@", adjustingFocus ? @"YES" : @"NO" );
//        if(!adjustingFocus){
//            [self finishedFocusing];
//        }
    }
    if( [keyPath isEqualToString:@"adjustingExposure"] ){
        BOOL adjustingExposure = [ [change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1] ];
//        NSLog(@"Is adjusting exposure? %@", adjustingExposure ? @"YES" : @"NO" );
        if(!adjustingExposure){
            [self finishedFocusing];
        }
    }
}


-(void)initializeCamera
{
    
    _stillCamera=[[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
    _stillCamera.outputImageOrientation=UIInterfaceOrientationPortrait;
    
    _stillCamera.horizontallyMirrorFrontFacingCamera = YES; // flip front-facing camera
    
    NSError *error;
    if (![_stillCamera.inputCamera lockForConfiguration:&error])
    {
        NSLog(@"Error locking for configuration: %@", error);
    }

    [_stillCamera.inputCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    [_stillCamera.inputCamera setExposureMode:AVCaptureExposureModeLocked];

    [_stillCamera.inputCamera unlockForConfiguration];
    
    
    
    // 1) background blurred preview
    GPUImageView *image=[[GPUImageView alloc]initWithFrame:CGRectMake(0.0, 70+_frameWidth, _frameWidth, _frameHeight-(0+_frameWidth))];
    image.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.view insertSubview:image atIndex:2];
    _camerBackground = image;
    
    /* ---------- Background blur  ---------- */
    
    // initiate filter group
    _backgroundStream = [[GPUImageFilterGroup alloc] init];
    
    // crop filter
    GPUImageCropFilter *crop = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0.8, 1, 0.2 )]; // just selecting lower 20% of the picture. Does not necessarily allign with the bottom of the centered image that is overlayed on top.
    [_backgroundStream addFilter:crop];
    
    // followed by a blur filter
    GPUImageiOSBlurFilter *blurFilter=[[GPUImageiOSBlurFilter alloc] init];
    blurFilter.downsampling = 16;
    blurFilter.blurRadiusInPixels = 3.0f;
    blurFilter.saturation = 1.4;
    [_backgroundStream addFilter:blurFilter];
    
    // Combine the two filters
    [crop addTarget:blurFilter];
    [_backgroundStream setInitialFilters:[NSArray arrayWithObject:crop]];
    [_backgroundStream setTerminalFilter:blurFilter];
    
    // add filters to camera
    
    [_stillCamera addTarget:_backgroundStream];
    [_backgroundStream addTarget:image];
    
    _backgroundFilter = blurFilter;
    
    
    
    /* ---------- Photo stream  ---------- */
    
    CGFloat w = _frameWidth; //-20;
    _verticalOffset = 70; //    _verticalOffset = ((_frameWidth*4/3)-_frameWidth)/2; or take center part of the captured image..
    
    // preview container
    GPUImageView *thumbnail=[[GPUImageView alloc]initWithFrame:CGRectMake(0.0, 70.0, w, w)];
    self.cameraFeed = thumbnail;
    [self.view insertSubview:thumbnail atIndex:3];
    [self.view bringSubviewToFront:self.camButton];
    
    // filters
    _camStream = [[GPUImageFilterGroup alloc] init];
    
    GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0/_frameWidth, _verticalOffset/(_frameWidth*4/3), w/_frameWidth, (w)/(_frameWidth*4/3))];
    [_camStream addFilter:cropFilter];
    
    GPUImageGammaFilter *gamma = [[GPUImageGammaFilter alloc] init];
    [_camStream addFilter:gamma];
    [gamma forceProcessingAtSize:CGSizeMake(1080.0, 1080.0)];
    _filter = gamma;
    
    // blur filter for blurring when needed
    GPUImageiOSBlurFilter *addBlurFilter=[[GPUImageiOSBlurFilter alloc] init];
    addBlurFilter.downsampling = 16;
    addBlurFilter.blurRadiusInPixels = 3.0f;
    addBlurFilter.saturation = 1.4;
    
    // Combine the two filters
    [cropFilter addTarget:gamma];
    [_camStream setInitialFilters:[NSArray arrayWithObject:cropFilter]];
    [_camStream setTerminalFilter:gamma];
    
    [_stillCamera addTarget:_camStream];
    [_camStream addTarget:thumbnail];
    
    // blur filter for later..
    _blurredCamStream = [[GPUImageFilterGroup alloc] init];
    [_blurredCamStream addFilter:cropFilter];
    [_blurredCamStream addFilter:gamma];
    [_blurredCamStream addFilter:addBlurFilter];
    // Combine all filters
    [cropFilter addTarget:gamma];
    [gamma addTarget:addBlurFilter];
    [_blurredCamStream setInitialFilters:[NSArray arrayWithObject:cropFilter]];
    [_blurredCamStream setTerminalFilter:addBlurFilter];

    
    // attach tap gesture recognizer
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                          initWithTarget:self
                                                          action:@selector(focusAndExposeTap:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    [self.cameraFeed addGestureRecognizer:singleTapGestureRecognizer];
    
    [self setupFocusIcon];
    [_stillCamera startCameraCapture];
    
//    int64_t delay = 2.0; // In seconds
//    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
//    dispatch_after(time, [self sessionQueue], ^(void){
//        [_stillCamera stopCameraCapture];
//    });
    
    _init = YES;
    self.view.backgroundColor = [UIColor clearColor];
}

-(void)wakeUp{
    if(!_init){
        // runs the first time you swipe over to camera before user gives permission to use the camera
        [self performSelector:@selector(initializeCamera) withObject:nil afterDelay:0.5];
    }
    dispatch_async([self sessionQueue], ^{
        [_stillCamera startCameraCapture];
        if(_snappedPic)
            [_stillCamera removeTarget:_backgroundStream];
        
    });
//    [self checkLocation];

    if(_uploadedPic)
        [self reset];

}
-(void)sleep{
    dispatch_async([self sessionQueue], ^{
        [_stillCamera stopCameraCapture];
    });
}
-(void)checkLocation{
    NSLog(@"camera checking location");
    // subscribe to location updates
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatedLocation:)
                                                 name:@"newLocationFound"
                                               object:nil];
    // start fetching location
    [[LocationController sharedInstance] startUpdatingLocation];
}
// Do something when location updates
-(void) updatedLocation:(NSNotification*)notif {

    // stop listening for locaton
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"newLocationFound" object:nil];
    // stop location manager
    [[LocationController sharedInstance] stopUpdatingLocation];
    
    // report current location
    CLLocation* location = (CLLocation*)[[notif userInfo] valueForKey:@"newLocationResult"];
    _placePhotoTaken = location;
    
    // compare this locaiton to momunt location
    CLLocation *mmntLocation = [[CLLocation alloc] initWithLatitude:[MMNTDataController sharedInstance].currentMomunt.lat longitude:[MMNTDataController sharedInstance].currentMomunt.lng];
    CLLocationDistance meters = [location distanceFromLocation:mmntLocation];
    NSLog(@"You are %f meters away from the momunt", meters);
    
    // if too far away from momunt center - ask user to reload the momunt
    if(meters > 100){ // What should the threshold be???
        NSLog(@"COME BACK!!!!");
        [self showReloadPrompt];
    }else{
        // checked location and you are within momunt bondaries
        [self hideReloadPrompt];
        // scale up regular accept, reject buttons
        [_sharedVars scaleUp:self.acceptButton];
        [_sharedVars scaleUp:self.cancelButton];
        // scale down camera, selfie, flash buttons
        [_sharedVars scaleDown:self.camButton];
        [_sharedVars scaleDown:self.flashButton];
        [_sharedVars scaleDown:self.selfieButton];
        [_sharedVars scaleDown:self.closeButton];
    }
}
-(void) setFilterGroup:(GPUImageFilterGroup *)filters{
    [_stillCamera pauseCameraCapture];
    
    [_stillCamera removeTarget:_camStream];
    [_camStream removeTarget:_cameraFeed];
    [_stillCamera removeTarget:_blurredCamStream];
    [_blurredCamStream removeTarget:_cameraFeed];
    [_stillCamera removeAllTargets];
    
    [_stillCamera addTarget:_backgroundStream];
    [_stillCamera addTarget:filters];
    [filters addTarget:_cameraFeed];
    
    [_stillCamera resumeCameraCapture];

}
-(void)showReloadPrompt{
    // fade in reload prompt
    _reloadView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        _reloadView.alpha = 1.0;
    }];
    
    if(!_blurFilter){
        // followed by a blur filter
        _blurFilter=[[GPUImageiOSBlurFilter alloc] init];
        _blurFilter.downsampling = 16;
        _blurFilter.blurRadiusInPixels = 5.0f;
        _blurFilter.saturation = 1.4;
    }
    if(!_blurView){
        _blurView = [[GPUImageView alloc] initWithFrame:CGRectMake(0,0,_reloadView.frame.size.width,_reloadView.frame.size.height)];
        _blurView.clipsToBounds = YES;
        _blurView.layer.contentsGravity = kCAGravityTop;
        [_reloadView insertSubview:_blurView atIndex:0];
    }
    
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:_previewImageView.image];
    [picture addTarget:_blurFilter];
    [_blurFilter addTarget:_blurView];
    [picture processImage];
    
    // blur camera
//    [self setFilterGroup:_blurredCamStream];
    
    //disable cam button
//    _camButton.userInteractionEnabled = NO;
}
-(void)hideReloadPrompt{
    // fade out reload prompt
    [UIView animateWithDuration:0.3 animations:^{
        _reloadView.alpha = 0.0;
    } completion:^(BOOL finished) {
        _reloadView.hidden = YES;
    }];
    
    
    // unblur camera
//    [self setFilterGroup:_camStream];
    
    //enable cam button
//    _camButton.userInteractionEnabled = YES;
}

-(void)reset{
    self.previewImageView.hidden = YES;
    self.previewImageView.center = CGPointMake(self.frameWidth/2, 70+(self.frameWidth/2));
    self.previewImageView.transform = CGAffineTransformMakeScale(1, 1);
    
    _cameraFeed.hidden = NO;
    [_camerBackground setAlpha:1.0];
    [_cancelButton setAlpha:1.0];
    [_acceptButton setAlpha:1.0];
    
    self.camButton.transform = CGAffineTransformMakeScale(1, 1);
    self.selfieButton.transform = CGAffineTransformMakeScale(1, 1);
    self.closeButton.transform = CGAffineTransformMakeScale(1, 1);
    if(!_selfieON)
        self.flashButton.transform = CGAffineTransformMakeScale(1, 1);
    _cancelButton.transform = CGAffineTransformMakeScale(0,0);
    _acceptButton.transform = CGAffineTransformMakeScale(0,0);
    _uploadedPic = NO;
    
}
- (void)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
//    if(_selfieON)
//        return;
    
	CGPoint devicePoint = [gestureRecognizer locationInView:[gestureRecognizer view]];
    [self showFocusAtPoint:devicePoint];
    devicePoint = [self convertToPointOfInterestFromViewCoordinates:devicePoint];
    
    //[(AVCaptureVideoPreviewLayer *)[[self cameraFeed] layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
	[self focusWithMode:(_selfieON ? AVCaptureFocusModeContinuousAutoFocus : AVCaptureFocusModeAutoFocus) exposeWithMode:AVCaptureExposureModeContinuousAutoExposure
          atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

-(void)setupFocusIcon{
    UIImage *focusImg = [UIImage imageNamed:@"onFocus"];
    _focusIcon = [[UIImageView alloc] initWithImage:focusImg];
    _focusIcon.alpha = 0.0f;
    _focusIcon.frame = CGRectMake(0, 0, 40,40);
    [self.cameraFeed addSubview:_focusIcon];

}

-(void)showFocusAtPoint:(CGPoint)point{
//    if(![_stillCamera.inputCamera isFocusModeSupported:AVCaptureExposureModeAutoExpose])
//        return;
    
    [_focusIcon setCenter:point];
    
    _focusIcon.alpha = 0.0f;
    _focusIcon.transform = CGAffineTransformMakeScale(0.7,0.7);
    
    [_focusIcon pop_removeAllAnimations];
    POPSpringAnimation *scaleUp = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleUp.toValue = [NSValue valueWithCGPoint: CGPointMake(1.2, 1.2)] ;
    scaleUp.springBounciness = 15;
    scaleUp.springSpeed = 15;
    scaleUp.completionBlock = ^(POPAnimation *animation, BOOL finished){};
    [_focusIcon pop_addAnimation:scaleUp forKey:@"scale"];
    
    POPBasicAnimation *fadeIn = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    fadeIn.toValue = @(1.0);
    fadeIn.duration = 0.3;
    [_focusIcon pop_addAnimation:fadeIn forKey:@"alpha"];
    
}
-(void)finishedFocusing{
    [_focusIcon pop_removeAllAnimations];
    POPBasicAnimation *scaleDown = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleDown.toValue = [NSValue valueWithCGPoint: CGPointMake(0.7, 0.7)] ;
    scaleDown.beginTime = (CACurrentMediaTime() + 0.1);
    [_focusIcon pop_addAnimation:scaleDown forKey:@"scale"];
    
    POPBasicAnimation *fadeOut = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    fadeOut.toValue = @(0.0);
    fadeOut.duration = 0.3;
    fadeOut.beginTime = (CACurrentMediaTime() + 0.1);
    [_focusIcon pop_addAnimation:fadeOut forKey:@"alpha"];
}

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates {
    [self getCameraResolution];
    
//    viewCoordinates.y = (viewCoordinates.y+_verticalOffset)/(_frameWidth/_apertureRatio);
    viewCoordinates.y = (viewCoordinates.y+70)/(_frameWidth/_apertureRatio);
//    viewCoordinates.y = viewCoordinates.y/_frameWidth;
    viewCoordinates.x = 1-(viewCoordinates.x/_frameWidth);

    return viewCoordinates;

}

-(void)getCameraResolution{
    CGRect cleanAperture;
    for(AVCaptureInputPort *port in [[_stillCamera.captureSession.inputs lastObject]ports]) {
        if([port mediaType] == AVMediaTypeVideo) {
            cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
            _apertureSize = cleanAperture.size;
            _apertureRatio = _apertureSize.height / _apertureSize.width;
        }
    }
    
}


- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
	dispatch_async([self sessionQueue], ^{
        
		AVCaptureDevice *device = _stillCamera.inputCamera;
		NSError *error = nil;
		if ([device lockForConfiguration:&error])
		{
			if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
			{
				[device setFocusPointOfInterest:point];
                [device setFocusMode:focusMode];
			}
			if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
			{
//				int flags = (NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew);
//                [_stillCamera.inputCamera addObserver:self forKeyPath:@"adjustingExposure" options:flags context:nil];
                
				[device setExposurePointOfInterest:point];
                [device setExposureMode:exposureMode];
			}
			[device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
			[device unlockForConfiguration];
		}
		else
		{
			NSLog(@"%@", error);
		}
	});
}


- (IBAction)capturePhoto:(id)sender {
    
        [_stillCamera capturePhotoAsImageProcessedUpToFilter:_filter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
//            NSLog(@"%@", _stillCamera.currentCaptureMetadata);
            [self previewImage:processedImage];
        }];

}

-(void)previewImage:(UIImage *)image{
    [Amplitude logEvent:@"photo taken"];
    
//    [_acceptButton onTouchUp];
    [self.previewImageView setImage:image];
    self.acceptButton.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    self.cancelButton.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    
//    [self.view bringSubviewToFront:self.previewImageView];
    [self.view bringSubviewToFront:self.cancelButton];
    [self.view bringSubviewToFront:self.acceptButton];
    
    _previewImageView.hidden = NO;
    _snappedPic = YES;
    [_stillCamera removeTarget:_backgroundStream]; // pause background stream 0 like taking a snapshot

    _timePhotoTaken = [[NSDate alloc] init];
    
    [self checkLocation]; // check if you are still within the momunt boundaries
}


- (IBAction)cancelPhoto:(id)sender {
    [self cancelSnappedPhoto];
}
-(void)cancelSnappedPhoto{
    [self hideReloadPrompt];
    
    _previewImageView.hidden = YES;
    _snappedPic = NO;
    [_stillCamera addTarget:_backgroundStream];
    
    [_sharedVars scaleDown:self.acceptButton];
    [_sharedVars scaleDown:self.cancelButton];
    
    [_sharedVars scaleUp:self.camButton];
    if(!_selfieON)
        [_sharedVars scaleUp:self.flashButton];
    [_sharedVars scaleUp:self.selfieButton];
    [_sharedVars scaleUp:self.closeButton];
    
    [Amplitude logEvent:@"photo cancelled"];
}
- (IBAction)submitPhoto:(id)sender {
    
    // AMPLITUDE ---------------------------------------------------------------------------------------------------
    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    [eventProperties setValue:[NSNumber numberWithDouble:_placePhotoTaken.coordinate.latitude] forKey:@"latitude"];
    [eventProperties setValue:[NSNumber numberWithDouble:_placePhotoTaken.coordinate.longitude] forKey:@"longitude"];
    [eventProperties setValue:[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];
    [Amplitude logEvent:@"photo added" withEventProperties:eventProperties];
    //--------------------------------------------------------------------------------------------------------------

    
    
    _snappedPic = NO;
    [_stillCamera addTarget:_backgroundStream];
    
    [_sharedVars scaleDown:self.acceptButton];
    [_sharedVars scaleDown:self.cancelButton];
    _uploadedPic = YES;
    MMNTViewController *parent = self.parentViewController;
    [parent uploadImage:self.previewImageView.image withLocation:_placePhotoTaken timestamp:_timePhotoTaken afterRefresh:NO];

}

- (IBAction)pressedSelfie:(id)sender {
    
    _selfieON = !_selfieON;

    self.cameraFeed.alpha = 0.999;
    [UIView transitionWithView:self.cameraFeed duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        self.cameraFeed.alpha = 1;
//        self.previewImageView.image = [UIImage imageNamed:@"ryan.jpg"];
    } completion:^(BOOL finished) {
        //done!
    }];
    
    [_selfieButton onTouchUp];
    
    if(_selfieON){
        [_sharedVars scaleDown:_flashButton];
        // FOR SELFIE - Continuous Auto Focus and Exposure
//        NSError *error;
//        if (![_stillCamera.inputCamera lockForConfiguration:&error]){NSLog(@"Error locking for configuration: %@", error);}
//        [_stillCamera.inputCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
//        [_stillCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
//        [_stillCamera.inputCamera unlockForConfiguration];
        
    }else{
        [_sharedVars scaleUp:_flashButton];
        // FOR BackCamera - Auto Focus and Exposure
//        NSError *error;
//        if (![_stillCamera.inputCamera lockForConfiguration:&error]){NSLog(@"Error locking for configuration: %@", error);}
//        [_stillCamera.inputCamera setFocusMode:AVCaptureFocusModeAutoFocus];
//        [_stillCamera.inputCamera setExposureMode:AVCaptureExposureModeAutoExpose];
//        [_stillCamera.inputCamera unlockForConfiguration];

    }
    
    
    
    dispatch_queue_t queue;
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [_stillCamera rotateCamera];
        
        @try{
            [_stillCamera.inputCamera removeObserver:self forKeyPath:@"adjustingFocus"];
            [_stillCamera.inputCamera removeObserver:self forKeyPath:@"adjustingExposure"];
        }@catch(id anException){
            //do nothing, obviously it wasn't attached because an exception was thrown
        }
        
        int flags = (NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew);
        [_stillCamera.inputCamera addObserver:self forKeyPath:@"adjustingFocus" options:flags context:nil];
        [_stillCamera.inputCamera addObserver:self forKeyPath:@"adjustingExposure" options:flags context:nil];
    });
    
}

- (IBAction)pressedClose:(id)sender {
    [_closeButton onTouchUp];
    MMNTViewController *parent = self.parentViewController;
    [parent closeCamera];
}

- (IBAction)pressedFlash:(id)sender {
    [_flashButton onTouchUp];
    [self toggleFlash:!_flashON];
}
-(void)toggleFlash:(BOOL)status{
    _flashON = status;

    if([_stillCamera.inputCamera isFlashModeSupported:AVCaptureFlashModeOn]){
        [_flashButton setAlpha:_flashON ? 1.0 : 0.5 ];
    
        NSError *error;
        if (![_stillCamera.inputCamera lockForConfiguration:&error]){
            NSLog(@"Error locking for configuration: %@", error);
        }
        [_stillCamera.inputCamera setFlashMode:  _flashON ? AVCaptureFlashModeOn : AVCaptureFlashModeOff];
        [_stillCamera.inputCamera unlockForConfiguration];
    }
    
}
- (IBAction)pressedYesReload:(id)sender {
    // start refreshing momunt in the background
//    [[MMNTDataController sharedInstance] refreshMomunt];
    [[MMNTDataController sharedInstance] refreshMomuntAtCoordinate:_placePhotoTaken.coordinate];
    
    // hide reload prompt
    [self hideReloadPrompt];
    _snappedPic = NO;
    [_stillCamera addTarget:_backgroundStream];
    _uploadedPic = YES;
    
    // scale down camera, selfie, flash buttons
    [_sharedVars scaleDown:self.camButton];
    [_sharedVars scaleDown:self.flashButton];
    [_sharedVars scaleDown:self.selfieButton];
    [_sharedVars scaleDown:self.closeButton];

    // trigger photo upload
    MMNTViewController *parent = self.parentViewController;
    [parent uploadImage:self.previewImageView.image withLocation:_placePhotoTaken timestamp:_timePhotoTaken afterRefresh:YES];
}

- (IBAction)pressedNoReload:(id)sender {
    [self cancelSnappedPhoto];
}
@end
