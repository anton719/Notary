//
//  UILabel+Helper.m
//  Notary
//
//  Created by Raja on 3/7/17.
//  Copyright © 2017 newline. All rights reserved.
//

#import "UILabel+Helper.h"

@implementation UILabel (Helper)

- (void)setSubstituteFontName:(NSString *)name UI_APPEARANCE_SELECTOR
{
    self.font = [UIFont fontWithName:name size:self.font.pointSize];
}
@end
