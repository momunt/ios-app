//
//  MMNTMapView.h
//  Momunt
//
//  Created by Masha Belyi on 12/16/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MMNTMapView : MKMapView

@property(nonatomic) BOOL overridesAnimationDuration;
@property(nonatomic) NSTimeInterval mapAnimationDuration;

@end
