//
//  NLCommon.h
//  Notary
//
//  Created by Raja on 2/5/17.
//  Copyright © 2017 newline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class RKObjectRequestOperation;
@class RKMappingResult;
@class TUser;

typedef enum : NSUInteger {
    UserMainOperationEnum_Booking,
    UserMainOperationEnum_List
} UserMainOperationEnum;

@interface NLCommon : NSObject

@property (nonatomic, retain) NSString *currentUserNationalID;
@property (nonatomic, readonly) TUser *user;
@property (nonatomic, readonly) NSMutableDictionary *defaultParameters;
@property (nonatomic, readonly) NSMutableDictionary *defaultClientParameters;

@property (nonatomic, readonly) BOOL isRTL;
@property (nonatomic, readonly) BOOL isAR;
@property (nonatomic, readonly) BOOL isEN;

@property (nonatomic, assign) UserMainOperationEnum userMainOperationEnum;


@property (nonatomic, assign) NSArray *appLanguage;

+ (NLCommon*)shared;

+(void) viewToastMsg :(NSString*) msg view:(UIView*)view;

+(NSString*) getDeviceLanguage;

+(BOOL) isIDNumberValid : (NSString*) text;

+(BOOL) isMobileNumberValid : (NSString*) text;

+(NSString *) randomStringWithLength:(int)len;

+ (BOOL)webServiceDefaultHandlerFailedWithOperation:(RKObjectRequestOperation *)operation mappingResult:(RKMappingResult *)mappingResult error:(NSError *)error view:(UIView*)view;

+(NSDate*)returnFormatedDt : (NSDate*) dt dtFormat:(NSString*) dtFormat;
@end


@interface NSDate (Extra)

+ (instancetype)dateFromAvailableTimeString:(NSString*)string;

@property (nonatomic, readonly) NSString *hijriDateString;
@property (nonatomic, readonly) NSString *gregorianDateString;
@property (nonatomic, readonly) NSString *availableTimeString;
@property (nonatomic, readonly) NSString *gregorianDateStringServerFormat;

- (NSString*)hijriDateStringWithFormat:(NSString*)format;
- (NSString*)gregorianDateStringWithFormat:(NSString*)format;

@end



@interface UIButton (Titles)

@property (nonatomic, retain) NSString *titles;

@end



@interface NSString (Filter)

@property (nonatomic, readonly) NSString *filteredText;

@end


