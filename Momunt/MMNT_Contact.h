//
//  MMNT_Contact.h
//  Momunt
//
//  Created by Masha Belyi on 8/28/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMNT_Contact : NSObject

@property (nonatomic, strong) NSString  *name;
@property (nonatomic, strong) NSString  *phone;
@property (nonatomic)         NSInteger  userId;
@property (nonatomic, strong) NSString  *username;
@property (nonatomic, strong) NSString  *profileUrl;

@property (nonatomic, strong) NSMutableArray *numbers;
@property (nonatomic)         BOOL            momuntUser;



-(MMNT_Contact *)initWithDict:(NSDictionary *)data;
-(UILabel *)avatar;
@end
