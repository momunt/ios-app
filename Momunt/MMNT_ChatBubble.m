//
//  MMNT_ChatBubble.m
//  Momunt
//
//  Created by Masha Belyi on 10/8/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MMNT_ChatBubble.h"
#import "MMNTDataController.h"

@implementation MMNT_ChatBubble

#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)

#define padding_top      5.0;
#define padding_left     10.0;
#define arrow_width      15.0;
#define default_height   100.0;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame data:(MMNTMessageObj *)msg type:(MMNTBubbleType *)type{
    self = [super initWithFrame:frame];
    if (self) {

        _msg             = msg;
        
        _textColor       = type==Me ?  [UIColor colorWithWhite:1.0 alpha:1.0] : [UIColor colorWithWhite:0.0 alpha:0.85];
        _font            = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
        _bubbleImage     = type==Me ? @"ChatBubble_black" : @"ChatBubble_white";
        _bubbleMaskAlpha = type==Me ? @"ChatBubble_black_mask" : @"ChatBubble_white_mask";
//        _bubbleInsets    = type==Me ? UIEdgeInsetsMake(31,31,31,40) : UIEdgeInsetsMake(22,18,7,12);
        _bubbleInsets    = type==Me ? UIEdgeInsetsMake(16,18,16,20) : UIEdgeInsetsMake(16,20,16,18);
        _textInsets      = UIEdgeInsetsMake(8,5,8,5);
        _paddingTop      = 0.0;//4.0;
        _paddingLeft     = 10.0;
        _contentOrigin   = type==Me ? CGPointMake(0.0, _paddingTop) : CGPointMake(8.0, _paddingTop); // leave room for arrow on the left
        _type            = type;
        _maxWidth        = self.frame.size.width; //-2*_paddingLeft; // 15 = arrow width
        
        if (_msg.needToUpdate) {
            [[MMNTDataController sharedInstance] fetchMessageById:_msg.messageId];
        }
        
        if ([_msg.message objectForKey:@"momuntId"]) {
            [self drawMomuntBubble];
        }
        else{
            [self writeMessage];
            [self drawBubble];
        }
        
        // align to the right if Me
        if(type==Me){
            
            CGRect frame = self.frame; // CGRectMake(0,0,self.frame.size.width, self.frame.size.height);
            frame.size.width = _contentWidth+ ([_msg.message objectForKey:@"momuntId"] ? 0.0 : 20.0);
            frame.size.height = _contentHeight;
            self.frame = frame;
        }
        
    }
    return self;

}

-(void)writeMessage{
    NSString *text  = [_msg.message objectForKey:@"text"];
    // calculate content height & width
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attrStr addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, [attrStr length])];
    CGSize contentSize = [self textViewHeightForAttributedText:attrStr andWidth:_maxWidth];
    _contentHeight = contentSize.height; //contentSize.height-6.0;
    _contentWidth = contentSize.width;
    
    
    _text                 = [[UITextView alloc] initWithFrame:CGRectMake(_contentOrigin.x,_contentOrigin.y, _contentWidth, _contentHeight)];
    _text.text            = text;
    _text.textColor       = _textColor;
    _text.font            = _font;
    _text.editable        = NO;
    _text.backgroundColor = [UIColor clearColor]; // [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.1]; //
    _text.scrollEnabled   = NO;
//    _text.textContainer.lineFragmentPadding = 0;
//    _text.textContainerInset = UIEdgeInsetsMake(12,10,12,10);
    _text.textContainerInset = _textInsets;
    
//    _text.contentInset = UIEdgeInsetsMake(-10,-10,0,0);
    
    [self addSubview:_text];
}
-(void)drawBubble{
//    UIImage *smallImg = [self resizeImage:[UIImage imageNamed:_bubbleImage] toSize:CGSizeMake(38,34)];
    UIImage *bubbleImg = [[UIImage imageNamed:_bubbleImage] resizableImageWithCapInsets:_bubbleInsets];

    _bubble         = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _contentWidth + (_type==Me ? 12.0 : 12.0),  _contentHeight)];
//    _bubble         = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _contentWidth + 20.0,  _contentHeight)];
    _bubble.image   = bubbleImg;
    
    [self insertSubview:_bubble atIndex:0];
    
    
}

- (CGSize)textViewHeightForAttributedText: (NSAttributedString*)text andWidth: (CGFloat)width {
    UITextView *calculationView = [[UITextView alloc] init];
    [calculationView setAttributedText:text];
//    calculationView.textContainerInset = UIEdgeInsetsMake(12,10,12,10);
    calculationView.textContainerInset = _textInsets;
    CGSize size = [calculationView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size;
}

-(void)drawMomuntBubble{
    // inser masked view with image
    _contentWidth = self.frame.size.width;
    _contentHeight = 100.0;
    
    // the view
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, _contentHeight )];
    
    UIImage *_maskingImage = [UIImage imageNamed:_bubbleMaskAlpha];
    CALayer *_maskingLayer = [CALayer layer];
    _maskingLayer.contentsCenter = _type==Me ? CGRectMake(0.5, 0.7, 1.0/_maskingImage.size.width, 1.0/_maskingImage.size.height) : CGRectMake(0.5, 0.7, 1.0/_maskingImage.size.width, 1.0/_maskingImage.size.height); // rounded bubbles
    _maskingLayer.contentsScale = _maskingImage.scale;
    [_maskingLayer setContents:(id)[_maskingImage CGImage]];
    _maskingLayer.frame = CGRectMake(0, 0, self.frame.size.width, _contentHeight );
    [view.layer setMask:_maskingLayer];
    [self addSubview:view];
    
    // add Image
    if (_msg.needToUpdate || _msg.uploadId) { // has uplod Id -> still uploading to server
        // add placeholder image
        UIImage *placeholder = [UIImage imageNamed:@"Logo Icon 3"];
        UIImageView *momuntBubble = [[UIImageView alloc] initWithImage:placeholder];
        momuntBubble.frame = CGRectMake(0,0, self.frame.size.height*(placeholder.size.width/placeholder.size.height) ,self.frame.size.height);
        momuntBubble.center = view.center;
        [view addSubview:momuntBubble];
    }else{
        MMNT_AsyncImage *momuntBubble = [[MMNT_AsyncImage alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, _contentHeight )];
        momuntBubble.shouldCenter = YES;
        NSString *url = [_msg.message objectForKey:@"momuntPoster"];
        momuntBubble.imageURL = [NSURL URLWithString: url];
        [view addSubview:momuntBubble];
    }
    
    // add dark overlay
    UIView *overlay = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.frame.size.width, _contentHeight ) ];
    [overlay setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.3]];
    [view addSubview:overlay];
    
    // add name
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(_type==Me ? 0.0 : 15.0, 20, _maxWidth,  30)];
    name.text = [_msg.message objectForKey:@"momuntName"];
    name.textColor = [UIColor colorWithWhite:1 alpha:1];
    name.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:25.0];
    name.textAlignment = NSTextAlignmentCenter;
    [view addSubview:name];
    
    // add date
    if ([_msg.message objectForKey:@"momuntDate"]) {
        UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, _contentWidth,  15)];
        date.text = [_msg.message objectForKey:@"momuntDate"];
        date.textColor = [UIColor colorWithWhite:1 alpha:1];
        date.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
        date.textAlignment = NSTextAlignmentCenter;
        [view addSubview:date];
    }
    
}
-(UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)targetSize{

    UIImage *tempImage = nil;
//    CGSize targetSize = CGSizeMake(80,60);
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
    thumbnailRect.origin = CGPointMake(0.0,0.0);
    thumbnailRect.size.width  = targetSize.width;
    thumbnailRect.size.height = targetSize.height;
    
    [image drawInRect:thumbnailRect];
    
    tempImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tempImage;
}
+(CGFloat)getHeightForMessage:(NSDictionary *)msg{
    if(!msg){
        return 0;
    }
    if ([[msg objectForKey:@"message"] objectForKey:@"momuntId"]) {
        return 100.0;
    }
    else{
        NSString *text  = [msg objectForKey:@"text"];
        
        CGFloat maxWidth  = SCREEN_WIDTH - 85.0; // - profile Width (50) - profile padding (10+5) - arrpw width (15)
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text];
        [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0] range:NSMakeRange(0, [attrStr length])];
        
//        CGSize contentSize = [self textViewHeightForAttributedText:attrStr andWidth:maxWidth];
//        return contentSize.height;
        
        UITextView *calculationView = [[UITextView alloc] init];
        [calculationView setAttributedText:attrStr];
//        calculationView.textContainerInset = UIEdgeInsetsMake(12,10,12,10);
        calculationView.textContainerInset = UIEdgeInsetsMake(8,5,8,5);
        CGSize size = [calculationView sizeThatFits:CGSizeMake(maxWidth, FLT_MAX)];
        return size.height; // because of pngs
    }
}

@end





