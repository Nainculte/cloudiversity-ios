//
//  CloudiversityViewController.m
//  Cloudiversity
//
//  Created by Rémy Marty on 04/02/2014.
//  Copyright (c) 2014 Rémy Marty. All rights reserved.
//

#import "CloudiversityViewController.h"
#import "IOSRequest.h"

@interface CloudiversityViewController ()
@end

@implementation CloudiversityViewController

@synthesize loginField;
@synthesize passwordField;
@synthesize loginBtn;
@synthesize _user;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	// Labels modifications (font, color...)
	[self.cloudLabel setFont:[UIFont fontWithName:@"FiraSansOt-Bold" size:self.cloudLabel.font.pointSize]];
	[self.cloudLabel setTextColor:[UIColor cloudDarkBlue]];
	[self.iversityLabel setTextColor:[UIColor cloudLightBlue]];

	// setting arrays for fake users
	self.logins = @[@"merle_a", @"dumeni_o", @"hamel_t"];
	self.passwords = @[@"anthony", @"olivier", @"thibault"];
	self.users = @[[User withName:@"anthony" lastName:@"merle" andEmail:@"anthony.merle@mail.ru"],
				   [User withName:@"olivier" lastName:@"dumenil" andEmail:@"olivier.dumenil@mail.ru"],
				   [User withName:@"thibault" lastName:@"hamel" andEmail:@"thibault.hamel@mail.ru"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loginWithID:(NSString *)userName andPassword:(NSString *)password
{
	User *user;
    if ([userName isEqual:NULL] || [userName isEqualToString:@""] || [password isEqual:NULL] || [password isEqualToString:@""]) {
        //ERROR PASSWORD || USERNAME == NULL
        NSLog(@"UserName or password is NULL");
        [self endLogin];
	} else {
		int idx = [self.logins indexOfObject:userName];
		if (idx != NSNotFound) {
			if ([[self.passwords objectAtIndex:idx] isEqualToString:password]) {
				[self setUser:user];
				// login succes
				[self performSegueWithIdentifier:@"login_success" sender:self];
			} else
				[self alertStatus:@"Mauvais mot de Pass" :@"Connection echouee" :0];
		} else
			[self alertStatus:@"Mauvais nom d'utilisateur" :@"Connection echouee" :0];
		[self endLogin];
	}
}

-(void) setUser:(User *)user {
    NSLog(@"set user: %@", user.email);
    if (_user != user)
    {
        _user = user;
    }
}

- (void) startLogin
{
    NSLog(@"Login ....");
    self.loginBtn.enabled = NO;
}

- (void) endLogin
{
    NSLog(@"End of Login. Retry");
    self.loginBtn.enabled = YES;
}

- (IBAction)loginBtn:(id)sender {
    [self startLogin];
    NSLog(@"%@ & %@", self.loginField.text, self.passwordField.text);
    [self loginWithID:self.loginField.text andPassword:self.passwordField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [loginField resignFirstResponder];
    [passwordField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[UIView animateWithDuration:0.3 animations:^{
		[self.cloudLogo setAlpha:0];
		[self.logoView setFrame:CGRectMake(self.logoView.frame.origin.x, self.logoView.frame.origin.y - 100,
										   self.logoView.frame.size.width, self.logoView.frame.size.height)];
		[self.loginField setFrame:CGRectMake(self.loginField.frame.origin.x, self.loginField.frame.origin.y - 100,
											 self.loginField.frame.size.width, self.loginField.frame.size.height)];
		[self.passwordField setFrame:CGRectMake(self.passwordField.frame.origin.x, self.passwordField.frame.origin.y - 100,
												self.passwordField.frame.size.width, self.passwordField.frame.size.height)];
		[self.loginBtn setFrame:CGRectMake(self.loginBtn.frame.origin.x, self.loginBtn.frame.origin.y - 200,
										   self.loginBtn.frame.size.width, self.loginBtn.frame.size.height)];
	}];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[UIView animateWithDuration:0.3 animations:^{
		[self.cloudLogo setAlpha:1];
		[self.logoView setFrame:CGRectMake(self.logoView.frame.origin.x, self.logoView.frame.origin.y + 100,
										   self.logoView.frame.size.width, self.logoView.frame.size.height)];
		[self.loginField setFrame:CGRectMake(self.loginField.frame.origin.x, self.loginField.frame.origin.y + 100,
											 self.loginField.frame.size.width, self.loginField.frame.size.height)];
		[self.passwordField setFrame:CGRectMake(self.passwordField.frame.origin.x, self.passwordField.frame.origin.y + 100,
												self.passwordField.frame.size.width, self.passwordField.frame.size.height)];
		[self.loginBtn setFrame:CGRectMake(self.loginBtn.frame.origin.x, self.loginBtn.frame.origin.y + 200,
										   self.loginBtn.frame.size.width, self.loginBtn.frame.size.height)];
	}];
}

- (IBAction)backgroundTap:(id)sender {
	[self.view endEditing:YES];
}

// Pop up de message d'erreur
- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}

@end
