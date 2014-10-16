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

-(NSIndexPath *)nextIndexPath:(NSIndexPath *)indexPath
{
    if ([self.formViewController.tableView numberOfRowsInSection:indexPath.section] > (indexPath.row + 1)){
        return [NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:indexPath.section];
    }
    else if ([self.formViewController.tableView numberOfSections] > (indexPath.section + 1)){
        if ([self.formViewController.tableView numberOfRowsInSection:(indexPath.section + 1)] > 0){
            return [NSIndexPath indexPathForRow:0 inSection:(indexPath.section + 1)];
        }
    }
    return nil;
}


- (BOOL)formDescriptorCellBecomeFirstResponder
{
    [self resignFirstResponder];
    UITableViewCell<XLFormDescriptorCell> * cell = self;
    NSIndexPath * currentIndexPath = [self.formViewController.tableView indexPathForCell:cell];
    NSIndexPath * nextIndexPath = [self nextIndexPath:currentIndexPath];

    if (nextIndexPath){
        XLFormRowDescriptor * nextFormRow = [self.formViewController.form formRowAtIndex:nextIndexPath];
        UITableViewCell<XLFormDescriptorCell> * nextCell = (UITableViewCell<XLFormDescriptorCell> *)[nextFormRow cellForFormController:self.formViewController];
        if ([nextCell respondsToSelector:@selector(formDescriptorCellBecomeFirstResponder)]){
            [nextCell formDescriptorCellBecomeFirstResponder];
            return YES;
        }
    }
    if ([cell respondsToSelector:@selector(formDescriptorCellResignFirstResponder)]){
        [cell formDescriptorCellResignFirstResponder];
    }
    return YES;
}

@end
