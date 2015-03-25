//
//  MMNTMessageObj.h
//  Momunt
//
//  Created by Masha Belyi on 10/3/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMNTMessageObj : NSObject

@property (nonatomic) NSInteger              messageId;
@property (nonatomic) NSInteger              chatId;
@property (nonatomic) NSString               *username;
@property (nonatomic) NSString               *profileUrl;
@property (strong, nonatomic) NSDictionary   *message;
@property (strong, nonatomic) NSDate         *timestamp;
@property (nonatomic) CGFloat                height;
@property (nonatomic) BOOL                   read;
@property (nonatomic) BOOL                   needToUpdate;
@property (nonatomic) BOOL                   uploading;
@property (nonatomic) NSString               *uploadId;

@property BOOL                               needsTimestamp;
@property NSString                           *timeString;


-(MMNTMessageObj *)initWithData:(NSData *)data;
-(MMNTMessageObj *)initWithDict:(NSDictionary *)data;
-(void)updateWithData:(NSDictionary *)data;
-(void)setRead:(BOOL)read;

@end
