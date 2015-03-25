//
//  MMNTChatObj.h
//  Momunt
//
//  Created by Masha Belyi on 10/2/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMNTMessageObj.h"

@interface MMNTChatObj : NSObject

@property (nonatomic) NSInteger chatId;
@property (nonatomic) NSInteger messageId;
@property (strong, nonatomic) NSDictionary *message;
@property (strong, nonatomic) NSDate *timestamp;
@property (strong, nonatomic) NSArray *members;
@property (strong, nonatomic) NSMutableArray *messages;
@property NSArray *memberImages;
@property NSString *usernameStr;
@property CGFloat numUnread;

-(MMNTChatObj *)initWithData:(NSData *)data;
-(MMNTChatObj *) initWithDict:(NSDictionary *)data;
-(NSInteger)countUnread;
-(BOOL)hasMessageWithId:(NSInteger)messageId;
-(NSInteger)IdxForMessageWithId:(NSInteger)messageId;
-(void)updateMessage:(NSInteger)messageId withData:(NSDictionary *)data;
-(void)addMessage:(MMNTMessageObj *)message;
-(void)readAll;

+(NSMutableArray *)parseMessageData:(NSArray *)messages;

@end
