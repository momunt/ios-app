//
//  MMNTAppDelegate.h
//  Momunt
//
//  Created by Masha Belyi on 6/16/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMNTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow     *window;
@property (nonatomic) BOOL                 openFromPushNotification;
@property NSTimer                          *myTimer;

/*
 CORE DATA
 */
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end
