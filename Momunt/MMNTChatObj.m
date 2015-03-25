//
//  MMNTChatObj.m
//  Momunt
//
//  Created by Masha Belyi on 10/2/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNTChatObj.h"
#import "MMNTMessageObj.h"
#import "AsyncImageView.h"
#import "MMNTDataController.h"

@implementation MMNTChatObj

-(MMNTChatObj *)initWithData:(NSData *)data{
    NSError *e;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    return [self initWithDict:dict];
}

-(MMNTChatObj *)initWithDict:(NSDictionary *)data{
    self = [super init];
    if(self){
        _numUnread = 0;
        _chatId = [[data valueForKey:@"chatId"] integerValue];
        _messageId = [[data valueForKey:@"messageId"] integerValue];
        
        _members = [data valueForKey:@"members"];
        NSMutableArray *names = [[NSMutableArray alloc] init];
        NSMutableArray *profiles = [[NSMutableArray alloc] init];
        for (int i = 0; i < [_members count]; i++) {
            NSDictionary *member = _members[i];
            [names addObject:[member objectForKey:@"username"]];
            [profiles addObject:[member objectForKey:@"profileUrl"]];
        }
        _usernameStr = [names componentsJoinedByString:@", "];
        _memberImages = profiles;
        
        _timestamp = [NSDate dateWithTimeIntervalSince1970: (NSTimeInterval)[[data valueForKey:@"timestamp"] doubleValue] ];
        
//        NSString *msgString = [data valueForKey:@"message"];
//        NSError *e;
//        _message = [NSJSONSerialization JSONObjectWithData: [msgString dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &e];
        
        NSArray *messages = [data valueForKey:@"messages"];
        NSMutableArray *myMessages = [[NSMutableArray alloc] init];
        for (NSDictionary *msgDict in messages) {
            MMNTMessageObj *msg = [[MMNTMessageObj alloc] initWithDict:msgDict];
            if(msg.message!=nil){
                [myMessages addObject:msg];
                _numUnread =_numUnread + (msg.read ? 0:1);
            }
        }
        _messages = myMessages;
        
        
    }
    return self;
}

-(NSInteger)countUnread{
    NSInteger count = 0;
    for(int i=0; i<[_messages count]; i++){
        MMNTMessageObj *msg = _messages[i];
        count = count + (msg.read ? 0:1);
    }
    _numUnread = count;
    return count;
}

-(BOOL)hasMessageWithId:(NSInteger)messageId{
    for(int i=0; i<[_messages count]; i++){
        MMNTMessageObj *msg = _messages[i];
        if(msg.messageId == messageId){
            return YES;
        }
    }
    return NO;
}

-(NSInteger)IdxForMessageWithId:(NSInteger)messageId{
    if(!messageId){
        return -1;
    }
    for(int i=0; i<[_messages count]; i++){
        MMNTMessageObj *msg = _messages[i];
        if(msg.messageId == messageId){
            return i;
        }
    }
    return -1;
}

-(void)updateMessage:(NSInteger)messageId withData:(NSDictionary *)data{
    MMNTMessageObj *msg = _messages[messageId];
    for (NSString *key in data) {
        if ([msg respondsToSelector:NSSelectorFromString(key)]) {
            if( [key isEqualToString:@"message"]){
                NSError *e;
                NSDictionary *setVal = [NSJSONSerialization JSONObjectWithData: [[data valueForKey:key] dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &e];
                [msg setValue:setVal forKey:key];
            }
            if([key isEqualToString:@"timestamp"]){
                [NSDate dateWithTimeIntervalSince1970: (NSTimeInterval)[[data valueForKey:@"timestamp"] doubleValue] ];
            }
            else{
                [msg setValue:[data valueForKey:key] forKey:key];
            }
        }
    }
}

-(void)addMessage:(MMNTMessageObj *)message{
    [_messages addObject:message];
}

-(void)readAll{
    for(int i=0; i<[_messages count]; i++){
        MMNTMessageObj *msg = _messages[i];
        if(!msg.read && [UIApplication sharedApplication].applicationState!=UIApplicationStateBackground){
            // mark as read
            msg.read = YES;
            // ping the server that message was read
            [[MMNTApiCommuniator sharedInstance] markMessageAsRead:msg];
            
            if([UIApplication sharedApplication].applicationIconBadgeNumber > 0){
                [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber - 1;
            }
            
        }
    }

}

+(NSMutableArray *)parseMessageData:(NSArray *)messages{

    NSMutableArray *res = [[NSMutableArray alloc] init];
    
    for (NSDictionary *msgDict in messages) {
        MMNTMessageObj *msg = [[MMNTMessageObj alloc] initWithDict:msgDict];
        [res addObject:msg];
    }
    
    return res;

}


@end
