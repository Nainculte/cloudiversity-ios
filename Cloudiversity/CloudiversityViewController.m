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
@property (nonatomic) BOOL shouldAnimate;
@property (nonatomic) BOOL hasSelected;
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
    self.shouldAnimate = YES;
    self.hasSelected = NO;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	// trying to get userDefaults
	NSUserDefaults *defaultUserData = [NSUserDefaults standardUserDefaults];
	NSString *password = [defaultUserData objectForKey:DEFAULT_PASS_USER_KEY];
	NSString *login = [defaultUserData objectForKey:DEFAULT_LOG_USER_KEY];
	if (password && login) {
		[self performSegueWithIdentifier:@"login_success" sender:self];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loginWithID:(NSString *)userName andPassword:(NSString *)password
{
	User *user = [[User alloc] init];
    if ([userName isEqual:NULL] || [userName isEqualToString:@""] || [password isEqual:NULL] || [password isEqualToString:@""]) {
        //ERROR PASSWORD || USERNAME == NULL
        NSLog(@"UserName or password is NULL");
        [self endLogin];
	} else {
		int idx = [self.logins indexOfObject:userName];
		if (idx != NSNotFound) {
			if ([[self.passwords objectAtIndex:idx] isEqualToString:password]) {
				// login succes
				[self setUser:user];
				
				// Saving user's informations
				NSUserDefaults *defaultUser = [NSUserDefaults standardUserDefaults];
				[defaultUser setObject:userName forKey:DEFAULT_LOG_USER_KEY];
				[defaultUser setObject:password forKey:DEFAULT_PASS_USER_KEY];
				
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([loginField isFirstResponder]) {
        self.shouldAnimate = NO;
        [self.loginField resignFirstResponder];
        [passwordField becomeFirstResponder];
    } else {
        self.shouldAnimate = YES;
        self.hasSelected = NO;
        [passwordField resignFirstResponder];
    }
    return NO;
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
		[self.logoView setFrame:CGRectMake(self.logoView.frame.origin.x, self.logoView.frame.origin.y - 100,
										   self.logoView.frame.size.width, self.logoView.frame.size.height)];
		[self.loginField setFrame:CGRectMake(self.loginField.frame.origin.x, self.loginField.frame.origin.y - 100,
											 self.loginField.frame.size.width, self.loginField.frame.size.height)];
		[self.passwordField setFrame:CGRectMake(self.passwordField.frame.origin.x, self.passwordField.frame.origin.y - 100,
												self.passwordField.frame.size.width, self.passwordField.frame.size.height)];
		[self.loginBtn setFrame:CGRectMake(self.loginBtn.frame.origin.x, self.loginBtn.frame.origin.y - 200,
										   self.loginBtn.frame.size.width, self.loginBtn.frame.size.height)];
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
    self.shouldAnimate = YES;
    self.hasSelected = NO;
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
