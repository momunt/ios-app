//
//  MMNT_MapBlurView.h
//  Momunt
//
//  Created by Masha Belyi on 1/6/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "UIImage+ImageEffects.h"

@interface MMNT_MapBlurView : UIView <MKMapViewDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UIImageView *mapImageView;
@property (strong, nonatomic) UIView *whiteOverlay;
@property (strong, nonatomic) UITextView *prompt;
@property (strong, nonatomic) UIImageView *arrow;

@property BOOL loadedMap;

-(void)showCurrentLocation;
-(void)setDefaultState;
-(void)promptToAction;

@end
