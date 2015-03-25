//
//  MMNTMapView.m
//  Momunt
//
//  Created by Masha Belyi on 12/16/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNTMapView.h"

@interface MKMapView (Private)
- (void)_setZoomScale:(float)scale centerMapPoint:(CLLocationCoordinate2D)center duration:(double)d animationType:(int)animType;
@end

@implementation MMNTMapView
- (void)_setZoomScale:(float)scale centerMapPoint:(CLLocationCoordinate2D)center duration:(double)d animationType:(int)animType
{
    if (_overridesAnimationDuration) {
        d = _mapAnimationDuration;
    }
    [super _setZoomScale:scale centerMapPoint:center duration:d animationType:animType];
}
@end
