//
//  MMNT_SharedVars.h
//  Momunt
//
//  Created by Masha Belyi on 8/25/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MMNT_SharedVars : NSObject{
    CLLocation *currentLocation;
    NSString *currentCity;
    NSString *momuntState;
    NSString *currentCountry;
    NSString *momuntId;
    NSString *momuntTimestamp;
    NSString *momuntName;
    NSMutableArray *photosToShare;
    NSString *pileMomuntId;
    NSMutableDictionary *urlQuery;
    
    NSString *profileUrl;
}
+(MMNT_SharedVars *) sharedVars;
//@property (nonatomic, retain) NSString* momuntId;

- (void)setCurrentLocation:(CLLocation *)location;
- (CLLocation *)currentLocation;

- (void)setMomuntState:(NSString *)state;
- (NSString *)momuntState;

- (void)setMomuntName:(NSString *)name;
- (NSString *)momuntName;

- (void)setMomuntTimestamp:(NSDate *)timestamp;
- (NSDate *)momuntTimestamp;

- (void)setCurrentCountry:(NSString *)country;
- (NSString *)currentCountry;

- (void)setCurrentCity:(NSString *)city;
- (NSString *)currentCity;

- (void)setPileMomuntId:(NSString *)city;
- (NSString *)pileMomuntId;

- (void)setProfileUrl:(NSString *)url;
- (NSString *)profileUrl;

- (void)setUrlQuery:(NSString *)query;
- (NSDictionary *)urlQuery;

-(void)setPhotosToShare:(NSMutableArray *)array;
-(NSMutableArray *)photosToShare;

+(NSString *)uniqueId;
+(NSString *)uniqueIdWithLength:(NSInteger)len;
- (void)setMomuntId:(NSString *)momuntId;
- (NSString *)momuntId;

-(void)scaleDown:(UIView *)view;
-(void)scaleDown:(UIView *)view withDuration:(CFTimeInterval)duration;
-(void)scaleDown:(UIView *)view completion:(void(^)(BOOL finished))completion;
-(void)scaleUp:(UIView *)view;
-(void)scaleUp:(UIView *)view completion:(void(^)(BOOL finished))completion;
-(void)scaleView:(UIView *)view toVal:(CGPoint)point withDuration:(CFTimeInterval)duration;
-(void)scaleView:(UIView *)view toVal:(CGPoint)point withDuration:(CFTimeInterval)duration completion:(void (^)(BOOL))completion;
-(NSString *)urlEncode:(NSString *)str;

+(void)runPOPSpringAnimation:(NSString *)animationType onView:(UIView *)view toValue:(NSValue *)toValue springBounciness:(CGFloat)bounciness springSpeed:(CGFloat)speed delay:(NSTimeInterval)delay forKey:(NSString *)key completion:(void(^)(BOOL finished))completion;
+(void)runPOPSpringAnimation:(NSString *)animationType onLayer:(CALayer *)layer toValue:(NSValue *)toValue springBounciness:(CGFloat)bounciness springSpeed:(CGFloat)speed delay:(NSTimeInterval)delay forKey:(NSString *)key completion:(void(^)(BOOL finished))completion;

/*
 Tint Image
 */
+(UIImage *)tintImage:(UIImage *)image WithColor:(UIColor *)tintColor;

/*
    Convert timestamp to dat/time string
 */
+(NSString *)getTimeString:(NSDate*)date;
@end