//
//  MMNT_Contact.m
//  Momunt
//
//  Created by Masha Belyi on 8/28/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNT_Contact.h"
#import "MMNTDataController.h"
#import "AsyncImageView.h"

@implementation MMNT_Contact


-(MMNT_Contact *)initWithDict:(NSDictionary *)data{
    self = [super init];
    if(self){
        for (NSString *key in data) {
            if ([self respondsToSelector:NSSelectorFromString(key)]) {
                [self setValue:[data valueForKey:key] forKey:key];
            }
        }
        
    }
    return self;
}

-(void)setNumbers:(NSMutableArray *)numbers{
    if(!_numbers){
        _numbers  = [[NSMutableArray alloc] init];
    }
//    _numbers = numbers;
    // check if this is a momunt user
    for(int i=0; i<[numbers count]; i++){
        NSString *number = numbers[i];
        NSString *cleanNumber = [[number componentsSeparatedByCharactersInSet: [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
        [_numbers addObject:cleanNumber];
        NSDictionary *user = [[MMNTDataController sharedInstance] getPublicProfile:cleanNumber];
        if([[user objectForKey:@"error"]boolValue] == NO){
            // if user not found - add to array
            _momuntUser = YES;
            _username = [user objectForKey:@"username"];
            _profileUrl = [user objectForKey:@"profileUrl"];
            
            // load image into cache
            [[[AsyncImageLoader alloc] init] loadImageWithURL:[NSURL URLWithString:_profileUrl]];
            
        }
        
    }
}

-(UILabel *)avatar{
    NSArray * words = [_name componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableString * initials = [NSMutableString string];
    for (NSString * word in words) {
        if ([word length] > 0) {
            NSString * firstLetter = [word substringToIndex:1];
            [initials appendString:[firstLetter uppercaseString]];
        }
    }
    
    UILabel *profilePic = [[UILabel alloc] initWithFrame:CGRectMake(0,0,50,50) ];
    profilePic.text = [initials uppercaseString];
    profilePic.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    profilePic.textAlignment = NSTextAlignmentCenter;
    profilePic.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0];
    
    profilePic.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
    profilePic.layer.borderWidth = 2.0;
    profilePic.layer.cornerRadius = 25;
    profilePic.layer.masksToBounds = YES;
    
    return profilePic;

}

@end
