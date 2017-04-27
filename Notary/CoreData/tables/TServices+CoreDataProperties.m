//
//  TServices+CoreDataProperties.m
//  Notary
//
//  Created by MKD on 26/2/17.
//  Copyright © 2017 newline. All rights reserved.
//

#import "TServices+CoreDataProperties.h"

@implementation TServices (CoreDataProperties)

+ (NSFetchRequest<TServices *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"TServices"];
}

@dynamic s_name_ar;
@dynamic s_name_en;
@dynamic pk_i_id;

@end
