//
//  CloudURLCellPicker.m
//  Cloudiversity
//
//  Created by Nainculte on 04/10/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "UIView+XLFormAdditions.h"
#import "XLFormRightImageButton.h"
#import "NSObject+XLFormAdditions.h"
#import "XLFormRowDescriptor.h"
#import "XLForm.h"
#import "UICloud.h"
#import "UIColor+Cloud.h"
#import "CloudURLCellPicker.h"

@interface CloudURLCellPicker () <UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic, strong)NSArray *leftSelectors;
@property (nonatomic, strong)NSArray *colors;
@property (nonatomic)NSNumber *selectedIndex;
@property (nonatomic, strong)NSString *text;

@end

@implementation CloudURLCellPicker

@synthesize leftButton = _leftButton;
@synthesize rightTextField = _rightTextField;

#pragma mark - Properties

- (UIButton *)leftButton {
    if (_leftButton) return _leftButton;
    _leftButton = [[XLFormRightImageButton alloc] init];
    [_leftButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"XLForm.bundle/forwardarrow.png"]];
    [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_leftButton addSubview:imageView];
    [_leftButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[image(8)]|" options:0 metrics:0 views:@{@"image": imageView}]];

    UIView * separatorTop = [UIView autolayoutView];
    UIView * separatorBottom = [UIView autolayoutView];
    [_leftButton addSubview:separatorTop];
    [_leftButton addSubview:separatorBottom];
    [_leftButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[separatorTop(separatorBottom)][image][separatorBottom]|" options:0 metrics:0 views:@{@"image": imageView, @"separatorTop": separatorTop, @"separatorBottom": separatorBottom}]];

    _leftButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);

    [_leftButton setTitleColor:[UIColor colorWithRed:0.0 green:0.478431 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [_leftButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [_leftButton setContentHuggingPriority:500 forAxis:UILayoutConstraintAxisHorizontal];
    return _leftButton;
}

-(UITextField *)rightTextField
{
    if (_rightTextField) return _rightTextField;
    _rightTextField = [UITextField autolayoutView];
    [_rightTextField setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
    _rightTextField.keyboardType = UIKeyboardTypeURL;
    _rightTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _rightTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _rightTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    _rightTextField.returnKeyType = UIReturnKeyGo;
    return _rightTextField;
}

- (NSArray *)leftSelectors {
    return @[@"https", @"http"];
}

- (NSArray *)colors {
    return @[[UIColor cloudLightBlue], [UIColor cloudLightBlue]];
}

#pragma mark - XLFormDescriptorCell

- (void)configure {
    [super configure];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    UIView * separatorView = [UIView autolayoutView];
    [separatorView setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:1.0]];

    [self.contentView addSubview:self.leftButton];
    [self.contentView addSubview:self.rightTextField];
    [self.contentView addSubview:separatorView];

    NSDictionary * views = @{@"leftButton" : self.leftButton, @"rightTextField": self.rightTextField, @"separatorView": separatorView};

    [self.contentView addConstraint:[self.leftButton layoutConstraintSameHeightOf:self.contentView]];
    [self.contentView addConstraint:[self.rightTextField layoutConstraintSameHeightOf:self.contentView]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[leftButton]-[separatorView(1)]-[rightTextField]-14-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightTextField]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[separatorView]-8-|" options:0 metrics:nil views:views]];

    [self.imageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:0];

    [self.rightTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    [self.leftButton setTitle:[NSString stringWithFormat:@"%@%@", [self.leftSelectors objectAtIndex:0], self.rowDescriptor.required ? @"*" : @""] forState:UIControlStateNormal];
    [self.leftButton setTitleColor:[self.colors objectAtIndex:[self.selectedIndex integerValue]] forState:UIControlStateNormal];
}

- (void)update {
    [super update];
    self.rightTextField.delegate = self;
    self.rightTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.rightTextField.text = self.text ? self.text : self.rowDescriptor.noValueDisplayText;
    [self.leftButton setTitle:[NSString stringWithFormat:@"%@%@", [self.leftSelectors objectAtIndex:[self.selectedIndex unsignedIntegerValue]], self.rowDescriptor.required ? @"*" : @""] forState:UIControlStateNormal];
    [self.leftButton addTarget:self action:@selector(leftButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(NSError *)formDescriptorCellLocalValidation
{
    if (self.rowDescriptor.required && self.rowDescriptor.value == nil){
        return [[NSError alloc] initWithDomain:XLFormErrorDomain code:XLFormErrorCodeRequired userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"%@ can't be empty", nil), [self.rowDescriptor.leftRightSelectorLeftOptionSelected displayText]]}];

    }
    return nil;
}

-(BOOL)formDescriptorCellBecomeFirstResponder
{
    return [self.rightTextField becomeFirstResponder];
}

-(BOOL)formDescriptorCellResignFirstResponder
{
    return [self.rightTextField resignFirstResponder];
}

-(void)dealloc
{
    [self.imageView removeObserver:self forKeyPath:@"image"];
}

#pragma mark - Actions

- (void)leftButtonPressed:(UIButton *)button {
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:self.rowDescriptor.selectorTitle delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    actionSheet.tag = [self.rowDescriptor hash];
    for (NSString * leftOption in self.leftSelectors) {
        [actionSheet addButtonWithTitle:leftOption];
    }
    [actionSheet showInView:self.formViewController.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex >= 0){
        NSString * title = [actionSheet buttonTitleAtIndex:buttonIndex];
        [self.leftButton setTitle:[NSString stringWithFormat:@"%@%@", title, self.rowDescriptor.required ? @"*" : @""] forState:UIControlStateNormal];
        [self.leftButton setTitleColor:[self.colors objectAtIndex:buttonIndex] forState:UIControlStateNormal];
        self.selectedIndex = [NSNumber numberWithInteger:buttonIndex];
        [self updateValue];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return [self.formViewController textFieldShouldClear:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.delegate) {
        [self.delegate returnCell:self];
    }
    return [self.formViewController textFieldShouldReturn:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self textFieldDidChange:textField];
    [self.formViewController textFieldDidEndEditing:textField];
}

- (void)textFieldDidChange:(UITextField *)textField{
    self.text = self.rightTextField.text;
    [self updateValue];
}

#pragma mark - valueUpdate

- (void)updateValue {
    if (self.text.length) {
        self.rowDescriptor.value = [NSString stringWithFormat:@"%@://%@", [self.leftSelectors objectAtIndex:[self.selectedIndex integerValue]], self.text];
    } else {
        self.rowDescriptor.value = nil;
    }
}

@end
