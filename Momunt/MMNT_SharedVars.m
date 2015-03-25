//
//  MMNT_SharedVars.m
//  Momunt
//
//  Created by Masha Belyi on 8/25/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_SharedVars.h"
#import "POPSpringAnimation.h"
#import "POPBasicAnimation.h"
#import "MMNTPhoto.h"
#import "NSDateFormatter+RelativeDateFormat.h"

@implementation MMNT_SharedVars

+ (MMNT_SharedVars *)sharedVars
{
    static MMNT_SharedVars *sharedVars;
    
    @synchronized(self)
    {
        if (!sharedVars)
            sharedVars = [[MMNT_SharedVars alloc] init];
        return sharedVars;
    }
}


- (void)setProfileUrl:(NSString *)url{
    profileUrl = url;
}
- (NSString *)profileUrl{
    return profileUrl;
}

- (void)setCurrentLocation:(CLLocation *)location{
    currentLocation = location;
}
- (CLLocation *)currentLocation{
    return currentLocation;
}

-(void)setMomuntState:(NSString *)state{
    momuntState = state;
}
-(NSString *)momuntState{
    return momuntState;
}

- (void)setMomuntName:(NSString *)name{
    momuntName = name;
}
- (NSString *)momuntName{
    return momuntName;
}

-(void)setMomuntTimestamp:(NSDate *)timestamp{
    momuntTimestamp = timestamp;
}
- (NSDate *)momuntTimestamp{
    return momuntTimestamp;
}

- (void)setCurrentCity:(NSString *)city{
    currentCity = city;
}
- (NSString *)currentCity{
    return currentCity;
}

- (void)setCurrentCountry:(NSString *)country{
    currentCountry = country;
}
- (NSString *)currentCountry{
    return currentCountry;
}
/*
    Store and retrieve photos comprising the current Momunt
 */
-(void)setPhotosToShare:(NSMutableArray *)array{
    if(!photosToShare){
        photosToShare = [[NSMutableArray alloc] init];
    }
    [photosToShare removeAllObjects];
    for(int i = 0; i < array.count; i++) {
        MMNTPhoto *photo = array[i];
        [photosToShare addObject:[photo toNSDictionary]];
    }
}
-(NSMutableArray *)photosToShare{
    return photosToShare;
}

/*
    Jeep track of Momunt ID in the pile. Should change every time a photo is added to the pile
 */
- (void)setPileMomuntId:(NSString *)uid{
    pileMomuntId = uid;
}
- (NSString *)pileMomuntId{
    return pileMomuntId;
}

- (void)setUrlQuery:(NSString *)query{
    if(!urlQuery){
        urlQuery = [[NSMutableDictionary alloc] init];
    }
    
    NSArray *urlComponents = [query componentsSeparatedByString:@"&"];
    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [pairComponents objectAtIndex:0];
        NSString *value = [pairComponents objectAtIndex:1];
        
        [urlQuery setObject:value forKey:key];
    }

}
- (NSMutableDictionary *)urlQuery{
    return urlQuery;
}


/*
 uniqueId
 return a unique ID for momunt sharing
 */
 
+(NSString *)uniqueId{
    NSInteger len = 7;
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
        
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
        
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length]) % [letters length]]];
    }
    // this also adds a timestamp-based substring to make it more unique
    NSString *timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    NSString *sub = [timestamp substringWithRange:NSMakeRange(7,3)];
    [randomString appendString:sub];
//    momuntId = randomString;
    return randomString;
}
+(NSString *)uniqueIdWithLength:(NSInteger)len{
//    NSInteger len = 7;
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length]) % [letters length]]];
    }
    return randomString;
}
- (void)setMomuntId:(NSString *)str{
    momuntId = str;
}
-(NSString *)momuntId{
    return momuntId;
}

/*
 Common Scale up/down functions
 */
-(void)scaleUp:(UIView *)view{
    [view pop_removeAllAnimations];
//    view.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
    POPSpringAnimation *scaleUp = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleUp.toValue = [NSValue valueWithCGPoint: CGPointMake(1, 1)] ;
    scaleUp.springBounciness = 15;
    scaleUp.springSpeed = 15;
    [view pop_addAnimation:scaleUp forKey:@"scale"];
}
-(void)scaleUp:(UIView *)view completion:(void (^)(BOOL))completion{
    [view pop_removeAllAnimations];
    POPSpringAnimation *scaleUp = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleUp.toValue = [NSValue valueWithCGPoint: CGPointMake(1, 1)] ;
    scaleUp.springBounciness = 15;
    scaleUp.springSpeed = 15;
    scaleUp.completionBlock = ^(POPAnimation *animation, BOOL finished){
        if(completion)
            completion(finished);
    };
    [view pop_addAnimation:scaleUp forKey:@"scale"];
}
-(void)scaleDown:(UIView *)view{
//    [view pop_removeAllAnimations];
//    POPBasicAnimation *scaleDown = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
//    scaleDown.toValue = [NSValue valueWithCGPoint: CGPointMake(0,0)] ;
//    scaleDown.duration = 0.3;
//    [view pop_addAnimation:scaleDown forKey:@"scale"];
    [self scaleDown:view withDuration:0.3];
}
-(void)scaleDown:(UIView *)view withDuration:(CFTimeInterval)duration{
    [view pop_removeAllAnimations];
    POPBasicAnimation *scaleDown = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleDown.toValue = [NSValue valueWithCGPoint: CGPointMake(0,0)] ;
    scaleDown.duration = duration;
    [view pop_addAnimation:scaleDown forKey:@"scale"];
}
-(void)scaleView:(UIView *)view toVal:(CGPoint)point withDuration:(CFTimeInterval)duration{
    [view pop_removeAllAnimations];
    POPBasicAnimation *scaleDown = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleDown.toValue = [NSValue valueWithCGPoint:point] ;
    scaleDown.duration = duration;
    [view pop_addAnimation:scaleDown forKey:@"scale"];
}
-(void)scaleView:(UIView *)view toVal:(CGPoint)point withDuration:(CFTimeInterval)duration completion:(void (^)(BOOL))completion{
    [view pop_removeAllAnimations];
    POPBasicAnimation *scaleDown = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleDown.toValue = [NSValue valueWithCGPoint:point] ;
    scaleDown.duration = duration;
    scaleDown.completionBlock = ^(POPAnimation *animation, BOOL finished){
        if(completion)
            completion(finished);
    };

    [view pop_addAnimation:scaleDown forKey:@"scale"];
}


-(void)scaleDown:(UIView *)view completion:(void (^)(BOOL))completion{
    [view pop_removeAllAnimations];
    POPBasicAnimation *scaleDown = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleDown.toValue = [NSValue valueWithCGPoint: CGPointMake(0,0)] ;
    scaleDown.duration = 0.3;
    scaleDown.completionBlock = ^(POPAnimation *animation, BOOL finished){
        if(completion)
            completion(finished);
    };
    [view pop_addAnimation:scaleDown forKey:@"scale"];
}
-(NSString *)urlEncode:(NSString *)str{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)str,
                                                                                 NULL,
//                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 (CFStringRef)@"&",
                                                                                 kCFStringEncodingUTF8));
}

/*
 Common POP animation functions
 */
+(void)runPOPSpringAnimation:(NSString *)animationType onView:(UIView *)view toValue:(NSValue *)toValue springBounciness:(CGFloat)bounciness springSpeed:(CGFloat)speed delay:
(NSTimeInterval)delay forKey:(NSString *)key completion:(void (^)(BOOL))completion{
    
    [view pop_removeAllAnimations];
    
    POPSpringAnimation *a = [POPSpringAnimation animationWithPropertyNamed:animationType];
    a.toValue = toValue;
    a.springBounciness = bounciness;
    a.springSpeed = speed;
    a.beginTime = CACurrentMediaTime() + delay;
    a.completionBlock = ^(POPAnimation *animation, BOOL finished){
        if(completion)
            completion(finished);
    };

    [view pop_addAnimation:a forKey:key];
    
}

+(void)runPOPSpringAnimation:(NSString *)animationType onLayer:(CALayer *)layer toValue:(NSValue *)toValue springBounciness:(CGFloat)bounciness springSpeed:(CGFloat)speed delay:(NSTimeInterval)delay forKey:(NSString *)key completion:(void (^)(BOOL))completion{
    
    [layer pop_removeAllAnimations];
    
    POPSpringAnimation *a = [POPSpringAnimation animationWithPropertyNamed:animationType];
    a.toValue = toValue;
    a.springBounciness = bounciness;
    a.springSpeed = speed;
    a.beginTime = CACurrentMediaTime() + delay;
    a.completionBlock = ^(POPAnimation *animation, BOOL finished){
        if(completion)
            completion(finished);
    };

    [layer pop_addAnimation:a forKey:key];
    
}

+(UIImage *)tintImage:(UIImage *)image WithColor:(UIColor *)tintColor
{
    // It's important to pass in 0.0f to this function to draw the image to the scale of the screen
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    UIRectFill(bounds);
    [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

+(NSString *)getTimeString:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
//    [dateFormatter setDateFormat:@"MMM d"];
//    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
//    [dateFormatter setDateFormat:@"MMM d hh:mm a"];
    dateFormatter.doesRelativeDateFormatting = YES;
    [dateFormatter relativeStringFromDateIfPossible:date];
    return [dateFormatter stringFromDate:date];
    
    
//    NSDate *now      = [NSDate new];
//    
//    
//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit;
//    NSDateComponents *components = [gregorian components:unitFlags
//                                                fromDate:date
//                                                  toDate:now options:0];
//        NSInteger months = [components month];
//    NSInteger days = [components day];
//    //    NSInteger hours = [components hour];
//    
//    if(months==0 && days < 1){
//        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//        [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
//        [dateFormat setDateFormat:@"hh:mm a"];
//        NSString *dateString = [NSString stringWithFormat:@"Today %@", [dateFormat stringFromDate:date] ];
//        
//        //        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:dateString];
//        //        [attrString beginEditing];
//        //        [attrString addAttribute:kCTFontAttributeName
//        //                           value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]
//        //                           range:NSMakeRange(0,5)];
//        //
//        //        [attrString endEditing];
//        return dateString;
//    }
//    if(months==0 && days == 1){
//        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//        [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
//        [dateFormat setDateFormat:@"hh:mm a"];
//        NSString *dateString = [NSString stringWithFormat:@"Yesterday %@", [dateFormat stringFromDate:date] ];
//        
//        //        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:dateString];
//        //        [attrString beginEditing];
//        //        [attrString addAttribute:kCTFontAttributeName
//        //                           value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]
//        //                           range:NSMakeRange(0,9)];
//        //
//        //        [attrString endEditing];
//        return dateString;
//        
//    }else{
//        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//        [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
//        [dateFormat setDateFormat:@"MMM d hh:mm a"];
//        NSString *dateString = [dateFormat stringFromDate:date];
//        
//        return dateString;
//    }
//    
}



@end
