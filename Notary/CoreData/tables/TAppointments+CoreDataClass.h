//
//  TAppointments+CoreDataClass.h
//  Notary
//
//  Created by MKD on 26/2/17.
//  Copyright © 2017 newline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAppointments : NSManagedObject

@property (nonatomic, readonly) NSDate *dt_datetime;

@end

NS_ASSUME_NONNULL_END

#import "TAppointments+CoreDataProperties.h"
