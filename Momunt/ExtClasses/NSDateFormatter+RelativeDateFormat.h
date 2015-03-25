//
//  NSDateFormatter (RelativeDateFormat).h
//  Momunt
//
//  Created by Masha Belyi on 2/14/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (RelativeDateFormat)
-(NSString*) relativeStringFromDateIfPossible:(NSDate *)date;
@end