//
//  MMNTApiCommunicatorDelegate.h
//  Momunt
//
//  Created by Masha Belyi on 6/30/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMNTApiCommunicatorDelegate <NSObject>

- (void)receivedMomuntJSON:(NSData *)objectNotation;
- (void)receivedMomuntData:(NSData *)data atCoordinate:(CLLocationCoordinate2D)location andTime:(NSDate *)timestamp;
//- (void)receivedMomuntFromId:(NSData *)objectNotation;
- (void)receivedMomuntFromId:(NSString *)mId data:(NSData *)objectNotation;

- (void)receivedMomuntData:(NSData *)data;
- (void)fetchingMomuntFailedWithError:(NSError *)error;
- (void)receivedMorePhotos:(NSData *)data;

- (void)storedMomunt;
- (void)storingMomuntFailedWithError:(NSError *)error;

- (void)sharedMomuntData:(NSDictionary *)res;

/**
 * Register user account
 */
-(void)registeringUserFailedWithMessage:(NSString *)message;
-(void)registeredUserWithId:(NSString *)id;

/**
 * Verify user phone number with verification code
 */
-(void)receivedAccessToken:(NSString *)token;
-(void)failedVerificationWithMessage:(NSString *)message;

-(void)startedChat:(NSData *)data;

@end
