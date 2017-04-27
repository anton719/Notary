//
//  TServices+CoreDataClass.m
//  Notary
//
//  Created by MKD on 26/2/17.
//  Copyright © 2017 newline. All rights reserved.
//

#import "TServices+CoreDataClass.h"
#import "NLCommon.h"

@implementation TServices

- (NSString *)s_name {
    return NLCommon.shared.isAR ? self.s_name_ar : self.s_name_en;
}

@end
