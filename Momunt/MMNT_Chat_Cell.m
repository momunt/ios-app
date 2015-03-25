//
//  MMNT_Chat_Cell.m
//  Momunt
//
//  Created by Masha Belyi on 10/2/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_Chat_Cell.h"
#import "MMNTMessageObj.h"

@implementation MMNT_Chat_Cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellData:(MMNTChatObj *)chat{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    self.backgroundColor = [UIColor colorWithRed:(0 / 255.0) green:(0 / 255.0) blue:(0 / 255.0) alpha:0]; // clear background
    self.contentView.backgroundColor = [UIColor colorWithRed:(0 / 255.0) green:(0 / 255.0) blue:(0 / 255.0) alpha:0]; // clear background
    
    _data = chat;
    
    _username = [[UILabel alloc] initWithFrame:CGRectMake(70,10,100,20)];
    _username.text = chat.usernameStr;
    _username.textColor = [UIColor colorWithWhite:1.0 alpha:0.45];
    _username.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0];
    [self.contentView addSubview:_username];
    
    
    MMNTMessageObj *lastMsg = [chat.messages objectAtIndex:[chat.messages count]-1];
    BOOL ismomunt = [[lastMsg.message allKeys] containsObject:@"momuntId"];

    // message body
    if(ismomunt){
        // add momunt icon
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MomuntIconPreview"]];
        icon.frame = CGRectMake(70, 35, 25,25);
        [self.contentView addSubview:icon];
    }
    
    _message = [[UILabel alloc] initWithFrame: ismomunt ? CGRectMake(100,35,190,30) : CGRectMake(70,30,230,50)];
    _message.text = ismomunt ? [lastMsg.message objectForKey:@"momuntName"] : [lastMsg.message objectForKey:@"text"];
    _message.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    _message.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
    _message.backgroundColor = [UIColor clearColor];
    _message.numberOfLines = 2;
    [_message sizeToFit];
    [self.contentView addSubview:_message];
    
    // date
    _date = [[UILabel alloc] initWithFrame:CGRectMake(70+230-110,10,100,15)];
    _date.text = [self formatDate:lastMsg.timestamp];
    _date.textColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    _date.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0];
    _date.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_date];
    
    // profile image
    _thumbnail = [[MMNT_ChatThumbnail alloc] initWithFrame:CGRectMake(10,15,50,50) withImages:chat.memberImages];
    [self.contentView addSubview:_thumbnail];
    
    // unread
    NSInteger num = [chat countUnread];
    if(num > 0){
        _unreadBadge = [[MMNT_UnreadBadge alloc] initWithFrame:CGRectMake(5,20,15,15) num: num ];
        [self.contentView addSubview:_unreadBadge];
    }
    
    [self initGestures];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    return self;
}

-(void)initGestures{
    // tap gesture
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    tapRecognizer.delegate = self;
    [self.contentView addGestureRecognizer:tapRecognizer];
}
-(void)tapped:(UITapGestureRecognizer *)tapRecognizer{
    [self.delegate selectedChat:_data];
    
}
-(NSString *)formatDate:(NSDate *)date{

    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    
    if([today day] == [otherDay day] &&
       [today month] == [otherDay month] &&
       [today year] == [otherDay year] &&
       [today era] == [otherDay era]) {
        //TODAY
        NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
        [timeFormat setDateFormat:@"a"];
        NSString *ampm = [[timeFormat stringFromDate:date] isEqualToString:@"AM"] ? @"a" : @"p";
        
        [timeFormat setDateFormat:@"h:mm"];
        NSString *theTime = [NSString stringWithFormat:@"%@%@" , [timeFormat stringFromDate:date ], ampm];
        
        return theTime;
        
    }
    else if([today day] == ([otherDay day]-1) &&
        [today month] == [otherDay month] &&
        [today year] == [otherDay year] &&
        [today era] == [otherDay era]) {
        //YESTEDAY
        return @"yesterday";
    }else{
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormat setDateFormat:@"M.dd.yy"];
        return [dateFormat stringFromDate:date];
    }

    
}


@end
