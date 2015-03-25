//
//  MMNT_ContactsCell.m
//  Momunt
//
//  Created by Masha Belyi on 8/28/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_ContactsCell.h"
#import "AsyncImageView.h"
#import "MMNT_SharedVars.h"

@implementation MMNT_ContactsCell

#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellData:(MMNT_Contact *)contact selected:(BOOL)selected
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    self.backgroundColor = [UIColor colorWithRed:(0 / 255.0) green:(0 / 255.0) blue:(0 / 255.0) alpha:0]; // clear background
    self.contentView.backgroundColor = [UIColor colorWithRed:(0 / 255.0) green:(0 / 255.0) blue:(0 / 255.0) alpha:0]; // clear background
    
    _contact = contact;
    _isSelected = selected;
    
    // init with profile pic, name, phone number
    _contactName = [[UILabel alloc] initWithFrame:CGRectMake(68, 5, SCREEN_WIDTH-170, 30)];
    _contactName.text = contact.name;
    _contactName.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    _contactName.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0];
    _contactName.adjustsFontSizeToFitWidth = NO;
//    _contactName.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
    _contactName.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:_contactName];
    
//    if([data valueForKey:@"numbers"]){
//        _contactNumber = [[UILabel alloc] initWithFrame:CGRectMake(58, 25, SCREEN_WIDTH-58, 20)];
//        _contactNumber.text = [[data valueForKey:@"numbers"] objectAtIndex:0];
//        _contactNumber.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
//        _contactNumber.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
//        [self addSubview:_contactNumber];
//    }
    
    
    _contactNumber = [[UILabel alloc] initWithFrame:CGRectMake(68, 30, SCREEN_WIDTH-58, 20)];
    _contactNumber.text = contact.momuntUser ? [NSString stringWithFormat:@"@%@", contact.username ] : contact.phone;
    _contactNumber.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    _contactNumber.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
    [self addSubview:_contactNumber];
    
    if(contact.momuntUser){
        // profile pic
        _contactPic = [[AsyncImageView alloc] initWithFrame: CGRectMake(10, 5, 50, 50) ];
        _contactPic.layer.cornerRadius = 25.0;
        _contactPic.clipsToBounds = YES;
        _contactPic.crossfadeDuration = 0;
        _contactPic.animationType = AsyncImageNormal;
        [self addSubview:_contactPic];
        [_contactPic setImageURL:[NSURL URLWithString: contact.profileUrl ]];

    }else{
        // fake profilepic
        UILabel *profilePic = [contact avatar];
        profilePic.frame = CGRectMake(10, 5, 50, 50);
        [self addSubview:profilePic];
        
        
        // invite button
        _inviteBtn = [[UILabel alloc] initWithFrame:CGRectMake(0,0,80,35) ];
        _inviteBtn.center = CGPointMake(self.frame.size.width-50, 30);
        _inviteBtn.text = @"invite";
        _inviteBtn.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        _inviteBtn.textAlignment = NSTextAlignmentCenter;
        _inviteBtn.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0];
        
        _inviteBtn.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
        _inviteBtn.layer.borderWidth = 2.0;
        _inviteBtn.layer.cornerRadius = 5;
        _inviteBtn.layer.masksToBounds = YES;
        
        [self addSubview:_inviteBtn];
        
        if(_isSelected){
            _inviteBtn.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
        }
    }
    
    // check Img
    _checkImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-45,15,30,30)];
    _checkImg.image = [UIImage imageNamed:@"Check"];
    _checkImg.contentMode = UIViewContentModeScaleAspectFit;
    _checkImg.alpha = 0.5;
    [self addSubview:_checkImg];
    if(!_isSelected){
        _checkImg.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    }
    
    self.userInteractionEnabled = YES;
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
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

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted) {
        self.backgroundColor = [[UIColor alloc] initWithWhite:1 alpha:0.3];
    } else {
        self.backgroundColor = [[UIColor alloc] initWithWhite:1 alpha:0];
    }
}

-(BOOL)toggleSelection{
    if(_isSelected){
        _isSelected = NO;
        if(_inviteBtn){
            [[MMNT_SharedVars sharedVars] scaleView:_checkImg toVal:CGPointMake(0,0) withDuration:0.2 completion:^(BOOL finished) {
                [[MMNT_SharedVars sharedVars] scaleView:_inviteBtn toVal:CGPointMake(1,1) withDuration:0.2];
            }];
        }else{
            [[MMNT_SharedVars sharedVars] scaleView:_checkImg toVal:CGPointMake(0,0) withDuration:0.2];
        }
    }else{
        _isSelected = YES;
        if(_inviteBtn){
            [[MMNT_SharedVars sharedVars] scaleView:_inviteBtn toVal:CGPointMake(0,0) withDuration:0.2 completion:^(BOOL finished) {
                [[MMNT_SharedVars sharedVars] scaleView:_checkImg toVal:CGPointMake(1,1) withDuration:0.2];
            }];
        }else{
            [[MMNT_SharedVars sharedVars] scaleView:_checkImg toVal:CGPointMake(1,1) withDuration:0.2];
       }

    }
    return _isSelected;
}
@end
