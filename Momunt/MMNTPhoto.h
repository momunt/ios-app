//
//  MMNTPhoto.h
//  Momunt
//
//  Created by Masha Belyi on 6/30/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMNTPhoto : NSObject

@property (strong, nonatomic) NSString *created_time;
//@property (strong, nonatomic) NSString *link;
//@property (strong, nonatomic) NSString *num_comments;
//@property (strong, nonatomic) NSString *num_likes;
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *source;
@property (strong, nonatomic) NSString *link; // link to photo in instagra/twitter/

@property (strong, nonatomic) NSDictionary *images;
@property (strong, nonatomic) NSDictionary *location;
@property (strong, nonatomic) NSString *user;

@property (nonatomic, assign) BOOL uploading; // YES when recently added image is still uploading to the server
@property (nonatomic) UIImage *tempImage; // temporary UIImage used while recently added image is uploading to the server

-(MMNTPhoto *)initWithDict:(NSDictionary *)data;
-(NSDictionary *)toNSDictionary;

@end
