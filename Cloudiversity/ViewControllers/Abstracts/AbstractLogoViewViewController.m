//
//  AbstractLogoViewViewController.m
//  Cloudiversity
//
//  Created by Nainculte on 6/19/14.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AbstractLogoViewViewController.h"
#import "UIColor+Cloud.h"

@interface AbstractLogoViewViewController ()

@end

@implementation AbstractLogoViewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Labels modifications (font, color...)
	[self.cloudLabel setFont:[UIFont fontWithName:@"FiraSansOt-Bold" size:self.cloudLabel.font.pointSize]];
	[self.cloudLabel setTextColor:[UIColor cloudDarkBlue]];
	[self.iversityLabel setTextColor:[UIColor cloudLightBlue]];

    [self.errorLabel setTextColor:[UIColor cloudRed]];

    self.shouldAnimate = YES;
    self.hasSelected = NO;

    self.view.backgroundColor = [UIColor cloudGrey];
    self.logoView.backgroundColor = [UIColor cloudGrey];

    for (UIView *v in self.borders) {
        v.backgroundColor = [UIColor cloudBorderGrey];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!self.shouldAnimate) {
        return ;
    }
    if (self.hasSelected) {
        return;
    }

	[UIView animateWithDuration:0.3 animations:^{
		[self.cloudLogo setAlpha:0];
		[self.logoView setFrame:CGRectMake(self.logoView.frame.origin.x, self.logoView.frame.origin.y - 130,
										   self.logoView.frame.size.width, self.logoView.frame.size.height)];
        [self.textfields setFrame:CGRectMake(self.textfields.frame.origin.x, self.textfields.frame.origin.y - 130,
                                             self.textfields.frame.size.width, self.textfields.frame.size.height)];
        [self.errorLabel setFrame:CGRectMake(self.errorLabel.frame.origin.x, self.errorLabel.frame.origin.y - 130,
                                             self.errorLabel.frame.size.width, self.errorLabel.frame.size.height)];
		[self.button setFrame:CGRectMake(self.button.frame.origin.x, self.button.frame.origin.y - 200,
										   self.button.frame.size.width, self.button.frame.size.height)];
	}];
    self.hasSelected = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (!self.shouldAnimate) {
        return ;
    }
    if (self.hasSelected) {
        return ;
    }

	[UIView animateWithDuration:0.3 animations:^{
		[self.cloudLogo setAlpha:1];
		[self.logoView setFrame:CGRectMake(self.logoView.frame.origin.x, self.logoView.frame.origin.y + 130,
										   self.logoView.frame.size.width, self.logoView.frame.size.height)];
        [self.textfields setFrame:CGRectMake(self.textfields.frame.origin.x, self.textfields.frame.origin.y + 130,
                                             self.textfields.frame.size.width, self.textfields.frame.size.height)];
        [self.errorLabel setFrame:CGRectMake(self.errorLabel.frame.origin.x, self.errorLabel.frame.origin.y + 130,
                                             self.errorLabel.frame.size.width, self.errorLabel.frame.size.height)];
		[self.button setFrame:CGRectMake(self.button.frame.origin.x, self.button.frame.origin.y + 200,
										   self.button.frame.size.width, self.button.frame.size.height)];
	}];
}

- (IBAction)backgroundTap:(id)sender {
    self.shouldAnimate = YES;
    self.hasSelected = NO;
	[self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
