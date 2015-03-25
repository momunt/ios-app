//
//  MQTTChatController.h
//  Momunt
//
//  Created by Masha Belyi on 10/4/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//
// MQTT Chat Controller. Implements MQTT protocol
//

#import <Foundation/Foundation.h>
#import "MQTTKit.h"
#import "MMNTMessageObj.h"

#define kMQTTServerHost @"54.187.29.89"
//#define kTopic @"momuntchat/6178947367"

@interface MQTTChatController : NSObject
@property (nonatomic, strong) MQTTClient *client;

-(id)init;
-(void)connect;
-(void)postMessage:(MMNTMessageObj *)message toTopic:(NSString *)topic;
- (void)sendMessageToMQTTBroker:(MMNTMessageObj *)message toTopic:(NSString *)topic; // should use this

@end
