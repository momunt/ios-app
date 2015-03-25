//
//  MMNT_MapPin.m
//  Momunt
//
//  Created by Masha Belyi on 7/23/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//
// Basic Pin

#import "MMNT_MapPin.h"

@implementation MMNT_MapPin

@synthesize  coordinate;

- (NSString *)subtitle{
	return nil;
}

- (NSString *)title{
	return nil;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	return self;
}

@end
