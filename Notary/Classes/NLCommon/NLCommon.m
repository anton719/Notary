//
//  NLCommon.m
//  Notary
//
//  Created by Raja on 2/5/17.
//  Copyright © 2017 newline. All rights reserved.
//

#import "NLCommon.h"
#import "UIView+Toast.h"
#import "TUser+CoreDataClass.h"
#import <MagicalRecord/MagicalRecord.h>
#import <RestKit/RestKit.h>

@implementation NLCommon

+ (NLCommon*)shared
{
    static NLCommon *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [NLCommon new];
    });
    return _shared;
}

- (NSString *)currentUserNationalID {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"currentUserNationalID"];
}

- (void)setCurrentUserNationalID:(NSString *)currentUserNationalID {
    if (currentUserNationalID) {
        [[NSUserDefaults standardUserDefaults] setValue:currentUserNationalID forKey:@"currentUserNationalID"];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"currentUserNationalID"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (TUser *)user {
    return [TUser MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"s_national_id = %@", self.currentUserNationalID]];
}

- (NSMutableDictionary *)defaultParameters {
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    if (NLCommon.shared.user.pk_i_id.length) params[@"repID"] = NLCommon.shared.user.pk_i_id;
    if (NLCommon.shared.user.s_national_id.length) params[@"nationalID"] = NLCommon.shared.user.s_national_id;
    if (NLCommon.shared.user.s_mobile.length) params[@"mobile"] = NLCommon.shared.user.s_mobile;
    if (NLCommon.shared.user.s_access_token.length) params[@"refGuid"] = NLCommon.shared.user.s_access_token;

    params[@"sp"] = @"F7E009C286C34A6EA300C419D64EBA44";
    return params;
}

- (NSMutableDictionary *)defaultClientParameters {
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    if (NLCommon.shared.user.s_national_id.length) params[@"nationalID"] = NLCommon.shared.user.s_national_id;
    if (NLCommon.shared.user.s_mobile.length) params[@"mobile"] = NLCommon.shared.user.s_mobile;

    return params;
}

+(void) viewToastMsg :(NSString*) msg view:(UIView*)view
{
    if (!msg.length) return;
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    UIFont *font = [UIFont fontWithName:@"GretaArabic-Regular" size:14];
    style.titleFont = font;
    style.messageFont = font;
    style.backgroundColor = [UIColor colorWithRed:0.710 green:0.435 blue:0.106 alpha:1.00];
    CGSize size;
    size.height = 35;
    size.width = 35;
    style.imageSize = size;
    style.titleAlignment = NSTextAlignmentCenter;
    style.messageAlignment = NSTextAlignmentCenter;
    [CSToastManager setSharedStyle:style];
    [CSToastManager setTapToDismissEnabled:YES];
    [CSToastManager setQueueEnabled:NO];
    
    [view makeToast:msg
           duration:3.0
           position:CSToastPositionCenter
              title:nil
              image:nil//[UIImage imageNamed:img]
              style:style
         completion:nil];
    
}

+(NSDate*)returnFormatedDt : (NSDate*) dt dtFormat:(NSString*) dtFormat
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:dtFormat];
    
    //    NSDate *now = [[NSDate alloc] init];
    
    NSString *dateString = [format stringFromDate:dt];
    
    NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
    [inFormat setDateFormat:dtFormat];
    NSDate *parsed = [inFormat dateFromString:dateString];
    
    return parsed;
}

+(NSString*) getDeviceLanguage
{
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if([language containsString:@"ar"])
    {
        return @"ar";
    }
    else
    {
        return @"en";
    }
}

-(void)setAppLanguage:(NSArray*)appLanguage
{
    [[NSUserDefaults standardUserDefaults] setObject:appLanguage forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSArray*)appLanguage
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
}

- (BOOL)isRTL {
    return [[NLCommon getDeviceLanguage] isEqualToString:@"ar"];
}

- (BOOL)isAR {
    return [[NLCommon getDeviceLanguage] isEqualToString:@"ar"];
}

- (BOOL)isEN {
    return [[NLCommon getDeviceLanguage] isEqualToString:@"en"];
}

+(BOOL) isMobileNumberValid : (NSString*) text
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(009665|9665|\\+9665|05|5)(5|0|3|6|4|9|1|8|7)([0-9]{7})$"
                                                                           options:0
                                                                             error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:text
                                                    options:0
                                                      range:NSMakeRange(0, [text length])];
    if (match)
        return YES;
    else
        return NO;
}

+(BOOL) isIDNumberValid : (NSString*) text
{
    NSString *firstLetter = [text substringToIndex:1];
    if(text.length != 10 || !([firstLetter isEqualToString:@"1"] || [firstLetter isEqualToString:@"2"]) )
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

+(NSString *) randomStringWithLength:(int)len
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

+ (BOOL)webServiceDefaultHandlerFailedWithOperation:(RKObjectRequestOperation *)operation mappingResult:(RKMappingResult *)mappingResult error:(NSError *)error view:(UIView*)view {
    if (error) {
        [NLCommon viewToastMsg:NSLocalizedString(@"Operation Has Faild", nil) view:view];
        return YES;
    }
    
    if (!operation.HTTPRequestOperation.responseData) {
        
        return YES;
    }
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
    if (!json) {
        
        return YES;
    }
    
    NSNumber *errorCode = [json valueForKeyPath:@"result"];
    if (!errorCode) {
    
        return YES;
    }
    
    if (![errorCode isKindOfClass:[NSNumber class]]) {
        
        return YES;
    }
    
    if (errorCode.intValue == 1) return NO;
    
    NSString *errorMessage;
    switch (errorCode.intValue)
    {
            case 0: errorMessage = NSLocalizedString(@"api_response_result_code_0", nil); break;
            case 1: errorMessage = NSLocalizedString(@"api_response_result_code_1", nil); break;
            case 2: errorMessage = NSLocalizedString(@"api_response_result_code_2", nil); break;
            case 3: errorMessage = NSLocalizedString(@"api_response_result_code_3", nil); break;
            case 4: errorMessage = NSLocalizedString(@"api_response_result_code_4", nil); break;
            case 5: errorMessage = NSLocalizedString(@"api_response_result_code_5", nil); break;
            case 6: errorMessage = NSLocalizedString(@"api_response_result_code_6", nil); break;
            case 7: errorMessage = NSLocalizedString(@"api_response_result_code_7", nil); break;
            case 8: errorMessage = NSLocalizedString(@"api_response_result_code_8", nil); break;
            case 9: errorMessage = NSLocalizedString(@"api_response_result_code_9", nil); break;
        default: errorMessage = @"Uknown error number returened from server."; break;
    }
    if (errorMessage && view) [NLCommon viewToastMsg:errorMessage view:view];
    return YES;
}

@end


@implementation NSDate (Extra)

- (NSString *)hijriDateString {
    return [self hijriDateStringWithFormat:@"yyyy-MM-dd"];;
}

- (NSString *)gregorianDateString {
    return [self gregorianDateStringWithFormat:@"yyyy-MM-dd"];
}

+ (instancetype)dateFromAvailableTimeString:(NSString*)string {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:NLCommon.shared.isAR ? @"ar_US" : @"en_US"];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Riyadh"];
    formatter.dateFormat = @"yyMMddHHmm";
    NSDate *date = [formatter dateFromString:string];
    return date;
}

- (NSString *)availableTimeString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:NLCommon.shared.isAR ? @"ar_US" : @"en_US"];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Riyadh"];
//    formatter.dateFormat = @"dd MMMM,hh:mm a";
    formatter.dateFormat = @"hh:mm a";
    NSString *str = [formatter stringFromDate:self];
    return str;
}

- (NSString *)gregorianDateStringServerFormat {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Riyadh"];
    formatter.dateFormat = @"yyMMddHHmm";
    NSString *str = [formatter stringFromDate:self];
    return str;
}

- (NSString*)hijriDateStringWithFormat:(NSString*)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierIslamicCivil];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Riyadh"];
    formatter.dateFormat = format;
    NSString *str = [formatter stringFromDate:self];
    return str;
}

- (NSString*)gregorianDateStringWithFormat:(NSString*)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Riyadh"];
    formatter.dateFormat = format;
    formatter.locale = [NLCommon shared].isEN ? [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] : [[NSLocale alloc] initWithLocaleIdentifier:@"ar_US"];
    NSString *str = [formatter stringFromDate:self];
    return str;
}

@end


@implementation UIButton (Titles)

- (void)setTitles:(NSString *)titles
{
    [self setTitle:titles forState:UIControlStateNormal];
    [self setTitle:titles forState:UIControlStateHighlighted];
    [self setTitle:titles forState:UIControlStateSelected];
}

@end



@implementation NSString (Filter)

- (NSString *)filteredText {
    NSString *string = self;
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"ar"];
    for (NSInteger i = 0; i < 10; i++) {
        NSNumber *num = @(i);
        string = [string stringByReplacingOccurrencesOfString:[formatter stringFromNumber:num] withString:num.stringValue];
    }
    return string;
}

@end



