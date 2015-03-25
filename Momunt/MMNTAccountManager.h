//
//  MMNTAccountManager.h
//  Momunt
//
//  Created by Masha Belyi on 9/28/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMNTChatObj.h"
#import "MMNTObj.h"

@interface MMNTAccountManager : NSObject{
    NSInteger _userId;
}

+(MMNTAccountManager*)sharedInstance;

//@property (nonatomic) NSInteger userId;
@property (nonatomic) NSString  *profileURl;
@property (nonatomic) NSString  *username;
@property (nonatomic) NSString  *phone;
@property NSMutableArray        *userMomunts;
@property NSMutableArray        *userFollows;
@property NSDictionary          *trendingMomunts;
@property NSMutableArray        *messagesBuffer;
@property NSMutableArray        *helpTasksDone;

@property NSMutableArray        *Chats;
@property NSMutableArray        *chatOrder; // key-valye dictionary to keep track of chat ids
@property NSInteger             numUnread;
@property NSInteger             authInstagram; // 0-no, 1-yes, 2-don't have instagram account

@property MMNTObj *myMomunt;

-(NSInteger)countTotalUnread;

-(void) populateWithData:(NSData *)data;
-(void) updateChatData:(NSData *)data;
-(void)addOrUpdate:(MMNTChatObj *)chat atIdx:(CGFloat)idx;
-(MMNTChatObj *)getChatById:(NSInteger)chatId;
-(void)addMessageWithData:(NSDictionary *)messageDict;
-(NSArray *)updateUploadedMessageWithData:(NSDictionary *)data;
-(BOOL)isTaskDone:(NSInteger)taskId;
-(NSArray *)activeChats;

/*----- setters ------*/
-(void)setUserId:(NSInteger)userId;
-(void)setTrendingData:(NSData *)data;

/*----- getters ------*/
-(NSInteger)userId;

-(void)clearAll;
@end
