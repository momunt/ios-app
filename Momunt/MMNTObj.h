//
//  MMNTObj.h
//  Momunt
//
//  Created by Masha Belyi on 9/28/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MMNTObj : NSObject

@property (nonatomic) double lat;
@property (nonatomic) double lng;
@property (strong, nonatomic) NSArray *body;
@property (strong, nonatomic) NSDate *timestamp;
@property (strong, nonatomic) NSString *timestampStr;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *momuntId;
@property (strong, nonatomic) NSString *uploadId; // used when sharing momunts
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *type; //gallery/pile?
@property (nonatomic) NSInteger ownerId; // initial owner of the momunt
@property (strong, nonatomic) NSString *poster;
@property (nonatomic) BOOL live;

-(MMNTObj *)initWithData:(NSData *)data;
-(MMNTObj *) initWithDict:(NSDictionary *)data;

-(NSMutableArray *)bodyToNSDictionary;
+(NSString *)photoArrayToString:(NSArray *)photos;
-(NSDictionary *)toDictinatry; // convert momunt data to dictionary
-(void)nameFromLocationWithCompletion:(void (^)(BOOL finished, NSString *name))completion;

+(NSArray *)parseMomuntBody:(NSString *)bodyStr;
-(void)setEqualTo:(MMNTObj*)mmnt;
@end
