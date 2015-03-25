//
//  MMNT_BubbleTableCell.m
//  Momunt
//
//  Created by Masha Belyi on 10/8/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_BubbleTableCell.h"
#import "MMNTAccountManager.h"
#import "MMNTDataController.h"
#import "MMNT_SharedVars.h"


@implementation MMNT_BubbleTableCell

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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellData:(MMNTMessageObj *)msg profile:(BOOL)needProfile{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    self.backgroundColor = [UIColor clearColor];
    _data = msg;
    
    NSString *myUsername    = [MMNTAccountManager sharedInstance].username;
    MMNTBubbleType type     = [msg.username isEqualToString:myUsername] ? Me : Other;
    CGFloat W               = self.contentView.frame.size.width;
    CGFloat H               = self.contentView.frame.size.height;
    _paddingTop             = 0.0;
    _paddingLeft            = type == Me ? 35.0 : (H+5); //type == Me ? 35.0 : (H+20);
    CGFloat bubbleW         = W - (H+20) - 10 ; //screen width - space for profile img - padding on the right
    CGFloat bubbleH         = H-2*_paddingTop;
    _bubbleFrame            = CGRectMake(_paddingLeft, _paddingTop + (msg.needsTimestamp ? 30.0 : 0),  bubbleW, bubbleH);
    
    if(!msg.read && [UIApplication sharedApplication].applicationState!=UIApplicationStateBackground){ // ???
        // mark as read
        msg.read = YES;
        // ping the server that message was read
        [[MMNTApiCommuniator sharedInstance] markMessageAsRead:msg];
    
        if([UIApplication sharedApplication].applicationIconBadgeNumber > 0){
            [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber - 1;
        }
    
    }
    if(msg.needsTimestamp){
//        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//        [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
//        [dateFormat setDateFormat:@"MMM dd h:m a"];
//        NSString *dateString = [dateFormat stringFromDate:msg.timestamp];
        
        UILabel *timestamp = [[UILabel alloc] initWithFrame:CGRectMake(0,0,W, 30)];
        timestamp.text = msg.timeString;
        timestamp.textAlignment = NSTextAlignmentCenter;
        timestamp.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        timestamp.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        [self.contentView addSubview:timestamp];
        
    }
    
    if(type == Me){
        _chatBubble = [[MMNT_ChatBubble alloc] initWithFrame:_bubbleFrame data:msg type:type];
        [self.contentView addSubview:_chatBubble];
        
         CGRect frame = _chatBubble.frame;
         _chatBubble.layer.anchorPoint = CGPointMake(1, 0);
         _chatBubble.layer.position = CGPointMake(self.contentView.frame.size.width-10.0, _bubbleFrame.origin.y);
    }
    else{
        
        if(needProfile){
            _profile = [[MMNT_AsyncImage alloc] initWithFrame:CGRectMake(10,_paddingTop + (msg.needsTimestamp ? 30.0 : 0) ,H,H)];
            _profile.layer.cornerRadius =  H/2;
            _profile.clipsToBounds = YES;
            [_profile setImageURL:[NSURL URLWithString:msg.profileUrl]];
            [self.contentView addSubview:_profile];
        }
        
        _chatBubble = [[MMNT_ChatBubble alloc] initWithFrame:_bubbleFrame data:msg type:type];
        [self.contentView addSubview:_chatBubble];
        
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    [self initGestures];
    return self;
}

-(void)initGestures{
    // tap gesture
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    tapRecognizer.delegate = self;
    [self.contentView addGestureRecognizer:tapRecognizer];
}
-(void)tapped:(UITapGestureRecognizer *)tapRecognizer{
    
    if(_data.uploadId){ // still uploading the message
        return;
    }
    
    if([[_data.message allKeys] containsObject:@"needToUpdate"]){
        // still loading the message, no momunt here
        return;
    }
    
    if ([_data.message objectForKey:@"momuntId"]) {
        
        // POST NOTIFICATION to load a new momunt
        [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedStoredMomunt"
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:[_data.message objectForKey:@"momuntId"]
                                                                                               forKey:@"momuntId"]];
    
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder)
                                               to:nil
                                             from:nil
                                         forEvent:nil];
    }

    
}

- (CGFloat)textViewHeightForAttributedText: (NSAttributedString*)text andWidth: (CGFloat)width {
    UITextView *calculationView = [[UITextView alloc] init];
    [calculationView setAttributedText:text];
    CGSize size = [calculationView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}

@end
