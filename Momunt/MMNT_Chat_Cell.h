//
//  MMNT_Chat_Cell.h
//  Momunt
//
//  Created by Masha Belyi on 10/2/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNTChatObj.h"
#import "MMNT_ChatThumbnail.h"
#import "MMNT_UnreadBadge.h"

@protocol ChatCellDelegate

-(void)selectedChat:(MMNTChatObj *)chat;

@end

@interface MMNT_Chat_Cell : UITableViewCell{
//    MMNT_AsyncImage *_profile;
    MMNT_ChatThumbnail *_thumbnail;
    UILabel *_username;
    UILabel *_message;
    UILabel *_date;
    MMNTChatObj *_data;
    MMNT_UnreadBadge *_unreadBadge;
}
@property (nonatomic, weak) id<ChatCellDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellData:(MMNTChatObj *)mmnt;

@end