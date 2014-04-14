//
//  CloudTextField.m
//  Cloudiversity
//
//  Created by Nainculte on 4/9/14.
//  Copyright (c) 2014 Rémy Marty. All rights reserved.
//

#import "CloudTextField.h"

@implementation CloudTextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.font = [UIFont fontWithName:@"FiraSansOT" size:self.font.pointSize];
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
