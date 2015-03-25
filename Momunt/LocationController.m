//
//  LocationController.m
//  Momunt
//
//  Created by Masha Belyi on 9/25/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "LocationController.h"

@implementation LocationController


- (id)init
{
    // THIS RUNS THE 1st TIME APP CALLS [LocationController sharedInstance]
    self = [super init];
    if (self != nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) { // for ios8
            [_locationManager performSelector:@selector(requestWhenInUseAuthorization)];
            // [_locationManager performSelector:@selector(requestAlwaysAuthorization)]; // lets user grant permission to use gps when app is in background. Should not need this..
        }
        _locationManager.pausesLocationUpdatesAutomatically = YES;

    }
    return self;
}
+ (LocationController*)sharedInstance
{
    static LocationController *sharedInstance;
    @synchronized(self)
    {
        if (!sharedInstance)
            sharedInstance = [[self alloc] init];
        return sharedInstance;
    }
}
-(void)startUpdatingLocation{
    [self performSelector:@selector(checkPermission) withObject:nil afterDelay:0.5];
    [_locationManager startUpdatingLocation];
}
-(void)stopUpdatingLocation{
    [_locationManager stopUpdatingLocation];
}
-(void)checkPermission{
    if([CLLocationManager locationServicesEnabled]){
        
        NSLog(@"Location Services Enabled");
        
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            // LOCATION PERMISSION DENIED
            // 1) let app know that we don't have gps info
            [[NSNotificationCenter defaultCenter] postNotificationName:@"failedToFetchLocation"
                                                                object:self
                                                              userInfo:nil];

            
            // 2) show alert to update location settings
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Let Momunt Access Location?"
                                               message:@"Momunt needs your location to show you the photos around you. Please go to Settings and turn on Location Service for this app."
                                              delegate:self
                                     cancelButtonTitle:@"not now"
                                     otherButtonTitles:@"take me to settings", nil];
            [alert show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        // go to setting!
        // OPEN SETTINGS
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
        
    }
    
}


/*
    CLLocationManagerDelegate methods
 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"locationAccessDenied"
                                                        object:self
                                                      userInfo:nil];
    }

}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    // post notification that a new location has been found
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newLocationFound"
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:newLocation
                                                                                           forKey:@"newLocationResult"]];

}
+(void)nameFromLocation:(CLLocation *)location completion:(void (^)(NSString *name))completion{
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if (error) {
                           NSLog(@"Error %@", error.description);
                       } else {
                           CLPlacemark *placemark = [placemarks lastObject];
                           NSString *city = [placemark locality];
                           NSString *country = [placemark country];
                           NSString *state = [placemark administrativeArea];
                           
                           NSString *name;
                           if(city.length > 0){
                           
                               name = [country isEqualToString:@"United States"] ?
                                    [NSString stringWithFormat:@"%@, %@", city, state] :
                                    [NSString stringWithFormat:@"%@, %@", city, country];
                           }else{
                               name = country;
                               
                           }
                           
                           completion(name);
                       }
                   }];

}


@end
