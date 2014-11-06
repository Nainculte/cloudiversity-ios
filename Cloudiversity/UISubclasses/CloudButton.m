//
//  CloudButton.m
//  Cloudiversity
//
//  Created by Nainculte on 4/9/14.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "CloudButton.h"

@implementation CloudButton

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.titleLabel.font = [UIFont fontWithName:@"FiraSansOT" size:self.titleLabel.font.pointSize];
    }
    return self;
}
@end
