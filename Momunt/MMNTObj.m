//
//  MMNTObj.m
//  Momunt
//
//  Created by Masha Belyi on 9/28/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//
#import <objc/runtime.h>
#import "MMNTObj.h"
#import "MMNTPhoto.h"
#import "MMNTAccountManager.h"
#import "MMNTDataController.h"

@implementation MMNTObj

-(MMNTObj *)initWithData:(NSData *)data{
    NSError *e;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    return [self initWithDict:dict];
}

-(MMNTObj *)initWithDict:(NSDictionary *)data{
    self = [super init];
    if(self){
        
        NSString *timestamp = [data valueForKey:@"time_saved"];
        _timestamp = [NSDate dateWithTimeIntervalSince1970: (NSTimeInterval)[timestamp doubleValue] ];  // :O TIME ZONES?????
        _timestampStr = timestamp;
        _momuntId = [data valueForKey:@"id"] ? [data valueForKey:@"id"] : [[MMNTDataController sharedInstance] uniqueId]; // make new ID if not specified
        _name = [data valueForKey:@"name"];
        _poster = [data valueForKey:@"poster"];
        _lat = [[data valueForKey:@"lat"] doubleValue];
        _lng = [[data valueForKey:@"lng"] doubleValue];
//        _ownerId = [data valueForKey:@"ownerId"] ? [[data valueForKey:@"lng"] integerValue] : [MMNTAccountManager sharedInstance].userId; // if no previous owner - you become the owner
        _live = [[data valueForKey:@"live"] boolValue]==YES;
        _type = [data valueForKey:@"type"];
        
        if([data valueForKey:@"body"]){
            NSString *bodyStr = [data valueForKey:@"body"];
            NSMutableArray *myPhotos = [[NSMutableArray alloc] init];
            NSError *e;
            NSDictionary *bodyDict = [NSJSONSerialization JSONObjectWithData: [bodyStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &e];
        
            for (NSDictionary *imageDic in bodyDict) {
                MMNTPhoto *photo = [[MMNTPhoto alloc] initWithDict:imageDic];
                                            
                [myPhotos addObject:photo];
            }
            _body = myPhotos;
        }
        
        if(![_name length]){
            
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:_lat longitude:_lng]
                           completionHandler:^(NSArray *placemarks, NSError *error) {
                               if (error) {
                                   NSLog(@"Error %@", error.description);
                               } else {
                                   CLPlacemark *placemark = [placemarks lastObject];
                                   _city = [placemark locality];
                                   _country = [placemark country];
                                   _state = [placemark administrativeArea];
                                   
                                   if(!_city){
                                       _name = _country;
                                   }else{
                                       _name = [_country isEqualToString:@"United States"] ?
                                                [NSString stringWithFormat:@"%@, %@", _city, _state] :
                                                [NSString stringWithFormat:@"%@, %@", _city, _country];
                                   }
                               }
                           }];
        }
    }
    return self;
}

-(void)nameFromLocationWithCompletion:(void (^)(BOOL finished, NSString *name))completion{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:_lat longitude:_lng]
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if (error) {
                           NSLog(@"Error %@", error.description);
                           completion(NO, nil);
                       } else {
                           CLPlacemark *placemark = [placemarks lastObject];
                           _city = [placemark locality];
                           _country = [placemark country];
                           _state = [placemark administrativeArea];
                           
                           _name = [_country isEqualToString:@"United States"] ?
                                                [NSString stringWithFormat:@"%@, %@", _city, _state] :
                                                [NSString stringWithFormat:@"%@, %@", _city, _country];
                           completion(YES, _name);
                           
                       }
                   }];

}

-(NSMutableArray *)bodyToNSDictionary{
//    NSArray *array = [NSArray arrayWithArray:_body];
//    [_body removeAllObjects];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(int i = 0; i < _body.count; i++) {
        MMNTPhoto *photo = _body[i];
        [array addObject:[photo toNSDictionary]];
    }
    return array;
}
+(NSString *)photoArrayToString:(NSArray *)photos{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(int i = 0; i < photos.count; i++) {
        MMNTPhoto *photo = photos[i];
        [array addObject:[photo toNSDictionary]];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:nil];
    NSString *bodyStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return bodyStr;

}

-(NSDictionary *)toDictinatry{
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self bodyToNSDictionary] options:0 error:nil];
    NSString *bodyStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          _momuntId, @"id",
                          [NSNumber numberWithDouble:_lat ], @"lat",
                          [NSNumber numberWithDouble:_lng ],@"lng",
                          _timestampStr, @"time_saved",
                          bodyStr , @"body",
                          _type, @"type",
                          nil];
    
    return dict;

}


+(NSArray *)parseMomuntBody:(NSString *)bodyStr{
    
    NSMutableArray *myPhotos = [[NSMutableArray alloc] init];
    NSError *e;
    NSDictionary *bodyDict = [NSJSONSerialization JSONObjectWithData: [bodyStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &e];
    
    for (NSDictionary *imageDic in bodyDict) {
        MMNTPhoto *photo = [[MMNTPhoto alloc] initWithDict:imageDic];
        
        [myPhotos addObject:photo];
    }
    
    return myPhotos;
    
}


-(void)setEqualTo:(MMNTObj*)mmnt{
    self.lat = mmnt.lat;
    self.lng = mmnt.lng;
    self.body = mmnt.body;
    self.timestamp = mmnt.timestamp;
    _timestampStr = mmnt.timestampStr;
    _name = mmnt.name;
    _momuntId = mmnt.momuntId;
    _type = mmnt.type;
    _ownerId = mmnt.ownerId;
    _poster = mmnt.poster;
    _live = mmnt.live;

}

@end
