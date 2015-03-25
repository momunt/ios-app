//
//  MMNTMessageObj.m
//  Momunt
//
//  Created by Masha Belyi on 10/3/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNTMessageObj.h"
#import "MMNTAccountManager.h"
#import "MMNT_ChatBubble.h"

@implementation MMNTMessageObj
#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)

#if !defined(MIN)
#define MIN(A,B)((A) < (B) ? (A) : (B))
#endif

#if !defined(MAX)
#define MAX(A,B)((A) > (B) ? (A) : (B))
#endif

-(MMNTMessageObj *)initWithData:(NSData *)data{
    NSError *e;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    return [self initWithDict:dict];

}
-(MMNTMessageObj *)initWithDict:(NSDictionary *)data{
    self = [super init];
    if(self){
        _messageId = [[data valueForKey:@"messageId"] integerValue];
        _chatId = [[data valueForKey:@"chatId"] integerValue];
        _username = [data valueForKey:@"username"];
        _profileUrl = [data valueForKey:@"profileUrl"];
        _timestamp = [NSDate dateWithTimeIntervalSince1970: (NSTimeInterval)[[data valueForKey:@"timestamp"] doubleValue] ];
        _read = [[data valueForKey:@"isRead"] boolValue];
        _uploadId = [data valueForKey:@"uploadId"]; // is set if message is a momunt, still uploading to server
        
        NSString *msgString = [data valueForKey:@"message"];
        NSError *e;
        _message = [NSJSONSerialization JSONObjectWithData: [msgString dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &e];
        
        _needToUpdate = [[data valueForKey:@"needToUpdate"] boolValue]== YES;

        
    }
    return self;
}

-(void)updateWithData:(NSDictionary *)data{
    if(!_needToUpdate){
        return;
    }
    
    
    if ([[data allKeys] containsObject:@"username"]){
        _username = [data valueForKey:@"username"];
    }
    if ([[data allKeys] containsObject:@"profileUrl"]){
        _profileUrl = [data valueForKey:@"profileUrl"];
    }
    if ([[data allKeys] containsObject:@"timestamp"]){
        _timestamp = [NSDate dateWithTimeIntervalSince1970: (NSTimeInterval)[[data valueForKey:@"timestamp"] doubleValue] ];
    }
    if ([[data allKeys] containsObject:@"isread"]){
        _read = [[data valueForKey:@"isRead"] boolValue];
    }
    if ([[data allKeys] containsObject:@"message"]){
        NSString *msgString = [data valueForKey:@"message"];
        NSError *e;
        _message = [NSJSONSerialization JSONObjectWithData: [msgString dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &e];
    }
    
    _needToUpdate = NO;
    
    
}


- (CGFloat)textViewHeightForAttributedText: (NSAttributedString*)text andWidth: (CGFloat)width {
    UITextView *calculationView = [[UITextView alloc] init];
    [calculationView setAttributedText:text];
    CGSize size = [calculationView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}

-(void)setRead:(BOOL)read{
    _read = read;
//    MMNTChatObj *chat = [[MMNTAccountManager sharedInstance] getChatById:_chatId];
//    chat.numUnread = chat.numUnread - 1;
////    [chat countUnread];
    
}

@end
