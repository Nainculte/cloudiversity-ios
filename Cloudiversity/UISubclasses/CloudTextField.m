//
//  CloudTextField.m
//  Cloudiversity
//
//  Created by Nainculte on 4/9/14.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "CloudTextField.h"

@implementation CloudTextField

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.font = [UIFont fontWithName:@"FiraSansOT" size:self.font.pointSize];
    }
    return self;
}
@end
