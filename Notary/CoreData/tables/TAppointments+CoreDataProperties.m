//
//  TAppointments+CoreDataProperties.m
//  Notary
//
//  Created by MKD on 26/2/17.
//  Copyright © 2017 newline. All rights reserved.
//

#import "TAppointments+CoreDataProperties.h"

@implementation TAppointments (CoreDataProperties)

+ (NSFetchRequest<TAppointments *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"TAppointments"];
}

@dynamic pk_i_id;
@dynamic s_datetime;
@dynamic b_cancelled;
@dynamic b_upcoming;
@dynamic d_lat;
@dynamic d_lng;
@dynamic i_beneficiaries_count;
@dynamic fk_i_service_id;

@end
