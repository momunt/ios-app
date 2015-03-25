//
//  MMNTZoomViewController.h
//  Momunt
//
//  Created by Masha Belyi on 7/5/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MMNTViewController.h"
#import "MMNT_HelpTasksController.h"
#import "MMNTPhoto.h"

@interface MMNTZoomViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UIActionSheetDelegate, MMNTHelpTaskDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *carouselView;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) IBOutlet UIView *mapContainer;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIButton *sourceIcon;
- (IBAction)pressedSourceIcon:(id)sender;
- (IBAction)pressedFollow:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *followIcon;


- (IBAction)closeBtn:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *zoomContainer;
@property (strong, nonatomic) IBOutlet UIView *shareBar;
@property (strong, nonatomic) IBOutlet UIView *fakeLogoBar;
@property (strong, nonatomic) IBOutlet UIView *sharedPicsContainer;

@property UINavigationController *shareNavController;
@property MMNT_BlurContainer *blurContainer;


- (IBAction)pressedSend:(id)sender;
- (IBAction)pressedCancel:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *xImg;
@property (strong, nonatomic) IBOutlet UIImageView *checkImg;
@property (strong, nonatomic) IBOutlet UIButton *xBtn;
@property (strong, nonatomic) IBOutlet UIButton *checkBtn;

@property (strong, nonatomic) IBOutlet MMNT_TransparentView *swipeUpPrompt;

@property (strong, nonatomic) IBOutlet MMNT_TransparentView *pullDownPrompt;


@property NSMutableArray *momunt;
@property MMNTPhoto *currentPhoto;

@property BOOL on; // is view currently showing?
@property NSInteger currentIdx; // current slide idx
@property CGFloat width;
@property NSMutableArray *toShare; // keep track of photo urls selected for sharing

-(void)setData:(NSArray *)array;
-(void)updateMapWithLatitude:(CLLocationDegrees)lat andLongitude:(CLLocationDegrees)lng;
@property BOOL onMap; // Tells if Map view is on
-(void)toggleMapView; // Switch between map and image view

-(void)setUpWithFrame:(CGRect)frame atIndex:(NSInteger)id;
-(void)clickedGallery:(MMNTViewController *)fromVC cell:(UICollectionViewCell *)cell cellId:(NSInteger)idx withSelectedPhotos:(NSMutableArray *)photos;

/*
 LOAD CUSTOM MOMUNT
 */
@property (strong, nonatomic) IBOutlet UIView *customIcon;
@property (strong, nonatomic) IBOutlet UIImageView *customIconImage;
@property CAShapeLayer *outline;


///
// MMNTShareTransitioning protocol
///
-(void)exitingFromShareView;

/*
 TOOLTIP
 */
@property MMNT_HelpTasksController *helpTaskVC;
-(void)showMapTip;

@end

