//
//  MMNTViewController.h
//  Momunt
//
//  Created by Masha Belyi on 6/16/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "MMNTPullRefreshHeader.h"
#import "FXBlurView.h"
#import "MMNT_DropDownView.h"
#import "MMNT_TrashView.h"
#import "MMNT_TransparentView.h"

#import "MMNTShareTransitionManager.h"

#import "MMNT_CameraContainerView.h"
#import "MMNT_MapBlurView.h"

@class MMNTShareTransitionManager;

typedef enum{
    DropViewOpen,
    DropViewClosed,
} DropViewState;


@interface MMNTViewController : UIViewController <CLLocationManagerDelegate, MMNTPullRefreshHeaderDelegate, MKMapViewDelegate, UIActionSheetDelegate>{
    MMNTPullRefreshHeader *_pullRefreshHeaderView;
    
}
@property BOOL reloading;

@property (nonatomic) DropViewState dropState;

- (void)reloadCollectionViewDataSource;
- (void)doneLoadingCollectionViewData;

@property (strong, nonatomic) IBOutlet UIView *blurContainer;
@property (strong, nonatomic) IBOutlet UIImageView *blurImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet MMNT_DropDownView *dropDownView;

@property (strong, nonatomic) IBOutlet MMNT_TransparentView *trashView;
- (IBAction)pressedTrashFlag:(id)sender;
- (IBAction)pressedTrashUndo:(id)sender;
- (IBAction)pressedTrashTrash:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *trashButton;
@property (strong, nonatomic) IBOutlet UIButton *flagButton;
@property (strong, nonatomic) IBOutlet UIButton *undoButton;

@property (strong, nonatomic) MMNT_MapBlurView *mapBackgroundView;


@property UIImageView *galleryBlur;

@property NSString *currSegue; // Identifier of the curernt segue

//- (IBAction)handleSwipeLeft:(id)sender;
- (void) captureBlur;
- (void) unBlur;
- (void) captureBlurWithRadius:(CGFloat)blurRadius time:(CGFloat)animationTime;
-(void)captureBlurToImageView:(UIImageView *)imageView;

@property CGFloat currentOffsetY;
@property CGFloat galleryTopOffset;

@property NSMutableArray *momunt;

@property NSMutableArray *photosToShare; // keep track of photos selected to share in MMNT_ZoomViewController

-(void)removedImageAtIndex:(NSInteger)index;
//@property MMNT_TrashView *trashView;

@property MMNTShareTransitionManager *shareViewsManager;

@property (strong, nonatomic) IBOutlet MMNT_CameraContainerView *cameraContainer;

@property UIPanGestureRecognizer *panRight;
@property BOOL startedPanRight; // used to block panning left for camera view
@property UISwipeGestureRecognizer *swipeLeft;

-(void)swipedLeft:(UISwipeGestureRecognizer *)recognizer;

-(void)uploadImage:(UIImage *)image withLocation:(CLLocation *)location timestamp:(NSDate *)t afterRefresh:(BOOL)willRefresh;
-(void)loadMomuntFromUrl:(NSString *)url;

-(void)setRefreshing;

-(void)showDropDown;

//-(void)returnedToGallery;
-(void)restartTipTimer;
@property NSTimer *tipTimer;

@property BOOL loadedStoredMomunt;


/*
 Navigation Buttons
 */
@property (strong, nonatomic) IBOutlet UIView *navContainer;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIButton *cameraButton;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIButton *momuntButton;

/*
 Tooltip
 */
@property (strong, nonatomic) IBOutlet UILabel *tooltip;


-(void)closeCamera;

@end
