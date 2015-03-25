//
//  MMNT_SavedMomunt_Cell.m
//  Momunt
//
//  Created by Masha Belyi on 8/2/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_SavedMomunt_Cell.h"
#import "MMNT_GalleryCell.h"
#import "MMNTDataController.h"
#import "MMNT_AsyncImage.h"
#import "MMNTAccountManager.h"
#import "MMNT_SharedVars.h"
#import "POPSpringAnimation.h"
#import "POPBasicAnimation.h"
#import "MMNTApiCommuniator.h"
#import "MMNT_InteractiveIcon.h"
#import "LocationController.h"
#import "MMNT_SharedVars.h"

#import "Amplitude.h"
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0];
#define PADDING 0.0
#define POSTER_ALPHA 0.8


@implementation MMNT_SavedMomunt_Cell 

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellData:(MMNTObj *)mmnt type:(NSString *)type
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    self.backgroundColor = [UIColor colorWithRed:(0 / 255.0) green:(0 / 255.0) blue:(0 / 255.0) alpha:0]; // clear background
    self.contentView.backgroundColor = [UIColor colorWithRed:(0 / 255.0) green:(0 / 255.0) blue:(0 / 255.0) alpha:0]; // clear background
    
    _data = mmnt;
    _theMomunt = mmnt;
    _type = type;
    _momuntId = mmnt.momuntId;
    
    _canDelete = NO;
    if([[MMNTAccountManager sharedInstance].userMomunts containsObject:_theMomunt]){
        _canDelete = YES;
        _parentArray = [MMNTAccountManager sharedInstance].userMomunts;
    }
    if([[MMNTAccountManager sharedInstance].userFollows containsObject:_theMomunt]){
        _canDelete = YES;
        _parentArray = [MMNTAccountManager sharedInstance].userFollows;
    }
    
    CGRect frame = self.frame;
    frame.size.height = 125;
    self.frame = frame;
    
    _momunt = [[UIView alloc] initWithFrame:self.frame];
    [self.contentView addSubview:_momunt];
    
    // Shadow
//    _momunt.layer.shadowOffset = CGSizeMake(0,0);
//    _momunt.layer.shadowRadius = 0;
//    _momunt.layer.shadowOpacity = 0.7;

    
    // poster image
    _poster = [[MMNT_AsyncImage alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-PADDING)];
    _poster.shouldCenter = YES;
    NSString *url = _data.poster;
    if(!url){
        url= @"https://s3-us-west-2.amazonaws.com/uploads.momunt.com/sadFaceImg.png";
    }
    _poster.imageURL = [NSURL URLWithString: url];
    _poster.alpha = POSTER_ALPHA;
    [_momunt addSubview:_poster];
    
    // dark overlay
    UIView *overlay = [[UIView alloc] initWithFrame: _poster.frame ];
//    [overlay setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:0.5]];
    [overlay setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.50]];
    [_momunt addSubview:overlay];
    
    // name
    _name = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2 - 25, self.frame.size.width,  30)];
    _name.text = [_data.name stringByRemovingPercentEncoding];
    _name.textColor = [UIColor colorWithWhite:1 alpha:1];
    _name.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:25.0];
    _name.textAlignment = NSTextAlignmentCenter;
    [_momunt addSubview:_name];
    
    if([_data.momuntId isEqual:@"myMomunt"]){
        _data.timestamp = [NSDate date];
    }

    // date
    
    NSString *dateString;
//    if([_data.momuntId isEqualToString:@"firstMomunt"]){
//        dateString = @"with the photos around you.";
//    }
    if(_data.live){
        dateString = @"live";
    }else{
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormat setDateFormat:@"MMMM dd, yyyy"];
        dateString = [dateFormat stringFromDate:_data.timestamp];
    }
    
    _date = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2 + 5, self.frame.size.width,  15)];
    _date.text = dateString;
    _date.textColor = [UIColor colorWithWhite:1 alpha:1];
    _date.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
    _date.textAlignment = NSTextAlignmentCenter;
    [_momunt addSubview:_date];
    
    if([_data.momuntId isEqual:@"myMomunt"]){
        _canDelete = NO;
    }else{ // can't share My Momunt yet
        [self addShareDelete];
    }
    [self initGestures];
    
    
    return self;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier messageData:(MMNTMessageObj *)msg{
    
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    self.backgroundColor = [UIColor colorWithRed:(0 / 255.0) green:(0 / 255.0) blue:(0 / 255.0) alpha:0]; // clear background
    self.contentView.backgroundColor = [UIColor colorWithRed:(0 / 255.0) green:(0 / 255.0) blue:(0 / 255.0) alpha:0]; // clear background
    
    _type = @"chat";
    _momuntId = [msg.message objectForKey:@"momuntId"];
    _canDelete = NO;
    
    _theMomunt = [[MMNTObj alloc] init];
    _theMomunt.momuntId = _momuntId;
    _theMomunt.name = [msg.message objectForKey:@"momuntName"]; // just need momunt Id and Name to re-share this
    _theMomunt.poster = [msg.message objectForKey:@"momuntPoster"];
    _theMomunt.timestamp = [NSDate new];
    
    
    NSString *myUsername    = [MMNTAccountManager sharedInstance].username;
    BOOL isMe               = [msg.username isEqualToString:myUsername];
    
    CGRect frame = self.frame;
    frame.size.height = 125 + (msg.needsTimestamp ? 30 : 0) ;
    self.frame = frame;
    
    if(msg.needsTimestamp){
//        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//        [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
//        [dateFormat setDateFormat:@"MMM dd h:ma"];
//        NSString *dateString = [dateFormat stringFromDate:msg.timestamp];
        
        UILabel *timestamp = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width, 30)];
        timestamp.text = msg.timeString;
        timestamp.textAlignment = NSTextAlignmentCenter;
        timestamp.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        timestamp.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        [self.contentView addSubview:timestamp];
        
    }

    CGRect theFrame = msg.needsTimestamp ? CGRectMake(0, 30, self.frame.size.width, self.frame.size.height-30) : self.frame;
    _momunt = [[UIView alloc] initWithFrame: theFrame];
    [self.contentView addSubview:_momunt];
    
    // Shadow
//    _momunt.layer.shadowOffset = CGSizeMake(0,0);
//    _momunt.layer.shadowRadius = 0;
//    _momunt.layer.shadowOpacity = 0.7;

    
    if(!msg.read && [UIApplication sharedApplication].applicationState!=UIApplicationStateBackground){ // ???
        // mark as read
        msg.read = YES;
        // ping the server that message was read
//        [[MMNTDataController sharedInstance] markMessageAsRead:msg];
        [[MMNTApiCommuniator sharedInstance] markMessageAsRead:msg];
        
        if([UIApplication sharedApplication].applicationIconBadgeNumber > 0){
            [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber - 1;
        }
        
    }

    
    // poster image

    if (msg.needToUpdate || msg.uploadId) { // has uplod Id -> still uploading to server
        _uploading = YES;
        // add placeholder image
        UIImage *placeholder = [UIImage imageNamed:@"Logo Icon 3"];
        UIImageView *momuntBubble = [[UIImageView alloc] initWithImage:placeholder];
        momuntBubble.contentMode = UIViewContentModeScaleAspectFit;
        momuntBubble.frame = CGRectMake(0,0, _momunt.frame.size.width/2,_momunt.frame.size.height/2);
        momuntBubble.center = CGPointMake(_momunt.frame.size.width/2,_momunt.frame.size.height/2);
        [_momunt addSubview:momuntBubble];
    }else{
        _poster = [[MMNT_AsyncImage alloc] initWithFrame:CGRectMake(0,0,_momunt.frame.size.width, _momunt.frame.size.height)];
        _poster.shouldCenter = YES;
        NSString *url = [msg.message objectForKey:@"momuntPoster"];
        if(!url){
            url= @"https://s3-us-west-2.amazonaws.com/uploads.momunt.com/sadFaceImg.png";
        }
        _poster.imageURL = [NSURL URLWithString: url];
        _poster.alpha = POSTER_ALPHA;
        [_momunt addSubview:_poster];
        
    }
    
    // dark overlay
    UIView *overlay = [[UIView alloc] initWithFrame: _poster.frame ];
//    UIColor *color = isMe ? [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.50] : [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:0.4];
    UIColor *color = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.50];
    [overlay setBackgroundColor:color];
    [_momunt addSubview:overlay];
    
    // profile
    CGFloat H = 35.0;
    CGFloat padding = 5.0;
    MMNT_AsyncImage *profile = [[MMNT_AsyncImage alloc] initWithFrame: isMe ? CGRectMake(self.frame.size.width-H-padding,padding,H,H) : CGRectMake(padding,padding,H,H)];
    profile.layer.cornerRadius =  H/2;
    profile.clipsToBounds = YES;
    [profile setImageURL:[NSURL URLWithString:msg.profileUrl]];
    [_momunt addSubview:profile];

    
    
    // name
    _name = [[UILabel alloc] initWithFrame:CGRectMake(0, _momunt.frame.size.height/2 - 25, self.frame.size.width,  30)];
    _name.text = [[msg.message objectForKey:@"momuntName"] stringByRemovingPercentEncoding];
//    name.textColor = isMe ? [UIColor colorWithWhite:1 alpha:1] : [UIColor colorWithWhite:0 alpha:0.85];
    _name.textColor = [UIColor colorWithWhite:1 alpha:1];
    _name.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:25.0];
    _name.textAlignment = NSTextAlignmentCenter;
    [_momunt addSubview:_name];
    
    // date
    
    NSString *dateString = [msg.message objectForKey:@"momuntDate"];
    _date = [[UILabel alloc] initWithFrame:CGRectMake(0, _momunt.frame.size.height/2 + 5, self.frame.size.width,  15)];
    _date.text = dateString;
//    date.textColor = isMe ? [UIColor colorWithWhite:1 alpha:1] : [UIColor colorWithWhite:0 alpha:0.85];
    _date.textColor = [UIColor colorWithWhite:1 alpha:1];
    _date.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
    _date.textAlignment = NSTextAlignmentCenter;
    [_momunt addSubview:_date];
    
    [self addShareDelete];
    [self initGestures];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone; //dont highlight on select
    return self;
    
}
-(void)addShareDelete{
    // DELETE
    _delete = [[UIView alloc] initWithFrame: _momunt.frame ];
    _delete.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.25];
    // delete text
    UILabel *deleteTxt = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width*0.4,0,self.frame.size.width*0.6 - 30, _momunt.frame.size.height)];
    deleteTxt.text = @"delete";
    deleteTxt.font = [UIFont fontWithName:@"HelveticaNeue" size:24.0];
    deleteTxt.textColor = [UIColor whiteColor];
    deleteTxt.textAlignment = NSTextAlignmentCenter;
    [_delete addSubview:deleteTxt];
    // delete image
    UIImageView *deleteImg = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,25,25)];
    deleteImg.image = [UIImage imageNamed:@"X"];
    deleteImg.center = CGPointMake(_delete.frame.size.width -30, _delete.frame.size.height/2);
    deleteImg.contentMode = UIViewContentModeScaleAspectFit;
    [_delete addSubview:deleteImg];
    
    _delete.hidden = YES;
    [self.contentView insertSubview:_delete atIndex:0];
    // tap gesture
    UITapGestureRecognizer *deleteTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePressedDelete)];
    deleteTap.delegate = self;
    [_delete addGestureRecognizer:deleteTap];
    
    // SHARE
    _share = [[UIView alloc] initWithFrame: CGRectMake(0,_momunt.frame.origin.y,_momunt.frame.size.width,_momunt.frame.size.height)];
    _share.backgroundColor = [UIColor colorWithRed:133/255 green:255/255 blue:0 alpha:0.25];
    // share text
    UILabel *shareTxt = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width*0.8,_momunt.frame.size.height)];
    shareTxt.text = @"share";
    shareTxt.font = [UIFont fontWithName:@"HelveticaNeue" size:24.0];
    shareTxt.textColor = [UIColor whiteColor];
    shareTxt.textAlignment = NSTextAlignmentCenter;
//    [_share addSubview:shareTxt];
    
    // share icons
    CGFloat iconSize = shareTxt.frame.size.width*0.15; //shareTxt.frame.size.width*0.20;
    CGFloat spacing = shareTxt.frame.size.width*0.1;
    
    UIButton *save;
    if(!_canDelete){ // if can delete0 this is already you rsaved momunt
        // save
        save = [[UIButton alloc] initWithFrame:CGRectMake(0,0,iconSize, iconSize)];
        [save setImage:[UIImage imageNamed:@"Save"] forState:UIControlStateNormal];
        [save setImage:[UIImage imageNamed:@"Save"] forState:UIControlStateHighlighted];
        save.imageView. contentMode = UIViewContentModeScaleAspectFit;
        save.center = CGPointMake(shareTxt.frame.size.width*0.125, _momunt.frame.size.height/2);
        [_share addSubview:save];
        
        [save addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchDown];
        [save addTarget:self action:@selector(Save:) forControlEvents:UIControlEventTouchUpInside];

    }
    
    // message
    UIButton *message = [[UIButton alloc] initWithFrame:CGRectMake(0,0,iconSize, iconSize)];
    [message setImage:[UIImage imageNamed:@"messages"] forState:UIControlStateNormal];
    [message setImage:[UIImage imageNamed:@"messages"] forState:UIControlStateHighlighted];
    message.imageView. contentMode = UIViewContentModeScaleAspectFit;
    message.center = _canDelete ? CGPointMake(shareTxt.frame.size.width*0.2, _momunt.frame.size.height/2) : CGPointMake(shareTxt.frame.size.width*0.375, _momunt.frame.size.height/2);
    [_share addSubview:message];
    
    // facebook
    UIButton *facebook = [[UIButton alloc] initWithFrame:CGRectMake(0,0,iconSize, iconSize)];
    [facebook setImage:[UIImage imageNamed:@"Facebook"] forState:UIControlStateNormal];
    [facebook setImage:[UIImage imageNamed:@"Facebook"] forState:UIControlStateHighlighted];
    facebook.imageView. contentMode = UIViewContentModeScaleAspectFit;
    facebook.center =  _canDelete ? CGPointMake(shareTxt.frame.size.width*0.5, _momunt.frame.size.height/2) :CGPointMake(shareTxt.frame.size.width*0.625, _momunt.frame.size.height/2);
    [_share addSubview:facebook];
    
    // twitter
    UIButton *twitter = [[UIButton alloc] initWithFrame:CGRectMake(0,0,iconSize, iconSize)];
    [twitter setImage:[UIImage imageNamed:@"Twitter"] forState:UIControlStateNormal];
    [twitter setImage:[UIImage imageNamed:@"Twitter"] forState:UIControlStateHighlighted];
//    twitter.image = [UIImage imageNamed:@"Twitter"];
    twitter.imageView.contentMode = UIViewContentModeScaleAspectFit;
    twitter.center = _canDelete ? CGPointMake(shareTxt.frame.size.width*0.8, _momunt.frame.size.height/2) : CGPointMake(shareTxt.frame.size.width*0.875, _momunt.frame.size.height/2);
//    twitter.delegate = self;
    [_share addSubview:twitter];

    
    _share.hidden = YES;
    [self.contentView insertSubview:_share atIndex:0];
    
    // GESTURES
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    panGesture.delegate = self;
    panGesture.delaysTouchesBegan = NO;
    [self.contentView addGestureRecognizer:panGesture];
    
    // facebook share
    [facebook addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchDown];
    [facebook addTarget:self action:@selector(facebookShare:) forControlEvents:UIControlEventTouchUpInside];
//    facebook.userInteractionEnabled = YES;
//    UITapGestureRecognizer *facebookTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(facebookShare)];
//    facebookTap.delegate = self;
//    [facebook addGestureRecognizer:facebookTap];
    
//    // twitter share
    [twitter addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchDown];
    [twitter addTarget:self action:@selector(twitterShare:) forControlEvents:UIControlEventTouchUpInside];
    
    // message
    [message addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchDown];
    [message addTarget:self action:@selector(messageShare:) forControlEvents:UIControlEventTouchUpInside];
//    message.userInteractionEnabled = YES;
//    UITapGestureRecognizer *messageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageShare)];
//    messageTap.delegate = self;
//    [message addGestureRecognizer:messageTap];
    
    
    
    _shareButtons = _canDelete ? @[message, facebook, twitter] : @[save, message, facebook, twitter];

    
}
// Scale up on button press
- (void) buttonPress:(UIButton*)button {
    [UIView animateWithDuration:0.1 animations:^{
        button.transform = CGAffineTransformMakeScale(0.8, 0.8);
    }];
    
    
    
//    [button pop_removeAllAnimations];
//    POPBasicAnimation *a = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
//    a.toValue = [NSValue valueWithCGPoint:CGPointMake(0.8,0.8)];
//    a.duration = 0.05;
//    a.completionBlock = ^(POPAnimation *animation, BOOL finished){
//    };
//    
//    [button pop_addAnimation:a forKey:@"scale"];
}

// Scale down on button release
- (void) buttonRelease:(UIButton*)button {
    
    [button pop_removeAllAnimations];
    POPSpringAnimation *a = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    a.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0,1.0)];
    a.springBounciness = 15;
    a.springSpeed = 10;
    a.completionBlock = ^(POPAnimation *animation, BOOL finished){
    };
    
    [button pop_addAnimation:a forKey:@"scale"];
    //    // Do something else
    NSLog(@"touchup twitter");
}
/*
 SHARE BUTTONS
 */
-(void)facebookShare:(UIButton*)button {
    [self setupForShare];
    
    [button pop_removeAllAnimations];
    POPSpringAnimation *a = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    a.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0,1.0)];
    a.springBounciness = 15;
    a.springSpeed = 10;
    a.completionBlock = ^(POPAnimation *animation, BOOL finished){
        
        [self performFacebookShare];
    };
    
    [button pop_addAnimation:a forKey:@"scale"];

}
-(void)twitterShare:(UIButton*)button {
    [self setupForShare];
    
    [button pop_removeAllAnimations];
    POPSpringAnimation *a = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    a.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0,1.0)];
    a.springBounciness = 15;
    a.springSpeed = 10;
    a.completionBlock = ^(POPAnimation *animation, BOOL finished){

        [self performTwitterShare];
    };
    
    [button pop_addAnimation:a forKey:@"scale"];
    
    
}
-(void)messageShare:(UIButton*)button {
    [self setupForShare];
    
    [button pop_removeAllAnimations];
    POPSpringAnimation *a = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    a.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0,1.0)];
    a.springBounciness = 15;
    a.springSpeed = 10;
    a.completionBlock = ^(POPAnimation *animation, BOOL finished){
    };
    
    //open contacts
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showContacts"
                                                        object:self
                                                      userInfo:nil];
    
    [self performSelector:@selector(closeOptions) withObject:nil afterDelay:0.5];
    
    [button pop_addAnimation:a forKey:@"scale"];

    
}
-(void)Save:(UIButton*)button {
    [self setupForShare];
    
    [button pop_removeAllAnimations];
    POPSpringAnimation *a = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    a.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0,1.0)];
    a.springBounciness = 15;
    a.springSpeed = 10;
    a.completionBlock = ^(POPAnimation *animation, BOOL finished){
        [self closeOptions];
        [[MMNTDataController sharedInstance] storeMomunt: [MMNTDataController sharedInstance].toShareMomunt];
    };
    
    [button pop_addAnimation:a forKey:@"scale"];
    
//    [self performSelector:@selector(closeOptions) withObject:nil afterDelay:0.3];
    
    
//    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
//    dispatch_async(sessionQueue, ^{
    
    
//    });
    
    
}
-(void)animateShareButtons{
    [_shareButtons enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        obj.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    }];
    
    [self scaleUpViews:_shareButtons withMinDelay:0];

}

-(void)initGestures{
    // tap gesture
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    tapRecognizer.delegate = self;
    tapRecognizer.delaysTouchesBegan = NO;
    [_momunt addGestureRecognizer:tapRecognizer];
}

-(void)closeOptions{
    _optionsOpen = NO;
    CGPoint target = CGPointMake(self.frame.size.width/2, _momunt.center.y);
    
    POPSpringAnimation *a = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    a.toValue = [NSValue valueWithCGPoint:target];
    a.springBounciness = _optionsOpen ? 6:1;
    a.springSpeed = 8;
    a.completionBlock = ^(POPAnimation *animation, BOOL finished){
        if(!_optionsOpen){
            _delete.hidden = YES;
            _share.hidden = YES;
            _poster.alpha = POSTER_ALPHA;
        }
    };
    
    [_momunt pop_addAnimation:a forKey:@"center"];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return NO;
    }
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return NO;
    }
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        return NO;
//    }
    
    return YES;
//    return NO;
}

-(void)tapped:(UITapGestureRecognizer *)tapRecognizer{
    // tapped -> load this momunt
    
    if(_uploading){
        return;
    }
    
    if(![_momuntId isEqual:@"myMomunt"]){
        // AMPLITUDE ---------------------------------------------------------------------------------------------------
        NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
        [eventProperties setValue:_momuntId forKey:@"momuntId"];
        [eventProperties setValue:_type forKey:@"type"];
        [Amplitude logEvent:@"opened momunt" withEventProperties:eventProperties];
        // --------------------------------------------------------------------------------------------------------------
    }else{
        [Amplitude logEvent:@"tapped my momunt"];
    }
    
    // POST NOTIFICATION to load a new momunt
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedStoredMomunt"
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:_momuntId
                                                                                           forKey:@"momuntId"]];
    
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder)
                                               to:nil
                                             from:nil
                                         forEvent:nil];

    
}

-(void)handlePan:(UIPanGestureRecognizer*)recognizer{
    // swipe left/right -> delete/share

    CGPoint point     = [recognizer translationInView:[self window]];
    CGPoint location  = [recognizer locationInView:[self window]];
    CGPoint velocity  = [recognizer velocityInView:[self window]];
    
    BOOL horizontal = ABS(point.x) > ABS(point.y); // swiped horizontal?
    BOOL swipedRight = velocity.x > 0; // swiped left->right?
    NSInteger direction = point.x > 0 ? 1 : -1;
    //
    
//    NSLog(@"x = %f", point.x);
    // If not Horizontal or swiped right->left - Ignore
//    if((!horizontal  && recognizer.state!=UIGestureRecognizerStateEnded)){
//        return;
//    }
    
    // 1. Gesture is started, show the modal controller
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _poster.alpha = 1.0;
//        _momunt.layer.shadowRadius = 2;
        
        _startCenter = _momunt.center;
        _verticalPan = !horizontal;

        _startedPan = horizontal;
        _swipeDirection = point.x>0 ? 1 : -1;
        if(!_optionsOpen){
            if(_swipeDirection==1){
                _delete.hidden = YES;
                _share.hidden = NO;
                [self animateShareButtons];
            }else{
                _delete.hidden = NO;
                _share.hidden = YES;
            }
        }
        
    }
    
    // 2. Update the animation state
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        _swipeDirection = point.x>0 ? 1 : -1;
        if(_verticalPan || (_swipeDirection==-1 && !_optionsOpen && !_canDelete) )
            return;
        
        [_momunt pop_removeAllAnimations];
        
        if(_startedPan){
            if(!_optionsOpen){
                if(_swipeDirection==1){
                    _delete.hidden = YES;
                    _share.hidden = NO;
                }else{
                    _delete.hidden = NO;
                    _share.hidden = YES;
                }
            }
            
            _momunt.center = CGPointMake(_startCenter.x+point.x, _momunt.center.y);
        }
        
    }

    // 3. Complete or cancel the animation when gesture ends
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if(_verticalPan || (_swipeDirection==-1 && !_optionsOpen && !_canDelete) )
            return;
        
        CGPoint target;
        BOOL completed = NO;
        if(_optionsOpen){
            _optionsOpen = NO;
            target = CGPointMake(self.frame.size.width/2, _momunt.center.y);
        }else{
            _openedShare = point.x > 0;
            if((ABS(velocity.x)>3000) && !_openedShare){
                // complete the action!
                target = CGPointMake(self.frame.size.width/2 + (_openedShare ? 1:-1)*self.frame.size.width, _momunt.center.y);
                completed = YES;
                
                if(!_openedShare){
                    [self deleteMomunt];
                }

            }
            else if((ABS(point.x)>70  || ABS(velocity.x)>500)){
                _optionsOpen = YES;
                _openedShare = point.x > 0;
                target = CGPointMake(self.frame.size.width/2 + (_openedShare ? self.frame.size.width*0.8: -self.frame.size.width*0.6), _momunt.center.y);
                
                if(_openedShare){
                    [Amplitude logEvent:@"swiped to share"];
                }else{
                    [Amplitude logEvent:@"swiped to delete"];
                }
            }else{
                _optionsOpen = NO;
                target = CGPointMake(self.frame.size.width/2, _momunt.center.y);
            }
        }
        
        
        [_momunt pop_removeAllAnimations];
        
        POPSpringAnimation *a = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
        a.toValue = [NSValue valueWithCGPoint:target];
        a.velocity = [NSValue valueWithCGPoint:CGPointMake(velocity.x, 0)];
        a.springBounciness = _optionsOpen ? 6:1;
        a.springSpeed = 8;
        a.completionBlock = ^(POPAnimation *animation, BOOL finished){
            if(!_optionsOpen){
                _delete.hidden = YES;
                _share.hidden = YES;
                _poster.alpha = POSTER_ALPHA;
//                _momunt.layer.shadowRadius = 0;
            }
        };
        
        [_momunt pop_addAnimation:a forKey:@"center"];
        _startedPan = NO;

    }
    
}
-(void)handlePressedDelete{
    [self deleteMomunt];
    [UIView animateWithDuration:0.3 animations:^{
        _momunt.center = CGPointMake(-self.frame.size.width/2, self.frame.size.height/2);
    } completion:^(BOOL finished) {}];

}
-(void)deleteMomunt{

    [[MMNTApiCommuniator sharedInstance] deleteMomunt:_momuntId];
    [_parentArray removeObject:_data];
    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [_tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.35];
    
}


-(NSString *)dateFromTimestamp:(NSDate *)timestamp{
    // set date and time
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"M/d/yy"];
    NSString *theDate = [dateFormat stringFromDate:timestamp];
    
    return theDate;
    
}
-(NSString *)timeFromTimestamp:(NSDate *)timestamp{
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"a"];
    NSString *ampm = [[timeFormat stringFromDate:timestamp] isEqualToString:@"AM"] ? @"a" : @"p";
    [timeFormat setDateFormat:@"h:mm"];
    NSString *theTime = [NSString stringWithFormat:@"%@%@" , [timeFormat stringFromDate:timestamp ], ampm];
    
    return theTime;

}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
//    self.collectionView.frame = self.contentView.bounds;
}

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index
{
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.tag = index;
    
    [self.collectionView reloadData];
}




/*
 SHARE
 */
-(void)setupForShare{
    [[MMNTDataController sharedInstance].toShareMomunt setEqualTo:_theMomunt];
    if(_theMomunt.live){
        // sharing live momunt - new ID
        [MMNTDataController sharedInstance].toShareMomunt.momuntId = [[MMNTDataController sharedInstance] uniqueId];
    }
}

-(void)performFacebookShare{
    // share the momunt. But wait for it to save&share before presenting the dialog
    NSArray *recipients = @[@"facebook"];    // do the actual sharing=

    [[MMNTDataController sharedInstance] shareMomuntViaText: [MMNTDataController sharedInstance].toShareMomunt with:recipients];
    

    // Check if the Facebook app is installed and we can present the share dialog
    NSString *urlString = [NSString stringWithFormat:@"http://www.momunt.com/%@", [MMNTDataController sharedInstance].toShareMomunt.momuntId];
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:urlString];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:@"Check out my momunt!"];
        [controller addURL:[NSURL URLWithString:urlString]];
        controller.completionHandler = ^(SLComposeViewControllerResult result) {
            switch(result) {
                    //  This means the user cancelled without sending the Tweet
                case SLComposeViewControllerResultCancelled:
                    break;
                    //  This means the user hit 'Send'
                case SLComposeViewControllerResultDone:
                    break;
            }
            // close sharing buttons
            [self closeOptions];
        };

        
        [_parentVC presentViewController:controller animated:YES completion:Nil];
        

    }
    else if ([FBDialogs canPresentShareDialogWithParams:params]) {
        
        // Present share dialog
        [FBDialogs presentShareDialogWithLink:params.link
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog(@"Error publishing story: %@", error.description);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
//                                          [self dismissViewControllerAnimated:YES completion:nil];
                                          [self closeOptions];
                                      }];
    } else {
        // Present the feed dialog
        
        // Put together the dialog parameters
        NSMutableDictionary *paramsFD = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [MMNTDataController sharedInstance].toShareMomunt.name, @"name",
                                         urlString, @"link",
                                         nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:paramsFD
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User cancelled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                          // close sharing buttons
                                                        [self closeOptions];
                                                      }
                                                  }];
    }
    
}

// A function for parsing URL parameters returned by the Feed Dialog.
-(NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    
    return params;
}

-(void)performTwitterShare{
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        // share the momunt. But wait for it to save&share before presenting the dialog
        NSArray *recipients = @[@"twitter"];    // do the actual sharing=
        
        [[MMNTDataController sharedInstance] shareMomuntViaText: [MMNTDataController sharedInstance].toShareMomunt with:recipients];
        
        SLComposeViewController *tweetSheetOBJ = [SLComposeViewController
                                                  composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *urlString = [NSString stringWithFormat:@"http://www.momunt.com/%@", [MMNTDataController sharedInstance].toShareMomunt.momuntId];
        
        [tweetSheetOBJ setInitialText:@"Check out my momunt!"];
        [tweetSheetOBJ addURL:[NSURL URLWithString:urlString]];
        
        // Sets the completion handler.  Note that we don't know which thread the
        // block will be called on, so we need to ensure that any UI updates occur
        // on the main queue
        tweetSheetOBJ.completionHandler = ^(SLComposeViewControllerResult result) {
            switch(result) {
                    //  This means the user cancelled without sending the Tweet
                case SLComposeViewControllerResultCancelled:
                    break;
                    //  This means the user hit 'Send'
                case SLComposeViewControllerResultDone:
                    break;
            }
            // close sharing buttons
            [self closeOptions];
            
            //  dismiss the Tweet Sheet
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.parentVC dismissViewControllerAnimated:YES completion:^{
//                    NSLog(@"Tweet Sheet has been dismissed.");
//            
//                }];
//            });
            
            
        };
        
        [self.parentVC presentViewController:tweetSheetOBJ animated:YES completion:nil];
        
    }
}

-(void)scaleUpViews:(NSArray *)views withMinDelay:(NSTimeInterval)mindelay{
    [views enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        NSTimeInterval delay = mindelay + ((float)idx / (float)[views count]) * 0.2;
        [self scaleUpView:obj withDelay:delay];
    }];
}

- (void)scaleDownView:(UIView *)view withDelay:(NSTimeInterval)delay
{
    POPBasicAnimation *scaleDown = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleDown.toValue = [NSValue valueWithCGPoint: CGPointMake(0,0)] ;
    scaleDown.beginTime = (CACurrentMediaTime() + delay);
    scaleDown.duration = 0.3;
    [view pop_addAnimation:scaleDown forKey:@"scale"];
}

- (void)scaleUpView:(UIView *)view withDelay:(NSTimeInterval)delay
{
    POPSpringAnimation *scaleUp = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleUp.toValue = [NSValue valueWithCGPoint: CGPointMake(1, 1)] ;
    scaleUp.springBounciness = 15;
    scaleUp.springSpeed = 15;
    scaleUp.beginTime = (CACurrentMediaTime() + delay);
    [view pop_addAnimation:scaleUp forKey:@"scale"];
}


@end
