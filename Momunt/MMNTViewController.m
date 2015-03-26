//
//  MMNTViewController.m
//  Momunt
//
//  Created by Masha Belyi on 6/16/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//


#import "MMNTViewController.h"
#import "MMNTShareViewController.h"
#import "AsyncImageView.h"
#import "MMNTZoomViewController.h"
#import "MMNTAccountManager.h"
#import "MMNTApplication.h"
#import "Amplitude.h"
#import "MMNTAppDelegate.h"

#import "MMNTPhoto.h"
#import "MMNT_GalleryCell.h"
#import "MMNT_SpinnerCell.h"

#import "MMNT_ShareView_Transition.h"
#import "MMNT_ZoomIn_Transition.h"
#import "MMNT_FadeOutTransition.h"
#import "MMNT_MapToGalleryTransition.h"


#import "UIImage+ImageEffects.h"
#import "MMNT_DropDownView.h"
#import "POPSpringAnimation.h"
#import "POPBasicAnimation.h"

#import "MMNT_TrashView.h"

#import "MMNT_SharedVars.h"
#import "MMNT_Camera.h"

#import "MMNTDataController.h"
#import "MMNTAccountManager.h"
#import "MMNTApiCommuniator.h"

#import "GPUImage.h"

#import "MMNTMessages.h"

#import "MMNT_HelpTasksController.h"
#import "MMNT_InstagramSignInViewController.h"

#import "MTReachabilityManager.h"

#import "MMNT_OnboardingVC.h"


@interface MMNTViewController () <UIViewControllerTransitioningDelegate, UIViewControllerInteractiveTransitioning, DropDownViewDelegate, MMNTTrashViewDelegate, UIGestureRecognizerDelegate, CameraContainerDelegate, UICollectionViewDelegateFlowLayout, MMNTHelpTaskDelegate>{
    
    MMNTApiCommuniator *_apicommunicator;
    MMNT_HelpTasksController *_helpTaskVC;
}
    
    @property (nonatomic, strong) POPSpringAnimation *animation;

    @property UICollectionView *zoomCarouselView;
    @property BOOL onMap;

    @property BOOL zoomedIn;
    @property BOOL reloadingGallery;

    @property CLLocationManager *locationManager;

    @property MMNTShareViewController *ShareView;
    @property MMNTZoomViewController *ZoomView;

//    @property (weak, nonatomic) IBOutlet UIView *zoomContainer;

    @property UICollectionViewCell *selectedCell;

    @property BOOL *receivedLocation;
@property BOOL *hideStatusBar;

//@property MMNT_TrashView *trashView;
@property MMNTPhoto *removedItem;
@property NSInteger removedItemIdx;

@property MMNT_Camera *cameraVC;
@property MMNTPhoto *addedPhotoFromCamera;

@property NSString *tmpMomuntId;
@property NSInteger *shouldUpdateMomuntId;

@property BOOL fakeLocation;
@property CLLocationCoordinate2D customLocation;
@property NSString *customTime;

@property GPUImageiOSBlurFilter *blurFilter;
@property GPUImageView *blurView;

@property BOOL isActive;
@property BOOL alertShowing;
@property BOOL firstLoad;
@property BOOL loadedMap;
@property BOOL selectedMyMomunt;
@property BOOL shouldLoadMore;

@property MMNTObj *myMomunt;

/*
 Navigation Buttons
 */
@property BOOL navVisible;

@property CGFloat startScrollOffset;

@end

@implementation MMNTViewController

#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.galleryTopOffset = self.collectionView.frame.origin.y;
    [self.collectionView registerClass:[MMNT_GalleryCell class] forCellWithReuseIdentifier:@"galleryCell"];
    [self.collectionView registerClass:[MMNT_SpinnerCell class] forCellWithReuseIdentifier:@"spinnerCell"];
    
    // ORANGE CURSOR EVERYWHERE
    [[UITextField appearance] setTintColor:[UIColor colorWithRed:254.0/255.0 green:126.0/255.0 blue:0 alpha:1.0]]; // make cursor and selection orange
    [[UITextView appearance] setTintColor:[UIColor colorWithRed:254.0/255.0 green:126.0/255.0 blue:0 alpha:1.0]]; // make cursor and selection orange
    
    // INIT PULL REFRESH VIEW
    if(_pullRefreshHeaderView == nil){
        _pullRefreshHeaderView = [[MMNTPullRefreshHeader alloc] initWithFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, 100.0f)];
        _pullRefreshHeaderView.delegate = self;
        [self.view insertSubview:_pullRefreshHeaderView atIndex:0];
    }
    self.blurContainer.layer.position = CGPointMake(0,0);
    self.blurContainer.layer.anchorPoint = CGPointMake(0,0);
    self.blurContainer.frame = CGRectMake(0,0,SCREEN_WIDTH, SCREEN_HEIGHT);
    self.blurContainer.bounds = CGRectMake(0,0,SCREEN_WIDTH,70);
    self.blurContainer.clipsToBounds = YES;
    
    _galleryBlur = [[UIImageView alloc] initWithFrame:self.view.frame];
    NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"blurImage"];
    UIImage *blur = [UIImage imageWithData:imageData];
    if(blur){
        _galleryBlur.image = blur;
    }
    
    // INIT GESTURE HANDLERS
    [self.view setUserInteractionEnabled:YES];
    [self initGestures];
    
    // DROP DOWN VIEW
    self.dropDownView.delegate = self;
    self.dropDownView.navigationController = [self.childViewControllers objectAtIndex:1];
    [self.dropDownView setup];
    self.dropState = DropViewClosed;
    self.dropDownView.frame = CGRectMake(0,70-SCREEN_HEIGHT,SCREEN_WIDTH, SCREEN_HEIGHT);
    self.dropDownView.logo.center = CGPointMake(SCREEN_WIDTH/2, 17);
    
    UIView *dropNavigationContainer = [self.dropDownView.subviews objectAtIndex:0];
    dropNavigationContainer.frame =  CGRectMake(0,80,SCREEN_WIDTH, SCREEN_HEIGHT-80-50);
    
    
    // CAMERA CONTAINER
    self.cameraContainer.delegate = self;
    [self.cameraContainer setup];
    
    self.cameraVC = [self.childViewControllers objectAtIndex:0];
    
    // TRASH + UNDO
    self.undoButton.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.4];
    self.undoButton.layer.cornerRadius = 35.0;
    self.undoButton.clipsToBounds = YES;
    
    self.trashButton.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.4];
    self.trashButton.layer.cornerRadius = 35.0;
    self.trashButton.clipsToBounds = YES;

    self.flagButton.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.4];
    self.flagButton.layer.cornerRadius = 35.0;
    self.flagButton.clipsToBounds = YES;

    // Share transitioning manager 
    self.shareViewsManager = [[MMNTShareTransitionManager alloc] init];
    self.shareViewsManager.mainController = self; // Set the reference to the main controller
    
    
    // FAKE MOMUNT!
    self.fakeLocation = NO; // set to NO to load momunt at your gps location
    self.customLocation = CLLocationCoordinate2DMake(50.8833, 4.7000); // set to your custom location (lat, lng)
    self.customTime = @"2014-09-11 10:45:32 +0200";
    
    
//    _momunt = [NSMutableArray arrayWithArray: [[MMNTDataController sharedInstance] currentMomunt].body ];
//    [[MMNTDataController sharedInstance] currentMomunt].body;
    // subscribe to new momunts
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchedNewMomunt:)
                                                 name:@"fetchedNewMomunt"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchedMorePhotos:)
                                                 name:@"fetchedMorePhotos"
                                               object:nil];
    
    // subscribe to shared momunts
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showChat:)
                                                 name:@"showChat"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showChat:)
                                                 name:@"showMessages"
                                               object:nil];

    
    // subscribe to selectedStoredMomunt notifications (from saved momunts or chat views)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectedStoredMomunt:)
                                                 name:@"selectedStoredMomunt"
                                               object:nil];
    
    // location manager failed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopLoadingAnimation)
                                                 name:@"failedToFetchLocation"
                                               object:nil];
    // did not reach server
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopLoadingAnimation)
                                                 name:@"failedToFetchMomuntData"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationAccessDenied:)
                                                 name:@"locationAccessDenied"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setRefreshing)
                                                 name:@"loadingMomunt"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showNextTip:)
                                                 name:kApplicationDidTimeoutNotification
                                               object:nil];

    
    
    
    
//    // START ON TRENDING PAGE
//    [self showDropDownWithDefaultBlur:YES];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:nil];
    
    
    _mapBackgroundView = [[MMNT_MapBlurView alloc] initWithFrame:CGRectMake(0,70,self.view.frame.size.width, self.view.frame.size.height-70)];
    [self.view insertSubview:_mapBackgroundView atIndex:1];
//    [_mapBackgroundView showCurrentLocation];

    
    // fetch momunt on load
    self.blurImageView.image = [UIImage imageNamed:@"backgoundblur"];
    [self loadedApp];
    
//    [self restartTipTimer];
    
    /*
     Navigation Buttons
     */
    _navVisible = YES;
    [_cameraButton addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchDown];
    [_shareButton addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchDown];
    [_menuButton addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchDown];
    [_momuntButton addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchDown];
    
    [_cameraButton addTarget:self action:@selector(pressedCameraButton:) forControlEvents:UIControlEventTouchUpInside];
    [_shareButton addTarget:self action:@selector(pressedShareButton:) forControlEvents:UIControlEventTouchUpInside];
    [_menuButton addTarget:self action:@selector(pressedMenuButton:) forControlEvents:UIControlEventTouchUpInside];
    [_momuntButton addTarget:self action:@selector(pressedMomuntButton:) forControlEvents:UIControlEventTouchUpInside];
    
    // center the buttons
    CGFloat buttonW = _cameraButton.frame.size.width;
    CGFloat padding = (SCREEN_WIDTH - (4*buttonW))/5;
    _cameraButton.center = CGPointMake(padding + buttonW/2, _cameraButton.center.y);
    _menuButton.center = CGPointMake(2*padding + buttonW*3/2, _menuButton.center.y);
    _momuntButton.center = CGPointMake(3*padding + buttonW*5/2, _momuntButton.center.y);
    _shareButton.center = CGPointMake(4*padding + buttonW*7/2, _shareButton.center.y);
    
    _startScrollOffset = 0;
}

/* ------------------------------------------------------------------------
 Navigation Buttons
 ------------------------------------------------------------------------*/

- (void) buttonPress:(UIButton*)button {
    [UIView animateWithDuration:0.1 animations:^{
        button.transform = CGAffineTransformMakeScale(0.8, 0.8);
    }];
}

-(void)pressedCameraButton:(UIButton*)button {
    [Amplitude logEvent:@"pressed camera button"];
    
    [button pop_removeAllAnimations];
    POPSpringAnimation *a = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    a.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0,1.0)];
    a.springBounciness = 15;
    a.springSpeed = 10;
    a.completionBlock = ^(POPAnimation *animation, BOOL finished){
        
        
    };
    [self openCamera];
    [button pop_addAnimation:a forKey:@"scale"];
    
}

-(void)pressedShareButton:(UIButton*)button {
    [Amplitude logEvent:@"pressed share button"];
    
    [button pop_removeAllAnimations];
    POPSpringAnimation *a = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    a.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0,1.0)];
    a.springBounciness = 15;
    a.springSpeed = 10;
    a.completionBlock = ^(POPAnimation *animation, BOOL finished){
        
        //        [self performFacebookShare];
    };
    
    [self swipedLeft:nil];
    [button pop_addAnimation:a forKey:@"scale"];
    
}

-(void)pressedMenuButton:(UIButton*)button {
    [Amplitude logEvent:@"pressed menu button"];
    
    [button pop_removeAllAnimations];
    POPSpringAnimation *a = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    a.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0,1.0)];
    a.springBounciness = 15;
    a.springSpeed = 10;
    a.completionBlock = ^(POPAnimation *animation, BOOL finished){
    };
    
    [self showChatView]; // opens dropdown
    [button pop_addAnimation:a forKey:@"scale"];
    
}

-(void)pressedMomuntButton:(UIButton*)button {

    [button pop_removeAllAnimations];
    POPSpringAnimation *a = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    a.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0,1.0)];
    a.springBounciness = 15;
    a.springSpeed = 10;
    a.completionBlock = ^(POPAnimation *animation, BOOL finished){
    };
    [button pop_addAnimation:a forKey:@"scale"];
    
    if(_reloading)
        return;
    [Amplitude logEvent:@"pressed momunt button"];
    
    _tooltip.text = @"Loading the momunt at your location.";
    
    // get current momunt
    [self setRefreshing];
    _loadedStoredMomunt = NO;
    [[MMNTDataController sharedInstance] refreshMomunt];
    
    
}

-(void)hideNavigation{
    if(!_navVisible)
        return;
    
    _navVisible = NO;
    
    POPSpringAnimation *fromA = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    fromA.toValue = @(SCREEN_HEIGHT + _navContainer.frame.size.height/2);
    fromA.springBounciness = 0;
    fromA.springSpeed = 20;
    [_navContainer pop_addAnimation:fromA forKey:@"center"];
}

-(void)showNavigation{
    if(_navVisible)
        return;
    
    _navVisible = YES;
    
    POPSpringAnimation *fromA = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    fromA.toValue = @(SCREEN_HEIGHT - _navContainer.frame.size.height/2);
    fromA.springBounciness = 0;
    fromA.springSpeed = 20;
    [_navContainer pop_addAnimation:fromA forKey:@"center"];
}

-(void)showTooltipWithText:(NSString *)string{
    _tooltip.text = string;
    _tooltip.transform = CGAffineTransformMakeTranslation(0, -10);
    // slide gallery down to reveal tooltip
    [UIView animateWithDuration:0.3 animations:^{
        _collectionView.transform = CGAffineTransformMakeTranslation(0, 30);
    }];
}
-(void)hideTooltip{
    [UIView animateWithDuration:0.3 animations:^{
        _collectionView.transform = CGAffineTransformIdentity;
    }];
}
/* ------------------------------------------------------------------------ */

-(void)loadedApp{
    _firstLoad = YES;
    // set up API communicator
    _apicommunicator = [[MMNTApiCommuniator alloc] init];

    // connect to chat
    [[[MMNTDataController sharedInstance] MQTTcontroller] connect];
    
    /*
     NEW ONBOARINDG
     */
    if(![[MMNTAccountManager sharedInstance] isTaskDone:200]){
//        [self hideNavigation];
        _tooltip.text = @"Loading momunt...";
        [self setRefreshing];
        [[MMNTDataController sharedInstance] fetchMomuntWithId:@"Gpumw51886"]; // Load Golden Gate Momunt
        return;
    }

    
    
    
    // fetch user pile
    NSString *pileStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPile"];
    if(pileStr){
        _photosToShare = [[NSMutableArray alloc] init];
        NSError *e;
        NSDictionary *pileDict = [NSJSONSerialization JSONObjectWithData: [pileStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &e];
        for (NSDictionary *imageDic in pileDict) {
            MMNTPhoto *photo = [[MMNTPhoto alloc] initWithDict:imageDic];
            [_photosToShare addObject:photo];
        }
    }
    
    
    self.collectionView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    
    NSDictionary *lastMomuntDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastMomunt"];
    
    // load momunt if opened from notification
    if([MMNTDataController sharedInstance].openedFromNotification){
        [[MMNTDataController sharedInstance] fetchMomuntWithId:[MMNTDataController sharedInstance].openMomuntId];
    }
    
    else if(lastMomuntDict){
        // show where user left off
        MMNTObj *lastMomunt = [[MMNTObj alloc] initWithDict:lastMomuntDict];
        [MMNTDataController sharedInstance].currentMomunt = lastMomunt;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"fetchedNewMomunt"
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:lastMomunt
                                                                                               forKey:@"momunt"]];
        
    }
//    else if([[MMNTAccountManager sharedInstance] isTaskDone:103] && [CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse ){ // PULLED DOWN TO LOAD MOMUNT
    
    else{
        [self showTooltipWithText:@"Loading your momunt"];
        [self setRefreshing];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"isFirstLoad"];
        
//        // set refresh spinner
//        _collectionView.transform = CGAffineTransformMakeTranslation(0, 20);
//        _mapBackgroundView.transform = CGAffineTransformMakeTranslation(0, 20);
//        [_mapBackgroundView setDefaultState];
//        [_pullRefreshHeaderView setAlpha:1.0f];
//        [_pullRefreshHeaderView setState:MMNTPullRefreshLoading];
//        _reloading = YES;

        
        // LOAD CURRENT MOMUNT!
        if([MMNTDataController sharedInstance].shouldLoadFromId){
            [[MMNTDataController sharedInstance] fetchMomuntWithId:[MMNTDataController sharedInstance].mmntId];
        }else{
            // get current momunt
            _loadedStoredMomunt = NO;
            [[MMNTDataController sharedInstance] refreshMomunt];
        }
        
    }
//    else{
        
//    }
    

}

-(void)setRefreshing{
    // set refresh spinner
    [UIView animateWithDuration:0.3 animations:^{
        _collectionView.transform = CGAffineTransformMakeTranslation(0, 40);
    }];
    _tooltip.transform = CGAffineTransformIdentity;
    _mapBackgroundView.transform = CGAffineTransformMakeTranslation(0, 40);
    [_mapBackgroundView setDefaultState];
    [_dropDownView setAlpha:0.0f];
    [_pullRefreshHeaderView setAlpha:1.0f];
    [_pullRefreshHeaderView setState:MMNTPullRefreshLoading];
    _reloading = YES;
}

-(void)viewDidAppear:(BOOL)animated{
    
    self.dropDownView.bottomBar.frame = CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, 50);
//    if([[MMNTAccountManager sharedInstance] isTaskDone:101]){
//        [self showNextTip];
//    }else{
//        [self restartTipTimer];
//    }
    
}

/*
 Grabbing a Momunt
 Listen to changes in momunt data
 */
-(void)fetchedNewMomunt:(NSNotification*)notif {
    
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    _myMomunt = (MMNTObj *)[[notif userInfo] valueForKey:@"momunt"];
//    [self storeMomuntData];
    _momunt = [NSMutableArray arrayWithArray:  _myMomunt.body ];
    
    // Store momunt info
    NSDictionary *mmntDict = [_myMomunt toDictinatry];
    [[NSUserDefaults standardUserDefaults] setObject:mmntDict forKey:@"lastMomunt"];
    
    if([_myMomunt.type isEqualToString:@"pile"] || [_momunt count]<10){
        _shouldLoadMore = NO;
    }else{
        _shouldLoadMore = YES;
    }

    if(_addedPhotoFromCamera!=nil){
        // if momunt does not contain this photo - insert
        [self pushUploadedPhotoToFront:_addedPhotoFromCamera.id]; // WEird error. The new photo is not the first one to show up. Fix for now.
//        if(![self array:_momunt containsPhotoWithId:_addedPhotoFromCamera.id]){
//            [_momunt insertObject:_addedPhotoFromCamera atIndex:0];
//        }
        _addedPhotoFromCamera = nil;
    }
    
    if(self.dropState==DropViewOpen && !_firstLoad){
        // close profile view
       self.dropState = DropViewClosed;
       [self animatePaneWithInitialVelocity:[self.animation.velocity CGPointValue]];
    }
    if(_firstLoad){
        _firstLoad = NO;
    }
    
    // hide map background if it is still visible
    if(!self.mapBackgroundView.hidden){
        [UIView animateWithDuration:0.5 animations:^{
            self.mapBackgroundView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.mapBackgroundView.hidden = YES;
        }];
    }
    
    
    // update MomuntID. using local var and setting global var right before sharing.
    self.tmpMomuntId = [[MMNTDataController sharedInstance] mmntId];
    self.shouldUpdateMomuntId = 0;
    
    // make all visible cells animate on refresh
    [_collectionView.visibleCells enumerateObjectsUsingBlock:^(MMNT_GalleryCell *obj, NSUInteger idx, BOOL *stop) {
        if([obj respondsToSelector:@selector(shouldAnimate)]){
            obj.shouldAnimate = YES;
            obj.animationDelay = 0.03*( [_collectionView.visibleCells count] -idx );
        }
        
    }];
    
    // Reload galleries!
        [self.collectionView scrollRectToVisible:CGRectMake(0, 0, self.collectionView.frame.size.width, self.collectionView.frame.size.height) animated:NO]; // scroll gallery to top
        
        [self.collectionView reloadData];
    
        if([[MMNTAccountManager sharedInstance] isTaskDone:200]){

            // return collection view to correct position after reloading the view
            [UIView animateWithDuration:0.7
                              delay:0.2
             usingSpringWithDamping:0.5
              initialSpringVelocity:0.5
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.collectionView.transform = CGAffineTransformIdentity;
                         }
                         completion:nil];
        }else{
            [[MMNTDataController sharedInstance] setTaskDone:200];
            [self showTooltipWithText:@"This is a momunt at the Golden Gate Bridge."];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self showTooltipWithText:@"Tap a photo."];
            });
        }
    
    if(_reloading){        
        [[MMNTApplication sharedApplication] sendEvent:nil];
        
        _reloading = NO;
        [_pullRefreshHeaderView PullRefreshScrollViewDataSourceDidFinishedLoading:self.collectionView];
        
        [self.dropDownView setAlpha:1.0f];
        [_pullRefreshHeaderView setAlpha:0.0f];
    }
    
    [self showNavigation];
    
}
-(void)storeMomuntData
{
    MMNTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSManagedObject *newContact;
    newContact = [NSEntityDescription insertNewObjectForEntityForName:@"MomuntObj" inManagedObjectContext:context];
    
    [newContact setValue: [NSNumber numberWithDouble:_myMomunt.lat] forKey:@"lat"];
    [newContact setValue: [NSNumber numberWithDouble:_myMomunt.lng] forKey:@"lng"];
    [newContact setValue: _myMomunt.momuntId forKey:@"momuntId"];
    [newContact setValue: _myMomunt.name forKey:@"name"];
    [newContact setValue: _myMomunt.timestamp forKey:@"timestamp"];
    [newContact setValue: _momunt forKey:@"body"];
    
    
    NSError *error;
    [context save:&error];
}

-(void)fetchedMorePhotos:(NSNotification*)notif {

    [[MMNTApplication sharedApplication] sendEvent:nil];
    NSMutableArray *photos = [[notif userInfo] valueForKey:@"photos"];
    if([photos count]>0){
        if([photos count]<1){
            _shouldLoadMore = NO;
            [_collectionView reloadData];
            return;
        }
        // sometimes get repeating photo. Not sure why... remove them here
        MMNTPhoto *first = [photos objectAtIndex:0];
        MMNTPhoto *last = [_momunt lastObject];
        if([first.id isEqualToString:last.id]){
            [photos removeObject:first];
        }
        
         _momunt = [NSMutableArray arrayWithArray: [_momunt arrayByAddingObjectsFromArray:photos] ];
        
        if([_momunt count]<10 || [photos count]<1){
            _shouldLoadMore = NO;
        }
        else{
            _shouldLoadMore = YES;
        }
        
        [_collectionView reloadData];
        
//        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
//        for (int i = _momunt.count; i < [[_momunt arrayByAddingObjectsFromArray:photos] count]; i++) {
//            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
//            [indexPaths addObject:indexPath];
//        }
//        _momunt = [_momunt arrayByAddingObjectsFromArray:photos];
//        [_collectionView reloadItemsAtIndexPaths:indexPaths];
    }else{
        _shouldLoadMore = NO;
        [_collectionView reloadData];
    }
}

-(void)failedToFetchLocation:(NSNotification*)notif {
    [[MMNTApplication sharedApplication] sendEvent:nil];
    if(_reloading){
        _reloading = NO;
        [_pullRefreshHeaderView PullRefreshScrollViewDataSourceDidFinishedLoading:self.collectionView];
        
        [UIView animateWithDuration:0.7
                              delay:0.2
             usingSpringWithDamping:0.5
              initialSpringVelocity:0.5
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.collectionView.transform = CGAffineTransformIdentity;
                             self.mapBackgroundView.transform = CGAffineTransformIdentity;
                         }
                         completion:nil];

    }

}
-(void)stopLoadingAnimation{
    [[MMNTApplication sharedApplication] sendEvent:nil];
    if(_reloading){
        _reloading = NO;
        [_pullRefreshHeaderView PullRefreshScrollViewDataSourceDidFinishedLoading:self.collectionView];
        
        [UIView animateWithDuration:0.7
                              delay:0.2
             usingSpringWithDamping:0.5
              initialSpringVelocity:0.5
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.collectionView.transform = CGAffineTransformIdentity;
                             self.mapBackgroundView.transform = CGAffineTransformIdentity;
                         }
                         completion:nil];
        
    }
    
}

-(void)locationAccessDenied:(NSNotification*)notif {
    
    [_mapBackgroundView promptToAction];
    [self stopLoadingAnimation];
}

-(void)selectedStoredMomunt:(NSNotification*)notif {
    if(_reloading)
        return;
    
    NSString *momuntId = [[notif userInfo] valueForKey:@"momuntId"];
    
    
//    [self.collectionView scrollRectToVisible:CGRectMake(0, 0, self.collectionView.frame.size.width, self.collectionView.frame.size.height) animated:NO]; // scroll gallery to top
    
    [_mapBackgroundView setDefaultState]; // set "loading your momunt"
    
        if([momuntId isEqualToString:@"myMomunt"])
        {
            _selectedMyMomunt = YES;
            _loadedStoredMomunt = NO;
            
            
            _tooltip.text = @"Loading the momunt at your location";
            [self setRefreshing];

            
            [[MMNTDataController sharedInstance] refreshMomunt];

        }
        else{
            
            _selectedMyMomunt = NO;
            _loadedStoredMomunt = YES;
            
            _tooltip.text = [NSString stringWithFormat:@"Loading %@", [[notif userInfo] valueForKey:@"name"]];
            [self setRefreshing];

            
            // start fetching momunt.
            [[MMNTDataController sharedInstance] fetchMomuntWithId: momuntId];

        }
    
    // transition back to gallery
    if(self.dropState==DropViewOpen){
        // close profile view
        self.dropState = DropViewClosed;
        [self animatePaneWithInitialVelocity:[self.animation.velocity CGPointValue]];

    }
    
    
}

-(void)hideDropDown{
    [self.dropDownView setAlpha:0.0f];
}



// check if momunt contains a specific photo
-(BOOL)array:(NSMutableArray *)array containsPhotoWithId:(NSString *)uid{
    for(int i = 0; i < array.count; i++) {
        MMNTPhoto *photo = array[i];
        if([photo.id isEqualToString:uid])
            return YES;
    }
    return NO;
}
-(void)pushUploadedPhotoToFront:(NSString *)uid{
    for(int i = 0; i < _momunt.count; i++) {
        MMNTPhoto *photo = _momunt[i];
        if([photo.id isEqualToString:uid]){
            [_momunt removeObjectAtIndex:i];
            [_momunt insertObject:photo atIndex:0];
        }
    }
}


-(void) initGestures{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(swipedRight:)];
    panGesture.delegate = self;
    self.panRight = panGesture;
    [self.view addGestureRecognizer:panGesture];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft:)];
    swipeGesture.delegate = self;
    self.swipeLeft = swipeGesture;
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.collectionView addGestureRecognizer:swipeGesture];
    
}
-(void)swipedLeft:(UISwipeGestureRecognizer *)recognizer{
    if(self.mapBackgroundView.alpha==1.0){return;}
//    _isActive = YES;
    [[MMNTDataController sharedInstance] setTaskDone:2]; // swipe left to share -> done!
    
    MMNTDataController *mmntDataController = [MMNTDataController sharedInstance];
    
    [mmntDataController.toShareMomunt setEqualTo:_myMomunt];
    
    BOOL issame =[_momunt count]>=[_myMomunt.body count] &&
                [[_momunt subarrayWithRange:NSMakeRange(0, [_myMomunt.body count])] isEqualToArray:_myMomunt.body]; // _myMomunt is the original momunt that was loaded before scrolling,deleting,adding images
    
    if(issame && !_myMomunt.live){ // live momunts - always save the fisrt 100 as a new momunt. 
        mmntDataController.toShareMomunt.type = @"gallery";
    }else{
        mmntDataController.toShareMomunt.body = [_momunt count]>100 ? [_momunt subarrayWithRange:NSMakeRange(0, 100)] : _momunt; // share 1st 100 photos if scrolled to load more photos
        // id
        mmntDataController.toShareMomunt.momuntId = [[MMNTDataController sharedInstance] uniqueId];
        mmntDataController.toShareMomunt.timestamp = _myMomunt.timestamp; // store this momunt's timestamp
        mmntDataController.toShareMomunt.ownerId = [MMNTAccountManager sharedInstance].userId;
        mmntDataController.toShareMomunt.type = @"gallery";
        mmntDataController.toShareMomunt.live = NO;
//        mmntDataController.toShareMomunt.lat
    }
    
    // set poster image to first image in _momunt
    MMNTPhoto *first = [_momunt objectAtIndex:0];
    NSString *poster = [[[first valueForKey:@"images"] valueForKey:@"standard_resolution"] valueForKey:@"url"];
    mmntDataController.toShareMomunt.poster = poster;

    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    self.shareViewsManager.modalController = (MMNTShareViewController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"shareScreen"];
    
    self.shareViewsManager.modalController.transitioningDelegate = self;
    self.shareViewsManager.modalController.modalPresentationStyle = UIModalPresentationCustom;
    
    self.transitioningDelegate = self.shareViewsManager;
    
    self.currSegue = @"showShareScreen";
    
    // Present the controller
    MMNTShareViewController *toVC = self.shareViewsManager.modalController;
    mmntDataController.sharePile = NO;
    [self presentViewController:toVC animated:YES completion:nil];
    
    // hide trash view
    [UIView animateWithDuration:0.3 animations:^{
        self.trashView.transform = CGAffineTransformIdentity;
    }];

}

#pragma mark - CameraContainerDelegate
-(void)cameraContainer:(MMNT_CameraContainerView *)view dragggingWithPercentage:(CGFloat)percentage{
    [self.collectionView pop_removeAllAnimations];
    [self.trashView pop_removeAllAnimations];
    [_navContainer pop_removeAllAnimations];
    [self.cameraContainer pop_removeAllAnimations];
    
    // follow finger drag
    
    self.collectionView.layer.position = CGPointMake(SCREEN_WIDTH*3/2-SCREEN_WIDTH*percentage, self.collectionView.center.y);
    self.trashView.layer.position = CGPointMake(SCREEN_WIDTH*3/2-SCREEN_WIDTH*percentage, self.trashView.center.y);
   _navContainer.layer.position = CGPointMake(SCREEN_WIDTH*3/2-SCREEN_WIDTH*percentage, _navContainer.layer.position.y);
    self.cameraContainer.layer.position = CGPointMake(SCREEN_WIDTH/2-SCREEN_WIDTH*percentage, SCREEN_HEIGHT/2);
    
}


-(void)cameraContainer:(MMNT_CameraContainerView *)view draggingEndedWithVelocity:(CGPoint)velocity withDeltaX:(CGFloat)deltaX{
    // Slide out camera container if dragged enough
    
    BOOL close = !((ABS(deltaX)<SCREEN_WIDTH/4 && ABS(velocity.x)<800) || velocity.x>0);
    if(close){

        [Amplitude logEvent:@"went to gallery"];
    }else{
        // opened camera - swipe right task done
//        [[MMNTDataController sharedInstance] setTaskDone:3];
    }
    
    
    POPSpringAnimation *fromA = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    fromA.toValue = @( close ?  SCREEN_WIDTH*1/2 : SCREEN_WIDTH*3/2);
    fromA.velocity = @(velocity.x);
    fromA.springBounciness = 0;
    fromA.springSpeed = 20;
    [self.collectionView pop_addAnimation:fromA forKey:@"center"];
    [self.trashView pop_addAnimation:fromA forKey:@"center"];
    [_navContainer pop_addAnimation:fromA forKey:@"center"];
    
    POPSpringAnimation *cameraCenter = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    cameraCenter.toValue = @( close ?  -SCREEN_WIDTH*1/2 : SCREEN_WIDTH*1/2);
    cameraCenter.velocity = @(velocity.x);
    cameraCenter.springBounciness = 0;
    cameraCenter.springSpeed = 20;
    cameraCenter.completionBlock = ^(POPAnimation *animation, BOOL finished){
        [self.cameraVC sleep];
    };
    [self.cameraContainer pop_addAnimation:cameraCenter forKey:@"center"];

}


/*
    uploadImage
    pressed the check button in MMNT_Camera Controller.
    upload the image and animate the new photo into place
 */
-(void)uploadImage:(UIImage *)image withLocation:(CLLocation *)location timestamp:(NSDate *)t afterRefresh:(BOOL)willRefresh{
    if(willRefresh){
        _tooltip.text = @"Loading the momunt at your location.";
        [self setRefreshing];
//        // set refresh spinner
//        _collectionView.transform = CGAffineTransformMakeTranslation(0, 20);
//        
//        [_pullRefreshHeaderView setAlpha:1.0f];
//        [self.dropDownView setAlpha:0.0f];
//        self.collectionView.backgroundColor = [UIColor clearColor];
//        
//        [_pullRefreshHeaderView setState:MMNTPullRefreshLoading];
//        _reloading = YES;
        
    }
    
    /*
        start image upload
     */
    NSString *uId = [MMNT_SharedVars uniqueIdWithLength:5]; // unique ID that will be used in the image file name
    
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(sessionQueue, ^{
        [[MMNTApiCommuniator sharedInstance] uploadImage:image quality:0.6 withCoordinate:location.coordinate withTimestamp:t uId:uId];
    });
    
    /* --------- animate new image into the gallery ------------------
     
            camera background fades out
            momunt gallery appears under the faded out camera
            snapped image falls into place in gallery
            (add new image into _momunt array, but use the UIImage until image file uploads to the server) */
    
    // 1) add new blank object to _momunt
    MMNTPhoto *photo = [[MMNTPhoto alloc] init];
    photo.tempImage = [UIImage imageNamed:@"blankImage"];
    photo.uploading = YES;
    photo.location = [[NSDictionary alloc] initWithObjectsAndKeys:
                      @(location.coordinate.latitude), @"latitude",
                      @(location.coordinate.longitude), @"longitude",
                      nil];
    
    photo.created_time = [NSString stringWithFormat:@"%i", (int)[t timeIntervalSince1970]];
    photo.user = [NSString stringWithFormat: @"%i", [[MMNTAccountManager sharedInstance] userId] ];
    
    // image url: userIdTimestampUniqueId[_s/_m].jpg
    NSInteger userId = [MMNTAccountManager sharedInstance].userId;
    NSString *baseFileName = [NSString stringWithFormat:@"%i%i%@",userId, (int)[t timeIntervalSince1970], uId ];
    NSString *baseUrl = @"http://s3-us-west-2.amazonaws.com/uploads.momunt.com/";
    
    NSDictionary *thumbnail = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [NSString stringWithFormat:@"%@%@%@", baseUrl, baseFileName, @"_s.jpg"], @"url",
                               [NSNumber numberWithInteger:150], @"height",
                               [NSNumber numberWithInteger:150], @"width",
                               nil];
    NSDictionary *lowres = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [NSString stringWithFormat:@"%@%@%@", baseUrl, baseFileName, @"_m.jpg"], @"url",
                               [NSNumber numberWithInteger:360], @"height",
                               [NSNumber numberWithInteger:360], @"width",
                               nil];
    NSDictionary *standard = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [NSString stringWithFormat:@"%@%@%@", baseUrl, baseFileName, @".jpg"], @"url",
                               [NSNumber numberWithInteger:1080], @"height",
                               [NSNumber numberWithInteger:1080], @"width",
                               nil];
    
    photo.images = [[NSDictionary alloc] initWithObjectsAndKeys:
                      thumbnail, @"thumbnail",
                      lowres, @"low_resolution",
                      standard, @"standard_resolution",
                      nil];
    photo.id = [NSString stringWithFormat:@"%i%@%@",userId, photo.created_time, uId ];
    
    
    [self.momunt insertObject:photo atIndex:0];
    
    NSIndexPath *indexpath = [NSIndexPath indexPathForItem:0 inSection:0];
    NSArray *paths = [NSArray arrayWithObjects:indexpath, nil];
    [self.collectionView reloadData]; // reload instead of insertItemsAtIndexPaths to avoid cell animation
    
    
    // scroll gallery to top
    [self.collectionView scrollRectToVisible:CGRectMake(0, 0, self.collectionView.frame.size.width, self.collectionView.frame.size.height) animated:NO];
    
    // calculate dimensions..
    UICollectionViewCell *currCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"galleryCell" forIndexPath:indexpath];
    CGPoint targetCenter = CGPointMake(currCell.center.x, currCell.center.y+self.galleryTopOffset+(willRefresh ? 20 :0));
    CGFloat scale = currCell.frame.size.width/SCREEN_WIDTH;

    
    // 1 ) bring gallery under the camera view
    self.collectionView.center = CGPointMake(SCREEN_WIDTH/2, self.collectionView.center.y);
    self.trashView.center = CGPointMake(SCREEN_WIDTH/2, self.trashView.center.y);
    self.trashView.transform = CGAffineTransformIdentity;
    self.navContainer.center = CGPointMake(SCREEN_WIDTH/2, self.navContainer.center.y);

    
    // 2) Fade out camera view
    _cameraVC.cameraFeed.hidden = YES;
    self.cameraContainer.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3 animations:^{
        [_cameraVC.camerBackground setAlpha:0.0];
        [_cameraVC.cancelButton setAlpha:0.0];
        [_cameraVC.acceptButton setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self.cameraVC sleep];
    }];

    // 3) make image fall into place
        [MMNT_SharedVars runPOPSpringAnimation:kPOPViewCenter
                                        onView:self.cameraVC.previewImageView
                                       toValue:[NSValue valueWithCGPoint:targetCenter]
                              springBounciness:3
                                   springSpeed:20
                                         delay:0
                                        forKey:@"center"
                                        completion:^(BOOL finished) {
                                            //
                                        }];
        [MMNT_SharedVars runPOPSpringAnimation:kPOPLayerScaleXY
                                       onLayer:self.cameraVC.previewImageView.layer
                                       toValue:[NSValue valueWithCGPoint:CGPointMake(scale,scale)]
                              springBounciness:15
                                   springSpeed:20
                                         delay:0
                                        forKey:@"scale"
                                        completion:^(BOOL finished) {
                                            // replace blank photo with the new image. Still no url for now
                                            photo.tempImage = image;
                                            if(willRefresh){
                                                _addedPhotoFromCamera = photo;
                                            }
                                            _momunt[0] = photo;
                                            // reload first cell and get rid of the animated snapshot when done
                                            [self.collectionView performBatchUpdates:^{
                                                [self.collectionView reloadItemsAtIndexPaths:paths];
                                            }completion:^(BOOL finished) {
                                                self.cameraVC.previewImageView.hidden = YES;
                                            }];
                                            
                                            
                                            
                                        }];
    // 4) update momunt timestamp
    NSDate *now = [[NSDate alloc] init];
    MMNT_SharedVars *sharedVars = [MMNT_SharedVars sharedVars];
    sharedVars.momuntTimestamp = now;
    // 5) update MomuntID
    self.shouldUpdateMomuntId = self.shouldUpdateMomuntId+1;
    
//    [self restartTipTimer];
    
    

}

-(void)swipedRight:(UIPanGestureRecognizer*)recognizer{
    if(self.mapBackgroundView.alpha==1.0){return;}
//    _isActive = YES;
    [[MMNTDataController sharedInstance] setTaskDone:3]; // swipe right to camera -> done!
    
    if(self.dropState == DropViewOpen){
        return;
    }
    // Reveal Camera View :)
    CGPoint translation = [recognizer translationInView:[self.view window]];
    CGPoint location = [recognizer locationInView:[self.view window]];
    CGPoint velocity = [recognizer velocityInView:[self.view window]];
    
    BOOL horizontal = ABS(velocity.x) > ABS(velocity.y); // swiped horizontal?
    BOOL right = velocity.x > 0; // swiped left->right?
//    
    CGPoint point = [recognizer translationInView:[self.view window]];
    
    // If not Horizontal or swiped right->left - Ignore
    if((!horizontal  && recognizer.state!=UIGestureRecognizerStateEnded) || (!right && recognizer.state==UIGestureRecognizerStateBegan) ){
        return;
    }
    
    // 1. Gesture is started, show the modal controller
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if(location.x > self.view.frame.size.width/2){
            return;
        }
        self.startedPanRight = YES;
        self.cameraContainer.userInteractionEnabled = YES;
        [self.cameraVC wakeUp];
        
        [self.collectionView pop_removeAllAnimations];
        [self.cameraContainer pop_removeAllAnimations];
        [self.trashView pop_removeAllAnimations];
        
    }
    // 2. Update the animation state
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        if(!self.startedPanRight)
            return;
        
        self.collectionView.layer.position = CGPointMake(SCREEN_WIDTH/2+point.x, self.collectionView.center.y);
        self.trashView.layer.position = CGPointMake(SCREEN_WIDTH/2+point.x, self.trashView.center.y);
        _navContainer.layer.position = CGPointMake(SCREEN_WIDTH/2+point.x, _navContainer.layer.position.y);
        self.cameraContainer.layer.position = CGPointMake(-SCREEN_WIDTH/2+point.x, SCREEN_HEIGHT/2);
    }
    
    // 3. Complete or cancel the animation when gesture ends
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if(location.x>SCREEN_WIDTH/2 || ABS(velocity.x)>1000){
            [[MMNTDataController sharedInstance] setTaskDone:105]; // swiped to camera DONE
            [Amplitude logEvent:@"went to camera"];
        }
        if(!self.startedPanRight)
            return;
        self.startedPanRight = NO;
        
        [self.view pop_removeAllAnimations];
        [self.cameraContainer pop_removeAllAnimations];
        
        POPSpringAnimation *fromA = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
        fromA.toValue = @( location.x<SCREEN_WIDTH/2 && ABS(velocity.x)<1000 ?  SCREEN_WIDTH*1/2 : SCREEN_WIDTH*3/2);
        fromA.velocity = @(velocity.x);
        fromA.springBounciness = 0;
        fromA.springSpeed = 20;
        [self.collectionView pop_addAnimation:fromA forKey:@"center"];

        [self.trashView pop_addAnimation:fromA forKey:@"center"];
        [_navContainer pop_addAnimation:fromA forKey:@"center"];
        [_tooltip pop_addAnimation:fromA forKey:@"center"];

        
        POPSpringAnimation *cameraCenter = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
        cameraCenter.toValue = @( location.x<SCREEN_WIDTH/2 && ABS(velocity.x)<1000 ?  -SCREEN_WIDTH*1/2 : SCREEN_WIDTH*1/2);
        cameraCenter.velocity = @(velocity.x);
        cameraCenter.springBounciness = 0;
        cameraCenter.springSpeed = 20;
        [self.cameraContainer pop_addAnimation:cameraCenter forKey:@"center"];
        

    }

}

/* ------------------------------------------------------------------------------------
 HELPERS to Open/Close Camera
 ------------------------------------------------------------------------------------
 */
-(void)openCamera{
    [self.view pop_removeAllAnimations];
    [self.cameraContainer pop_removeAllAnimations];
    
    self.cameraContainer.userInteractionEnabled = YES;
    [self.cameraVC wakeUp];
    
    POPSpringAnimation *fromA = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    fromA.toValue = @(SCREEN_WIDTH*3/2);
    fromA.springBounciness = 0;
    fromA.springSpeed = 20;
    
    [self.collectionView pop_addAnimation:fromA forKey:@"center"];
    [self.trashView pop_addAnimation:fromA forKey:@"center"];
    [_navContainer pop_addAnimation:fromA forKey:@"center"];
    [_tooltip pop_addAnimation:fromA forKey:@"center"];
    
    
    POPSpringAnimation *cameraCenter = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    cameraCenter.toValue = @(SCREEN_WIDTH*1/2);
    cameraCenter.springBounciness = 0;
    cameraCenter.springSpeed = 20;
    [self.cameraContainer pop_addAnimation:cameraCenter forKey:@"center"];
}

-(void)closeCamera{
    [self.view pop_removeAllAnimations];
    [self.cameraContainer pop_removeAllAnimations];
    
    POPSpringAnimation *fromA = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    fromA.toValue = @(SCREEN_WIDTH*1/2);
    fromA.springBounciness = 0;
    fromA.springSpeed = 20;
    
    [self.collectionView pop_addAnimation:fromA forKey:@"center"];
    [self.trashView pop_addAnimation:fromA forKey:@"center"];
    [_navContainer pop_addAnimation:fromA forKey:@"center"];
    [_tooltip pop_addAnimation:fromA forKey:@"center"];
    
    
    POPSpringAnimation *cameraCenter = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    cameraCenter.toValue = @(-SCREEN_WIDTH*1/2);
    cameraCenter.springBounciness = 0;
    cameraCenter.springSpeed = 20;
    [self.cameraContainer pop_addAnimation:cameraCenter forKey:@"center"];
}

/* ------------------------------------------------------------------------------------ */

// don't fire pan if not horizontal!
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    CGPoint location = [gestureRecognizer locationInView:[self.view window]];
//    CGPoint velocity = [gestureRecognizer velocityInView:[self.view window]];
    
    if ([gestureRecognizer isEqual:self.panRight]) {
//        if(velocity.x<0 && gestureRecognizer.state==UIGestureRecognizerStateBegan){
//            return NO;
//        }else if(gestureRecognizer.state==UIGestureRecognizerStateBegan){
//            self.startedPanRight = YES;
//        }else if(gestureRecognizer.state==UIGestureRecognizerStateEnded){
//            self.startedPanRight = NO;
//        }
        
        if (gestureRecognizer.numberOfTouches > 0) {
            CGPoint translation = [self.panRight velocityInView:self.collectionView];
            return fabs(translation.y) < fabs(translation.x);
        } else {
            return NO;
        }
        
        
    }
    return YES;
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if((gestureRecognizer == self.panRight && otherGestureRecognizer==self.swipeLeft) || (otherGestureRecognizer == self.panRight && gestureRecognizer==self.swipeLeft)){
        return YES;
    }
    
    return NO;
}

//- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    for(UIView *subview in self.view.subviews)
//    {
//        UIView *view = [subview hitTest:[self.view convertPoint:point toView:subview] withEvent:event];
//        if(view) return view;
//    }
//    return [self.view hitTest:point withEvent:event];
//}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    _isActive = YES;
    if(self.removedItem != nil){
        // remove undo button
        self.removedItem = nil;
        // hide trash view
        [UIView animateWithDuration:0.3 animations:^{
            self.trashView.transform = CGAffineTransformIdentity;
        }];
    }
    
    [super prepareForSegue:segue sender:sender];
    if([segue identifier]){
        self.currSegue = [segue identifier];
    }
    
    if([self.currSegue isEqualToString:@"showShareScreen"]){
        UIViewController *toVC = segue.destinationViewController;
        toVC.modalPresentationStyle = UIModalPresentationCustom;
        toVC.transitioningDelegate = self.shareViewsManager;
        self.transitioningDelegate = self.shareViewsManager;
        
    }else{
    
        UIViewController *toVC = segue.destinationViewController;
        toVC.transitioningDelegate = self;
        self.transitioningDelegate = self;
        toVC.modalPresentationStyle = UIModalPresentationCustom;
    
        if([self.currSegue isEqualToString:@"zoomIn"] && [sender isKindOfClass:[UICollectionViewCell class]] ){
            self.selectedCell = sender;
        
            MMNTZoomViewController *secondVC = (MMNTZoomViewController *) segue.destinationViewController;
            [secondVC setData:self.momunt];
        }
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

-(BOOL)prefersStatusBarHidden {
    return self.hideStatusBar;
}

#pragma mark DropDown View

- (CGPoint)targetPoint
{
    CGSize size = self.view.bounds.size;
    return self.dropState == DropViewOpen ? CGPointMake(size.width/2, size.height/2) : CGPointMake(size.width/2, 70-size.height/2);
}
-(UIColor *) targetColor
{
    return self.dropState == DropViewOpen ? [UIColor colorWithRed:(0 / 255.0) green:(0 / 255.0) blue:(0 / 255.0) alpha:0.1] :
                                            [UIColor colorWithRed:(255.0 / 255.0) green:(255.0 / 255.0) blue:(255.0 / 255.0) alpha:1.0];
}
-(UIColor *) targetLogoBarColor
{
    return self.dropState == DropViewOpen ? [UIColor colorWithRed:(216 / 255.0) green:(216 / 255.0) blue:(216 / 255.0) alpha:0.3] :
    [UIColor colorWithRed:(216 / 255.0) green:(216 / 255.0) blue:(216 / 255.0) alpha:0];
}
-(CGRect) targetBounds
{
    return self.dropState == DropViewOpen ? CGRectMake(0,0,SCREEN_WIDTH, SCREEN_HEIGHT) : CGRectMake(0,0,SCREEN_WIDTH,70);
}

/*
 Method with the stupidest name ever
 Animates the dropdown menu view in place. Open/Close
 */
- (void)animatePaneWithInitialVelocity:(CGPoint)initialVelocity
{
    [self.dropDownView pop_removeAllAnimations];
    [self.blurContainer pop_removeAllAnimations];
    
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    animation.velocity = [NSValue valueWithCGPoint:initialVelocity];
    animation.toValue = [NSValue valueWithCGPoint:self.targetPoint];
    animation.springSpeed = 15;
    animation.springBounciness = 6;
    [self.dropDownView pop_addAnimation:animation forKey:@"dropDown"];
    
    
    POPBasicAnimation *alpha = [POPBasicAnimation animationWithPropertyNamed:kPOPViewBackgroundColor];
    alpha.toValue = [self targetColor];
    [self.dropDownView pop_addAnimation:alpha forKey:@"fade"];
    
    POPBasicAnimation *color = [POPBasicAnimation animationWithPropertyNamed:kPOPViewBackgroundColor];
    color.toValue = [self targetLogoBarColor];
    [self.dropDownView.bottomBar pop_addAnimation:color forKey:@"color"];
    
    if(self.dropState == DropViewClosed){
        self.dropDownView.spacerBar.alpha = 0.0f;
        self.dropDownView.spacerBar.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.dropDownView.spacerBar.alpha = 1.0f;
            self.dropDownView.logo.center = CGPointMake(SCREEN_WIDTH/2, 17);
            self.dropDownView.logo.hidden = NO;
            self.dropDownView.exit.hidden = YES;
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.dropDownView.logo.hidden = YES;
            self.dropDownView.exit.hidden = NO;
//            self.dropDownView.logo.center = CGPointMake(SCREEN_WIDTH/2, 25);
        }];
    }
    
    POPSpringAnimation *bounds = [POPSpringAnimation animationWithPropertyNamed:kPOPViewBounds];
    bounds.velocity = [NSValue valueWithCGRect:CGRectMake(0,0, initialVelocity.x, initialVelocity.y)];
    bounds.toValue = [NSValue valueWithCGRect:[self targetBounds]];
    bounds.springSpeed = 15;
    bounds.springBounciness = 6;
    bounds.completionBlock = ^(POPAnimation *animation, BOOL finished){
        if(self.dropState==DropViewClosed){
            self.blurContainer.hidden = YES;
            self.dropDownView.spacerBar.hidden = NO;
        }else{
            self.dropDownView.spacerBar.hidden = YES;
        }
    };
    [self.blurContainer pop_addAnimation:bounds forKey:@"bounds"];
    
    self.animation = animation;
    
//    MMNTProfileContainerController *dropDownController = [self.childViewControllers objectAtIndex:0];
//    UITableViewController *currentViewController = _dropDownView.navigationController.visibleViewController;
    
    UITableViewController *currentViewController = _dropDownView.navigationController.currentViewController;
    if([currentViewController respondsToSelector:@selector(tableView)] && currentViewController.tableView!=nil){
        NSArray *visibleCells = [currentViewController.tableView visibleCells];
    
        [visibleCells enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
            NSTimeInterval delay = ((float)idx / (float)[visibleCells count]) * 0.15;
            POPSpringAnimation *transform = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerTranslationXY];
            transform.toValue = [NSValue valueWithCGPoint:CGPointMake(0, self.dropState == DropViewOpen ? 0 : -100)];
            transform.beginTime = (CACurrentMediaTime() + delay);
            transform.springBounciness = 10;
            transform.springSpeed = 15;
            [obj.layer pop_addAnimation:transform forKey:@"drop"];
        
        }];
    }
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:(self.dropState == DropViewOpen) withAnimation:UIStatusBarAnimationSlide];
    [self.dropDownView layoutIfNeeded];
    
    if(_dropState == DropViewClosed){
        [[MMNTDataController sharedInstance] setTaskDone:102]; // tapped momunt logo to return to gallery
        [Amplitude logEvent:@"went to gallery"];
    }else{
        [[MMNTDataController sharedInstance] setTaskDone:4];
        [Amplitude logEvent:@"went to menu"];
    }
    
    if(_reloading && self.dropState == DropViewClosed){
        //fade out dropdown view + blur so that loading spinner is visible
        [UIView animateWithDuration:0.3 animations:^{
            [self.dropDownView setAlpha:0.0f];
            [self.blurContainer setAlpha:0.0f];
        }];
    }
}

#pragma mark DropViewDelegate

- (void)dropDownView:(MMNT_DropDownView *)view draggingEndedWithVelocity:(CGPoint)velocity withTouchLocation:(CGPoint)location
{
    self.dropState = velocity.y <= 0 || (location.y<SCREEN_HEIGHT/2 && ABS(velocity.y)<100) ? DropViewClosed : DropViewOpen;
    velocity.y = self.dropState == DropViewOpen ? 3.5*velocity.y : 2*velocity.y;
    [self animatePaneWithInitialVelocity:velocity];
}

- (void)dropDownViewBeganDragging:(MMNT_DropDownView *)view
{
//    _isActive = YES;
    
    [view.layer pop_removeAllAnimations];
    [self killScroll];
    
    if(self.dropState == DropViewClosed){
        self.dropDownView.spacerBar.hidden = YES;
         dispatch_async(dispatch_get_main_queue(), ^{
             self.blurContainer.alpha = 1.0;
             self.blurImageView.alpha = 1.0f;
             self.blurContainer.hidden = NO;
             [self captureBlurToImageView:self.blurImageView];
         });
    }
}
-(void)dropDownViewTapped:(MMNT_DropDownView *)view{
//    _isActive = YES;
    
    if(self.removedItem != nil){
        // remove undo button
        self.removedItem = nil;
        // hide trash view
        [UIView animateWithDuration:0.3 animations:^{
            self.trashView.transform = CGAffineTransformIdentity;
        }];
    }
    
    [self killScroll];
    
    if(self.dropState == DropViewClosed){
        self.dropDownView.spacerBar.hidden = YES;
        
        self.blurContainer.alpha = 1.0f;
        self.blurImageView.alpha = 1.0f;
        self.blurContainer.hidden = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self captureBlurToImageView:self.blurImageView];
        });
//        MMNTProfileContainerController *dropDownController = [self.childViewControllers objectAtIndex:0];
        UITableViewController *currentViewController = _dropDownView.navigationController.visibleViewController;
        if([currentViewController respondsToSelector:@selector(tableView)]){
            NSArray *visibleCells = [currentViewController.tableView visibleCells];
            [visibleCells enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
                obj.layer.transform =  CATransform3DMakeTranslation(0, -100, 0);
            }];
        }

    }
    
    self.dropState = self.dropState == DropViewClosed ? DropViewOpen : DropViewClosed;
    [self animatePaneWithInitialVelocity:[self.animation.velocity CGPointValue]];
    
    [[MMNTDataController sharedInstance] setTaskDone:4];
}
-(void)dropDownView:(MMNT_DropDownView *)view dragggingWithPercentage:(CGFloat)percentage

{
    if(self.removedItem != nil){
        // remove undo button
        self.removedItem = nil;
        // hide trash view
        [UIView animateWithDuration:0.3 animations:^{
            self.trashView.transform = CGAffineTransformIdentity;
        }];
    }
    
    self.blurContainer.bounds = CGRectMake(0,0,SCREEN_WIDTH,70 + (SCREEN_HEIGHT-70)*percentage);
    
//    MMNTProfileContainerController *dropDownController = [self.childViewControllers objectAtIndex:0];
    UITableViewController *currentViewController = _dropDownView.navigationController.visibleViewController;
    if([currentViewController respondsToSelector:@selector(tableView)]){
        NSArray *visibleCells = [currentViewController.tableView visibleCells];
        [visibleCells enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
            obj.layer.transform =  CATransform3DMakeTranslation(0, -100*(1-percentage), 0);
        }];
    }

}
-(void)showChat:(NSNotification*)notif {
    [self showDropDownWithDefaultBlur:NO];
}

-(void)showChatView{
    if(self.dropState == DropViewClosed){
        self.blurContainer.alpha = 1.0f;
        self.blurImageView.alpha = 1.0f;
        self.blurContainer.hidden = NO;
        self.dropDownView.spacerBar.hidden = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            //            [self captureBlurWithRadius:15 time: 0.5];
            [self captureBlurToImageView:self.blurImageView];
        });
        //        MMNTProfileContainerController *dropDownController = [self.childViewControllers objectAtIndex:0];
        MMNTMessages *currentViewController = _dropDownView.navigationController.currentViewController;
        if([currentViewController respondsToSelector:@selector(tableView)]){
            NSArray *visibleCells = [currentViewController.tableView visibleCells];
            [visibleCells enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
                obj.layer.transform =  CATransform3DMakeTranslation(0, -100, 0);
            }];
        }
        
    }
    
    self.dropState = DropViewOpen;
    [self animatePaneWithInitialVelocity:[self.animation.velocity CGPointValue]];
}

-(void)showDropDownWithDefaultBlur:(BOOL)val{
    // REDUNDANT code here.... :(
    
    if(self.dropState == DropViewClosed){
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        self.dropState = DropViewOpen;
        
        self.blurContainer.alpha = 1.0f;
        self.blurImageView.alpha = 1.0f;
        self.blurContainer.hidden = NO;
        
        _dropDownView.logo.hidden = YES;
        _dropDownView.exit.hidden = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(val){
                // Set background blur
                NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"blurImage"];
                UIImage *blur = [UIImage imageWithData:imageData];
                if(blur){
                    _galleryBlur.image = blur;
                }else{
                    _galleryBlur.image = [UIImage imageNamed:@"backgoundblur"];
                    self.blurImageView.image = [UIImage imageNamed:@"backgoundblur"];
                }
            }else{
                [self captureBlurToImageView:self.blurImageView];
            }
        });
    
    // place all table cells into correct position
        MMNTMessages *currentViewController = _dropDownView.navigationController.currentViewController;
        if([currentViewController respondsToSelector:@selector(tableView)]){
            NSArray *visibleCells = [currentViewController.tableView visibleCells];
            [visibleCells enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
                obj.layer.transform =  CATransform3DMakeTranslation(0, 0, 0);
            }];
        }
    
        self.dropDownView.center = [self targetPoint];
        self.dropDownView.backgroundColor = [self targetColor];
        self.blurContainer.bounds = [self targetBounds];
        self.dropDownView.spacerBar.hidden = YES;
        self.dropDownView.bottomBar.backgroundColor = [self targetLogoBarColor];
    }

}


#pragma mark Fetching Momunt Data
-(void)loadMomuntFromUrl:(NSString *)url{
    [[MMNT_SharedVars sharedVars] setUrlQuery:url];

//    [_manager fetchMomuntWithId:[[MMNT_SharedVars sharedVars].urlQuery objectForKey:@"id"]];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    
    if([[[MMNTDataController sharedInstance] currentMomunt].type isEqual:@"pile"]){
//        _shouldLoadMore = NO;
        return _momunt.count;
    }else if(_momunt.count>0){
//        _shouldLoadMore = YES;
        return _momunt.count+1;
    }else{
        return _momunt.count; // default to no infinite scroll
    }
    
//    else if(!_loadedStoredMomunt && _momunt.count>15){
//        return _momunt.count+1;
//    }
//    else if(_loadedStoredMomunt && _momunt.count>15){ // probably not a pile
//        return _momunt.count+1;
//    }
//    else{
//        return _momunt.count; // default to no infinite scroll
//    }

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(_momunt.count<=1){
        return CGSizeMake(SCREEN_WIDTH-2, SCREEN_WIDTH-2);
    }
    else if(_momunt.count>=2 && _momunt.count<16){
        return CGSizeMake((SCREEN_WIDTH-6)/2, (SCREEN_WIDTH-6)/2);
    }
    else{
        CGFloat S = (SCREEN_WIDTH-(4*2))/3;
        return CGSizeMake(S, S);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    CGFloat T;
    CGFloat L;
    CGFloat B;
    CGFloat R;

    T = 2; L = 2; B = T; R = L;

    return UIEdgeInsetsMake(2,2,2,2);
}
/*
    Populate colletion views with images
*/
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row>=_momunt.count ){
        //spinner!
//        MMNT_SpinnerCell *cell = [[MMNT_SpinnerCell alloc] init];
        MMNT_SpinnerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"spinnerCell" forIndexPath:indexPath];
        if( _shouldLoadMore){
            cell.alpha = 1.0;
            [cell.spinner startLoading];
        
            [[MMNTDataController sharedInstance] fetchMorePhotosAfter:[_momunt lastObject]];
        }else{
            cell.alpha = 0.0;
        }
    
        return cell;
    }
    // try to scale down the cell before dequeuing
    MMNT_GalleryCell *currentCell = (MMNT_GalleryCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if(currentCell && currentCell.shouldAnimate){
//        currentCell.imageView.frame = CGRectMake(0,0,currentCell.frame.size.width, currentCell.frame.size.height);
        [[MMNT_SharedVars sharedVars] scaleDown:currentCell.imageView withDuration:0.4];
    }
    
    // dequeue cell if available
    MMNT_GalleryCell *cell = (MMNT_GalleryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"galleryCell" forIndexPath:indexPath];
    // if had to make a new cell - should animate it (going from few images in momunt to a full momunt)
    if(!currentCell){
        cell.shouldAnimate = YES;
//        cell.imageView.frame = CGRectMake(0,0,cell.frame.size.width, cell.frame.size.height);
        [[MMNT_SharedVars sharedVars] scaleDown:cell.imageView withDuration:0.4];
    }else{
    
//        cell.imageView.frame = CGRectMake(0,0,cell.frame.size.width, cell.frame.size.height);
    }
//    cell.imageView.transform = CGAffineTransformIdentity;
    cell.indexPath = indexPath;
    cell.collectionView = collectionView;
    
    if(collectionView.contentOffset.y != 0){
        [cell.imageView pop_removeAllAnimations];
        cell.shouldAnimate = NO;
        cell.imageView.transform = CGAffineTransformIdentity;
    }
    
    
    MMNTPhoto *photo = _momunt[indexPath.row];
    
//    // TWITTER CHECK
//    if(photo.source!=[NSNull null] && [photo.source isEqualToString:@"twitter"]){
//        cell.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
//    }else{
//        cell.backgroundColor = [UIColor whiteColor];
//    }

    
    if(!photo.uploading){
        NSString *path;
        if(cell.frame.size.width > 150){
            path = [[[photo valueForKey:@"images"] valueForKey:@"standard_resolution"] valueForKey:@"url"];
        }else if(photo.source!=[NSNull null] && [photo.source isEqualToString:@"twitter"]){
            path = [[[photo valueForKey:@"images"] valueForKey:@"low_resolution"] valueForKey:@"url"];
        }
        else{
            path = [[[photo valueForKey:@"images"] valueForKey:@"thumbnail"] valueForKey:@"url"];
        }
        [cell setUrl:[NSURL URLWithString:path]];
        
        // if larger cell - use larger image
        if(cell.frame.size.width > 150){
            NSString *largePath = [[[photo valueForKey:@"images"] valueForKey:@"standard_resolution"] valueForKey:@"url"];
            [cell setUrl:[NSURL URLWithString:largePath]];
        }

    }else{ // if photo is still uploading - use te tempImage UIImage to fill the cell
//        [imageView setImage:photo.tempImage];
        [cell setImage:photo.tempImage];
    }
    
    
        
//    }];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    [self performSegueWithIdentifier:@"zoomIn" sender:[self.collectionView cellForItemAtIndexPath:indexPath]];
}


- (void) unBlur {
    // fade out
//    self.blurContainer.frame = CGRectMake(0,0,SCREEN_WIDTH,0);
    [UIView animateWithDuration: 0.2
                          delay:0
                        options:(UIViewAnimationOptionCurveLinear)
                     animations:^{
                         self.blurImageView.alpha = 0;
                     } completion:^(BOOL finished) {
                         //
                        self.blurContainer.bounds = CGRectMake(0,0,SCREEN_WIDTH,0);
                     }];

}

-(void)captureBlurToImageView:(UIImageView *)imageView{
    
    if([_momunt count]<1){
        NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"blurImage"];
        UIImage *blur = [UIImage imageWithData:imageData];
        if(blur){
            _galleryBlur.image = blur;
        }else{
            _galleryBlur.image = [UIImage imageNamed:@"backgoundblur"];
            self.blurImageView.image = [UIImage imageNamed:@"backgoundblur"];
        }
        return;
    }
    
    // capture size of full screen
//    UIGraphicsBeginImageContext(CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT));
    CGFloat height = self.collectionView.contentSize.height > SCREEN_HEIGHT ? SCREEN_HEIGHT : self.collectionView.contentSize.height;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(SCREEN_WIDTH, height), YES, 0.25);
    CGContextRef resizedContext = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(resizedContext, kCGInterpolationNone);
    
    // shift context based on current offset of the collection view to capture the part that is curretnly visible.
    // Mandatory shift of 70px to cover area under the top bar. This is not a final solution..
//    CGContextTranslateCTM(resizedContext, 0, 70-MAX(self.collectionView.contentOffset.y,70));
     CGContextTranslateCTM(resizedContext, 0, -self.collectionView.contentOffset.y);
    
    CGPoint savedContentOffset = self.collectionView.contentOffset;
    CGRect savedFrame = self.collectionView.frame;

    // set min top offset of 70 and frame = screen size
//    self.collectionView.contentOffset = CGPointMake(0,MAX(self.collectionView.contentOffset.y,70));
//    self.collectionView.frame = CGRectMake(0,0,self.collectionView.contentSize.width, self.collectionView.contentSize.height);
    self.collectionView.frame = CGRectMake(0,0,self.collectionView.contentSize.width, SCREEN_HEIGHT );
    
//    NSDate *start = [NSDate date];
    
    // Take screenshot
    [self.collectionView.layer renderInContext:resizedContext];
    
//    NSDate *methodFinish = [NSDate date];
//    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
//    NSLog(@"renderInContext Execution Time: %f", executionTime);
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    // DOWNSAMPLE
    UIGraphicsBeginImageContext(CGSizeMake(self.view.bounds.size.width/8, self.view.bounds.size.height/8));
    [viewImage drawInRect:CGRectMake(0,0,self.view.bounds.size.width/8, self.view.bounds.size.height/8)];
    viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    
    // set offset and frame back to original
    self.collectionView.contentOffset = savedContentOffset;
    self.collectionView.frame = savedFrame;
    
    // blur image
    [self.blurImageView setFrame:CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT)];
    UIImage *img = [viewImage applyLightEffectWithRadius:7];
    imageView.image = img;
    _galleryBlur.image = img;
    
//    NSData* imageData = UIImagePNGRepresentation(img);
//    NSData* myEncodedImageData = [NSKeyedArchiver archivedDataWithRootObject:imageData];
    [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(img) forKey:@"blurImage"];


}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods


- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_pullRefreshHeaderView PullRefreshScrollViewDataSourceDidFinishedLoading:self.collectionView];
	
}
#pragma mark - UIScrollViewDelegate

/*
    Store currentOffsetY on vertical scroll
*/
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*
     Check scroll threshold to see if should show/hid nav buttons at the bottom
     Hide when scrolling down. Show when scrolling up
     */
    CGFloat diff = abs(_startScrollOffset - scrollView.contentOffset.y);
    if (diff>40 && _startScrollOffset > scrollView.contentOffset.y && scrollView.contentOffset.y>0){
        // scrolled up
        [self showNavigation];
        _startScrollOffset = scrollView.contentOffset.y;
    }else if (diff>40 && _startScrollOffset <= scrollView.contentOffset.y){
        // scrolled down
        [self hideNavigation];
        _startScrollOffset = scrollView.contentOffset.y;
    }
    self.currentOffsetY = scrollView.contentOffset.y;

    
    if(!self.cameraVC.previewImageView.hidden && self.cameraVC.previewImageView.frame.size.width<SCREEN_WIDTH){
        // have the previw image follow the cell while it is animating
        // calculate dimensions..
        NSIndexPath *indexpath = [NSIndexPath indexPathForItem:0 inSection:0];
        UICollectionViewCell *currCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"galleryCell" forIndexPath:indexpath];
        CGPoint targetCenter = CGPointMake(currCell.center.x, currCell.center.y+self.galleryTopOffset-self.currentOffsetY);
        self.cameraVC.previewImageView.center = targetCenter;
    }
    
    // Only animate loader if pulling view down with finger or if coming back after being pulled down with finger:
    if(!scrollView.isTracking && _pullRefreshHeaderView.alpha==0.0)
        return;
    

    // move map background view
//    self.mapBackgroundView.clipsToBounds = YES;
//    self.mapBackgroundView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + 35.0 - scrollView.contentOffset.y + 0.0);
    
    if( scrollView.contentOffset.y >0){ _collectionView.backgroundColor = [UIColor whiteColor];}
    else{ _collectionView.backgroundColor = [UIColor clearColor];}
    
    if(scrollView.contentOffset.y > 0){
        [self hideTooltip];
    }
    else if(scrollView.isTracking){
        _tooltip.text = [NSString stringWithFormat:@"Refresh photos at %@",  _myMomunt.name];
    }
    
    if([_myMomunt.type isEqualToString:@"pile"]){
        // can't refresh a pile momunt
        _tooltip.text = @"this is a collection";
        return;
    }

    if(scrollView.isTracking && scrollView.contentOffset.y <= -30.0f){
        
        // make tooltip follow the top of the collection view
        //            _tooltip.center = CGPointMake(_tooltip.center.x, scrollView.frame.origin.y - scrollView.contentOffset.y - 15.0);
        _tooltip.transform = CGAffineTransformMakeTranslation(0, -(scrollView.contentOffset.y+40));
    }else if(scrollView.isTracking){
        _tooltip.transform = CGAffineTransformMakeTranslation(0, -10);
    }
    
    if(scrollView.contentOffset.y <= -40.0f){
        [_pullRefreshHeaderView setAlpha:1.0f];
        [self.dropDownView setAlpha:0.0f];
        self.collectionView.backgroundColor = [UIColor clearColor];
        
        
    }
    else{
        if(_pullRefreshHeaderView.state != MMNTPullRefreshLoading && !_pullRefreshHeaderView.spinning){
            [self.dropDownView setAlpha:1.0f];
            [_pullRefreshHeaderView setAlpha:0.0f];
        }
    }
    [_pullRefreshHeaderView PullRefreshScrollViewDidScroll:scrollView force:NO];
    
    if (_collectionView.contentOffset.y  > 0 && _collectionView.contentOffset.y >= (_collectionView.contentSize.height - _collectionView.bounds.size.height))
    {
        NSLog(@"bounced at the bottom");
        if(![MTReachabilityManager isReachable])
            return;
        if(!_shouldLoadMore){
            _shouldLoadMore = YES;
            [_collectionView reloadData];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if([_myMomunt.type isEqualToString:@"pile"]){
        // can't refresh a pile momunt
        _tooltip.text = @"this is a collection";
        
        // show tooltip for a sec, then scroll up
        [UIView animateWithDuration:0.3 animations:^{
            _tooltip.transform = CGAffineTransformIdentity;
            _collectionView.transform = CGAffineTransformMakeTranslation(0, 40);
        }completion:^(BOOL finished) {
            _collectionView.backgroundColor = [UIColor whiteColor];
            [UIView animateWithDuration:0.2 delay:0.8 options:UIViewAnimationOptionCurveLinear animations:^{
                _collectionView.transform = CGAffineTransformIdentity;
            } completion:nil];
        }];
        
        return;
    }
    
	[_pullRefreshHeaderView PullRefreshScrollViewDidEndDragging:scrollView];
    
     scrollView.backgroundColor = [UIColor whiteColor];
    
	
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if(![[MMNTAccountManager sharedInstance] isTaskDone:103]){ // PULL DOWN TO LOAD MOMUNT){
        return;
    }
}

-(void) PullRefreshHeaderDidTriggerRefresh:(MMNTPullRefreshHeader*)view{
    [Amplitude logEvent:@"pulled to refresh"];
    // ask mmntDataController to fetch a new momunt. And listen for changes
    _reloading = YES;
    _loadedStoredMomunt = NO;
    
    // refresh current momunt!
//    [[MMNTDataController sharedInstance] refreshMomunt]; // before - load user current momunt
    [[MMNTDataController sharedInstance] fetchMomuntAtCoordinate:CLLocationCoordinate2DMake(_myMomunt.lat, _myMomunt.lng) andTime:[NSDate date] source:@"refresh"];
    
    // make tooltip follow the top of the collection view
    _tooltip.text = [NSString stringWithFormat:@"Loading new photos at %@",  _myMomunt.name];
    [UIView animateWithDuration:0.3 animations:^{
        _tooltip.transform = CGAffineTransformIdentity;
        _collectionView.transform = CGAffineTransformMakeTranslation(0, 40);
    }];
    
}

- (void) PullRefreshHeaderDidFinishLoading:(MMNTPullRefreshHeader*)view{
    [self.dropDownView setAlpha:1.0f];
    [_pullRefreshHeaderView setAlpha:0.0f];
    // if no momunt loaded -> still show background map
    if([_momunt count]>0){
        self.collectionView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];  // white background
    }
}

- (BOOL) PullRefreshHeaderDataSourceIsLoading:(MMNTPullRefreshHeader*)view{
	return _reloading; // should return if data source model is reloading
}


#pragma mark - Transition Animations
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                presentingController:(UIViewController *)presenting
                                                                     sourceController:(UIViewController *)source{
    
    if([self.currSegue isEqualToString:@"showShareScreen"]){
        // I DON'T KNOW WHY THIS IS CALLED INSTEAD OF self.shareViewsManager ????????? Oh well.. this works for now.
        
        self.shareViewsManager.tduration = 0.3;
        self.shareViewsManager.maxDelay = 0.2;
        self.shareViewsManager.operation = Present;
        return self.shareViewsManager;


    }
    else if([self.currSegue isEqualToString:@"zoomIn"]){ // zoomIn
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        
        MMNT_ZoomIn_Transition *animator = [MMNT_ZoomIn_Transition transitionWithSelectedCell:_selectedCell];
        animator.presenting = YES;
        return animator;
    }
    else if([self.currSegue isEqualToString:@"MapToGallery"]){
        return [MMNT_MapToGalleryTransition transitionWithOperation:@"present"];
    }
    else{ //([self.currSegue isEqualToString:@"LoadingToGallery"]){
        // default to simple fade
        return [MMNT_FadeOutTransition transitionWithOperation:@"present"];
    }
    
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    if(!_reloading){
        [self hideTooltip];
    }
    if(!_removedItem){
        [self showNavigation];
    }
    
    if([self.currSegue isEqualToString:@"showShareScreen"]){
        self.shareViewsManager.tduration = 0.3;
        self.shareViewsManager.maxDelay = 0.2;
        self.shareViewsManager.operation = Dismiss;
        return self.shareViewsManager;
    }
//    else if([self.currSegue isEqualToString:@"dropDown"]){
//        
//        MMNTVerticalDropTransition *animator = [MMNTVerticalDropTransition new];
//        return animator;
//    }
    else if([self.currSegue isEqualToString:@"zoomIn"]){
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        
        MMNT_ZoomIn_Transition *animator = [MMNT_ZoomIn_Transition new];
        animator.presenting = NO;
        return animator;
    }
    else{
        return nil;
    }
}

//// Implement these 2 methods to perform interactive transitions
//- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator{
//    return nil;
//}
//
//- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator{
//    return nil; // We don't want to use interactive transition to dismiss the modal view, we are just going to use the standard animator.
//}

-(void)removedImageAtIndex:(NSInteger)index{
    

    self.removedItem = _momunt[index];
    self.removedItemIdx = index;
    [self.momunt removeObjectAtIndex:index];
    
    // update MomuntID
    self.shouldUpdateMomuntId = self.shouldUpdateMomuntId + (self.removedItem.uploading ? -1 : 1); // -1 if removed an uploaded image. +1 if removed a regular image
        
    NSIndexPath *indexpath = [NSIndexPath indexPathForItem:index inSection:0];
    NSArray *paths = [NSArray arrayWithObjects:indexpath, nil];
    [self.collectionView deleteItemsAtIndexPaths:paths];
    
    // if user photo - show trash icon. Else - flag icon
    NSInteger userId = [self.removedItem.user integerValue];
    if(userId == [[MMNTAccountManager sharedInstance] userId]){
        self.trashButton.hidden = NO;
        self.flagButton.hidden = YES;
    }else{
        self.trashButton.hidden = YES;
        self.flagButton.hidden = NO;
    }
    
//    self.trashView.trashX.hidden = YES;
//    self.trashView.trashUndo.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
//    self.trashView.transform = CGAffineTransformMakeTranslation(0, -90);
//    
//    self.trashView.trashUndo.hidden = NO;
//    
//    POPSpringAnimation *scaleUndo = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
//    scaleUndo.toValue = [NSValue valueWithCGPoint: CGPointMake(1, 1)] ;
//    scaleUndo.springBounciness = 15;
//    scaleUndo.springSpeed = 15;
//    scaleUndo.completionBlock = ^(POPAnimation *animation, BOOL finished){
//    };
//    [self.trashView.trashUndo pop_addAnimation:scaleUndo forKey:@"scale"];
    
    [self hideNavigation];
//    
    [MMNT_SharedVars runPOPSpringAnimation:kPOPLayerTranslationXY
                                    onLayer:_trashView.layer
                                   toValue:[NSValue valueWithCGPoint:CGPointMake(0, -100)]
                          springBounciness:10
                               springSpeed:10
                                     delay:0
                                    forKey:@"transform"
                                completion:^(BOOL finished) {
                                    //
                                }];
    
}
- (void)MMNTTrashViewPressedUndo:(MMNT_TrashView*)view{
    // scroll back to position if needed
    float delay = 0;
    if(_momunt.count>0){
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:MIN(self.removedItemIdx,self.momunt.count) inSection:0];
        UICollectionViewCell *currCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"galleryCell" forIndexPath:indexPath];
    
        if(currCell.center.y < self.currentOffsetY || currCell.center.y > self.currentOffsetY+self.view.frame.size.height-70){
            // scroll to correct position
            CGFloat y;
            CGFloat h = self.collectionView.frame.size.height;
            CGFloat maxH = ceilf(self.momunt.count/3) * currCell.frame.size.height;
            if(currCell.center.y < h/2){
                y = 0;
            }else if(currCell.center.y > maxH-h/2){
                y = maxH-h;
            }else{
                y = currCell.center.y - h/2;
            }
            [self.collectionView scrollRectToVisible:CGRectMake(0, y, self.view.frame.size.width, h) animated:YES];
        
            delay = delay+0.5;
        }
    }

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.momunt insertObject:self.removedItem atIndex:self.removedItemIdx];
        self.removedItem = nil;
        // hide trash view
        [UIView animateWithDuration:0.3 animations:^{
            self.trashView.transform = CGAffineTransformIdentity;
        }];
        [self showNavigation];

    
            NSIndexPath *indexpath = [NSIndexPath indexPathForItem:self.removedItemIdx inSection:0];
            NSArray *paths = [NSArray arrayWithObjects:indexpath, nil];
            [self.collectionView insertItemsAtIndexPaths:paths];
    });
    
    // update MomuntID
    self.shouldUpdateMomuntId = self.shouldUpdateMomuntId+ (self.removedItem.uploading ? +1 : -1); // +1 if returend an added image -1 if returned a regular image
    
}

- (void)killScroll
{
    CGPoint offset = self.collectionView.contentOffset;
    [self.collectionView setContentOffset:offset animated:NO];
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"Touches began!");
//}
- (IBAction)pressedTrashFlag:(id)sender {
    // show confirmation alert
    UIAlertView *updateAlert = [[UIAlertView alloc] initWithTitle:@"Flag" message: @"Flag content as inappropriate?" delegate:self cancelButtonTitle:@"Flag"  otherButtonTitles:@"Cancel",nil];
    _alertShowing = YES;
    [updateAlert show];
    

}

- (IBAction)pressedTrashUndo:(id)sender {
    // scroll back to position if needed
    float delay = 0;
    if(_momunt.count>0){
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:MIN(self.removedItemIdx,self.momunt.count) inSection:0];
        UICollectionViewCell *currCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"galleryCell" forIndexPath:indexPath];
        
        if(currCell.center.y < self.currentOffsetY || currCell.center.y > self.currentOffsetY+self.view.frame.size.height-70){
            // scroll to correct position
            CGFloat y;
            CGFloat h = self.collectionView.frame.size.height;
            CGFloat maxH = ceilf(self.momunt.count/3) * currCell.frame.size.height;
            if(currCell.center.y < h/2){
                y = 0;
            }else if(currCell.center.y > maxH-h/2){
                y = maxH-h;
            }else{
                y = currCell.center.y - h/2;
            }
            [self.collectionView scrollRectToVisible:CGRectMake(0, y, self.view.frame.size.width, h) animated:YES];
            
            delay = delay+0.5;
        }
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.momunt insertObject:self.removedItem atIndex:self.removedItemIdx];
        self.removedItem = nil;
        // hide trash view
        [UIView animateWithDuration:0.3 animations:^{
            self.trashView.transform = CGAffineTransformIdentity;
        }];
        
        
        NSIndexPath *indexpath = [NSIndexPath indexPathForItem:self.removedItemIdx inSection:0];
        NSArray *paths = [NSArray arrayWithObjects:indexpath, nil];
        [self.collectionView insertItemsAtIndexPaths:paths];
    });
    
    // update MomuntID
    self.shouldUpdateMomuntId = self.shouldUpdateMomuntId+ (self.removedItem.uploading ? +1 : -1); // +1 if returend an added image -1 if returned a regular image
    
    [self showNavigation];
}

- (IBAction)pressedTrashTrash:(id)sender {
    
    // show confirmation alert
    UIAlertView *updateAlert = [[UIAlertView alloc] initWithTitle:@"Delete" message: @"Delete this photo from Momunt?" delegate:self cancelButtonTitle:@"Delete"  otherButtonTitles:@"Cancel",nil];
    _alertShowing = YES;
    [updateAlert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    _alertShowing = NO;
    
    if(buttonIndex==0 && [alertView.title isEqualToString:@"Flag"])
    {
        
        // hide trash view
        [UIView animateWithDuration:0.3 animations:^{
            self.trashView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self showNavigation];
        }];
        
        
        // send flag request
        [[MMNTApiCommuniator sharedInstance] flagRequest:self.removedItem];
        
    }
    else if(buttonIndex==0 && [alertView.title isEqualToString:@"Delete"])
    {
        
        // hide trash view
        [UIView animateWithDuration:0.3 animations:^{
            self.trashView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self showNavigation];
        }];
        
        // delete photo from Momunt
        [[MMNTApiCommuniator sharedInstance] deletePhoto:self.removedItem];
        
    }
    else if(buttonIndex==0 && [alertView.title isEqualToString:@"Sign In With Instagram?"]){
        // set instagram auth to = 2: don't use instagram
        NSInteger status = alertView.tag == 101 ? 2 : 1; //tag==101 : i dont use instagram. tag==100 - not now. Will change back to 3 next time you load a momunt
        [MMNTAccountManager sharedInstance].authInstagram = status;
        if(status==2){
            [[MMNTApiCommuniator sharedInstance] authenticate:@"instagram" status:2 withToken:@"" setName:@""];
        }
        
    }
    else if(buttonIndex==1 && [alertView.title isEqualToString:@"Sign In With Instagram?"]){
        // present Instagram sign in
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        MMNT_InstagramSignInViewController *instagramVC = (MMNT_InstagramSignInViewController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"instagramSignIn"];
        instagramVC.type = @"signin";
        instagramVC.modalPresentationStyle = UIModalPresentationCustom;
        instagramVC.transitioningDelegate = instagramVC;
        self.transitioningDelegate = instagramVC;
        [self presentViewController:instagramVC animated:YES completion:nil];
    }
    
}

#pragma mark MMNTHelpTasks

-(void)restartTipTimer:(NSNotification *) notif{
    _isActive = NO;
    
    if(_tipTimer){
        [_tipTimer invalidate];
    }
    _tipTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(showNextTip) userInfo:nil repeats:NO];
    
}
-(void)showNextTip:(NSNotification *) notif{
    
    
    
    if(_isActive || _alertShowing){return;}
    if(_reloading && self.dropState == DropViewClosed){return;}
    
    // if already presenting a modal controller - return
    BOOL modalPresent = self.presentedViewController != nil;
    if(modalPresent){
        if([self.presentedViewController isKindOfClass:[MMNTZoomViewController class]] ){
//            MMNTZoomViewController *vc = (MMNTZoomViewController *)self.presentedViewController;
//            [vc showMapTip];
            [(MMNTZoomViewController *)self.presentedViewController showMapTip];
        }else{
            return;
        }
    }
    
    // Dont show any other tips in this version
    return;
    
    
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//    MMNT_OnboardingVC *tipVC = (MMNT_OnboardingVC *)[mainStoryboard instantiateViewControllerWithIdentifier: @"onboarding"];
//    tipVC.taskId = 201;
//    tipVC.parent = self;
//    [tipVC show];
    
    if(!_galleryBlur){
        _galleryBlur = [[UIImageView alloc] initWithFrame:self.view.frame];
        [self captureBlurToImageView:_galleryBlur];
    }
    
    // Check if need to show help prompts
    // 2 = swipe left to share the momunt
    // 3 = swipe right to add a picture to the momunt
    // 4 = tap momunt button to access menu
    
    if(self.dropState == DropViewOpen){
//        // here are the top momunts DONT NEED THIS
//        if(![[MMNTAccountManager sharedInstance] isTaskDone:101]){
//            _helpTaskVC = [[MMNT_HelpTasksController alloc] init];
//            _helpTaskVC.delegate = self;
//            _helpTaskVC.helpText = @"Here are the top momunts from around the world.";
//            _helpTaskVC.position = @"top";
//            _helpTaskVC.taskType = @"tip";
//            _helpTaskVC.taskId = 101;
//            CGImageRef imageRef = CGImageCreateWithImageInRect([_galleryBlur.image CGImage], CGRectMake(0, _galleryBlur.image.size.height*0.85, _galleryBlur.image.size.width, _galleryBlur.image.size.height*0.15));
//            _helpTaskVC.blurImage = [UIImage imageWithCGImage:imageRef];
//            CGImageRelease(imageRef);
//            _helpTaskVC.parentVC = self;
//            // present modal controller
//            [_helpTaskVC show];
//            
//        }
//
        // only need to show 9 = Tap momunt button to return to gallery
        if(![[MMNTAccountManager sharedInstance] isTaskDone:102]){
            // tap on momunt logo button
            
            _helpTaskVC = [[MMNT_HelpTasksController alloc] init];
            _helpTaskVC.delegate = self;
            _helpTaskVC.fromPoint = CGPointMake(SCREEN_WIDTH/2,SCREEN_HEIGHT-25);
            _helpTaskVC.toPoint = CGPointMake(SCREEN_WIDTH/2,SCREEN_HEIGHT-25);
            _helpTaskVC.helpText = @"Press the momunt button to go to your gallery.";
            _helpTaskVC.position = @"top";
//            _helpTaskVC.targetPoint = CGPointMake(SCREEN_WIDTH/2,SCREEN_HEIGHT-25);
            _helpTaskVC.targetArea = CGRectMake(0, SCREEN_HEIGHT-70, SCREEN_WIDTH, 70);
            _helpTaskVC.taskType = @"tap";
            _helpTaskVC.taskId = 102;
            _helpTaskVC.passArea = CGRectMake(0,80,SCREEN_WIDTH, SCREEN_HEIGHT-200);
            CGImageRef imageRef = CGImageCreateWithImageInRect([_galleryBlur.image CGImage], CGRectMake(0, _galleryBlur.image.size.height*0.85, _galleryBlur.image.size.width, _galleryBlur.image.size.height*0.15));
            _helpTaskVC.blurImage = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
            _helpTaskVC.parentVC = self;
            // present modal controller
            [_helpTaskVC show];
        }
        return;
    }
    
    if([_momunt count]<1){
        return;
    }
    
    // if in camera - dont show tips
    if(_collectionView.center.x == SCREEN_WIDTH*3/2){
        return;
    }
    
    
//    if(![[MMNTAccountManager sharedInstance] isTaskDone:104]){ // SWIPE LEFT TO SHARE
//        // swipe left to share
//        
//        MMNT_HelpTasksController *helpVC = [[MMNT_HelpTasksController alloc] init];
//        helpVC.delegate = self;
//        helpVC.fromPoint = CGPointMake(250,SCREEN_HEIGHT*0.5);
//        helpVC.toPoint = CGPointMake(70,SCREEN_HEIGHT*0.5);
//        helpVC.helpText = @"Swipe left to save or share your momunt.";
//        helpVC.position = @"top";
//        helpVC.targetMotion = CGPointMake(-150, 0);
//        helpVC.taskType = @"swipe";
//        helpVC.taskId = 104;
//        CGImageRef imageRef = CGImageCreateWithImageInRect([_galleryBlur.image CGImage], CGRectMake(0, _galleryBlur.image.size.height*0.85, _galleryBlur.image.size.width, _galleryBlur.image.size.height*0.15));
//        helpVC.blurImage = [UIImage imageWithCGImage:imageRef];
//        CGImageRelease(imageRef);
//        
//        /*SETUP TO SHARE THE MOMUNT*/
//        MMNTDataController *mmntDataController = [MMNTDataController sharedInstance];
//        mmntDataController.toShareMomunt = mmntDataController.currentMomunt;
//        if(![_momunt isEqualToArray:[MMNTDataController sharedInstance].currentMomunt.body] ){
//            mmntDataController.toShareMomunt.body = _momunt;
//            mmntDataController.toShareMomunt.momuntId = [[MMNTDataController sharedInstance] uniqueId];
//            mmntDataController.toShareMomunt.timestamp = [NSDate date]; // does not really matter... just stores when the momunt was saved
//            mmntDataController.toShareMomunt.ownerId = [MMNTAccountManager sharedInstance].userId;
//        }
//        
//        // set poster image to first image in _momunt
//        MMNTPhoto *first = [_momunt objectAtIndex:0];
//        NSString *poster = [[[first valueForKey:@"images"] valueForKey:@"standard_resolution"] valueForKey:@"url"];
//        mmntDataController.toShareMomunt.poster = poster;
//        
//        mmntDataController.sharePile = NO;
//        
//        // hide trash view
//        [UIView animateWithDuration:0.3 animations:^{
//            self.trashView.transform = CGAffineTransformIdentity;
//        }];
//        
//        
//        /*ADD SHARE CONTROLLER TO STACK BELOW HELP VC*/
//        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//        MMNTShareViewController *shareVC = (MMNTShareViewController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"shareScreen"];
//        self.shareViewsManager.modalController = shareVC;
//        self.shareViewsManager.modalController.transitioningDelegate = self;
//        self.shareViewsManager.modalController.modalPresentationStyle = UIModalPresentationCustom;
//        
//        self.transitioningDelegate = self.shareViewsManager;
//        self.currSegue = @"showShareScreen";
//        
//        
//        // capture the blur
//        dispatch_async(dispatch_get_main_queue(), ^{
//            shareVC.blurContainer.alpha = 0.0f;
//            [self captureBlurToImageView:shareVC.blurContainer.imageView];
//            [shareVC setBlurAlpha:1.0f];
//        });
//        
//        // Present the VCs
//        shareVC.view.alpha = 0; // Set alpha to zero so that we can see the imageView
//        [self presentViewController:shareVC animated:NO completion:^{
//            [shareVC presentViewController:helpVC animated:NO completion:^{
//                POPSpringAnimation *move = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
//                move.toValue = [NSValue valueWithCGPoint:CGPointMake(_collectionView.center.x, _collectionView.center.y+80)] ;
//                move.springBounciness = 1;
//                move.springSpeed = 5;
//                [_collectionView pop_addAnimation:move forKey:@"position"];
//            }];
//        }];
//        
//        
//    }
    else if(![[MMNTAccountManager sharedInstance] isTaskDone:103] && !_selectedMyMomunt){ // PULL DOWN TO LOAD MOMUNT
        // check that didn get here from "my momunt"
        MMNT_HelpTasksController *helpVC = [[MMNT_HelpTasksController alloc] init];
        helpVC.delegate = self;
        helpVC.fromPoint = CGPointMake(SCREEN_WIDTH*0.5, 250);
        helpVC.toPoint = CGPointMake(SCREEN_WIDTH*0.5, SCREEN_HEIGHT-100);
        helpVC.helpText = @"Pull down to load your current momunt.";
        helpVC.position = @"top";
        helpVC.targetMotion = CGPointMake(0, 79);
        helpVC.taskType = @"swipe";
        helpVC.taskId = 103;
        CGImageRef imageRef = CGImageCreateWithImageInRect([_galleryBlur.image CGImage], CGRectMake(0, _galleryBlur.image.size.height*0.85, _galleryBlur.image.size.width, _galleryBlur.image.size.height*0.15));
        helpVC.blurImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        // present modal controller
        //        [helpVC show];
        helpVC.modalPresentationStyle = UIModalPresentationCustom;
        helpVC.transitioningDelegate = helpVC;
        [self presentViewController:helpVC animated:NO completion:^{
            POPSpringAnimation *move = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
            move.toValue = [NSValue valueWithCGPoint:CGPointMake(_collectionView.center.x, _collectionView.center.y+80)] ;
            move.springBounciness = 1;
            move.springSpeed = 5;
            [_collectionView pop_addAnimation:move forKey:@"position"];
        }];
        
        
    }
//    else if(![[MMNTAccountManager sharedInstance] isTaskDone:105] && ([[MMNTAccountManager sharedInstance] isTaskDone:103] || _selectedMyMomunt) ){ // SWIPE RIGHT TO CAMERA ONLY SHOW AFTER LOADED YOUR OWN CURRENT MOMUNT
//        // swipe right to add photo
//        
//        MMNT_HelpTasksController *helpVC = [[MMNT_HelpTasksController alloc] init];
//        helpVC.delegate = self;
//        helpVC.fromPoint = CGPointMake(40,SCREEN_HEIGHT*0.5);
//        helpVC.toPoint = CGPointMake(250,SCREEN_HEIGHT*0.5);
//        helpVC.helpText = @"Swipe right to add photos to your current momunt.";
//        helpVC.position = @"top";
//        helpVC.targetMotion = CGPointMake(150, 0);
//        helpVC.taskType = @"swipe";
//        helpVC.taskId = 105;
//        CGImageRef imageRef = CGImageCreateWithImageInRect([_galleryBlur.image CGImage], CGRectMake(0, _galleryBlur.image.size.height*0.85, _galleryBlur.image.size.width, _galleryBlur.image.size.height*0.15));
//        helpVC.blurImage = [UIImage imageWithCGImage:imageRef];
//        CGImageRelease(imageRef);
//        
//        // present modal controller
//        //        [helpVC show];
//        helpVC.modalPresentationStyle = UIModalPresentationCustom;
//        helpVC.transitioningDelegate = helpVC;
//        [self presentViewController:helpVC animated:NO completion:^{
//            POPSpringAnimation *move = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
//            move.toValue = [NSValue valueWithCGPoint:CGPointMake(_collectionView.center.x, _collectionView.center.y+80)] ;
//            move.springBounciness = 1;
//            move.springSpeed = 5;
//            [_collectionView pop_addAnimation:move forKey:@"position"];
//        }];
//        
//    }
    else if(![[MMNTAccountManager sharedInstance] isTaskDone:106]){ // MOMUNT BTN TO ACCESS MENU
        // tap on momunt logo button
        
        MMNT_HelpTasksController *helpVC = [[MMNT_HelpTasksController alloc] init];
        helpVC.delegate = self;
        helpVC.fromPoint = CGPointMake(SCREEN_WIDTH/2,40);
        helpVC.toPoint = CGPointMake(SCREEN_WIDTH/2,40);
        helpVC.helpText = @"Press the momunt button to return to menu.";
        helpVC.position = @"top";
//        helpVC.targetPoint = CGPointMake(SCREEN_WIDTH/2,40);
        helpVC.targetArea = CGRectMake(0, 0, SCREEN_WIDTH, 80);
        helpVC.taskType = @"tap";
        helpVC.taskId = 106;
        CGImageRef imageRef = CGImageCreateWithImageInRect([_galleryBlur.image CGImage], CGRectMake(0, _galleryBlur.image.size.height*0.85, _galleryBlur.image.size.width, _galleryBlur.image.size.height*0.15));
        helpVC.blurImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        // present modal controller
        //        [helpVC show];
        helpVC.modalPresentationStyle = UIModalPresentationCustom;
        helpVC.transitioningDelegate = helpVC;
        [self presentViewController:helpVC animated:NO completion:^{
            POPSpringAnimation *move = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
            move.toValue = [NSValue valueWithCGPoint:CGPointMake(_collectionView.center.x, _collectionView.center.y+80)] ;
            move.springBounciness = 1;
            move.springSpeed = 5;
            [_collectionView pop_addAnimation:move forKey:@"position"];
        }];
    }
    
    else if( [[MMNTAccountManager sharedInstance] authInstagram]==0 || [[MMNTAccountManager sharedInstance] authInstagram]==3){ // did not register or instagram token invalid
        BOOL invalid = [[MMNTAccountManager sharedInstance] authInstagram]==3;
        // make sure no other tooltip is currently showing..
        // ask user to sign in with instagram
        if(invalid){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign In With Instagram?"
                                                            message:@"Looks like your instagram account changed. For a better Momunt experience, sign in with your new Instagram information."
                                                           delegate:self
                                                  cancelButtonTitle:@"Not now"
                                                  otherButtonTitles:@"Sign In", nil];
            _alertShowing = YES;
            [alert setTag:100];
            [alert show];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign In With Instagram?"
                                                        message:@"For a better Momunt experience, sign in with your Instagram account."
                                                       delegate:self
                                              cancelButtonTitle:@"I don't use instagram"
                                              otherButtonTitles:@"Sign In", nil];
            _alertShowing = YES;
            [alert setTag:101];
            [alert show];
        }
        
    }

}


-(void)MMNTHelpTaskStartedTaskWithId:(CGFloat)taskId{
//     _isActive = YES;
    if(taskId==105){ // SHOW CAMERA
        self.cameraContainer.userInteractionEnabled = YES;
        [self.cameraVC wakeUp];

    }
}

-(void) MMNTHelpTaskFinishedTaskWithId:(CGFloat)taskId{
    [[MMNTDataController sharedInstance] setTaskDone:taskId];    
    if(taskId==104){
        NSLog(@"Should Open Share View!");
        // set up for shared momunt and present shared view from helperVC
        
        _collectionView.center = CGPointMake(_collectionView.center.x, 70+(SCREEN_HEIGHT-70)/2);
        
        [self.shareViewsManager.modalController dismissViewControllerAnimated:YES completion:^{
            self.shareViewsManager.modalController.view.frame = CGRectMake(0,70,SCREEN_WIDTH, SCREEN_HEIGHT-70);
        }];
    }
    else if(taskId ==105 ){ // TRANSITION TO CAMERA
//        _isActive = YES;
        
        POPSpringAnimation *fromA = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
        fromA.toValue = @(SCREEN_WIDTH*3/2);
        fromA.velocity = @(50.0);
        fromA.springBounciness = 0;
        fromA.springSpeed = 20;
        [self.collectionView pop_addAnimation:fromA forKey:@"center"];
        [self.trashView pop_addAnimation:fromA forKey:@"center"];
        
        POPSpringAnimation *cameraCenter = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
        cameraCenter.toValue = @(SCREEN_WIDTH*1/2);
        cameraCenter.velocity = @(50.0);
        cameraCenter.springBounciness = 0;
        cameraCenter.springSpeed = 20;
        [self.cameraContainer pop_addAnimation:cameraCenter forKey:@"center"];
        
        // 2) dismiss helper controller
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
        
        _collectionView.center = CGPointMake(_collectionView.center.x, 70+(SCREEN_HEIGHT-70)/2);

    }
    else if(taskId ==106 ){ // DROP DOWN MENU
        [self dropDownViewTapped:self.dropDownView];
        
        // 2) dismiss helper controller
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
            _collectionView.center = CGPointMake(_collectionView.center.x, 70+(SCREEN_HEIGHT-70)/2);
        });
    }

    else if(taskId ==102){ // PRESS MOMUNT BUTTON TO GO TO GALLERY
        [self dropDownViewTapped:self.dropDownView];
        // 2) dismiss helper controller
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//            [self dismissViewControllerAnimated:YES completion:nil];
            [[self.view.subviews lastObject] removeFromSuperview];
//            [self restartTipTimer];
        });
    }
    else if(taskId==103){ // PULL DOWN TO REFRESH
        
        [_pullRefreshHeaderView PullRefreshScrollViewDidEndDragging:_collectionView];
        
        [UIView animateWithDuration:0.2 animations:^{
            _collectionView.contentOffset = CGPointMake(0, -20);
            _pullRefreshHeaderView.center = CGPointMake(_pullRefreshHeaderView.center.x , _pullRefreshHeaderView.center.y);

        }];
        
        // 2) dismiss helper controller
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
            
            POPSpringAnimation *move = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
            move.toValue = [NSValue valueWithCGPoint:CGPointMake(_collectionView.center.x, 70+(SCREEN_HEIGHT-70)/2)] ;
            move.springBounciness = 1;
            move.springSpeed = 5;
            [_collectionView pop_addAnimation:move forKey:@"position"];
        });

        
    }
    else{
        if([_helpTaskVC.taskType isEqualToString:@"tip"]){
            [_helpTaskVC hide];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [[self.view.subviews lastObject] removeFromSuperview];
//                [self restartTipTimer];
            });
            
            return;
        }
        // dismiss helper controller
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
//        [self restartTipTimer];
//        });
    }
}
-(void) MMNTHelpTaskCancelledTaskWithId:(CGFloat)taskId{
//    [self restartTipTimer];
    if(taskId==105){ // SHOW CAMERA
        POPSpringAnimation *fromA = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
        fromA.toValue = @( SCREEN_WIDTH*1/2);
        fromA.velocity = @(50);
        fromA.springBounciness = 0;
        fromA.springSpeed = 20;
        [self.collectionView pop_addAnimation:fromA forKey:@"center"];
        [self.trashView pop_addAnimation:fromA forKey:@"center"];
        
        POPSpringAnimation *cameraCenter = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
        cameraCenter.toValue = @( -SCREEN_WIDTH*1/2);
        cameraCenter.velocity = @(50);
        cameraCenter.springBounciness = 0;
        cameraCenter.springSpeed = 20;
        [self.cameraContainer pop_addAnimation:cameraCenter forKey:@"center"];
        
//        POPSpringAnimation *move = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
//        move.toValue = [NSValue valueWithCGPoint:CGPointMake(_collectionView.center.x, 70+(SCREEN_HEIGHT-70)/2)] ;
//        move.springBounciness = 1;
//        move.springSpeed = 5;
//        [_collectionView pop_addAnimation:move forKey:@"position"];

    }
    else if(taskId==103){
        [_pullRefreshHeaderView PullRefreshScrollViewDidEndDragging:_collectionView];
        [UIView animateWithDuration:0.2 animations:^{
            _collectionView.contentOffset = CGPointMake(0, 0);
            _pullRefreshHeaderView.center = CGPointMake(_pullRefreshHeaderView.center.x , _pullRefreshHeaderView.center.y);
        }];
    }
}

-(void)MMNTHelpTaskId:(NSInteger)taskId completedWithPercent:(CGFloat)percent{
    if(taskId==105){ // SHOW CAMERA
        self.collectionView.layer.position = CGPointMake(SCREEN_WIDTH/2+SCREEN_WIDTH*percent, self.collectionView.center.y);
        self.trashView.layer.position = CGPointMake(SCREEN_WIDTH/2+SCREEN_WIDTH*percent, self.trashView.center.y);
        self.cameraContainer.layer.position = CGPointMake(-SCREEN_WIDTH/2+SCREEN_WIDTH*percent, SCREEN_HEIGHT/2);
    }
    else if(taskId==103){
        
        _collectionView.contentOffset = CGPointMake(0, -80*percent);
        
        
        // move map background view
        self.mapBackgroundView.clipsToBounds = YES;
        self.mapBackgroundView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + 35.0 - _collectionView.contentOffset.y + 0.0);
        
        if(_collectionView.contentOffset.y <= -20.0f){
            [_pullRefreshHeaderView setAlpha:1.0f];
            [self.dropDownView setAlpha:0.0f];
            self.collectionView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.0];  // clear background
        }else{
            if(_pullRefreshHeaderView.state != MMNTPullRefreshLoading && !_pullRefreshHeaderView.spinning){
                [self.dropDownView setAlpha:1.0f];
                [_pullRefreshHeaderView setAlpha:0.0f];
            }
        }
        [_pullRefreshHeaderView PullRefreshScrollViewDidScroll:_collectionView force:YES];
    }
}
-(void)MMNTHelpTaskSkippedTaskWithId:(CGFloat)taskId{
    [[MMNTDataController sharedInstance] setTaskDone:taskId];
    if(taskId==101 || taskId==102){ //
        [[self.view.subviews lastObject] removeFromSuperview];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    POPSpringAnimation *move = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    move.toValue = [NSValue valueWithCGPoint:CGPointMake(_collectionView.center.x, 70+(SCREEN_HEIGHT-70)/2)] ;
    move.springBounciness = 1;
    move.springSpeed = 5;
    [_collectionView pop_addAnimation:move forKey:@"position"];
    
//    [self restartTipTimer];
}

@end