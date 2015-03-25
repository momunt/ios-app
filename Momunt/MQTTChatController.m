//
//  MQTTChatController.m
//  Momunt
//
//  Created by Masha Belyi on 10/4/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MQTTChatController.h"
#import "MMNTAccountManager.h"

@implementation MQTTChatController


- (id)init
{
    self = [super init];
    if (self != nil) {
        // init API communicator
        [self setupMQTTClient];
        [self connectoToMQTTBroker];
    }
    return self;
}


-(void)connect{
    [self connectoToMQTTBroker];
}
/**
 *  Setup the connection with the MQTT broker
 */
- (void)setupMQTTClient
{
    
    // create the MQTT client with an unique identifier
    NSString *clientID = [UIDevice currentDevice].identifierForVendor.UUIDString;
    self.client = [[MQTTClient alloc] initWithClientId:clientID];
    
    // define the handler that will be called when MQTT messages are received by the client
    __weak typeof(self)weakSelf = self;
    
    [self.client setMessageHandler:^(MQTTMessage *message) {
        // extract the switch status from the message payload
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:message.payload options:kNilOptions error:nil];
        
        // the MQTTClientDelegate methods are called from a GCD queue.
        // Any update to the UI must be done on the main queue
        
        dispatch_queue_t concurrentQueue = dispatch_queue_create("some queue", NULL);
//        dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_async(concurrentQueue, ^{
            /**
             *  Sending a message. Your implementation of this method should do *at least* the following:
             *
             *  1. Play sound (optional)
             *  2. Add new id<JSQMessageData> object to your data source
             *  3. Call `finishSendingMessage`
             */
            
            if([UIApplication sharedApplication].applicationState!=UIApplicationStateBackground){ // if not in background
            
                NSString *dateString = json[@"date"] ;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
            NSDate *dateFromString = [[NSDate alloc] init];
            dateFromString = [dateFormatter dateFromString:dateString];
            
            MMNTMessageObj *message = [[MMNTMessageObj alloc] initWithDict:json];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedMessage"
                                                                object:weakSelf
                                                              userInfo:[NSDictionary dictionaryWithObject:message
                                                                                                   forKey:@"message"]];
                
            }
            
        });
    }];
}

/**
 *  Connects to the broker
 */
- (void)connectoToMQTTBroker
{
    if(![MMNTAccountManager sharedInstance].phone){
        return;
    }
    [self.client connectToHost:kMQTTServerHost completionHandler:^(MQTTConnectionReturnCode code) {
        if (code == ConnectionAccepted) {
            // The client is connected when this completion handler is called
            NSLog(@"client is connected with id %@", self.client.clientID);
            // Subscribe to the topic
            NSString *topic = [NSString stringWithFormat:@"momuntchat/%i", [MMNTAccountManager sharedInstance].userId ];
            [self.client subscribe:topic withCompletionHandler:^(NSArray *grantedQos) {
                // The client is effectively subscribed to the topic when this completion handler is called
                NSLog(@"subscribed to topic %@", topic);
            }];
        }
    }];
}

/**
 *  Posts message to MQTT broker
 *
 *  @param message The message object
 */

- (void)postMessage:(MMNTMessageObj *)message toTopic:(NSString *)topic{
    // when the client is connected, send a MQTT message
    message.timestamp = [NSDate date]; 
    NSData *msgData = [NSJSONSerialization dataWithJSONObject:message.message options:0 error:nil];
    NSString *msgStr = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
    
    NSDictionary *postDict = @{@"chatId" : [NSString stringWithFormat:@"%i", message.chatId ],
                               @"messageId" : [NSString stringWithFormat:@"%i", message.messageId ],
                               @"message" : msgStr,
                               @"username" : message.username,
                               @"profileUrl" : message.profileUrl,
                               @"timestamp" : [NSString stringWithFormat:@"%f",[message.timestamp timeIntervalSince1970]]
                               };
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDict options:0 error:nil];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];

    // UNCOMMET FOR DISTRIBUTION!
    
    [self.client publishString: postStr
                       toTopic:topic
                       withQos:AtMostOnce
                        retain:NO
             completionHandler:^(int mid) {
//                 NSLog(@"message has been delivered to MQTT broker");
             }];
}

- (void)sendMessageToMQTTBroker:(MMNTMessageObj *)message toTopic:(NSString *)topic
{
    // connect to the MQTT server
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (self.client.connected) {
            [self postMessage:message toTopic:topic];
        }
        else{
            [self.client connectToHost:kMQTTServerHost
                     completionHandler:^(NSUInteger code) {
                         if (code == ConnectionAccepted) {
                             [self postMessage:message toTopic:topic];
                         }
                     }];
        }
    });
}


@end
