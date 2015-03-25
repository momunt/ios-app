//
//  MMNT_ChatBubble.h
//  Momunt
//
//  Created by Masha Belyi on 10/8/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNT_AsyncImage.h"
#import "MMNTMessageObj.h"

typedef NS_ENUM(NSInteger, MMNTBubbleType) {
    Me,
    Other
};

@interface MMNT_ChatBubble : UIView <UIGestureRecognizerDelegate> {
    MMNTBubbleType *_type;
    MMNTMessageObj *_msg;
    UITextView  *_text;
    UIImageView *_bubble;
    
    UIFont *_font;
    UIColor *_textColor;
    NSString *_bubbleImage;
    UIEdgeInsets _bubbleInsets;
    UIEdgeInsets _textInsets;
    CGPoint _contentOrigin;
    
    BOOL _showProfile; // show arrow?
    CGFloat _paddingTop;
    CGFloat _paddingLeft;
    CGFloat _contentHeight;
    CGFloat _contentWidth;
    CGFloat _maxWidth;
    
    NSString *_bubbleMask;
    NSString *_bubbleMaskAlpha;
    
    

}

- (id)initWithFrame:(CGRect)frame data:(MMNTMessageObj *)msg type:(MMNTBubbleType)type;
+ (CGSize)textViewHeightForAttributedText: (NSAttributedString*)text andWidth: (CGFloat)width;
+(CGFloat)getHeightForMessage:(NSDictionary *)msg;
@end
