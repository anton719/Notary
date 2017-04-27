//
//  TAppointments+CoreDataProperties.h
//  Notary
//
//  Created by MKD on 26/2/17.
//  Copyright © 2017 newline. All rights reserved.
//

#import "TAppointments+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TAppointments (CoreDataProperties)

+ (NSFetchRequest<TAppointments *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *pk_i_id;
@property (nullable, nonatomic, copy) NSString *s_datetime;
@property (nonatomic) BOOL b_cancelled;
@property (nonatomic) BOOL b_upcoming;
@property (nullable, nonatomic, copy) NSString *d_lat;
@property (nullable, nonatomic, copy) NSString *d_lng;
@property (nullable, nonatomic, copy) NSString *i_beneficiaries_count;
@property (nullable, nonatomic, copy) NSString *fk_i_service_id;

@end

NS_ASSUME_NONNULL_END
