//
//  CloudLogoCell.m
//  Cloudiversity
//
//  Created by Nainculte on 03/10/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "CloudLogoCell.h"
#import "UICloud.h"
#import "UIColor+Cloud.h"

@interface CloudLogoCell ()

@property (nonatomic, strong)UIImageView *logo;
@property (nonatomic, strong)CloudLabel *cloudiversity;

@end

@implementation CloudLogoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, self.bounds.size.width);

        self.logo = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, 150.0f)];
        self.logo.image = [UIImage imageNamed:@"Logo_500x500"];
        self.logo.contentMode = UIViewContentModeScaleAspectFill;

        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"Cloudiversity"];
        NSRange cloudRange = NSMakeRange(0, 5);
        NSRange iversityRange = NSMakeRange(5, 8);
        [text beginEditing];
        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"FiraSansOt-Bold" size:35.0f] range:cloudRange];
        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"FiraSansOt" size:35.0f] range:iversityRange];
        [text addAttribute:NSForegroundColorAttributeName value:[UIColor cloudDarkBlue] range:cloudRange];
        [text addAttribute:NSForegroundColorAttributeName value:[UIColor cloudLightBlue] range:iversityRange];
        [text endEditing];

        self.cloudiversity = [[CloudLabel alloc] initWithFrame:CGRectMake(0.0f, 150.0f, self.bounds.size.width, 40.0f)];
        self.cloudiversity.textAlignment = NSTextAlignmentCenter;
        self.cloudiversity.attributedText = text;

        [self addSubview:self.logo];
        [self addSubview:self.cloudiversity];
    }
    return self;
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor
{
    return 190.0f;
}

- (BOOL)formDescriptorCellBecomeFirstResponder
{
    [self resignFirstResponder];
    return NO;
}

@end
