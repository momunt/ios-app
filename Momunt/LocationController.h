//
//  LocationController.h
//  Momunt
//
//  Created by Masha Belyi on 9/25/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationController : NSObject <CLLocationManagerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) CLLocationManager* locationManager;
+(LocationController*)sharedInstance;

-(void)startUpdatingLocation;
-(void)stopUpdatingLocation;

+(void)nameFromLocation:(CLLocation *)location completion:(void (^)(NSString *name))completion; // get city+Country string from CLLocation

@end
