//
//  NSDateFormatter (RelativeDateFormat).m
//  Momunt
//
//  Created by Masha Belyi on 2/14/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import "NSDateFormatter+RelativeDateFormat.h"

@implementation NSDateFormatter (RelativeDateFormat)
-(NSString*) relativeStringFromDateIfPossible:(NSDate *)date
{
    static NSDateFormatter *relativeFormatter;
    static NSDateFormatter *absoluteFormatter;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        const NSDateFormatterStyle arbitraryStyle = NSDateFormatterShortStyle;
        
        relativeFormatter = [[NSDateFormatter alloc] init];
        [relativeFormatter setDateStyle: arbitraryStyle];
        [relativeFormatter setTimeStyle: NSDateFormatterNoStyle];
        [relativeFormatter setDoesRelativeDateFormatting: YES];
        
        absoluteFormatter = [[NSDateFormatter alloc] init];
        [absoluteFormatter setDateStyle: arbitraryStyle];
        [absoluteFormatter setTimeStyle: NSDateFormatterNoStyle];
        [absoluteFormatter setDoesRelativeDateFormatting: NO];
    });
    
    NSLocale *const locale = [self locale];
    if([relativeFormatter locale] != locale)
    {
        [relativeFormatter setLocale: locale];
        [absoluteFormatter setLocale: locale];
    }
    
    NSCalendar *const calendar = [self calendar];
    if([relativeFormatter calendar] != calendar)
    {
        [relativeFormatter setCalendar: calendar];
        [absoluteFormatter setCalendar: calendar];
    }
    
    NSString *const maybeRelativeDateString = [relativeFormatter stringFromDate: date];
    const BOOL isRelativeDateString = ![maybeRelativeDateString isEqualToString: [absoluteFormatter stringFromDate: date]];
    
    if(isRelativeDateString)
    {
        return maybeRelativeDateString;
    }
    else
    {
        return [self stringFromDate: date];
    }
}
@end

