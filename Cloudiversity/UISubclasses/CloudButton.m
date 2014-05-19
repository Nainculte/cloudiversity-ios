//
//  CloudButton.m
//  Cloudiversity
//
//  Created by Nainculte on 4/9/14.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "CloudButton.h"

@implementation CloudButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.titleLabel.font = [UIFont fontWithName:@"FiraSansOT" size:self.titleLabel.font.pointSize];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
