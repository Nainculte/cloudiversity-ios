//
//  CloudTextFieldCell.h
//  Cloudiversity
//
//  Created by Nainculte on 16/10/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "XLFormBaseCell.h"

@class CloudTextFieldCell;

@protocol CloudTextFieldCellDelegate

- (void)textFieldReturned;

@end

@interface CloudTextFieldCell : XLFormBaseCell

@property (nonatomic, weak) id<CloudTextFieldCellDelegate> delegate;

@property (nonatomic, readonly) UILabel * textLabel;
@property (nonatomic, readonly) UITextField * textField;

@end
