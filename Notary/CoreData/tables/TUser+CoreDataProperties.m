//
//  TUser+CoreDataProperties.m
//  Notary
//
//  Created by MKD on 26/2/17.
//  Copyright © 2017 newline. All rights reserved.
//

#import "TUser+CoreDataProperties.h"

@implementation TUser (CoreDataProperties)

+ (NSFetchRequest<TUser *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"TUser"];
}

@dynamic pk_i_id;
@dynamic s_access_token;
@dynamic s_national_id;
@dynamic s_mobile;

@end
