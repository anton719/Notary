//
//  TServices+CoreDataProperties.h
//  Notary
//
//  Created by MKD on 26/2/17.
//  Copyright © 2017 newline. All rights reserved.
//

#import "TServices+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TServices (CoreDataProperties)

+ (NSFetchRequest<TServices *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *s_name_ar;
@property (nullable, nonatomic, copy) NSString *s_name_en;
@property (nullable, nonatomic, copy) NSString *pk_i_id;

@end

NS_ASSUME_NONNULL_END
