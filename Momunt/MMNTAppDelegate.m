//
//  MMNTAppDelegate.m
//  Momunt
//
//  Created by Masha Belyi on 6/16/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//
#import "Amplitude.h"

#import <FacebookSDK/FacebookSDK.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


#import "MMNTAppDelegate.h"
#import "MMNT_SharedVars.h"
#import "MMNTViewController.h"
#import "MTReachabilityManager.h"

#import "MMNTDataController.h"
#import "MMNTAccountManager.h"
#import "MMNTApiCommuniator.h"
#import "JNKeychain.h"
#import "MMNTChatObj.h"

@implementation MMNTAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions");
    
    [MMNTDataController sharedInstance].firstLaunch = YES;
    [[MMNTApiCommuniator sharedInstance] getTrendingMomunts];
    [[MMNTApiCommuniator sharedInstance] registerDeviceToken];
    
    // INITIALIZE ANALYTICS
    [Amplitude initializeApiKey:@"566dacda860af72ecbead86e2e33cff4"]; // Momunt Test App
//    [Amplitude initializeApiKey:@"eb6c64a259fcbe11c9a3dc3ce50130cc"]; // Momunt Production App
    
    NSMutableDictionary *userProperties = [NSMutableDictionary dictionary];
    [userProperties setValue:@"1.5" forKey:@"version"];
    [userProperties setValue:@"1.0" forKey:@"build"];
    [Amplitude setUserProperties:userProperties];
    
    // INITIALIZE CRASHLYTICS
    [Fabric with:@[CrashlyticsKit]];
    
    // REACHABILITY - Instantiate Shared Manager
    [MTReachabilityManager sharedManager];
    
    // background fetch
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum]; // NSTimeINterval in seconds. Default for now
    
    NSDictionary *notification = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notification) {
        // launched from notification. Show chat view
        [MMNTDataController sharedInstance].openedFromNotification = YES;
        NSDictionary *apsInfo = [notification objectForKey:@"aps"];
        
        if([[apsInfo allKeys] containsObject:@"type"] && [[apsInfo valueForKey:@"type"] isEqualToString:@"pushMomunt"]){
            [MMNTDataController sharedInstance].openMomuntId = [apsInfo valueForKey:@"momuntId"];
            
            // AMPLITUDE ---------------------------------------------------------------------------------------------------
            NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
            [eventProperties setValue:[apsInfo valueForKey:@"momuntId"] forKey:@"momuntId"];
            [Amplitude logEvent:@"opened momunt push notification" withEventProperties:eventProperties];
            //--------------------------------------------------------------------------------------------------------------
            
        }else{
        
            NSString *chatId = [apsInfo valueForKey:@"chatId"];
            [MMNTDataController sharedInstance].openChatId = chatId;
            NSLog(@"chatId:%@", chatId);
        }

    } else {
        // from the springboard
    }
    
    
    
    return YES;
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceTokenString = [NSString stringWithFormat:@"%@", deviceToken];
    // send this to server...
    deviceTokenString = [deviceTokenString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokenString forKey:@"DeviceTokenString"];
    
    [[MMNTApiCommuniator sharedInstance] registerDeviceToken];
    
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error
{
    NSLog(@"failed to register");
}
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    UIUserNotificationType allowedTypes = [notificationSettings types];
    //register to receive notifications
    [application registerForRemoteNotifications];
}
//For interactive notification only
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

// LOCAL NOTIFICATIONS
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler {
    NSLog(@"opened from notification");
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if (application.applicationState == UIApplicationStateInactive ) {
        NSLog(@"local notification, inactive state");
        
        // POST NOTIFICATION to show chat view
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showChat"
                                                            object:self
                                                          userInfo:nil];
        
        // open correct chat view!
//        NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
//        if([[apsInfo allKeys] containsObject:@"chatId"]){
//            NSString *chatId = [apsInfo valueForKey:@"chatId"];
        NSString *chatId = [NSString stringWithFormat:@"%i", 1];
        
            // transition to chat view
            [[NSNotificationCenter defaultCenter] postNotificationName:@"openedNotification"
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObject:chatId
                                                                                                   forKey:@"chatId"]];
//        }

        
        //The application received the notification from an inactive state, i.e. the user tapped the "View" button for the alert.
        //If the visible view controller in your view controller stack isn't the one you need then show the right one.
    }
    
    if(application.applicationState == UIApplicationStateActive ) {
        NSLog(@"local notification, active state");
        //The application received a notification in the active state, so you can display an alert view or do something appropriate.
    }
}


// listen to push notifications
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    NSLog(@"got notification");
    if(application.applicationState == UIApplicationStateBackground){
        NSLog(@"background state");
        
        
        if([[userInfo allKeys] containsObject:@"momunt"]){

// -----------------------
            NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
            [sessionConfiguration setHTTPAdditionalHeaders:@{@"Authorization":[JNKeychain loadValueForKey:@"AccessToken"]}];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
            
            NSDictionary *data = [userInfo objectForKey:@"momunt"];
            
            // send local notification
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.fireDate = [NSDate date];
            localNotification.alertBody = [data objectForKey:@"alert"];
            localNotification.soundName = @"MomuntSound.mp3";
            localNotification.applicationIconBadgeNumber = [[data objectForKey:@"badge"] integerValue];
            localNotification.userInfo = [NSDictionary dictionaryWithObject:[data objectForKey:@"chatId"] forKey:@"chatId"];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

            [[MMNTApiCommuniator sharedInstance] fetchNewMessages:^(BOOL done) {
                if(done){
                    handler(UIBackgroundFetchResultNewData);
                }else{
                    handler(UIBackgroundFetchResultFailed);
                }
            }];
            
            
        }else{
            handler(UIBackgroundFetchResultNoData);
        }

    }
    else if(application.applicationState == UIApplicationStateInactive) {
        //download data and go to correct chat
        NSLog(@"inactive state");
        _openFromPushNotification = YES;
        [[MMNTApiCommuniator sharedInstance] fetchNewMessages:^(BOOL done) {}];
        
        // open correct chat view! Do this later
        NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
        if([[apsInfo allKeys] containsObject:@"chatId"] && ![MMNTDataController sharedInstance].openedFromNotification ){
            
            NSString *chatId = [apsInfo valueForKey:@"chatId"];
            MMNTChatObj *chat = [[MMNTAccountManager sharedInstance] getChatById:[chatId intValue]];
            
            // 4) send out notification to show chat view
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showChat"
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObject:chat
                                                                                                   forKey:@"chatObj"]];
        }
        else if([[apsInfo allKeys] containsObject:@"type"] && [[apsInfo valueForKey:@"type"] isEqualToString:@"pushMomunt"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loadingMomunt"
                                                                object:self
                                                              userInfo:nil];
            
            [[MMNTDataController sharedInstance] fetchMomuntWithId:[apsInfo valueForKey:@"momuntId"]];
            
            // AMPLITUDE ---------------------------------------------------------------------------------------------------
            NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
            [eventProperties setValue:[apsInfo valueForKey:@"momuntId"] forKey:@"momuntId"];
            [Amplitude logEvent:@"opened momunt push notification" withEventProperties:eventProperties];
            //--------------------------------------------------------------------------------------------------------------
        }
        
        handler(UIBackgroundFetchResultNoData);
        
    }else{
        handler(UIBackgroundFetchResultNoData);
    }
    
    
    
    //Success
//    handler(UIBackgroundFetchResultNewData);
}

/* --------------------- Add authorization header to request --------------------- */

-(NSURLRequest *)addAuthHeader:(NSURLRequest *)request{
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    NSString *token = [JNKeychain loadValueForKey:@"AccessToken"];
    [mutableRequest addValue:token forHTTPHeaderField:@"Authorization"];
    return [mutableRequest copy];
}


-(void)handleNotification:(NSDictionary *)userInfo{
    NSDictionary *data = [userInfo objectForKey:@"momunt"];
    
    NSString *message = [data valueForKey:@"message"];
//    BOOL ismomunt = [message rangeOfString:@"sent you a momunt"].location != NSNotFound;
    NSDictionary *newMsg;
    
    newMsg = @{@"messageId"    : [data valueForKey:@"messageId"],
               @"message"      : [data valueForKey:@"message"],
               @"username"     : [data valueForKey:@"username"],
               @"profileUrl"   : [NSString stringWithFormat: @"https://s3-us-west-2.amazonaws.com/users.momunt.com/%@.jpg", [data valueForKey:@"username"] ],
               @"chatId"       : [data valueForKey:@"chatId"],
               @"timestamp"    : [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] ],
               @"needToUpdate" : [NSString stringWithFormat: @"%i", 1]
               };
    
    [[MMNTAccountManager sharedInstance] addMessageWithData:newMsg];
    
}

// BACKGROUND FETCH - update trending momunts on background fetch
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    
    [[MMNTApiCommuniator sharedInstance] getTrendingMomunts:^(BOOL done) {
        if(done){
            completionHandler(UIBackgroundFetchResultNewData);
        }else{
            completionHandler(UIBackgroundFetchResultNoData);
        }
    }];
}

// Calling the application from custom app url
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"Calling Application Bundle ID: %@", sourceApplication);
    NSLog(@"URL scheme:%@", [url scheme]);
    NSLog(@"URL query: %@", [url query]);
    
    [Amplitude logEvent:@"opened from url"];
    
    
//    HANDLE FACEBOOK LINKS
//    Return from facebook - go to gallery
    BOOL urlWasHandled = [FBAppCall handleOpenURL:url
                                sourceApplication:sourceApplication
                                  fallbackHandler:^(FBAppCall *call) {
                                      //  NSLog(@"Unhandled deep link: %@", url);
                                      // Here goes the code to handle the links
                                      // Use the links to show a relevant view of your app to the user
                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"returnedFromFacebookShare"
                                                                                          object:self
                                                                                        userInfo:nil];
                                  }];
    
    if(urlWasHandled){
        return YES;
    }
    
    // if not a facebook link - check if it's a momunt link
    NSMutableDictionary *queryObj = [[NSMutableDictionary alloc] init];
    
    NSArray *urlComponents = [[url query] componentsSeparatedByString:@"&"];
    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [pairComponents objectAtIndex:0];
        NSString *value = [pairComponents objectAtIndex:1];
        
        [queryObj setObject:value forKey:key];
    }
    if([[queryObj objectForKey:@"id"] length]){
        [[MMNTDataController sharedInstance] fetchMomuntWithId:[queryObj objectForKey:@"id"]];
    }
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//    NSLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    NSLog(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//    NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    NSLog(@"applicationDidBecomeActive");
    
    NSString *token = [JNKeychain loadValueForKey:@"AccessToken"];
    if(token!=nil && ![MMNTDataController sharedInstance].firstLaunch && !_openFromPushNotification){
        [[MMNTApiCommuniator sharedInstance] fetchNewMessages:^(BOOL done) {}];
        [[[MMNTDataController sharedInstance] MQTTcontroller] connect];
    }
    _openFromPushNotification = NO;
    
    // refresh trending every 2 mins
    _myTimer = [NSTimer scheduledTimerWithTimeInterval: 120.0 target: self
                                                      selector: @selector(refreshTrending:) userInfo: nil repeats: YES];
    [MMNTDataController sharedInstance].firstLaunch = NO;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [_myTimer invalidate];
    // SAVE DATA TO CORE DATA?
}
-(void)refreshTrending:(NSTimer*) t{
    
    [[MMNTApiCommuniator sharedInstance] getTrendingMomunts];

}


/* ---------------------------------------------------------------------------------------------
 CORE DATA
 */

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Momunt" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
