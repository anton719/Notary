//
//  TUser+CoreDataProperties.h
//  Notary
//
//  Created by MKD on 26/2/17.
//  Copyright © 2017 newline. All rights reserved.
//

#import "TUser+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TUser (CoreDataProperties)

+ (NSFetchRequest<TUser *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *pk_i_id;
@property (nullable, nonatomic, copy) NSString *s_access_token;
@property (nullable, nonatomic, copy) NSString *s_national_id;
@property (nullable, nonatomic, copy) NSString *s_mobile;

@end

NS_ASSUME_NONNULL_END
