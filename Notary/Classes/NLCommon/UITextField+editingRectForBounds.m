//
//  UITextField+editingRectForBounds.m
//  Notary
//
//  Created by Raja on 2/6/17.
//  Copyright © 2017 newline. All rights reserved.
//

#import "UITextField+editingRectForBounds.h"

@implementation UITextField (editingRectForBounds)


// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 10);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 10);
}

@end
