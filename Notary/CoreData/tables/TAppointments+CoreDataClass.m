//
//  TAppointments+CoreDataClass.m
//  Notary
//
//  Created by MKD on 26/2/17.
//  Copyright © 2017 newline. All rights reserved.
//

#import "TAppointments+CoreDataClass.h"

@implementation TAppointments

- (NSDate *)dt_datetime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Riyadh"];
    
    formatter.dateFormat = @"yyyyMMddHHmmss";
    if (self.s_datetime.length == 10) formatter.dateFormat = @"yyMMddHHmm";
    else if (self.s_datetime.length == 12) formatter.dateFormat = @"yyyyMMddHHmm";
    else if (self.s_datetime.length == 8) formatter.dateFormat = @"yyyyMMdd";
    
    NSDate *date = [formatter dateFromString:self.s_datetime];
    return date;
}

@end
