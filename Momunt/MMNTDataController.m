//
//  MMNTDataController.m
//  Momunt
//
//  Created by Masha Belyi on 9/25/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNTDataController.h"
#import "MMNTPhoto.h"
#import "MMNTObj.h"
#import "LocationController.h"
#import "MMNTAccountManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AddressBook/AddressBook.h>
#import "MTReachabilityManager.h"


@implementation MMNTDataController

- (id)init
{
    self = [super init];
    if (self != nil) {
        // init API communicator
        _APIcommunicator = [[MMNTApiCommuniator alloc] init];
        _APIcommunicator.delegate = self;
        
        _pileMomunt = [[MMNTObj alloc] init];
        _pileMomunt.type = @"pile";
        
        _toShareMomunt = [[MMNTObj alloc] init];
        
        _MQTTcontroller = [[MQTTChatController alloc] init];
        
//        // init Contacts Manager
//        _ContactsManager = [MMNTContactsManager sharedInstance];
        
        // init system sound
        NSString *path = [NSString stringWithFormat:@"%@/MomuntSound.mp3", [[NSBundle mainBundle] resourcePath]];
        NSURL *soundUrl = [NSURL fileURLWithPath:path];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundUrl, &MomuntSoundID);
        
        // subscribe to message notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receivedMessage:)
                                                     name:@"receivedMessage"
                                                   object:nil];

//        // subscribe to device token notifications
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(fetchedDeviceToken:)
//                                                     name:@"fetchedDeviceToken"
//                                                   object:nil];
//        
//        
//        // if have device token - register for this user
//        NSString *deviceTokenString = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceTokenString"];
//        if(deviceTokenString){
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"fetchedDeviceToken"
//                                                            object:self
//                                                          userInfo:[NSDictionary dictionaryWithObject:deviceTokenString
//                                                                                               forKey:@"DeviceToken"]];
//        }
//

    }
    
    return self;
}


+ (MMNTDataController*)sharedInstance
{
    static MMNTDataController *sharedInstance;
    @synchronized(self)
    {
        if (!sharedInstance)
            sharedInstance = [[self alloc] init];
        return sharedInstance;
    }
}

/*------------------ getter methods ------------------  */

-(NSMutableArray *)mmntBody{ return _body; }
-(NSMutableArray *)photosToShare{return _photosToShare;}
-(NSDate *)timestamp{return _timestamp;}
-(NSString *)mmntId{return _mId;}
-(NSString *)name{return _name;}
-(NSString *)currentCity{return _currentCity;}
-(NSString *)momuntState{return _momuntState;}
-(NSString *)currentCountry{return _currentCountry;}
-(CLLocationCoordinate2D )coordinate{return _coordinate;}
-(BOOL)shouldLoadFromId{ return _shouldLoadFromId; }
-(BOOL)openedFromNotification{return _didOpenFromNotification;}
-(BOOL)firstLaunch{return _isFirstLaunch;}
-(NSString *)openChatId{return _openChatId;}
-(NSString *)openMomuntId{return _openMomuntId;}
-(SystemSoundID)MomuntSoundID{return MomuntSoundID;}
/*------------------ setter methods ------------------  */

-(void)setPhotosToShare:(NSMutableArray *)array{
    // convert MMNTPhoto objects to NSDictionary objects and store
    
    if(!_photosToShare){
        _photosToShare = [[NSMutableArray alloc] init];
    }
    [_photosToShare removeAllObjects];
    for(int i = 0; i < array.count; i++) {
        MMNTPhoto *photo = array[i];
        [_photosToShare addObject:[photo toNSDictionary]];
    }
}
- (void)resetMomuntId{_mId = [self uniqueId];}
- (void)setMomuntId:(NSString *)str{ _mId = str; }
- (void)setName:(NSString *)name{ _name = name; }
-(void)setOpenedFromNotification:(BOOL)val{_didOpenFromNotification = val;}
-(void)setFirstLaunch:(BOOL)val{_isFirstLaunch = val;}
-(void)setOpenChatId:(NSString *)chatId{_openChatId = chatId;}
-(void)setOpenMomuntId:(NSString *)momuntId{_openMomuntId = momuntId;}

/*------------------ helper methods ------------------  */

// unique Momunt ID
-(NSString *)uniqueId{
    NSInteger len = 7;
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length]) % [letters length]]];
    }
    // this also adds a timestamp-based substring to make it more unique
    NSString *timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    NSString *sub = [timestamp substringWithRange:NSMakeRange(7,3)];
    [randomString appendString:sub];

    return randomString;
}
-(void)shouldLoadFromId:(NSString *)mId{
    _shouldLoadFromId = YES;
    _mId = mId;
}


/* ------------------ Request user info ------------------ */
- (void)getUserInfo{
    [_APIcommunicator getUserInfo];
}
//-(BOOL)checkUserExists:(NSString *)username{
//    return [_APIcommunicator checkUserExists:username];
//}
-(NSDictionary *)getPublicProfile:(NSString *)phone{
    return [_APIcommunicator getPublicProfile:phone];
}
//-(NSString *)resetPasswordFrom:(NSString *)oldPass to:(NSString *)newPass{
//    return [_APIcommunicator resetPasswordFrom:oldPass to:newPass];
//}
// LOGOUT
-(void)logout{
    [_APIcommunicator logout];
}
-(void)fetchUserChats{
    [_APIcommunicator fetchUserChats];
}
-(void)fetchMessagesForChatId:(NSInteger *)chatId{
    
}
-(void)fetchMessageById:(NSInteger)messageId{
    [_APIcommunicator fetchMessageById:messageId];
}

/* ------------------ Request momunt data from server ------------------ */


-(void)fetchMomuntAtCoordinate:(CLLocationCoordinate2D)coordinate andTime:(NSDate *)timestamp source:(NSString *)source{
//    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
//    dispatch_async(sessionQueue, ^{
        [_APIcommunicator searchMomuntAtCoordinate:coordinate andTime:timestamp source:source];
//    });
    
}
-(void)fetchMorePhotosAfter:(MMNTPhoto *)lastPhoto{
    if(_fetchingMorePhotos){
        return;
    }
    _fetchingMorePhotos = YES;
//    MMNTPhoto *lastPhoto = [_currentMomunt.body lastObject];
    CLLocationDegrees lat = [[[lastPhoto valueForKey:@"location"] valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees lng = [[[lastPhoto valueForKey:@"location"] valueForKey:@"longitude"] doubleValue];
    
    CLLocation *photoLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    CLLocation *momuntLocation = [[CLLocation alloc] initWithLatitude:_currentMomunt.lat longitude:_currentMomunt.lng];
    double distance = [photoLocation distanceFromLocation:momuntLocation];
    int D = 0;
//    NSString *timeStr = _currentMomunt.timestampStr;
    NSString *timeStr = lastPhoto.created_time;
    if(distance<=50){
        D = 50;
    }else if(distance<=100){
        D=100;
//        D = 50;
//        NSInteger tstamp = [_currentMomunt.timestampStr integerValue];
//        timeStr = [NSString stringWithFormat:@"%i", tstamp-(1*60*60)];
    }else if(distance<=500){
        D = 500;
//        D = 100;
//        NSInteger tstamp = [_currentMomunt.timestampStr integerValue];
//        timeStr = [NSString stringWithFormat:@"%i", tstamp-(5*60*60)];
    }else{
        D = 1000;
//        D = 500;
        // maxtime should be 24 hrs before mmnt time
//        NSInteger tstamp = [_currentMomunt.timestampStr integerValue];
//        timeStr = [NSString stringWithFormat:@"%i", tstamp-(48*60*60)];
    }
    
    [_APIcommunicator getMorePhotosAtCoordinate:CLLocationCoordinate2DMake(_currentMomunt.lat, _currentMomunt.lng) time:timeStr distance:D];
}


-(void)fetchMomuntWithId:(NSString *)momuntId{
    [_APIcommunicator searchMomuntById:momuntId];
}
/*
    Pull a new momunt from current coordinates
 */
-(void)refreshMomunt{
    // get current location -> fetch a new momunt
//    if(_refreshing)
//        return;
    
    _refreshing = YES;
    // init location manager
    LocationController *lc = [LocationController sharedInstance];
    
    // run loop to check if permissions given
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.5
                                                  target: self
                                                selector:@selector(startUpdatingLocation)
                                                userInfo: nil repeats:YES];
    

    
    
}
-(void)refreshMomuntAtCoordinate:(CLLocationCoordinate2D)coordinate{
    [self fetchMomuntAtCoordinate:coordinate andTime:[[NSDate alloc] init] source:@"current"];
}

-(void)startUpdatingLocation{
   if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
       // kill interval
       [timer invalidate];
       
       [self listenForLocation];
       [[LocationController sharedInstance] startUpdatingLocation];
 
   }

}

/*
 Delegate Callbacks
 */
//- (void)receivedMomuntData:(NSData *)data{
//    _currentMomunt = [[MMNTObj alloc] initWithData:data];
//    
//    if(!_currentMomunt.body){
//        NSLog(@"fetched empty momunt..?");
//        return;
//    }
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"fetchedNewMomunt"
//                                                        object:self
//                                                      userInfo:[NSDictionary dictionaryWithObject:_currentMomunt
//                                                                                           forKey:@"momunt"]];
//}

-(void)receivedMorePhotos:(NSData *)data{
    if(!data){
        // return empty array
        [[NSNotificationCenter defaultCenter] postNotificationName:@"fetchedMorePhotos"
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:[[NSArray alloc] init]
                                                                                               forKey:@"photos"]];
        return;
    }
    
    NSError *e;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    
    NSString *bodyStr = [dict valueForKey:@"body"];
    NSArray *photos = [MMNTObj parseMomuntBody:bodyStr];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fetchedMorePhotos"
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:photos
                                                                                           forKey:@"photos"]];
    _fetchingMorePhotos = NO;
}

- (void)receivedMomuntFromId:(NSString *)mId data:(NSData *)objectNotation{
    NSError *error = nil;
    NSMutableArray *momunt = [self photosFromMomuntData:objectNotation error:&error];
    _body = momunt;
    _mId = mId;
    
    // momunt is NIL when could not find it
    
    // POST NOTIFICATION that a new momunt has been loaded
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"fetchedNewMomunt"
//                                                        object:self
//                                                      userInfo:[NSDictionary dictionaryWithObject:momunt
//                                                                                           forKey:@"MomuntPhotos"]];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"fetchedNewMomunt"
//                                                        object:self
//                                                      userInfo:[NSDictionary dictionaryWithObject:_currentMomunt
//                                                                                           forKey:@"momunt"]];

}
//-(void)receivedMomuntData:(NSData *)data atCoordinate:(CLLocationCoordinate2D)location andTime:(NSDate *)timestamp{
//    NSError *error = nil;
//    NSMutableArray *momunt = [self photosFromData:data error:&error];
//    
//    if(error != nil){
//        // post notification that a momunt could not be fetched
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"failedFetchingMomunt"
//                                                            object:self
//                                                          userInfo:[NSDictionary dictionaryWithObject:@"Momunt could not be fetched."
//                                                                                               forKey:@"message"]];
//    }else{
//        
//        // STORE momunt values
//        _body = momunt;
//        _timestamp = timestamp;
//        _coordinate = location;
//        [self resetMomuntId]; // loaded new momunt -> new Id
//        
//        
//        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
//        [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude]
//                       completionHandler:^(NSArray *placemarks, NSError *error) {
//                           if (error) {
//                               NSLog(@"Error %@", error.description);
//                           } else {
//                               NSLog(@"Got address");
//                               CLPlacemark *placemark = [placemarks lastObject];
//                               _currentCity = [placemark locality];
//                               _currentCountry = [placemark country];
//                               _momuntState = [placemark administrativeArea];
//                               
//                               _name = [_currentCountry isEqualToString:@"United States"] ?
//                               [NSString stringWithFormat:@"%@, %@", _currentCity, _momuntState] :
//                               [NSString stringWithFormat:@"%@, %@", _currentCity, _currentCountry];
//                           }
//                       }];
//        
//        
//        // POST NOTIFICATION that a new momunt has been loaded
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"fetchedNewMomunt"
//                                                            object:self
//                                                          userInfo:[NSDictionary dictionaryWithObject:momunt
//                                                                                               forKey:@"MomuntPhotos"]];
//    }
//}

/* 
 Parse momunt. Convert NSData response into NSARray of MMNTPhoto objects
 @param objectNotation NSData returned from api request
 @return NSArray of momunt data
 */
- (NSMutableArray *)photosFromData:(NSData *)objectNotation error:(NSError **)error{
    
    NSError *localError = nil;
    NSArray *posts = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    if (localError != nil) {*error = localError;return nil;}
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    
    for (NSDictionary *imageDic in posts) {
        MMNTPhoto *photo = [[MMNTPhoto alloc] init];
        for (NSString *key in imageDic) {
            if ([photo respondsToSelector:NSSelectorFromString(key)]) {
                [photo setValue:[imageDic valueForKey:key] forKey:key];
            }
        }
        [photos addObject:photo];
    }
    
    return photos;
}

-(NSMutableArray *)photosFromMomuntData:(NSData *)objectNotation error:(NSError *__autoreleasing *)error{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSString *posts = [parsedObject valueForKey:@"body"];
    NSError *e;
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [posts dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &e];
    
    for (NSDictionary *imageDic in JSON) {
        MMNTPhoto *photo = [[MMNTPhoto alloc] init];
        
        for (NSString *key in imageDic) {
            if ([photo respondsToSelector:NSSelectorFromString(key)]) {
                [photo setValue:[imageDic valueForKey:key] forKey:key];
            }
        }
        
        [photos addObject:photo];
    }
    
    NSString *trimlat = [[parsedObject valueForKey:@"lat"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimlon = [[parsedObject valueForKey:@"lng"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //Convert to double
    double latdouble = [trimlat doubleValue];
    double londouble = [trimlon doubleValue];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latdouble longitude:londouble];
    
    // STORE momunt values
    NSString *timestamp = [parsedObject valueForKey:@"time_saved"];
    _timestamp = [NSDate dateWithTimeIntervalSince1970: (NSTimeInterval)[timestamp doubleValue] ];
    _coordinate = location.coordinate;
    
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if (error) {
                           NSLog(@"Error %@", error.description);
                       } else {
                           NSLog(@"Got address");
                           CLPlacemark *placemark = [placemarks lastObject];
                           _currentCity = [placemark locality];
                           _currentCountry = [placemark country];
                           _momuntState = [placemark administrativeArea];
                           
                           _name = [_currentCountry isEqualToString:@"United States"] ?
                            [NSString stringWithFormat:@"%@, %@", _currentCity, _momuntState] :
                            [NSString stringWithFormat:@"%@, %@", _currentCity, _currentCountry];
                       }
                   }];

    
    
    
    return photos;
    
}

/* ------------------ Storing momunt methods ------------------ */

-(void)storeMomunt:(MMNTObj *)momunt{
    
    if(!momunt.name || [momunt.momuntId isEqualToString:@"myMomunt"]){
        // fetch location?
        
        [momunt nameFromLocationWithCompletion:^(BOOL finished, NSString *name) {
            [_APIcommunicator storeMomunt:momunt];
        }];
    }else{
        [_APIcommunicator storeMomunt:momunt];
    }
}

-(void)shareMomunt:(MMNTObj *)momunt with:(NSArray *)recipients{
    if(![MTReachabilityManager isReachable]){
        [[MMNTApiCommuniator sharedInstance] alertServerError];
        return;
    }
        
    
    // 1) create/fetch chat - return an array of chats.. Only chats with momunt users are returned here
    NSArray *startedChats = [[MMNTDataController sharedInstance] startChat:recipients];

    
    // 2) create message(s)
    NSString *dateString;
//    if(momunt.live){
//        dateString = @"live";
//    }else{
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormat setDateFormat:@"MMMM dd, yyyy"];
        dateString = [dateFormat stringFromDate:(momunt.live ? [NSDate new] : momunt.timestamp)];
//    }

    NSDictionary *msg = @{ @"text"         : @"",
                           @"momuntId"     : momunt.momuntId,
                           @"momuntPoster" : momunt.poster ? momunt.poster : @"",
                           @"momuntName"   : @"momunt",
                           @"momuntDate"   : dateString
                           };
    NSData *msgData = [NSJSONSerialization dataWithJSONObject:msg options:0 error:nil];
    NSString *msgString = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
    
    // 3) add the message to every chat obj
    for(MMNTChatObj *theChat in startedChats){
        NSDictionary *data = @{ @"message"     : msgString,
                            @"username" : [MMNTAccountManager sharedInstance].username,
                            @"profileUrl" : [MMNTAccountManager sharedInstance].profileURl,
                            @"chatId" : [NSString stringWithFormat:@"%i",theChat.chatId] ,
                            @"isRead" : [NSNumber numberWithBool:YES],
                            @"uploadId" : momunt.uploadId,
                            @"timestamp" : [NSString stringWithFormat:@"%f",[[NSDate new] timeIntervalSince1970] ]
                            };

        // 3) add message to user chats
        [[MMNTAccountManager sharedInstance] addMessageWithData:data];
    }
    
    if([startedChats count]==1){
        // send out notification to show chat view
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showChat"
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:[startedChats firstObject]
                                                                                               forKey:@"chatObj"]];
    }else if([startedChats count]>1){
        // return to where you were before
        // send out notification to show messages view - show all chat threads
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showMessages"
                                                            object:self
                                                          userInfo:nil];
    }

    
    // 4) Asynch share the momunt with everyone. This API call with create messages and return an array of new messages. Each message will have upload Ids.
    // It may need to fetch data before storing in database - if this is a "present momunt". Should do this server-side?
    if(!momunt.name || [momunt.momuntId isEqualToString:@"myMomunt"]){
        [momunt nameFromLocationWithCompletion:^(BOOL finished, NSString *name) {
            [_APIcommunicator shareMomunt:momunt with:recipients willPost:YES completion:^(NSArray *messages) {
                for (NSDictionary *msg in messages) {
                    [[MMNTAccountManager sharedInstance] updateUploadedMessageWithData:msg];
                    // Send MQTT message here! Wooh!!
                    MMNTMessageObj *theMessage = [[MMNTMessageObj alloc] initWithDict:msg];
                    NSString *phone = [msg valueForKey:@"toUser"];
                    NSString *topic = [NSString stringWithFormat:@"momuntchat/%@", phone];
                    [_MQTTcontroller postMessage:theMessage toTopic:topic];
                }
            }];
        }];
    }else{
        [_APIcommunicator shareMomunt:momunt with:recipients willPost:YES completion:^(NSArray *messages) {
            for (NSDictionary *msg in messages) {
                
                NSInteger chatId = [[msg valueForKey:@"chatId"] integerValue];
                MMNTChatObj *chat = [[MMNTAccountManager sharedInstance] getChatById:chatId];
                if(!chat){
                    [[MMNTAccountManager sharedInstance] addMessageWithData:msg];
                }else{
                    [[MMNTAccountManager sharedInstance] updateUploadedMessageWithData:msg];
                }
                
                MMNTMessageObj *theMessage = [[MMNTMessageObj alloc] initWithDict:msg];
                NSString *phone = [msg valueForKey:@"toUser"];
                NSString *topic = [NSString stringWithFormat:@"momuntchat/%@", phone];
                [_MQTTcontroller postMessage:theMessage toTopic:topic];

            }
        }];
    }
    
    if([recipients count] != [startedChats count] && ![[[NSUserDefaults standardUserDefaults] valueForKey:@"sharedViaText"] boolValue] ){
        
        // ALERT that sent texts to non momunt users
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invited Friends"
                                                        message:@"We sent your momunt as a text to selected friends who aren't yet on the app."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert performSelector:@selector(show) withObject:nil afterDelay:0.5];

        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"sharedViaText"];

    }
    
    
}

-(void)shareMomuntViaText:(MMNTObj *)momunt with:(NSArray *)recipients{
    [_APIcommunicator shareMomunt:momunt with:recipients willPost:NO completion:^(NSArray *messages) {
        //nil
    }];
}
/* Start new chat session or retreive if exists
 return array of MMNTChatObjects
 */
-(NSArray *)startChat:(NSArray *)members{
    
    NSData *data = [_APIcommunicator startChat:members];
    NSError *e;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    // dict = array(chats => atay(chat1, chat2, chat3...))
    
    NSArray *chatsArray          = [dict objectForKey:@"chats"];
    NSMutableArray *startedChats = [[NSMutableArray alloc] init];
    
    for (NSDictionary *chatDict in chatsArray) {
        MMNTChatObj *chat = [[MMNTAccountManager sharedInstance] getChatById:[[chatDict valueForKey:@"chatId"] integerValue] ];
        if(chat){
            // This chat is already in user chats array
            [startedChats addObject:chat];
        }else{
            // This is a new chat
            MMNTChatObj *theChat = [[MMNTChatObj alloc] initWithDict:chatDict];
//            if([theChat.messages count]>0){ // members count == 0 if one of the members is not a user yet
                [[MMNTAccountManager sharedInstance].Chats insertObject:theChat atIndex:0];
                [startedChats addObject:theChat];
//            }
            //            [startedChats addObject:theChat];
        }
        
    }
    return startedChats;
}

// Deleagte callbacks..
//- (void)storingMomuntFailedWithError:(NSError *)error{
//    NSLog(@"Error %@; %@", error, [error localizedDescription]);
//}
//- (void)storedMomunt{
//    NSLog(@"stored momunt!");
//    
//    // UPDATE user's saved momunts
//    [self getUserInfo];
//}

-(void)sharedMomunt:(MMNTObj *)mmnt{
     NSLog(@"shared momunt!");
}


-(void)sharedMomuntData:(NSDictionary *)res{
    /*
     res
     @param NSString uploadId
     @param NSString name
     @param NSString poster
     @param NSArray recipients
     */
    NSLog(@"shared momunt upload id:%@", [res objectForKey:@"uploadId"]);

    // update message(s)
    NSArray *messages = [[MMNTAccountManager sharedInstance] updateUploadedMessageWithData:res];
    
    for(MMNTMessageObj * msg in messages){
        // post message
//        if(msg!=nil){
            [self postChatMessage:msg toRecipients:[res objectForKey:@"recipients"]];
//        }
    }
    
}

/*----------------- Post/Receive Chat messages -----------------*/
-(void)postChatMessage:(MMNTMessageObj *)message toRecipients:(NSArray *)recipients1{
 
    dispatch_async(dispatch_get_main_queue(), ^{
        // register the message in database, get message Id
       [_APIcommunicator postMessage:message completion:^(NSDictionary *res) {
            NSInteger messageId = [[res objectForKey:@"messageId"] integerValue];
            NSArray *recipients = [res objectForKey:@"recipients"];
            if(messageId > 0){
                message.messageId = messageId;
                for(int i=0; i<[recipients count]; i++){
                    NSString *userId = recipients[i];
                    //                NSLog(@"send message to %@", phone);
                
                    // DEV DONT POST MESSAGES. UNCOMMENT THIS!
                    NSString *topic = [NSString stringWithFormat:@"momuntchat/%@", userId];
                    [_MQTTcontroller postMessage:message toTopic:topic];
                }
            }
        }];
        
    });
    
    
}

/* ------ Receved Mesage Listener ---- */
// received message through mqtt_message broker (the app is active)
-(void) receivedMessage:(NSNotification*)notif {
    // just increase message count for this chat
    MMNTMessageObj *msg = (MMNTMessageObj *)[[notif userInfo] valueForKey:@"message"];
    
    MMNTChatObj *theChat = [[MMNTAccountManager sharedInstance] getChatById:msg.chatId]; // THIS IS NULL IF NEW CHAT!
    
    
    
    if(theChat){
        [theChat.messages addObject:msg];
        [theChat countUnread];
        [[MMNTAccountManager sharedInstance] addOrUpdate:theChat atIdx:(CGFloat)0];
    }else{
        // add new chat object .. should be async..
        MMNTChatObj *theChat = [[[MMNTDataController sharedInstance] APIcommunicator] fetchChatById:msg.chatId];
        if(theChat){ // in not nil
            [[MMNTAccountManager sharedInstance].Chats insertObject:theChat atIndex:0];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[MMNTAccountManager sharedInstance] countTotalUnread];
    });
    
    // post notificatoin about new chat data - if in messages view, will reload the table
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedChatData"
                                                        object:self
                                                      userInfo:nil];
    // post notificatoin about new chat data - if in messages view, will reload the table
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedChatWithId"
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%i", msg.chatId ]
                                                                                           forKey:@"chatId"]];
    
    // +1 app badge number
    if([UIApplication sharedApplication].applicationState!=UIApplicationStateBackground){
        [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
    }
    
    AudioServicesPlaySystemSound(MomuntSoundID);
    //    [_APIcommunicator fetchUserChats];
    
}

/* ------------------ Grabbing Location methods ------------------ */

-(void)listenForLocation{
    _fetchedLocation = nil;
    _numLocationFetch = 0;
    _didFetchLocation = NO;
    // subscribe to location updates
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatedLocation:)
                                                 name:@"newLocationFound"
                                               object:nil];
    
    [self performSelector:@selector(locationTimeout) withObject:nil afterDelay:5.0]; // tiemout search after 5.0 seconds
}

-(void)stopListenForLocation{
    // subscribe to location updates
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"newLocationFound" object:nil];
    [[LocationController sharedInstance] stopUpdatingLocation];
}
-(void)locationTimeout{
    if(_didFetchLocation){
        return;
    }
    
    // stop listening for locaton
    [self stopListenForLocation];
    // stop location manager
    [[LocationController sharedInstance] stopUpdatingLocation];
    
    if(!_fetchedLocation){
//        // error
//        // SHOULD SHOW A RANDOM MOMUNT
//        // show alert that says failed to get gps location
//        UIAlertView *updateAlert = [[UIAlertView alloc] initWithTitle:@"Poor connection" message: @"Momunt failed to detect your gps location. Please try again later" delegate:self cancelButtonTitle:@"Ok"  otherButtonTitles:nil, nil];
//        
//        [updateAlert show];
//        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"failedToFetchLocation"
                                                            object:self
                                                          userInfo:nil];
    }
    else{
        // use the closest location fetched so far to load momunt
        NSDate *now = [[NSDate alloc] init];
        [self fetchMomuntAtCoordinate:_fetchedLocation.coordinate andTime:now source:@"current"];
    }
    
}

// Do something when location updates
-(void) updatedLocation:(NSNotification*)notif {
    
    // report current location
    CLLocation* location = (CLLocation*)[[notif userInfo] valueForKey:@"newLocationResult"];
    NSLog(@"updated location: %@", location);

    if(_numLocationFetch == 0){
        _fetchedLocation = location;
    }
    if(_numLocationFetch > 1 && location.horizontalAccuracy<_fetchedLocation.horizontalAccuracy){
        _fetchedLocation  = location;
    }
    if(_numLocationFetch < 5 && _fetchedLocation.horizontalAccuracy > 100 ){ // try 5 times, get the most accurat value. Unless got < 100m already
        _numLocationFetch = _numLocationFetch + 1;
        return;
    }
    
    _didFetchLocation = YES;
    _coordinate = _fetchedLocation.coordinate;
    
    // stop listening for locaton
    [self stopListenForLocation];
    // stop location manager
    [[LocationController sharedInstance] stopUpdatingLocation];
    
    
    // use this location to load a momunt
    NSDate *now = [[NSDate alloc] init];
    [self fetchMomuntAtCoordinate:_fetchedLocation.coordinate andTime:now source:@"current"];
}


/* -------- Uploading Momunt Photo -------*/
//- (void)uploadImage:(UIImage *)image quality:(CGFloat)q withCoordinate:(CLLocationCoordinate2D)coordinate withTimestamp:(NSDate *)timestamp uId:(NSString *)uId{
//    [_APIcommunicator uploadImage:image quality:(CGFloat)q  withCoordinate:coordinate withTimestamp:timestamp uId:uId];
//}

///* ------ Device Token Listener ---- */
//// reload chat data
//-(void) fetchedDeviceToken:(NSNotification*)notif {
//    NSString *token = (NSString*)[[notif userInfo] valueForKey:@"DeviceToken"];
//    [_APIcommunicator registerDeviceToken:token];
//}

//-(void)markMessageAsRead:(MMNTMessageObj *)message{
//    [_APIcommunicator markMessageAsRead:message];
//}

-(void)asyncDownloadUrl:(NSURL *)imageURL completionBlock:(void (^)(BOOL succeeded, UIImage *image, NSURL *url))completionBlock{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:imageURL options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        // progression tracking code
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image)
        {
            // do something with image
            completionBlock(YES, image, imageURL);
            return;
        }else{
            completionBlock(NO, nil, nil);
        }
    }];
    
}

/* Flag photo */
//-(void)flagRequest:(MMNTPhoto *)photo{
//    [_APIcommunicator flagRequest:photo];
//}

/* Delete photo */
//-(void)deletePhoto:(MMNTPhoto *)photo{
//    [_APIcommunicator deletePhoto:photo];
//}

/*Set Help Task Done */
-(void)setTaskDone:(NSInteger)taskId{
    if(![[MMNTAccountManager sharedInstance] isTaskDone:taskId]){
        [_APIcommunicator finishedTaskId:taskId];
        [[MMNTAccountManager sharedInstance].helpTasksDone addObject:[NSNumber numberWithInteger:taskId]];
    }
}

/*
 Notifications Permission
 */
-(void)askNotificationsPermission{
    // Register for notifications!
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // use registerUserNotificationSettings
        UIUserNotificationType types = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    } else {
        // use registerForRemoteNotifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }
    
}


-(BOOL)askAddressBookPermission{
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        //        dispatch_release(sema);
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    return accessGranted;
}
@end
