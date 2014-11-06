//
//  CloudURLCellPicker.h
//  Cloudiversity
//
//  Created by Nainculte on 04/10/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XLFormBaseCell.h"

@protocol CloudURLCellPickerDelegate;

@interface CloudURLCellPicker : XLFormBaseCell

@property (nonatomic, readonly)UIButton *leftButton;
@property (nonatomic, readonly)UITextField *rightTextField;
@property (nonatomic, retain)id<CloudURLCellPickerDelegate> delegate;

@end

@protocol CloudURLCellPickerDelegate

- (void)returnCell:(CloudURLCellPicker *)cell;

@end
