//
//  MMNTReachabilityManager.m
//  Momunt
//
//  Created by Masha Belyi on 2/16/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import "MTReachabilityManager.h"

#import "Reachability.h"
#import "MMNTApiCommuniator.h"
#import "Amplitude.h"

@implementation MTReachabilityManager

#pragma mark -
#pragma mark Default Manager
+ (MTReachabilityManager *)sharedManager {
    static MTReachabilityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

#pragma mark -
#pragma mark Memory Management
- (void)dealloc {
    // Stop Notifier
    if (_reachability) {
        [_reachability stopNotifier];
    }
}

#pragma mark -
#pragma mark Class Methods
+ (BOOL)isReachable {
    return [[[MTReachabilityManager sharedManager] reachability] isReachable];
}

+ (BOOL)isUnreachable {
    return ![[[MTReachabilityManager sharedManager] reachability] isReachable];
}

+ (BOOL)isReachableViaWWAN {
    return [[[MTReachabilityManager sharedManager] reachability] isReachableViaWWAN];
}

+ (BOOL)isReachableViaWiFi {
    return [[[MTReachabilityManager sharedManager] reachability] isReachableViaWiFi];
}

#pragma mark -
#pragma mark Private Initialization
- (id)init {
    self = [super init];
    
    if (self) {
        // Initialize Reachability
        self.reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
        
        // Add Observer
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];
        _haveInternet = YES;
        // Start Monitoring
        [self.reachability startNotifier];
        
    }
    
    return self;
}

- (void)reachabilityDidChange:(NSNotification *)notification {
    Reachability *reachability = (Reachability *)[notification object];
    
//    BOOL reachable = [[[MTReachabilityManager sharedManager] reachability] isReachable] && [self doubleCheckHasConnection];
    BOOL reachable = [[[MTReachabilityManager sharedManager] reachability] isReachable];
    if(reachable){

        NSLog(@"status Reachable");
        if(!_haveInternet){ // changed from not reachable to reachable
           
            
            [[MMNTApiCommuniator sharedInstance] registerDeviceToken];     // register user device
            [[MMNTApiCommuniator sharedInstance] getTrendingMomunts];      // get updated trending list
            [[MMNTApiCommuniator sharedInstance] getUserInfo];             // update user info
            [[MMNTApiCommuniator sharedInstance] fetchNewMessages:nil];    // fetch any missed messages
        }
        _haveInternet = YES;
    } else {
        
        NSLog(@"status Unreachable");
        if(_haveInternet){ // changed reachable to not reachable
//            [Amplitude logEvent:@"lost internet connection"];
        
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet!"
                                                        message:@"No working internet connection is found."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
            [alert show];
        }
        _haveInternet = NO;

        
    }
}

-(BOOL)doubleCheckHasConnection{
    NSURL *scriptUrl = [NSURL URLWithString:@"http://www.momunt.com/reachability.png"];
    NSData *datatest = [NSData dataWithContentsOfURL:scriptUrl];
    if (datatest)
        return YES;
    else
        return NO;
}

@end