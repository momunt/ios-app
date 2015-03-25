//
//  MMNT_BubbleTableCell.h
//  Momunt
//
//  Created by Masha Belyi on 10/8/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MMNTMessageObj.h"
#import "MMNT_AsyncImage.h"
#import "MMNT_ChatBubble.h"

@interface MMNT_BubbleTableCell : UITableViewCell{
    MMNTMessageObj *_data;
    MMNT_AsyncImage *_profile;
    MMNT_ChatBubble *_chatBubble;
    
    CGRect _bubbleFrame;
    CGFloat _paddingTop;
    CGFloat _paddingLeft;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellData:(MMNTMessageObj *)msg profile:(BOOL)needProfile;

@end
