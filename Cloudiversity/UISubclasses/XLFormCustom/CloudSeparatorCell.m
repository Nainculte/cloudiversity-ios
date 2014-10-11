//
//  CloudSeparatorCell.m
//  Cloudiversity
//
//  Created by Nainculte on 10/10/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "CloudSeparatorCell.h"
#import "UIColor+Cloud.h"

@implementation CloudSeparatorCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor cloudBorderGrey];
    }
    return self;
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 0.5f;
}

- (BOOL)formDescriptorCellBecomeFirstResponder
{
    [self resignFirstResponder];
    return NO;
}

@end
