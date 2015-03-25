//
//  MMNT_AsyncImage.h
//  Momunt
//
//  Created by Masha Belyi on 11/23/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMNT_AsyncImage : UIImageView

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, assign) BOOL shouldCenter;

@end
