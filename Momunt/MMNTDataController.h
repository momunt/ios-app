//
//  MMNTDataController.h
//  Momunt
//
//  Created by Masha Belyi on 9/25/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AudioToolBox/AudioToolBox.h>

#import "MMNTApiCommunicatorDelegate.h"
#import "MMNTApiCommuniator.h"
#import "MQTTChatController.h"

#import "MMNTObj.h"
#import "MMNTMessageObj.h"
#import "MMNTChatObj.h"


@class MMNTApiCommuniator;

@interface MMNTDataController : NSObject<MMNTApiCommunicatorDelegate>{
    NSMutableArray *_body;
    NSDate *_timestamp;
    NSString *_mId;
    NSInteger *_ownerId;
    NSString *_name;
    NSString *_currentCity;
    NSString *_momuntState;
    NSString *_currentCountry;
    CLLocationCoordinate2D _coordinate;
    
    NSMutableArray *_photosToShare;
    BOOL _shouldLoadFromId;
    BOOL _didOpenFromNotification;
    BOOL _isFirstLaunch;
    NSString *_openChatId;
    NSString *_openMomuntId;

    SystemSoundID MomuntSoundID;
    
    CGFloat _numLocationFetch;
    CLLocation *_fetchedLocation;
    BOOL _didFetchLocation;
    BOOL _refreshing;
    
    NSTimer *timer;
}

@property (strong, nonatomic) MMNTObj *currentMomunt; // updated everytime a new/saved momunt is loaded into the gallery
@property (strong, nonatomic) MMNTObj *pileMomunt;
@property (strong, nonatomic) MMNTObj *toShareMomunt;
@property (nonatomic) BOOL sharePile;

@property (strong, nonatomic) MMNTApiCommuniator *APIcommunicator;
@property (strong, nonatomic) MQTTChatController *MQTTcontroller;

@property BOOL fetchingMorePhotos;

+(MMNTDataController*)sharedInstance;

/* getters */
-(NSMutableArray *)mmntBody;
-(NSMutableArray *)photosToShare;
-(NSDate *)timestamp;
-(NSString *)mmntId;
-(NSString *)name;
-(NSString *)currentCity;
-(NSString *)momuntState;
-(NSString *)currentCountry;
-(CLLocationCoordinate2D )coordinate;
-(BOOL)shouldLoadFromId;
-(BOOL)openedFromNotification;
-(BOOL)firstLaunch;
-(NSString *)openChatId;
-(NSString *)openMomuntId;
-(SystemSoundID)MomuntSoundID;

/* setters */
-(void)setPhotosToShare:(NSMutableArray *)array;
- (void)resetMomuntId;
- (void)setMomuntId:(NSString *)str;
-(void)setName:(NSString *)name;
-(void)setOpenedFromNotification:(BOOL)val;
-(void)setFirstLaunch:(BOOL)val;
-(void)setOpenChatId:(NSString *)chatId;
-(void)setOpenMomuntId:(NSString *)momuntId;

/* helpers */
-(NSString *)uniqueId;
-(void)shouldLoadFromId:(NSString *)mId;



/*----------------- API calls -----------------*/


/*
    Get user info
 */
- (void)getUserInfo;
/**
 * Check if username exists
 */
//-(BOOL)checkUserExists:(NSString *)username;
/* Get public user info */
-(NSDictionary *)getPublicProfile:(NSString *)phone;

// LOGOUT
-(void)logout;


/*
 - Fetch list of user chat sessions
*/
- (void)fetchUserChats;
-(void)fetchMessagesForChatId:(NSInteger *)chatId;
-(void)fetchMessageById:(NSInteger)messageId;


/*
    Request momunt data from server
 */
-(void)fetchMomuntAtCoordinate:(CLLocationCoordinate2D)coordinate andTime:(NSDate *)timestamp source:(NSString *)source;
-(void)fetchMorePhotosAfter:(MMNTPhoto *)lastPhoto;
-(void)fetchMomuntWithId:(NSString *)momuntId;
-(void)refreshMomunt;
-(void)refreshMomuntAtCoordinate:(CLLocationCoordinate2D)location;
/*
    Save momunt to database
 */
//-(void)storeMomunt:(NSString *)momuntId withCoordinate:(CLLocationCoordinate2D)coordinate withTimestamp:(NSString *)timestamp;
-(void)storeMomunt:(MMNTObj *)mmnt;
-(void)shareMomunt:(MMNTObj *)mmnt with:(NSArray *)recipients;
-(void)shareMomuntViaText:(MMNTObj *)momunt with:(NSArray *)recipients;
/*
    Upload photo to momunt
 */
//-(void)uploadImage:(UIImage *)image quality:(CGFloat)q withCoordinate:(CLLocationCoordinate2D)coordinate withTimestamp:(NSDate *)timestamp uId:(NSString *)uId;



/*----------------- Post/Receive Chat messages -----------------*/
-(void)postChatMessage:(MMNTMessageObj *)message toRecipients:(NSArray *)recipients;
/* Start new chat session or retreive if exists */
-(NSArray *)startChat:(NSArray *)members;
//-(void)markMessageAsRead:(MMNTMessageObj *)message;


/*----------------- Async Image Download -----------------*/
 -(void)asyncDownloadUrl:(NSURL *)imageURL completionBlock:(void (^)(BOOL succeeded, UIImage *image, NSURL *url))completionBlock;

/* Flag photo */
//-(void)flagRequest:(MMNTPhoto *)photo;

/* Delete photo */
//-(void)deletePhoto:(MMNTPhoto *)photo;

/* Set Help Task Done*/
-(void)setTaskDone:(NSInteger)taskId;

/*
 Permissions
 */
-(void)askNotificationsPermission;
-(BOOL)askAddressBookPermission;

@end
