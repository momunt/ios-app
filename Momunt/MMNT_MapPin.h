//
//  MMNT_MapPin.h
//  Momunt
//
//  Created by Masha Belyi on 7/23/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MMNT_MapPin : NSObject<MKAnnotation>{
    CLLocationCoordinate2D coordinate;
}
-(id)initWithCoordinate:(CLLocationCoordinate2D) c;

@property NSString *type; // pin type

@end
