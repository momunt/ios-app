//
//  MMNTApiCommuniator.h
//  Momunt
//
//  Created by Masha Belyi on 6/30/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MMNTObj.h"
#import "MMNTChatObj.h"
#import "MMNTMessageObj.h"
#import "MMNTPhoto.h"

@protocol MMNTApiCommunicatorDelegate;

@interface MMNTApiCommuniator : NSObject
@property (weak, nonatomic) id<MMNTApiCommunicatorDelegate> delegate;

+ (MMNTApiCommuniator*)sharedInstance;

-(void)alertServerError;

- (void)searchMomuntAtCoordinate:(CLLocationCoordinate2D)coordinate andTime:(NSDate *)timestamp source:(NSString *)source;
-(void)getMorePhotosAtCoordinate:(CLLocationCoordinate2D)coordinate time:(NSString *)timestr distance:(int)distance;

-(void)searchMomuntById:(NSString *)momuntId;

-(void)deleteMomunt:(NSString *)momuntId;

-(void)storeMomunt:(MMNTObj *)mmnt;
-(void)followMomunt:(NSString *)momuntId lat:(double)lat lng:(double)lng name:(NSString *)name;
-(void)shareMomunt:(MMNTObj *)mmnt with:(NSArray *)recipients willPost:(BOOL)willPost completion:(void (^)(NSArray *messages))completion;

- (void)uploadImage:(UIImage *)image withCoordinate:(CLLocationCoordinate2D)coordinate withTimestamp:(NSDate *)timestamp uId:(NSString *)uId; // SHOULD DELETE THIS. Make sure no one is calling this method
- (void)uploadImage:(UIImage *)image quality:(CGFloat)q withCoordinate:(CLLocationCoordinate2D)coordinate withTimestamp:(NSDate *)timestamp uId:(NSString *)uId;

// Register user account
-(void)verifyNumber:(NSString *)number withCode:(NSString *)code completion:(void (^)(BOOL done))completion;
-(void)registerNumber:(NSString *)number completion:(void (^)(BOOL done))completion;
-(void)registerUser:(NSString *)username password:(NSString *)password phone:(NSString *)phone profile:(UIImage *)profile instagramToken:(NSString *)token fullName:(NSString *)fullName completion:(void (^)(NSDictionary *result))completion;
-(void)cancelUserRegistration:(NSInteger)userId;
-(void)authenticate:(NSString *)platform status:(NSInteger)status withToken:(NSString *)token setName:(NSString *)name;

// Check if username exists
-(BOOL)checkUserExists:(NSString *)username;

// Verify user phone number with verification code
-(void)verifyNumber:(NSString *)phone withCode:(NSString *)code forUser:(NSString *)id;

// Fetch user info
- (NSDictionary *)getUserInfo;
-(void)getAllUsersWithCompletion:(void (^)(NSArray *obj))completion;
-(void)syncContacts:(NSArray *)contacts completion:(void (^)(NSDictionary *obj))completion;

// LOGIN USER. Return token string, or nil
- (NSDictionary *)loginUsername:(NSString *)username password:(NSString *)password;

// LOGOUT
-(void)logout;

// RESET PASSWORD (Forgot password)
//-(BOOL)resetPasswordForEmail:(NSString *)email;
-(void)resetPasswordForPhone:(NSString *)phone completion:(void (^)(BOOL error))completion;

// CHANGE PASSWORD
-(void)resetPasswordFrom:(NSString *)oldPass to:(NSString *)newPass completion:(void (^)(NSString *token))completion;

/*
 * Fetch user chats
 */
-(void)fetchUserChats;
-(void)fetchMessagesForChatId:(NSInteger)chatId;
-(void)fetchMessagesForChat:(NSInteger)chatId maxMessage:(NSInteger)maxId completion:(void (^)(NSMutableArray *obj))completion;
-(MMNTChatObj *)fetchChatById:(CGFloat)chatId;

-(void)fetchMessageById:(NSInteger)messageId;

/* Start a new chat or retreive started chat */
-(NSData *)startChat:(NSArray *)members;
/* Post chat message */
-(void)postMessage:(MMNTMessageObj *)message completion:(void (^)(NSDictionary *dict))completion;
/* mark message as read */
-(void)markMessageAsRead:(MMNTMessageObj *)message;
/* fetch any new messages */
-(void)fetchNewMessages:(void (^)(BOOL done))completion;

/* Get public user info */
-(NSDictionary *)getPublicProfile:(NSString *)phone;

/* Register user device */
-(void)registerDeviceToken;

/* Trending Momunts */
-(void)getTrendingMomunts;
-(void)getTrendingMomunts:(void (^)(BOOL done))completion;

/* Set Onboarding Task done */
-(void)finishedTaskId:(NSInteger)taskId;

/* Flag photo */
-(void)flagRequest:(MMNTPhoto *)photo;

/* Delete photo */
-(void)deletePhoto:(MMNTPhoto *)photo;

@end
