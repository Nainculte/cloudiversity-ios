//
//  CloudTextFieldCell.m
//  Cloudiversity
//
//  Created by Nainculte on 16/10/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "NSObject+XLFormAdditions.h"
#import "UIView+XLFormAdditions.h"
#import "XLFormRowDescriptor.h"
#import "XLForm.h"
#import "CloudTextFieldCell.h"

@interface CloudTextFieldCell() <UITextFieldDelegate>

@property NSArray * dynamicCustomConstraints;
@property (nonatomic, strong) NSNumber *isPassword;

@end

@implementation CloudTextFieldCell

@synthesize textField = _textField;
@synthesize textLabel = _textLabel;

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ((object == self.textLabel && [keyPath isEqualToString:@"text"]) ||  (object == self.imageView && [keyPath isEqualToString:@"image"])){
        if ([[change objectForKey:NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeSetting)]){
            [self.contentView needsUpdateConstraints];
        }
    }
}

-(void)dealloc
{
    [self.textLabel removeObserver:self forKeyPath:@"text"];
    [self.imageView removeObserver:self forKeyPath:@"image"];

}

#pragma mark - XLFormDescriptorCell

-(void)configure
{
    [super configure];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self.contentView addSubview:self.textLabel];
    [self.contentView addSubview:self.textField];
    [self.contentView addConstraints:[self layoutConstraints]];
    [self.textLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:0];
    [self.imageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:0];

    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

-(void)update
{
    [super update];
    self.textField.delegate = self;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    if ([self.isPassword isEqual:@0]) {
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.spellCheckingType = UITextSpellCheckingTypeNo;
        self.textField.returnKeyType = UIReturnKeyNext;
    } else {
        self.textField.secureTextEntry = YES;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.spellCheckingType = UITextSpellCheckingTypeNo;
        self.textField.returnKeyType = UIReturnKeyGo;
        self.textField.keyboardAppearance = UIKeyboardAppearanceDark;
    }

    self.textLabel.text = ((self.rowDescriptor.required && self.rowDescriptor.title) ? [NSString stringWithFormat:@"%@*", self.rowDescriptor.title] : self.rowDescriptor.title);

    self.textField.text = self.rowDescriptor.value ? [self.rowDescriptor.value displayText] : self.rowDescriptor.noValueDisplayText;
    [self.textField setEnabled:!self.rowDescriptor.disabled];
    self.textLabel.textColor  = self.rowDescriptor.disabled ? [UIColor grayColor] : [UIColor blackColor];
    self.textField.textColor = self.rowDescriptor.disabled ? [UIColor grayColor] : [UIColor blackColor];
    self.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.textField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

-(BOOL)formDescriptorCellBecomeFirstResponder
{
    return [self.textField becomeFirstResponder];
}

-(BOOL)formDescriptorCellResignFirstResponder
{
    return [self.textField resignFirstResponder];
}

-(NSError *)formDescriptorCellLocalValidation
{
    if (self.rowDescriptor.required && (self.textField.text == nil || [self.textField.text isEqualToString:@""])){
        return [[NSError alloc] initWithDomain:XLFormErrorDomain code:XLFormErrorCodeRequired userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"%@ can't be empty", nil), self.rowDescriptor.title] }];

    }
    else if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeEmail] && self.textField.text.length > 0 && ![self isValidAsEmail:self.textField.text]){
        return [[NSError alloc] initWithDomain:XLFormErrorDomain code:XLFormErrorCodeInvalidEmailAddress userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"\"%@\" is not an email", nil), self.textField.text] }];
    }
    return nil;
}

-(BOOL)isValidAsEmail:(NSString *)emailString
{
    NSString *regexForEmailAddress = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailValidation = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regexForEmailAddress];
    return [emailValidation evaluateWithObject:emailString];
}

#pragma mark - Properties

-(UILabel *)textLabel
{
    if (_textLabel) return _textLabel;
    _textLabel = [UILabel autolayoutView];
    [_textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
    return _textLabel;
}

-(UITextField *)textField
{
    if (_textField) return _textField;
    _textField = [UITextField autolayoutView];
    [_textField setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
    return _textField;
}

#pragma mark - LayoutConstraints

-(NSArray *)layoutConstraints
{
    NSMutableArray * result = [[NSMutableArray alloc] init];
    [self.textLabel setContentHuggingPriority:500 forAxis:UILayoutConstraintAxisHorizontal];
    [result addObject:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [result addObject:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [result addObject:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [result addObject:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    return result;
}

-(void)updateConstraints
{
    if (self.dynamicCustomConstraints){
        [self.contentView removeConstraints:self.dynamicCustomConstraints];
    }
    NSDictionary * views = @{@"label": self.textLabel, @"textField": self.textField, @"image": self.imageView};
    if (self.imageView.image){
        if (self.textLabel.text.length > 0){
            self.dynamicCustomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[image]-[label]-[textField]-4-|" options:0 metrics:0 views:views];
        }
        else{
            self.dynamicCustomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[image]-[textField]-4-|" options:0 metrics:0 views:views];
        }
    }
    else{
        if (self.textLabel.text.length > 0){
            self.dynamicCustomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[label]-[textField]-4-|" options:0 metrics:0 views:views];
        }
        else{
            self.dynamicCustomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[textField]-4-|" options:0 metrics:0 views:views];
        }
    }
    [self.contentView addConstraints:self.dynamicCustomConstraints];
    [super updateConstraints];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return [self.formViewController textFieldShouldClear:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.delegate) {
        [self.delegate textFieldReturned];
    }
    return [self.formViewController textFieldShouldReturn:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self textFieldDidChange:textField];
    [self.formViewController textFieldDidEndEditing:textField];
}


#pragma mark - Helper

- (void)textFieldDidChange:(UITextField *)textField{
    if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeNumber]){
        self.rowDescriptor.value =  @([self.textField.text doubleValue]);
    }
    else if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeInteger]){
        self.rowDescriptor.value = @([self.textField.text integerValue]);
    }
    else{
        self.rowDescriptor.value = self.textField.text;
    }
}

@end
