//
//  TServices+CoreDataClass.h
//  Notary
//
//  Created by MKD on 26/2/17.
//  Copyright © 2017 newline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface TServices : NSManagedObject

@property (nonatomic, readonly) NSString *s_name;

@end

NS_ASSUME_NONNULL_END

#import "TServices+CoreDataProperties.h"
