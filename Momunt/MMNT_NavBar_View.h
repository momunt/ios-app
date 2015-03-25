//
//  MMNT_NavBar_View.h
//  Momunt
//
//  Created by Masha Belyi on 7/31/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNT_NavigationChild_ViewController.h"
#import "MMNT_AsyncImage.h"
#import "MMNT_ChatThumbnail.h"
#import "MMNT_UnreadBadge.h"


#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0];


@class MMNTNavigationController;

@interface MMNT_NavBar_View : UIView {
    
    UIButton *_profileBtn;
    UIButton *_presentBtn;
    UIButton *_goBackBtn;
    UIButton *_storedMmntsBtn;
    UIButton *_settingsBtn;
    UIButton *_messageBtn;
    UIButton *_plusBtn;
    
    UIImageView *_goBackImgView;
    UIImageView *_msgImgView;
    UIImageView *_newMsgView;
    UIImageView *_settingsImgView;
    MMNT_AsyncImage *_profileImgView;
    
    UIView *_profileOutline;
    UIView *_settingsOutline;
    
    MMNT_UnreadBadge *_unreadBadge;
    NSInteger _unreadCount;
    
    BOOL _shouldShowBadge;
}

@property(nonatomic, assign) MMNTNavigationController *navigationController;
@property(nonatomic) MMNT_ChatThumbnail *chatThumbnailView;

-(void) goToStoredMomunts;
-(void)goToMessages;
-(void)transitionFrom:(MMNT_NavigationChild_ViewController *)fromVC to:(MMNT_NavigationChild_ViewController *)toVC;
-(void)setMessages;

@end
