//
//  MMNTApiCommuniator.m
//  Momunt
//
//  Created by Masha Belyi on 6/30/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//
#import "Amplitude.h"
#import "MTReachabilityManager.h"
#import <Crashlytics/Crashlytics.h>

#import "MMNTApiCommuniator.h"
#import "MMNTApiCommunicatorDelegate.h"
#import "MMNT_SharedVars.h"
#import "MMNTDataController.h"
#import "MMNTAccountManager.h"
#import "MMNTObj.h"
#import "MMNTChatObj.h"

#import <Security/Security.h>
#import "JNKeychain.h"

@implementation MMNTApiCommuniator

//#define API_BASE @"https://www.momunt.com/api/v1/" // old API - most users have this - Momunt db
#define API_BASE @"https://www.momunt.com/api/v2/" // new API - in apple review - MomuntDev db
//#define API_BASE @"http://10.0.0.29/~mashabelyi/momunt/api/v2/" // Local test server, new api

- (id)init
{
    self = [super init];
    if (self != nil) {
        // init here
    }
    return self;
}
+ (MMNTApiCommuniator*)sharedInstance
{
    static MMNTApiCommuniator *sharedInstance;
    @synchronized(self)
    {
        if (!sharedInstance)
            sharedInstance = [[self alloc] init];
        return sharedInstance;
    }
}

-(void)alertServerError{
    CLS_LOG(@"could not reach server");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                    message:@"Momunt is unable to process your request at this time. Please check your internet connection and try again in a few minutes."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

}
-(void)alertNoInternet{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet!"
                                                    message:@"No working internet connection is found."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)searchMomuntAtCoordinate:(CLLocationCoordinate2D)coordinate andTime:(NSDate *)timestamp source:(NSString *)source{
    if(![MTReachabilityManager isReachable]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"failedToFetchMomuntData" object:self userInfo:nil];
        [self alertNoInternet];
        return;
    }
    
    
    NSString *timeStr = [NSString stringWithFormat:@"%f",[timestamp timeIntervalSince1970] ];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@search/%.20g/%.20g/%@", API_BASE, coordinate.latitude, coordinate.longitude, timeStr] ];
    NSMutableURLRequest *mutableRelquest = [NSMutableURLRequest requestWithURL:url];
    NSURLRequest *request = [self addAuthHeader:mutableRelquest]; // add authentication

    
    // ASYNC!
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error){
            CLS_LOG(@"server error fetching momunt for search/lat/lng/time with message: %@", [error localizedDescription]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"failedToFetchMomuntData" object:self userInfo:nil];
            [self alertServerError];
            return;
        }

        NSError *e;
        NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        if(e){
            CLS_LOG(@"error parsing server response for search/lat/lng/time with message: %@", [e localizedDescription]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"failedToFetchMomuntData" object:self userInfo:nil];
            [self alertServerError];
            return;
        }
    
        BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
        if(failed){
            CLS_LOG(@"fetching momunt failed with error: %@",[res objectForKey:@"message"]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"failedToFetchMomuntData" object:self userInfo:nil];
            [self alertServerError];
            return;
            
        }
        else{
        
            // update instagram auth status
            NSInteger authInstagram = [[res objectForKey:@"authInstagram"] integerValue];
            [MMNTAccountManager sharedInstance].authInstagram = authInstagram;
        
            BOOL isFirstAutoLoad = [[[NSUserDefaults standardUserDefaults] valueForKey:@"isFirstLoad"] boolValue];
            if(isFirstAutoLoad){
                [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"isFirstLoad"];
            }
            else{
                // AMPLITUDE ---------------------------------------------------------------------------------------------------
                NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
                [eventProperties setValue:[NSNumber numberWithDouble:coordinate.latitude] forKey:@"latitude"];
                [eventProperties setValue:[NSNumber numberWithDouble:coordinate.longitude] forKey:@"longitude"];
                [eventProperties setValue:[NSNumber numberWithInteger:[timestamp timeIntervalSince1970]] forKey:@"timestamp"];
                [eventProperties setValue:source forKey:@"type"];
                [Amplitude logEvent:@"loaded momunt" withEventProperties:eventProperties];
                //--------------------------------------------------------------------------------------------------------------
            }

            // Show momunt to user!
            MMNTObj *theMomunt = [[MMNTObj alloc] initWithData:data];
            [MMNTDataController sharedInstance].currentMomunt = theMomunt;

            [[NSNotificationCenter defaultCenter] postNotificationName:@"fetchedNewMomunt"
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObject:theMomunt
                                                                                                   forKey:@"momunt"]];
        }
    }];

    
}

-(void)getMorePhotosAtCoordinate:(CLLocationCoordinate2D)coordinate time:(NSString *)timestr distance:(int)distance{
    if(![MTReachabilityManager isReachable]){
        [self alertServerError];
        [self.delegate receivedMorePhotos:nil];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@search/more/%.20g/%.20g/%i/%@", API_BASE, coordinate.latitude , coordinate.longitude, distance, timestr] ];
    
    NSMutableURLRequest *mutableRelquest = [NSMutableURLRequest requestWithURL:url];
    NSURLRequest *request = [self addAuthHeader:mutableRelquest]; // add authentication
    
    // AMPLITUDE ---------------------------------------------------------------------------------------------------
    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    [eventProperties setValue:[NSNumber numberWithDouble:coordinate.latitude] forKey:@"latitude"];
    [eventProperties setValue:[NSNumber numberWithDouble:coordinate.longitude] forKey:@"longitude"];
    [eventProperties setValue:[NSNumber numberWithInteger:[timestr integerValue]] forKey:@"timestamp"];
    [Amplitude logEvent:@"requested more photos" withEventProperties:eventProperties];
    //--------------------------------------------------------------------------------------------------------------
    
    // ASYNC!
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if(error){
            CLS_LOG(@"server error fetching more photos: %@", [error localizedDescription]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"failedToFetchMomuntData" object:self userInfo:nil];
            [self alertServerError];
            [self.delegate receivedMorePhotos:nil];
            return;
        }
        else {
            
            NSError *e;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
            
            if(e){
                CLS_LOG(@"error parsing server response for more photos: %@", [e localizedDescription]);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"failedToFetchMomuntData" object:self userInfo:nil];
                [self alertServerError];
                [self.delegate receivedMorePhotos:nil];
                return;
            }

            
            BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
            if(failed){
                CLS_LOG(@"failed fetchin more photos with message: %@", [res objectForKey:@"message"]);
            }else{
               CLS_LOG(@"got more photos!");
                
                // update instagram auth status
                NSInteger authInstagram = [[res objectForKey:@"authInstagram"] integerValue];
                [MMNTAccountManager sharedInstance].authInstagram = authInstagram;

                [self.delegate receivedMorePhotos:data];
                
            }
            
        }
    }];
    
    
}

-(void)searchMomuntById:(NSString *)momuntId{
    if(![MTReachabilityManager isReachable]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"failedToFetchMomuntData" object:self userInfo:nil];
        [self alertNoInternet];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@search/%@", API_BASE, momuntId] ];
    NSMutableURLRequest *mutableRelquest = [NSMutableURLRequest requestWithURL:url];
    NSURLRequest *request = [self addAuthHeader:mutableRelquest]; // add authentication
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error){
            CLS_LOG(@"server error fetching momunt for search/momuntId: %@", [error localizedDescription]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"failedToFetchMomuntData" object:self userInfo:nil];
            [self alertServerError];
            return;
        }
        
        NSError *e;
        NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        
        if(e){
            CLS_LOG(@"error parsing server response for search/momuntId: %@", [e localizedDescription]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"failedToFetchMomuntData" object:self userInfo:nil];
            [self alertServerError];
            return;
        }
        
        BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
        if(failed){
            CLS_LOG(@"failed search momunt by id with message: %@", [res objectForKey:@"message"]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"failedToFetchMomuntData" object:self userInfo:nil];
            [self alertServerError];
            return;
            
        }
        else{

            // update instagram auth status
            if([[res objectForKey:@"hasAuthInfo"] boolValue]==YES){
                NSInteger authInstagram = [[res objectForKey:@"authInstagram"] integerValue];
                [MMNTAccountManager sharedInstance].authInstagram = authInstagram;
            }
            
            // Show momunt to user!
            MMNTObj *theMomunt = [[MMNTObj alloc] initWithData:data];
            [MMNTDataController sharedInstance].currentMomunt = theMomunt;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"fetchedNewMomunt"
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObject:theMomunt
                                                                                                   forKey:@"momunt"]];

        }
    }];

    
}

/* -------------- Store Momunt ------------------ */
-(void)storeMomunt:(MMNTObj *)mmnt{
    if(![MTReachabilityManager isReachable]){
        [self alertServerError];
        return;
    }
    
    NSString *nameString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                      (CFStringRef)mmnt.name,
                                                                                      NULL,
                                                                                      (CFStringRef)@"&",
                                                                                      kCFStringEncodingUTF8));
    
    NSString *postString;
    
    if(mmnt.body){
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[mmnt bodyToNSDictionary] options:0 error:nil];
        NSString *body = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        body = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                          (CFStringRef)body,
                                                                                          NULL,
                                                                                          (CFStringRef)@"&",
                                                                                          kCFStringEncodingUTF8));
        
        postString = [NSString stringWithFormat:@"lat=%.20g&lng=%.20g&time_saved=%@&id=%@&name=%@&body=%@&ownerId=%i&type=%@",
                                mmnt.lat,
                                mmnt.lng,
                                [NSString stringWithFormat:@"%f", [mmnt.timestamp timeIntervalSince1970] ],
                                mmnt.momuntId,
                                nameString,
                                body,
                                mmnt.ownerId,
                                mmnt.type
                                ];
    }else{
        
        postString = [NSString stringWithFormat:@"lat=%.20g&lng=%.20g&time_saved=%@&id=%@&name=%@&ownerId=%i&type=%@",
                                mmnt.lat,
                                mmnt.lng,
                                [NSString stringWithFormat:@"%f", [mmnt.timestamp timeIntervalSince1970] ],
                                mmnt.momuntId,
                                nameString,
                                mmnt.ownerId,
                                mmnt.type
                                ];
    }

    
    NSData *postDataString = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@save_momunt", API_BASE] ]; // USE NEW API!
    NSLog(@"%@", url);
    
    NSMutableURLRequest *mutableRelquest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    [mutableRelquest setURL:url];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postDataString length]];
    [mutableRelquest setHTTPMethod:@"POST"];
    [mutableRelquest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [mutableRelquest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mutableRelquest setHTTPBody:postDataString];
    
    // ADD AUTHENTICATION HEADER!!!!
    NSString *token = [JNKeychain loadValueForKey:@"AccessToken"];
    [mutableRelquest addValue:token forHTTPHeaderField:@"Authorization"];
    
    NSURLRequest *request = [mutableRelquest copy];
    
    // AMPLITUDE ---------------------------------------------------------------------------------------------------
    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    [eventProperties setValue:[NSNumber numberWithDouble:mmnt.lat] forKey:@"latitude"];
    [eventProperties setValue:[NSNumber numberWithDouble:mmnt.lng] forKey:@"longitude"];
    [eventProperties setValue:mmnt.momuntId forKey:@"momuntId"];
    [eventProperties setValue:mmnt.type forKey:@"type"];
    [eventProperties setValue:[NSNumber numberWithInteger:[mmnt.timestamp timeIntervalSince1970]] forKey:@"timestamp"];
    [Amplitude logEvent:@"saved momunt" withEventProperties:eventProperties];
    //--------------------------------------------------------------------------------------------------------------
    
    // ASYNC!
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if(error){
            CLS_LOG(@"failed store momunt with error: %@", [error localizedDescription]);
            [self alertServerError];
            return;
        }
        else {
            NSError *e;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
            
            if(e){
                CLS_LOG(@"failed store momunt with error: %@", [e localizedDescription]);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"failedToFetchMomuntData" object:self userInfo:nil];
                [self alertServerError];
                [self.delegate receivedMorePhotos:nil];
                return;
            }
            
            BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
            if(failed){
                CLS_LOG(@"failed store momunt with message: %@", [res objectForKey:@"message"]);
            }else{
                CLS_LOG(@"saved momunt");
                // ADD TO USER'S SAVED MOMUNTS, DONE
                [self getUserInfo];
                
//                NSDictionary *mmntDict = [res objectForKey:@"momunt"];
//                MMNTObj *mmnt = [[MMNTObj alloc] initWithDict:mmntDict];
//                for(int i = 1; i< [[MMNTAccountManager sharedInstance].userMomunts count]; i++){
//                    MMNTObj *m = [[MMNTAccountManager sharedInstance].userMomunts objectAtIndex:i];
//                    if([mmnt.timestamp timeIntervalSince1970] > [m.timestamp timeIntervalSince1970]){
//                        [[[MMNTAccountManager sharedInstance] userMomunts] insertObject:mmnt atIndex:i];
//                        return;
//                    }
//                }
//                [[[MMNTAccountManager sharedInstance] userMomunts] addObject:mmnt];
//                return;

            }


        }
    }];
    

}

-(void)followMomunt:(NSString *)momuntId lat:(double)lat lng:(double)lng name:(NSString *)name{
    if(![MTReachabilityManager isReachable]){
        [self alertServerError];
        return;
    }

    NSString *postString = [NSString stringWithFormat:@"lat=%.20g&lng=%.20g&id=%@&name=%@",
                  lat,
                  lng,
                  momuntId,
                  name];
    NSData *postDataString = [postString dataUsingEncoding:NSUTF8StringEncoding];
    // API url
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@follow", API_BASE] ]; // USE NEW API!
    // set up request
    NSMutableURLRequest *mutableRelquest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    [mutableRelquest setURL:url];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postDataString length]];
    [mutableRelquest setHTTPMethod:@"POST"];
    [mutableRelquest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [mutableRelquest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mutableRelquest setHTTPBody:postDataString];
    
    // ADD AUTHENTICATION HEADER!!!!
    NSString *token = [JNKeychain loadValueForKey:@"AccessToken"];
    [mutableRelquest addValue:token forHTTPHeaderField:@"Authorization"];
    NSURLRequest *request = [mutableRelquest copy];
    
    // AMPLITUDE ---------------------------------------------------------------------------------------------------
    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    [eventProperties setValue:[NSNumber numberWithDouble:lat] forKey:@"latitude"];
    [eventProperties setValue:[NSNumber numberWithDouble:lng] forKey:@"longitude"];
    [eventProperties setValue:momuntId forKey:@"momuntId"];
    [Amplitude logEvent:@"followed location" withEventProperties:eventProperties];
    //--------------------------------------------------------------------------------------------------------------
    
    // ASYNC!
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if(error){
            CLS_LOG(@"failed follow momunt with error: %@", [error localizedDescription]);
            [self alertServerError];
            return;
        }
        else {
            NSError *e;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
            
            if(e){
                CLS_LOG(@"failed follow momunt with error: %@", [e localizedDescription]);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"failedToFetchMomuntData" object:self userInfo:nil];
                [self alertServerError];
                [self.delegate receivedMorePhotos:nil];
                return;
            }
            
            BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
            if(failed){
                CLS_LOG(@"failed store momunt with message: %@", [res objectForKey:@"message"]);
            }else{
                CLS_LOG(@"followed momunt");
                // ADD TO USER'S SAVED MOMUNTS, DONE
                [self getUserInfo];
                
            }
            
            
        }
    }];

    
}

-(void)deleteMomunt:(NSString *)momuntId{
    NSString *postString = [NSString stringWithFormat:@"momuntId=%@", momuntId ];
    NSData *postDataString = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@delete/momunt", API_BASE] ];
    NSMutableURLRequest *mutableRelquest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    [mutableRelquest setURL:url];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postDataString length]];
    [mutableRelquest setHTTPMethod:@"POST"];
    [mutableRelquest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [mutableRelquest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mutableRelquest setHTTPBody:postDataString];
    // ADD AUTHENTICATION HEADER!!!!
    NSString *token = [JNKeychain loadValueForKey:@"AccessToken"];
    [mutableRelquest addValue:token forHTTPHeaderField:@"Authorization"];
    NSURLRequest *request = [mutableRelquest copy];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            NSLog(@"faled to delete momunt");
        } else {
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            
            BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
            if(failed){
                NSLog(@"faled to delete momunt");
            }else{
                NSLog(@"deleted momunt");
            }
            
        }
    }];
}

/* -------------- Store Momunt ------------------ */
-(void)shareMomunt:(MMNTObj *)mmnt with:(NSArray *)recipients willPost:(BOOL)willPost completion:(void (^)(NSArray *messages))completion{
    
    NSData *jsonRecipients = [NSJSONSerialization dataWithJSONObject:recipients options:0 error:nil];
    NSString *recipientsString = [[NSString alloc] initWithData:jsonRecipients encoding:NSUTF8StringEncoding];
    
    NSString *postString;
    
    NSString *nameStr = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                      (CFStringRef)mmnt.name,
                                                                                      NULL,
                                                                                      (CFStringRef)@"&",
                                                                                      kCFStringEncodingUTF8));
    
    if(mmnt.body){
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[mmnt bodyToNSDictionary] options:0 error:nil];
        NSString *body = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        body = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                          (CFStringRef)body,
                                                                                          NULL,
                                                                                          (CFStringRef)@"&",
                                                                                          kCFStringEncodingUTF8));
    
    
        postString = [NSString stringWithFormat:@"lat=%.20g&lng=%.20g&time_saved=%@&id=%@&name=%@&body=%@&ownerId=%i&recipients=%@&uploadId=%@&type=%@",
                            mmnt.lat,
                            mmnt.lng,
                            [NSString stringWithFormat:@"%f", [mmnt.timestamp timeIntervalSince1970] ],
                            mmnt.momuntId,
                            nameStr,
                            body,
                            mmnt.ownerId,
                            recipientsString,
                            mmnt.uploadId,
                            mmnt.type
                            ];
    }else{
        
        postString = [NSString stringWithFormat:@"lat=%.20g&lng=%.20g&time_saved=%@&id=%@&name=%@&ownerId=%i&recipients=%@&uploadId=%@&type=%@",
                                mmnt.lat,
                                mmnt.lng,
                                [NSString stringWithFormat:@"%f", [mmnt.timestamp timeIntervalSince1970] ],
                                mmnt.momuntId,
                                nameStr,
                                mmnt.ownerId,
                                recipientsString,
                                mmnt.uploadId,
                                mmnt.type
                                ];
    }
    
    
    
    NSData *postDataString = [postString dataUsingEncoding:NSUTF8StringEncoding];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@share_momunt", API_BASE] ]; // USE NEW API!
    
    NSMutableURLRequest *mutableRelquest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    [mutableRelquest setURL:url];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postDataString length]];
    [mutableRelquest setHTTPMethod:@"POST"];
    [mutableRelquest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [mutableRelquest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mutableRelquest setHTTPBody:postDataString];
    
    // ADD AUTHENTICATION HEADER!!!!
    NSString *token = [JNKeychain loadValueForKey:@"AccessToken"];
    [mutableRelquest addValue:token forHTTPHeaderField:@"Authorization"];
    
    NSURLRequest *request = [mutableRelquest copy];

    // ASYNC!
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            [self.delegate storingMomuntFailedWithError:error];
        } else {
            NSError *e;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
            
            BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
            if(failed){
                [self.delegate storingMomuntFailedWithError:e];
            }else{
//                if(willPost){
//                    [self.delegate sharedMomuntData:res];
//                }
                if(completion){
                    completion([res objectForKey:@"messages"]); // send array of created messages to completion block
                }
            }
        }
    }];
    
    
    // AMPLITUDE ---------------------------------------------------------------------------------------------------
    NSString *sharedOn = [recipients containsObject:@"twitter"] ? @"twitter" :
                        [recipients containsObject:@"facebook"] ? @"facebook" : @"message";
    NSInteger numShares = [recipients containsObject:@"twitter"] || [recipients containsObject:@"facebook"] ? 0 : [recipients count];
    
    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    [eventProperties setValue:[NSNumber numberWithDouble:mmnt.lat] forKey:@"latitude"];
    [eventProperties setValue:[NSNumber numberWithDouble:mmnt.lng] forKey:@"longitude"];
    [eventProperties setValue:mmnt.momuntId forKey:@"momuntId"];
    [eventProperties setValue:mmnt.type forKey:@"type"];
    [eventProperties setValue:sharedOn forKey:@"sharedOn"];
    [eventProperties setValue:[NSNumber numberWithInteger:[mmnt.timestamp timeIntervalSince1970]] forKey:@"timestamp"];
    [eventProperties setValue:[NSNumber numberWithInteger:numShares] forKey:@"numShares"];
    [Amplitude logEvent:@"shared momunt" withEventProperties:eventProperties];
    //--------------------------------------------------------------------------------------------------------------

}

-(void)uploadImage:(UIImage *)image quality:(CGFloat)q withCoordinate:(CLLocationCoordinate2D)coordinate withTimestamp:(NSDate *)timestamp uId:(NSString *)uId{
    if(![MTReachabilityManager isReachable])
        return;
    
    // RUNS ON A BACKGROUND THREAD
    
    /*
	 turning the image into a NSData object
	 getting the image back out of the UIImageView
     */
	NSData *imageData = UIImageJPEGRepresentation(image, q); // 1.0 = best compression quality (0.0 to 1.0)
//	NSString *urlString = @"http://www.momunt.com/alpha/api/upload_image.php";
     NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@upload/photo", API_BASE] ]; // USE NEW API!
	
	// setting up the request object now
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:url];
	[request setHTTPMethod:@"POST"];
	
	/*
	 add some header info now
	 we always need a boundary when we post a file
	 also we need to set the content type
	 
	 You might want to generate a random boundary..
     */
	NSString *boundary = @"---------------------------14737809831466499882746641449";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	/*
	 now lets create the body of the post
     */
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[@"Content-Disposition: form-data; name=\"momuntfile\"; filename=\"momuntUpload.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[NSData dataWithData:imageData]];
    
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"latitude\"\r\n\r\n%.20g", coordinate.latitude] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"longitude\"\r\n\r\n%.20g", coordinate.longitude] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    //[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"timestamp\"\r\n\r\n%f",  [[[NSDate alloc] init] timeIntervalSince1970]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"timestamp\"\r\n\r\n%f",  [timestamp timeIntervalSince1970]] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user\"\r\n\r\n%d", [MMNTAccountManager sharedInstance].userId] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uniqueId\"\r\n\r\n%@", uId] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	// setting the body of the post to the reqeust
	[request setHTTPBody:body];
    
    // ADD AUTHENTICATION HEADER!!!!
    NSString *token = [JNKeychain loadValueForKey:@"AccessToken"];
    [request addValue:token forHTTPHeaderField:@"Authorization"];
    
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if(error){
        [self alertServerError];
        CLS_LOG(@"failed to delete photo with message: %@", [error localizedDescription]);
        return;
    }
    
    NSError *e;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    CLS_LOG(@"uploaded image with message: %@", [res objectForKey:@"message"] );

}

-(BOOL)checkUserExists:(NSString *)username{
    NSString *urlString = [NSString stringWithFormat:@"%@user/%@", API_BASE, username ];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:urlString] ];
    
    NSError *e;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    BOOL userExists = [[res objectForKey:@"error"]boolValue] == NO;
    return userExists;

}

-(void)getAllUsersWithCompletion:(void (^)(NSArray *obj))completion{
    if(![MTReachabilityManager isReachable])
        completion(nil);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@users", API_BASE] ];
    NSMutableURLRequest *mutableRelquest = [[NSMutableURLRequest alloc] initWithURL: url ];
    NSURLRequest *request = [self addAuthHeader:mutableRelquest];

    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            CLS_LOG(@"failed get all users");
            completion(nil);
        } else {
            NSError *e;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
            NSArray *users = [res objectForKey:@"users"];
            if (completion) {
                completion(users);
            }

        }
    }];
}

-(void)syncContacts:(NSArray *)contacts completion:(void (^)(NSDictionary *obj))completion{
    if(![MTReachabilityManager isReachable])
        completion(nil);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:contacts options:0 error:nil];
    NSString *addressbook = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    addressbook = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                     (CFStringRef)addressbook,
                                                                                     NULL,
                                                                                     (CFStringRef)@"&",
                                                                                     kCFStringEncodingUTF8));

    
    NSString *postString = [NSString stringWithFormat:@"addressbook=%@", addressbook];
    NSData *postDataString = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@contacts", API_BASE] ];
    NSMutableURLRequest *mutableRelquest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    [mutableRelquest setURL:url];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postDataString length]];
    [mutableRelquest setHTTPMethod:@"POST"];
    [mutableRelquest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [mutableRelquest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mutableRelquest setHTTPBody:postDataString];
    
    NSURLRequest *request = [self addAuthHeader:mutableRelquest];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            CLS_LOG(@"failed get contacts");
            completion(nil);
        } else {
            NSError *e;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
            if (completion) {
                completion(res);
            }
            
        }
    }];
}


-(void)cancelUserRegistration:(NSInteger)userId{
    
    NSString *urlString = [NSString stringWithFormat:@"%@cancel/registration/%i", API_BASE, [MMNTAccountManager sharedInstance].userId ];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:urlString] ];
    
    NSString *token = @"82EEA471-20F0-90AA-CD47-481600F9930B"; // app token
    [request addValue:token forHTTPHeaderField:@"Authorization"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSLog(@"failed cancel user");
        } else {
            NSError *e;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
            
            BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
            if(failed){
                NSLog(@"failed cancel user");
            }else{
               NSLog(@"cancelled user");
            }
            
        }
    }];
}

-(void)registerNumber:(NSString *)number completion:(void (^)(BOOL done))completion{
    if(![MTReachabilityManager isReachable]){
        [self alertServerError];
        completion(NO);
        return;
    }

    NSString *urlString = [NSString stringWithFormat:@"%@register/%@", API_BASE, number ];
    NSMutableURLRequest *mutableRelquest = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:urlString] ];
    
    NSURLRequest *request = [self addAuthHeader:mutableRelquest]; // add authentication
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            [self alertServerError];
            CLS_LOG(@"failed to register number with error: %@", [error localizedDescription]);
            return;
//            completion(NO);
        }
        else {
            NSError *e;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
            if (e || !res) {
//                [self alertServerError];
                CLS_LOG(@"failed to register number with error: %@", [error localizedDescription]);
                completion(NO);
                return;
            }
            
            BOOL fail = [[res objectForKey:@"error"]boolValue] == YES;
            completion(!fail);
            
        }
    }];

}

-(void)verifyNumber:(NSString *)number withCode:(NSString *)code completion:(void (^)(BOOL done))completion{
    if(![MTReachabilityManager isReachable]){
        [self alertServerError];
        completion(NO);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@verify/%@/%@", API_BASE, number, code ];
    NSMutableURLRequest *mutableRelquest = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:urlString] ];
    
    NSURLRequest *request = [self addAuthHeader:mutableRelquest]; // add authentication
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            [self alertServerError];
            CLS_LOG(@"failed to verify number with error: %@", [error localizedDescription]);
            //            completion(NO);
            return;
        }
        else {
            NSError *e;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
            if (e) {
//                [self alertServerError];
                CLS_LOG(@"failed to verify number with error: %@", [error localizedDescription]);
                completion(NO);
                return;
            }
            
            BOOL success = [[res objectForKey:@"error"]boolValue] == NO;
            completion(success);
            
        }
    }];

}

-(void)registerUser:(NSString *)username password:(NSString *)password phone:(NSString *)phone profile:(UIImage *)profile instagramToken:(NSString *)token fullName:(NSString *)fullName completion:(void (^)(NSDictionary *result))completion
{
    if(![MTReachabilityManager isReachable]){
        [self alertServerError];
        completion(nil);
    }
    
    NSData *imageData = UIImageJPEGRepresentation(profile, 0.6); // 1.0 = best compression quality (0.0 to 1.0)
	// setting up the URL to post to
	
    NSString *urlString = [NSString stringWithFormat:@"%@register", API_BASE];
    
	// setting up the request object now
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"POST"];
    
    NSString *timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    NSString *filename = [NSString stringWithFormat:@"%@%@%@", username, timestamp, @".jpg"];
    
    /*
	 add some header info now
     */
	NSString *boundary = @"---------------------------14737809831466499882746641449";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // URL ENCODE POST DATA
    password = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                     (CFStringRef)password,
                                                                                     NULL,
                                                                                     (CFStringRef)@"&",
                                                                                     kCFStringEncodingUTF8));
    // URL ENCODE POST DATA
    username = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                     (CFStringRef)username,
                                                                                     NULL,
                                                                                     (CFStringRef)@"&",
                                                                                     kCFStringEncodingUTF8));
    
    fullName = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                     (CFStringRef)fullName,
                                                                                     NULL,
                                                                                     (CFStringRef)@"&",
                                                                                     kCFStringEncodingUTF8));
	
	/*
	 now lets create the body of the post
     */
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"profile\"; filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[NSData dataWithData:imageData]];
    
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"username\"\r\n\r\n%@", username] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"password\"\r\n\r\n%@", password] dataUsingEncoding:NSUTF8StringEncoding]];
    
//    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"email\"\r\n\r\n%@", email] dataUsingEncoding:NSUTF8StringEncoding]];
    if(phone!=nil){
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"phone\"\r\n\r\n%@", phone] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"fullName\"\r\n\r\n%@", fullName] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if(token!=nil){
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"instagramToken\"\r\n\r\n%@", token] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	// setting the body of the post to the reqeust
	[request setHTTPBody:body];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            CLS_LOG(@"registration failed with message: %@", [error localizedDescription]);
            [self alertServerError];
            return;
//            completion(0);
        } else {
            NSError *e;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
            if (e) {
                CLS_LOG(@"registration failed with message: %@", [e localizedDescription]);
                [self alertServerError];
                return;
//                completion(0);
            }else{
                completion(res);
            }
//            if(status!=200){
//                
//                // POST NOTIFICATION that registration failed
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"registrationFailed"
//                                                                    object:self
//                                                                  userInfo:[NSDictionary dictionaryWithObject:username
//                                                                                                       forKey:@"username"]];
//
//            }else{
//                NSInteger status = [[res objectForKey:@"status"] integerValue];
//                NSString *usrId = [res valueForKey:@"userId"];
//                [[MMNTAccountManager sharedInstance] setUserId:[usrId integerValue]];
//            }

        }
    }];
}

-(void)authenticate:(NSString *)platform status:(NSInteger)status withToken:(NSString *)token setName:(NSString *)name{
    NSString *postString = [NSString stringWithFormat:@"status=%i&token=%@&fullname=%@", status, token, name];
    NSData *postDataString = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url=[NSURL URLWithString: [NSString stringWithFormat:@"%@authenticate/%@", API_BASE, platform]];
    NSMutableURLRequest *mutableRelquest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    [mutableRelquest setURL:url];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postDataString length]];
    [mutableRelquest setHTTPMethod:@"POST"];
    [mutableRelquest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [mutableRelquest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mutableRelquest setHTTPBody:postDataString];
    
    NSURLRequest *request = [self addAuthHeader:mutableRelquest]; // add authentication
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSLog(@"couldnt authenticate");
        } else {
            NSLog(@"authenticated!");
        }
    }];

    
}

-(void)verifyNumber:(NSString *)phone withCode:(NSString *)code forUser:(NSString *)userId{
    NSString *postString = [NSString stringWithFormat:@"phone=%@&code=%@&userId=%@", phone, code, userId];
    NSData *postDataString = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url=[NSURL URLWithString: [NSString stringWithFormat:@"%@verify", API_BASE]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    [request setURL:url];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postDataString length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postDataString];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
        if (error) {
            [self.delegate failedVerificationWithMessage:@"error"];
        } else {
            NSError *e;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
            
            BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
            if(failed){
                [self.delegate failedVerificationWithMessage:[res valueForKey:@"message"]];
            }else{
                NSString *token = [res valueForKey:@"token"];
                [self.delegate receivedAccessToken:token];
            }
        }
    }];
}

/* --------------------- Get user Info --------------------- */

- (NSDictionary *)getUserInfo{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"OK", @"status",  nil];
    if(![MTReachabilityManager isReachable]){
        [self alertNoInternet];
        [result setObject:@"no internet" forKey:@"status"];
        return result;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@user", API_BASE]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.momunt.com/api/user"]];
    // Create a mutable copy of the immutable request and add more headers
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    NSString *token = [JNKeychain loadValueForKey:@"AccessToken"];
    [mutableRequest addValue:token forHTTPHeaderField:@"Authorization"];
    
    // Now set our request variable with an (immutable) copy of the altered request
    request = [mutableRequest copy];
    
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error) {
        CLS_LOG(@"Invalid API key");
        CLS_LOG(@"error getUserInfo: %@",[error localizedDescription]);
        [result setObject:@"invalid API key" forKey:@"status"];
        return result;
    }
    NSError *e;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    if(e){
        CLS_LOG(@"error getUserInfo: %@",[e localizedDescription]);
        [result setObject:@"invalid API key" forKey:@"status"];
        return result;
    }
    
    BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
    if(failed){
        CLS_LOG(@"error getUserInfo: %@",[res objectForKey:@"message"]);
        [result setObject:@"invalid API key" forKey:@"status"];
        return result;
    }else{
        CLS_LOG(@"got user info");
        [result setObject:@"OK" forKey:@"status"];
        [[MMNTAccountManager sharedInstance] populateWithData:data];
        return result;

    }
    
    return NO;
}

- (NSDictionary *)loginUsername:(NSString *)username password:(NSString *)password{
    // URL ENCODE
    password = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                          (CFStringRef)password,
                                                                          NULL,
                                                                          (CFStringRef)@"&",
                                                                          kCFStringEncodingUTF8));
    
    username = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                     (CFStringRef)username,
                                                                                     NULL,
                                                                                     (CFStringRef)@"&",
                                                                                     kCFStringEncodingUTF8));
    
    NSString *postString = [NSString stringWithFormat:@"username=%@&password=%@", username, password];
    NSData *postDataString = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@login", API_BASE] ];
    NSMutableURLRequest *mutableRelquest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    [mutableRelquest setURL:url];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postDataString length]];
    [mutableRelquest setHTTPMethod:@"POST"];
    [mutableRelquest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [mutableRelquest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mutableRelquest setHTTPBody:postDataString];
    
    
    NSData *data = [NSURLConnection sendSynchronousRequest:mutableRelquest returningResponse:nil error:nil];
    NSError *e;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    
    BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
    if(failed){
        return nil;
    }else{
        return res;
    }

}

-(void)logout{
    NSString *postString = [NSString stringWithFormat:@"deviceToken=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"DeviceTokenString"]];
    NSData *postDataString = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@logout", API_BASE] ];
    NSMutableURLRequest *mutableRelquest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    [mutableRelquest setURL:url];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postDataString length]];
    [mutableRelquest setHTTPMethod:@"POST"];
    [mutableRelquest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [mutableRelquest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mutableRelquest setHTTPBody:postDataString];
    
    NSURLRequest *request = [self addAuthHeader:mutableRelquest]; // add authentication
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSError *e;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    
    BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
    if(failed){
        NSLog(@"logging out failed");
    }else{
        NSLog(@"logging out success");
    }

}

-(void)resetPasswordForPhone:(NSString *)phone completion:(void (^)(BOOL error))completion{
    NSString *postString = [NSString stringWithFormat:@"phone=%@", phone];
    NSData *postDataString = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@reset/password", API_BASE] ];
    NSMutableURLRequest *mutableRelquest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    [mutableRelquest setURL:url];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postDataString length]];
    [mutableRelquest setHTTPMethod:@"POST"];
    [mutableRelquest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [mutableRelquest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mutableRelquest setHTTPBody:postDataString];
    
    [NSURLConnection sendAsynchronousRequest:mutableRelquest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSLog(@"error on password reset");
            if (completion) {completion(NO);}

        } else {
            NSError *e;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
            if (completion) {
                completion([[res valueForKey:@"error"] boolValue]);
            }
        }
        
        
    }];
}


-(void)resetPasswordFrom:(NSString *)oldPass to:(NSString *)newPass completion:(void (^)(NSString *token))completion{
    if(![MTReachabilityManager isReachable]){
        [self alertServerError];
        completion(nil);
    }
    
    oldPass = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                       (CFStringRef)oldPass,
                                                                                       NULL,
                                                                                       (CFStringRef)@"&",
                                                                                       kCFStringEncodingUTF8));
    newPass = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                     (CFStringRef)newPass,
                                                                                                     NULL,
                                                                                                     (CFStringRef)@"&",
                                                                                                     kCFStringEncodingUTF8));
    
    NSString *postString = [NSString stringWithFormat:@"oldpassword=%@&newpassword=%@", oldPass, newPass];
    
    
    
    NSData *postDataString = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@change/password", API_BASE] ];
    NSMutableURLRequest *mutableRelquest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    [mutableRelquest setURL:url];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postDataString length]];
    [mutableRelquest setHTTPMethod:@"POST"];
    [mutableRelquest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [mutableRelquest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mutableRelquest setHTTPBody:postDataString];
    
    NSURLRequest *request = [self addAuthHeader:mutableRelquest]; // add authentication
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error){
            CLS_LOG(@"failed to reset password with message: %@", [error localizedDescription]);
            [self alertServerError];
            completion(nil);
        }
        
        NSError *e;
        NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        
        if(e){
            CLS_LOG(@"failed toreset password with message: %@", [e localizedDescription]);
            [self alertServerError];
            completion(nil);
        }
        
        BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
        if(failed){
            completion(nil);
        }else{
            completion([res objectForKey:@"token"]);
        }
    }];
    

}

/* Get public user info */
-(NSDictionary *)getPublicProfile:(NSString *)phone{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@public/user/%@", API_BASE, phone]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSError *e;
    if(data){
        NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        return res;
    }
    return nil;
}

/* --------------------- Fetch chats --------------------- */
-(void)fetchUserChats{
    if(![MTReachabilityManager isReachable]){
        return;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@chats", API_BASE]];
    NSURLRequest *r = [NSURLRequest requestWithURL:url];
    NSURLRequest *request = [self addAuthHeader:r]; // add authentication
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            NSLog(@"error fetching user chats");
        } else {
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            
            BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
            if(failed){
                NSLog(@"fetching user chats failed");
            }else{
                [[MMNTAccountManager sharedInstance] updateChatData:data];
            }

        }
    }];
    
}

-(MMNTChatObj *)fetchChatById:(CGFloat)chatId{
    if(![MTReachabilityManager isReachable]){
        return nil;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@chat/%f", API_BASE, chatId]];
    NSURLRequest *r = [NSURLRequest requestWithURL:url];
    NSURLRequest *request = [self addAuthHeader:r]; // add authentication
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSError *e;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    
    BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
    if(failed){
        NSLog(@"fetching chat by id failed");
        return nil;
    }else{
        MMNTChatObj *chat = [[MMNTChatObj alloc] initWithData:data];
        return chat;
    }

}

-(void)fetchMessageById:(NSInteger)messageId{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@message/%i", API_BASE, messageId]];
    NSURLRequest *r = [NSURLRequest requestWithURL:url];
    NSURLRequest *request = [self addAuthHeader:r]; // add authentication

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            NSLog(@"fetching message by id failed");
        } else {
            NSError *e;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
            
            BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
            if(failed){
                NSLog(@"fetching message by id failed");
            }else{
                [[MMNTAccountManager sharedInstance] addMessageWithData:res];
            }
        }
    }];

    
}


/* --------------------- Start a new chat with members = array of phone numbers --------------------- */
-(NSData *)startChat:(NSArray *)members{
    if(![MTReachabilityManager isReachable])
        return false;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:members options:NSJSONWritingPrettyPrinted error:nil];
    NSString *membersString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *postString = [NSString stringWithFormat:@"recipients=%@", membersString];
    NSData *postDataString = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@chat", API_BASE] ];
    NSMutableURLRequest *mutableRelquest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    [mutableRelquest setURL:url];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postDataString length]];
    
    [mutableRelquest setHTTPMethod:@"POST"];
    [mutableRelquest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [mutableRelquest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mutableRelquest setHTTPBody:postDataString];
    
    // ADD AUTHENTICATION HEADER!!!!
    NSString *token = [JNKeychain loadValueForKey:@"AccessToken"];
    [mutableRelquest addValue:token forHTTPHeaderField:@"Authorization"];
    NSURLRequest *request = [mutableRelquest copy];
    
    // return chat Object
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSError *e;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    
    BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
    if(failed){
        NSLog(@"starting chat failed");
        return false;
    }else{
        return data;
    }
    

}
/* --------------------- Fetch chat messages --------------------- */
-(void)fetchMessagesForChatId:(NSInteger)chatId{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@messages/%i", API_BASE, chatId]];
    NSURLRequest *r = [NSURLRequest requestWithURL:url];
    NSURLRequest *request = [self addAuthHeader:r]; // add authentication
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSError *e;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    
    BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
    if(failed){
        NSLog(@"fetching messages for chatId failed");
    }else{
//        [[MMNTAccountManager sharedInstance] updateChatData:data];
//        POST NOTIFICATION that the username is taken
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"fetchedChatMessages"
//                                                            object:self
//                                                          userInfo:[NSDictionary dictionaryWithObject:[res valueForKey:@"username"]
//                                                                                               forKey:@"username"]];
    }
}

-(void)fetchMessagesForChat:(NSInteger)chatId maxMessage:(NSInteger)maxId completion:(void (^)(NSMutableArray *obj))completion{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@messages/%i/%i", API_BASE, chatId, maxId]];
    NSURLRequest *r = [NSURLRequest requestWithURL:url];
    NSURLRequest *request = [self addAuthHeader:r]; // add authentication
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSLog(@"failed get more chats");
        } else {
            NSError *e;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
            NSArray *messages = [res valueForKey:@"messages"];
            
            NSMutableArray *msgArray = [MMNTChatObj parseMessageData:messages];
            
            if (completion) {
                completion(msgArray);
            }
            
        }
    }];
}


/* --------------------- Post messages --------------------- */
-(void)postMessage:(MMNTMessageObj *)message completion:(void (^)(NSDictionary *dict))completion{
    NSData *msgData = [NSJSONSerialization dataWithJSONObject:message.message options:0 error:nil];
    NSString *msgString = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
    msgString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                      (CFStringRef)msgString,
                                                                                      NULL,
                                                                                      (CFStringRef)@"&",
                                                                                      kCFStringEncodingUTF8));
    
    NSString *postString = [NSString stringWithFormat:@"chatId=%i&message=%@", message.chatId, msgString];
    NSData *postDataString = [postString dataUsingEncoding:NSUTF8StringEncoding];
    

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@message", API_BASE] ];
    NSMutableURLRequest *mutableRelquest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    [mutableRelquest setURL:url];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postDataString length]];
    [mutableRelquest setHTTPMethod:@"POST"];
    [mutableRelquest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [mutableRelquest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mutableRelquest setHTTPBody:postDataString];
    // ADD AUTHENTICATION HEADER!!!!
    NSString *token = [JNKeychain loadValueForKey:@"AccessToken"];
    [mutableRelquest addValue:token forHTTPHeaderField:@"Authorization"];
    NSURLRequest *request = [mutableRelquest copy];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            NSLog(@"failed posting message");
        } else {
            NSError *e;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
            
            BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
            if(failed){
                NSLog(@"failed posting message");
            }else{
                
                if(completion){
                    completion(res);
                }
            }
        }
    }];

    
}
-(void)markMessageAsRead:(MMNTMessageObj *)message{
    if(![MTReachabilityManager isReachable])
        return;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@message/read/%i", API_BASE, message.messageId] ];
    NSMutableURLRequest *mutableRelquest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    // ADD AUTHENTICATION HEADER!!!!
    NSString *token = [JNKeychain loadValueForKey:@"AccessToken"];
    [mutableRelquest addValue:token forHTTPHeaderField:@"Authorization"];
    NSURLRequest *request = [mutableRelquest copy];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            CLS_LOG(@"error marking message as read");
        } else {
            CLS_LOG(@"marked message as read");
        }
    }];

}
-(void)fetchNewMessages:(void (^)(BOOL done))completion{
    if(![MTReachabilityManager isReachable])
        return;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@newmessages", API_BASE]];
    NSURLRequest *r = [NSURLRequest requestWithURL:url];
    NSURLRequest *request = [self addAuthHeader:r]; // add authentication
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            CLS_LOG(@"error fetching messages: %@",[error localizedDescription]);
            if(completion)
                completion(NO);
        } else {
            NSError *e;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
            if(e){
                CLS_LOG(@"error fetching messages: %@",[error localizedDescription]);
                if(completion)
                    completion(NO);
                return;
            }
            
            BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
            if(failed){
                CLS_LOG(@"fetching new messages failed");
                if(completion)
                    completion(NO);

            }else{
                
                CLS_LOG(@"fetched new messages");
                
                NSArray *messages = [res valueForKey:@"messages"];
                for (NSDictionary *msgDict in messages) {
                    [[MMNTAccountManager sharedInstance] addMessageWithData:msgDict];
                }
                if(completion)
                    completion(YES);
                
            }

            
        }
    }];

}

-(void)registerDeviceToken{
    if(![MTReachabilityManager isReachable])
        return;
    
    // if have device token - register for this user
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceTokenString"];
    if(!deviceToken)
        return;

    
    NSString *postString = [NSString stringWithFormat:@"deviceToken=%@", deviceToken];
    NSData *postDataString = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@device", API_BASE] ];
    NSMutableURLRequest *mutableRelquest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    [mutableRelquest setURL:url];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postDataString length]];
    [mutableRelquest setHTTPMethod:@"POST"];
    [mutableRelquest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [mutableRelquest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mutableRelquest setHTTPBody:postDataString];
    // ADD AUTHENTICATION HEADER!!!!
    NSString *token = [JNKeychain loadValueForKey:@"AccessToken"];
    [mutableRelquest addValue:token forHTTPHeaderField:@"Authorization"];
    NSURLRequest *request = [mutableRelquest copy];
    
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error) {
        CLS_LOG(@"error registering token: %@",[error localizedDescription]);
        return;
    }
    NSError *e;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    if(e){
        CLS_LOG(@"error registering token: %@",[e localizedDescription]);
        return;
    }

    BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
    if(failed){
        CLS_LOG(@"error registering token: %@",[res objectForKey:@"message"]);
    }else{
        CLS_LOG(@"yay registered device");// with token: %@", deviceToken);
    }

}


/* 
 TRENDING - update list of trending momunts
 */
-(void)getTrendingMomunts{
    [self getTrendingMomunts:^(BOOL done) {}];
}

-(void)getTrendingMomunts:(void (^)(BOOL done))completion{
    if(![MTReachabilityManager isReachable]){
        completion(NO);
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@allTrending", API_BASE]];
    NSURLRequest *r = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:r queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            NSLog(@"error fetching trending momunts");
            if(completion)
                completion(NO);
        } else {
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            
            BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
            if(failed){
                if(completion)
                    completion(NO);
            }else{
                [[MMNTAccountManager sharedInstance] setTrendingData:data];
                if(completion)
                    completion(YES);
            }
            
        }
    }];

}

-(void)finishedTaskId:(NSInteger)taskId{
    if(![MTReachabilityManager isReachable])
        return;

    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@user/completed/task/%i", API_BASE, taskId]];
    NSURLRequest *r = [NSURLRequest requestWithURL:url];
    NSURLRequest *request = [self addAuthHeader:r]; // add authentication
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            CLS_LOG(@"failed finishedTaskId with messageL %@", [error localizedDescription]);
        } else {
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            
            BOOL failed = [[res objectForKey:@"error"] boolValue] == YES;
            if(failed){
                CLS_LOG(@"failed finishedTaskId with messageL %@", [res objectForKey:@"message"]);
            }else{
                CLS_LOG(@"set task done");
            }
            
        }
    }];
}



/* --------------------- Add authorization header to request --------------------- */

-(NSURLRequest *)addAuthHeader:(NSURLRequest *)request{
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    NSString *token = [JNKeychain loadValueForKey:@"AccessToken"];
    [mutableRequest addValue:token forHTTPHeaderField:@"Authorization"];
    return [mutableRequest copy];
}

/* Flag photo */
-(void)flagRequest:(MMNTPhoto *)photo{
    if(![MTReachabilityManager isReachable])
        return;

    NSString *photoUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                          (CFStringRef)[[[photo valueForKey:@"images"] valueForKey:@"standard_resolution"] valueForKey:@"url"],
                                                                          NULL,
                                                                          (CFStringRef)@"&",
                                                                          kCFStringEncodingUTF8));
    
    NSString *postString = [NSString stringWithFormat:@"photoId=%@&photoUrl=%@&userId=%@", photo.id, photoUrl, photo.user ];
    NSData *postDataString = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@flagrequest", API_BASE] ];
    NSMutableURLRequest *mutableRelquest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    [mutableRelquest setURL:url];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postDataString length]];
    [mutableRelquest setHTTPMethod:@"POST"];
    [mutableRelquest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [mutableRelquest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mutableRelquest setHTTPBody:postDataString];
    // ADD AUTHENTICATION HEADER!!!!
    NSString *token = [JNKeychain loadValueForKey:@"AccessToken"];
    [mutableRelquest addValue:token forHTTPHeaderField:@"Authorization"];
    NSURLRequest *request = [mutableRelquest copy];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            CLS_LOG(@"failed flag request with messageL %@", [error localizedDescription]);
        } else {
            NSError *e;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
            
            BOOL failed = [[res objectForKey:@"error"]boolValue] == YES;
            if(failed){
                CLS_LOG(@"failed flag request with messageL %@", [res objectForKey:@"message"]);
            }else{
                CLS_LOG(@"done flag request");
            }
            
        }
    }];
    
}

/* Delete photo */
-(void)deletePhoto:(MMNTPhoto *)photo{
    if(![MTReachabilityManager isReachable])
        return;

    
    NSString *postString = [NSString stringWithFormat:@"photoId=%@", photo.id ];
    NSData *postDataString = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@delete/photo", API_BASE] ];
    NSMutableURLRequest *mutableRelquest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    [mutableRelquest setURL:url];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postDataString length]];
    [mutableRelquest setHTTPMethod:@"POST"];
    [mutableRelquest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [mutableRelquest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mutableRelquest setHTTPBody:postDataString];
    // ADD AUTHENTICATION HEADER!!!!
    NSString *token = [JNKeychain loadValueForKey:@"AccessToken"];
    [mutableRelquest addValue:token forHTTPHeaderField:@"Authorization"];
    NSURLRequest *request = [mutableRelquest copy];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            CLS_LOG(@"failed to delete photo with message: %@", [error localizedDescription]);
        } else {
            NSError *e;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
            
            BOOL failed = [[res objectForKey:@"error"] boolValue] == YES;
            if(failed){
                CLS_LOG(@"failed to delete photo with message: %@", [res objectForKey:@"message"]);
            }else{
                CLS_LOG(@"deleted photo");
            }
            
        }
    }];
    
}



@end
