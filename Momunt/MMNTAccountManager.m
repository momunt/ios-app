//
//  MMNTAccountManager.m
//  Momunt
//
//  Created by Masha Belyi on 9/28/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNTAccountManager.h"
#import "MMNTDataController.h"
#import "MMNTObj.h"
#import "MMNTChatObj.h"
#import "MMNTMessageObj.h"
#import "MMNTContactsManager.h"
#import <Crashlytics/Crashlytics.h>

#import "Amplitude.h"

@implementation MMNTAccountManager

/*------------------ initialize ------------------  */
- (id)init
{
    self = [super init];
    if (self != nil) {
        // listen to changes in chats
        [self addObserver:self forKeyPath:@"Chats" options:NSKeyValueObservingOptionNew context:NULL];
        _chatOrder = [[NSMutableArray alloc] init];
        _messagesBuffer = [[NSMutableArray alloc] init];
        _numUnread = 0;
        _helpTasksDone = [[NSMutableArray alloc] init];
        
        _Chats = [[NSMutableArray alloc] init];
        
        _myMomunt = [[MMNTObj alloc] init];
        _myMomunt.momuntId = @"myMomunt";
        _myMomunt.poster = @"https://s3-us-west-2.amazonaws.com/uploads.momunt.com/MapBG_small.jpg";
        _myMomunt.name = @"my momunt";
        
        // if there is info in NSUser defaults -> use it
        NSDictionary *res = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"];
        if(res){
            _username = [res valueForKey:@"username"];
            _userId = [[res valueForKey:@"id"] integerValue];
            _profileURl = [res valueForKey:@"profileImg"];
            _phone = [res valueForKey:@"phone"];
            _helpTasksDone = [res valueForKey:@"helpTasks"];
            _authInstagram = [[res valueForKey:@"authInstagram"] integerValue];
            _numUnread = [[res valueForKey:@"numUnread"] integerValue];
        
            NSArray *momunts = [res valueForKey:@"momunts"];
            NSMutableArray *myMomunts = [[NSMutableArray alloc] init];
            for (NSDictionary *mmntDict in momunts) {
                MMNTObj *mmnt = [[MMNTObj alloc] initWithDict:mmntDict];
                [myMomunts addObject:mmnt];
            }
            _userMomunts = myMomunts;
            [_userMomunts insertObject:_myMomunt atIndex:0];
        }
        
        // Checkfor trending data
        NSDictionary *trending = [[NSUserDefaults standardUserDefaults] objectForKey:@"trendingData"];
        if(trending){
            NSDictionary *momunts = [trending valueForKey:@"trending"];
            NSMutableDictionary *myMomunts = [[NSMutableDictionary alloc] init];
            for(NSString *key in momunts) {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                NSArray *momuntsArray = [momunts objectForKey:key];
                for (NSDictionary *mmntDict in momuntsArray) {
                    MMNTObj *mmnt = [[MMNTObj alloc] initWithDict:mmntDict];
                    [array addObject:mmnt];
                }
                [myMomunts setValue:array forKey:key];
            }
            _trendingMomunts = myMomunts;
        }

        
    }
    return self;
}


+ (MMNTAccountManager*)sharedInstance
{
    static MMNTAccountManager *sharedInstance;
    @synchronized(self)
    {
        if (!sharedInstance)
            sharedInstance = [[self alloc] init];
        return sharedInstance;
    }
}

/*------------------ observers ------------------  */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"Chats"]){
        NSLog(@"updated chats!");
    }
}

/*------------------ getter methods ------------------  */
-(NSInteger)userId{
    return _userId;
}

/*------------------ setter methods ------------------  */
-(void)setUserId:(NSInteger)userId{
    _userId = userId;
}


-(void)populateWithData:(NSData *)data{
    NSError *e;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    
    // Store user info
    [[NSUserDefaults standardUserDefaults] setObject:res forKey:@"userInfo"];
    
    _username = [res valueForKey:@"username"];
    _userId = [[res valueForKey:@"id"] integerValue];
    _profileURl = [res valueForKey:@"profileImg"];
    _phone = [res valueForKey:@"phone"];
    _helpTasksDone = [res valueForKey:@"helpTasks"];
    _authInstagram = [[res valueForKey:@"authInstagram"] integerValue];
    _numUnread = [[res valueForKey:@"numUnread"] integerValue];
    
    NSArray *momunts = [res valueForKey:@"momunts"];
    NSMutableArray *myMomunts = [[NSMutableArray alloc] init];
    NSMutableArray *myFollows = [[NSMutableArray alloc] init];
    for (NSDictionary *mmntDict in momunts) {
        MMNTObj *mmnt = [[MMNTObj alloc] initWithDict:mmntDict];
        if(mmnt.live){
            [myFollows addObject:mmnt];
        }else{
            [myMomunts addObject:mmnt];
        }
    }
    _userMomunts = myMomunts;
    _userFollows = myFollows;
    [_userMomunts insertObject:_myMomunt atIndex:0];
    
    
    // POST NOTIFICATION that updated user info
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedUserInfo"
                                                        object:self
                                                      userInfo:nil];
    
    // init Contacts Manager - want this to run after we know who the user is
    [MMNTContactsManager sharedInstance];
    
    // AMPLITUDE ---------------------------------------------------------------------------------------------------
    [Amplitude setUserId:[NSString stringWithFormat:@"%@",[res valueForKey:@"id"] ]] ;
    [Crashlytics setUserIdentifier:[NSString stringWithFormat:@"%@",[res valueForKey:@"id"] ]] ;
    //--------------------------------------------------------------------------------------------------------------

}

-(void)setTrendingData:(NSData *)data{
    NSError *e;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    
    // Store trending data
    [[NSUserDefaults standardUserDefaults] setObject:res forKey:@"trendingData"];

    
    NSDictionary *momunts = [res valueForKey:@"trending"];
    NSMutableDictionary *myMomunts = [[NSMutableDictionary alloc] init];

    for(NSString *key in momunts) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        
        NSArray *momuntsArray = [momunts objectForKey:key];
        
        for (NSDictionary *mmntDict in momuntsArray) {
            MMNTObj *mmnt = [[MMNTObj alloc] initWithDict:mmntDict];
            [array addObject:mmnt];
        }
        
        [myMomunts setValue:array forKey:key];
    }
    _trendingMomunts = myMomunts;
    
    // POST NOTIFICATION that trending momunts were updated
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedTrendingMomunts"
                                                        object:self
                                                      userInfo:nil];

}

-(void)updateChatData:(NSData *)data{
    NSError *e;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    NSArray *chats = [res valueForKey:@"chats"];

    NSMutableArray *myChats = [[NSMutableArray alloc] init];
    for(int i=0; i<[chats count]; i++){
        MMNTChatObj *chat = [[MMNTChatObj alloc] initWithDict:chats[i]];
        [myChats addObject:chat];
        [_chatOrder insertObject:[NSString stringWithFormat:@"%li",(long)chat.chatId ] atIndex:i];
    }
    _Chats = myChats;
    [self countTotalUnread];
    
    // post notificatoin about new chat data
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedChatData"
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:_Chats
                                                                                           forKey:@"chatArray"]];
}
-(NSInteger)countTotalUnread{
    NSInteger count = 0;
    for(int i=0; i<[_Chats count]; i++){
        MMNTChatObj *chat = _Chats[i];
        count = count + [chat countUnread];
    }
    
    if(_numUnread != count){
    // send a notification
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedTotalUnreadCount"
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%i", count]
                                                                                           forKey:@"count"]];
        _numUnread = count;
    }
    
    return count;
}


-(void)addOrUpdate:(MMNTChatObj *)chat atIdx:(CGFloat)idx{
    for(int i=0; i<[_Chats count]; i++){
        MMNTChatObj *thisChat = _Chats[i];
        if(thisChat.chatId == chat.chatId){
            // update and move to front
            [_Chats removeObjectAtIndex:i];
            [_Chats insertObject:chat atIndex:idx];
            return;
        }
        
    }
    [_Chats insertObject:chat atIndex:0];
}

-(MMNTChatObj *)getChatById:(NSInteger)chatId{
    for(int i=0; i<[_Chats count]; i++){
        MMNTChatObj *thisChat = _Chats[i];
        if(thisChat.chatId == chatId){
            return thisChat;
        }
    }
    
    return nil;
    

}

-(void)addMessageWithData:(NSDictionary *)messageDict{
    NSInteger chatId = [[messageDict valueForKey:@"chatId"] integerValue];
    MMNTChatObj *chat = [self getChatById:chatId];
    if(chat){
        // add this message if not added yet
        NSInteger msgidx = [chat IdxForMessageWithId:[[messageDict objectForKey:@"messageId"] integerValue] ];
        if( msgidx == -1 ){
            MMNTMessageObj *msg = [[MMNTMessageObj alloc] initWithDict:messageDict];
            [chat addMessage:msg];
            if(msg.uploadId){
                [_messagesBuffer addObject:msg];
            }
            
        }else{
            MMNTMessageObj *msg = [chat.messages objectAtIndex:msgidx];
            [msg updateWithData:messageDict];
        }
        
        [self addOrUpdate:chat atIdx:0]; // push this chat to the top of the list
    
    }else{
        // add new chat obj
        MMNTChatObj *chat = [[[MMNTDataController sharedInstance] APIcommunicator] fetchChatById:chatId];
        
        MMNTMessageObj *msg = [[MMNTMessageObj alloc] initWithDict:messageDict];
        [chat addMessage:msg];
        if(msg.uploadId){
            [_messagesBuffer addObject:msg];
        }
        
        [_Chats insertObject:chat atIndex:0];
    }
    
    [self countTotalUnread];
    
    // post notificatoin about new chat data - if in messages view, will reload the table
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedChatData"
                                                        object:self
                                                      userInfo:nil];

    // post notificatoin about new chat data - if in chat view, will reload the table
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedChatWithId"
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%i", chatId]
                                                                                                    forKey:@"chatId"]];

}

-(NSArray *)updateUploadedMessageWithData:(NSDictionary *)data{
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    
    NSString *uploadId = [data objectForKey:@"uploadId"];
    
    NSString *msgString = [data valueForKey:@"message"];
    NSError *e;
    NSDictionary *newMessage = [NSJSONSerialization JSONObjectWithData: [msgString dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &e];
//    NSDictionary *newMessage = [data valueForKey:@"message"];
    
    for(int i=0; i<[_messagesBuffer count]; i++){
        MMNTMessageObj *msg = _messagesBuffer[i];
        if([uploadId isEqualToString:msg.uploadId]){
            // update this msg!
            msg.uploadId = nil;
            
            NSDictionary *msgDict = msg.message;
            [msgDict setValue:[newMessage objectForKey:@"momuntPoster"] forKey:@"momuntPoster"];
            [msgDict setValue:[newMessage objectForKey:@"momuntName"] forKey:@"momuntName"];
            [msgDict setValue:[newMessage objectForKey:@"momuntDate"] forKey:@"momuntDate"];
            
            msg.message = msgDict;
            
            // post notificatoin about new chat data - if in messages view, will reload the table
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedChatData"
                                                                object:self
                                                              userInfo:nil];
            
            // post notificatoin about new chat data - if in chat view, will reload the table
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedChatWithId"
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%i", msg.chatId]
                                                                                                   forKey:@"chatId"]];
           
            [messages addObject:msg];
        }
    }
    return messages;
}

-(void)clearAll{
    [self setUserId:nil];
    _username = nil;
    _userMomunts = nil;
    _profileURl = nil;
    _userMomunts = nil;
    _helpTasksDone = nil;
}

-(BOOL)isTaskDone:(NSInteger)taskId{
    // check if given task has been done
    NSInteger anIndex=[_helpTasksDone indexOfObject:[NSNumber numberWithInteger:taskId]];
    if(NSNotFound == anIndex) {
        return NO;
    }else{
        return YES;
    }
}

-(NSArray *)activeChats{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(MMNTChatObj *chat in _Chats){
        if([chat.messages count]>0 && [chat.members count]>0){
            [array addObject:chat];
        }
    }
    return array;
}
@end
