//
//  MMNT_MapBlurView.m
//  Momunt
//
//  Created by Masha Belyi on 1/6/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import "MMNT_MapBlurView.h"

@implementation MMNT_MapBlurView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect fullFrame = CGRectMake(0,0,frame.size.width, frame.size.height);
        // MAP
        _mapView = [[MKMapView alloc] initWithFrame:fullFrame];
//        _mapView.hidden = YES;
        _mapView.delegate = self;
        [self addSubview:_mapView];
        
        // IMAGE - will hold the blurred map image
        _mapImageView = [[UIImageView alloc] initWithFrame:fullFrame];
        [self addSubview:_mapImageView];
        _mapImageView.image = [UIImage imageNamed:@"Map"];
        _mapView.contentMode = UIViewContentModeScaleAspectFit;
        
        // TEXT
        _prompt = [[UITextView alloc] initWithFrame:CGRectMake(40,100,frame.size.width-80, 180)];
        _prompt.backgroundColor = [UIColor clearColor];
        _prompt.text = @"pull down to load your momunt.";
        _prompt.textColor = [UIColor whiteColor];
        _prompt.font = [UIFont fontWithName:@"HelveticaNeue" size:32.0];
        _prompt.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_prompt];
        
        // arrow
        _arrow = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,80,80)];
        _arrow.center = CGPointMake(frame.size.width/2, 280);
        _arrow.contentMode = UIViewContentModeScaleAspectFit;
        _arrow.image = [UIImage imageNamed:@"PullDown"];
        [self addSubview:_arrow];
    }
    return self;
}

-(void)showCurrentLocation{
    _loadedMap = NO;
    _mapView.showsUserLocation = YES; // turn on location
}

-(void)setDefaultState{
    _prompt.text = @"loading your momunt.";
    _arrow.hidden = YES;
}

-(void)promptToAction{
    _prompt.text = @"pull down to load your momunt.";
    _arrow.hidden = NO;
}


-(void)setLocationError{
    _prompt.text = @"unable to fetch your location.";
    _arrow.hidden = YES;
}

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    if(_loadedMap){
        return;
    }
    
    _loadedMap = YES;
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 1;
    span.longitudeDelta = 1;
    CLLocationCoordinate2D location;
    location.latitude = aUserLocation.coordinate.latitude;
    location.longitude = aUserLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    
    [_mapView setRegion:region animated:NO]; // prerender zoomed map on hidden view
    _mapView.showsUserLocation = NO;
    
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
    [self captureMapBlur];
}

-(void)captureMapBlur{
    
    // capture map screenshot
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.frame.size.width, self.frame.size.height), YES,1.0);
    CGContextRef resizedContext = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(resizedContext, kCGInterpolationNone);
    
    
    // Take screenshot
    [_mapView.layer renderInContext:resizedContext];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    // DOWNSAMPLE
    UIGraphicsBeginImageContext(CGSizeMake(self.bounds.size.width, self.bounds.size.height));
    [viewImage drawInRect:CGRectMake(0,0,self.bounds.size.width, self.bounds.size.height)];
    viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIColor *tintColor = [UIColor colorWithWhite:0.7 alpha:0.3];
    UIImage *img = [viewImage applyBlurWithRadius:5.0 tintColor:tintColor saturationDeltaFactor:1.5 maskImage:nil];
    _mapImageView.image = img;
    
    // fade in
    [UIView animateWithDuration:0.2 animations:^{
        _mapImageView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{_mapImageView.alpha = 1.0;}];
    }];

}

@end
