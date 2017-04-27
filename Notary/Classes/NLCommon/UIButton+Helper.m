//
//  UIButton+Helper.m
//  Notary
//
//  Created by Raja on 3/7/17.
//  Copyright © 2017 newline. All rights reserved.
//

#import "UIButton+Helper.h"

@implementation UIButton (Helper)

- (void)setSubstituteFontName:(NSString *)name UI_APPEARANCE_SELECTOR
{
    self.titleLabel.font = [UIFont fontWithName:name size:self.titleLabel.font.pointSize];
}

@end
