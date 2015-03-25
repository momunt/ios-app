//
//  MMNTReachabilityManager.h
//  Momunt
//
//  Created by Masha Belyi on 2/16/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reachability;

@interface MTReachabilityManager : NSObject

@property (strong, nonatomic) Reachability *reachability;
@property BOOL haveInternet;

#pragma mark -
#pragma mark Shared Manager
+ (MTReachabilityManager *)sharedManager;

#pragma mark -
#pragma mark Class Methods
+ (BOOL)isReachable;
+ (BOOL)isUnreachable;
+ (BOOL)isReachableViaWWAN;
+ (BOOL)isReachableViaWiFi;

@end