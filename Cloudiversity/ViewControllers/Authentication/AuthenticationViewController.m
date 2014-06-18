//
//  AuthenticationViewController.m
//  Cloudiversity
//
//  Created by Rémy Marty on 04/02/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AuthenticationViewController.h"
#import "IOSRequest.h"
#import "CloudKeychainManager.h"

#define LOCALIZEDSTRING(s) [[NSBundle mainBundle] localizedStringForKey:s value:@"Unknown error" table:@"AuthenticationVC"]

@interface AuthenticationViewController ()
@property (nonatomic) BOOL shouldAnimate;
@property (nonatomic) BOOL hasSelected;
@property (nonatomic) BOOL shouldSegue;
@end

@implementation AuthenticationViewController

@synthesize loginField;
@synthesize passwordField;
@synthesize loginBtn;
@synthesize serverField;
@synthesize _user;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

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

    [self localize];
}

- (void)localize {
    self.loginField.placeholder = LOCALIZEDSTRING(@"USERNAME");
    self.passwordField.placeholder = LOCALIZEDSTRING(@"PASSWORD");
    self.serverField.placeholder = LOCALIZEDSTRING(@"ADDRESS");
    NSString *title = LOCALIZEDSTRING(@"CONNECT");
    [self.loginBtn setTitle:title forState:UIControlStateNormal];
    [self.loginBtn setTitle:title forState:UIControlStateApplication];
    [self.loginBtn setTitle:title forState:UIControlStateDisabled];
    [self.loginBtn setTitle:title forState:UIControlStateHighlighted];
    [self.loginBtn setTitle:title forState:UIControlStateReserved];
    [self.loginBtn setTitle:title forState:UIControlStateSelected];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setUser:(User *)user {
    //NSLog(@"set user: %@", user.email);
    if (_user != user)
    {
        _user = user;
    }
}

- (void) startLogin {
    self.shouldAnimate = YES;
    self.hasSelected = NO;
    [self.view endEditing:YES];
    self.loginBtn.enabled = NO;
    [self saveServer];
}

- (void) endLoginWithSuccess:(BOOL)success {
    if (success) {
        self.shouldSegue = YES;
        [self performSegueWithIdentifier:@"login_success" sender:self];
        self.errorLabel.alpha = 0.0;
        [CloudKeychainManager saveToken:_user.token forEmail:_user.email];
        [self._user saveUser];
    } else {
        self.shouldSegue = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.errorLabel.alpha = 1.0;
        }];
    }
    self.loginBtn.enabled = YES;
}

- (void)saveServer {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *server = self.serverField.text;
    const char *s = [server cStringUsingEncoding:NSUTF8StringEncoding];
    if (s[server.length - 1] == '/') {
        server = [server substringToIndex:server.length - 1];
    }
    [defaults setObject:server forKey:@"server"];
    [defaults synchronize];
}

- (IBAction)loginBtn:(id)sender {
    if ([self.loginField.text isEqualToString:@""] || [self.passwordField.text isEqualToString:@""] || [self.serverField.text isEqualToString:@""]) {
        self.errorLabel.text = LOCALIZEDSTRING(@"FILLITALL");
        [self endLoginWithSuccess:false];
        return ;
    }
    [self startLogin];
    void (^success)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        User *user = [User withEmail:[response objectForKey:@"email"] andToken:[response objectForKey:@"token"]];
        [self setUser:user];
        [self endLoginWithSuccess:true];
    };
    void (^failure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        switch (operation.response.statusCode) {
            default:
                break;
        }
        [self endLoginWithSuccess:false];
    };
    [IOSRequest loginWithId:loginField.text andPassword:self.passwordField.text onSuccess:success onFailure:failure];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([self.loginField.text isEqualToString:@""] || [self.passwordField.text isEqualToString:@""] || [self.serverField.text isEqualToString:@""]) {
        self.errorLabel.text = LOCALIZEDSTRING(@"FILLITALL");
        [self endLoginWithSuccess:false];
        return NO;
    } else if (!self.shouldSegue) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([loginField isFirstResponder]) {
        self.shouldAnimate = NO;
        [self.loginField resignFirstResponder];
        [passwordField becomeFirstResponder];
    } else if ([passwordField isFirstResponder]) {
        self.shouldAnimate = NO;
        [self.passwordField resignFirstResponder];
        [serverField becomeFirstResponder];
    } else {
        self.shouldAnimate = YES;
        self.hasSelected = NO;
        [self loginBtn:nil];
        [serverField resignFirstResponder];
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
		[self.logoView setFrame:CGRectMake(self.logoView.frame.origin.x, self.logoView.frame.origin.y - 130,
										   self.logoView.frame.size.width, self.logoView.frame.size.height)];
//		[self.loginField setFrame:CGRectMake(self.loginField.frame.origin.x, self.loginField.frame.origin.y - 130,
//											 self.loginField.frame.size.width, self.loginField.frame.size.height)];
//		[self.passwordField setFrame:CGRectMake(self.passwordField.frame.origin.x, self.passwordField.frame.origin.y - 130,
//												self.passwordField.frame.size.width, self.passwordField.frame.size.height)];
//      [self.serverField setFrame:CGRectMake(self.serverField.frame.origin.x, self.serverField.frame.origin.y - 130,
//												self.serverField.frame.size.width, self.serverField.frame.size.height)];
        [self.textfields setFrame:CGRectMake(self.textfields.frame.origin.x, self.textfields.frame.origin.y - 130,
                                            self.textfields.frame.size.width, self.textfields.frame.size.height)];
        [self.errorLabel setFrame:CGRectMake(self.errorLabel.frame.origin.x, self.errorLabel.frame.origin.y - 130,
                                            self.errorLabel.frame.size.width, self.errorLabel.frame.size.height)];
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
		[self.logoView setFrame:CGRectMake(self.logoView.frame.origin.x, self.logoView.frame.origin.y + 130,
										   self.logoView.frame.size.width, self.logoView.frame.size.height)];
//		[self.loginField setFrame:CGRectMake(self.loginField.frame.origin.x, self.loginField.frame.origin.y + 130,
//											 self.loginField.frame.size.width, self.loginField.frame.size.height)];
//		[self.passwordField setFrame:CGRectMake(self.passwordField.frame.origin.x, self.passwordField.frame.origin.y + 130,
//												self.passwordField.frame.size.width, self.passwordField.frame.size.height)];
//      [self.serverField setFrame:CGRectMake(self.serverField.frame.origin.x, self.serverField.frame.origin.y + 130,
//												self.serverField.frame.size.width, self.serverField.frame.size.height)];
        [self.textfields setFrame:CGRectMake(self.textfields.frame.origin.x, self.textfields.frame.origin.y + 130,
                                             self.textfields.frame.size.width, self.textfields.frame.size.height)];
        [self.errorLabel setFrame:CGRectMake(self.errorLabel.frame.origin.x, self.errorLabel.frame.origin.y + 130,
                                             self.errorLabel.frame.size.width, self.errorLabel.frame.size.height)];
		[self.loginBtn setFrame:CGRectMake(self.loginBtn.frame.origin.x, self.loginBtn.frame.origin.y + 200,
										   self.loginBtn.frame.size.width, self.loginBtn.frame.size.height)];
	}];
}

- (IBAction)backgroundTap:(id)sender {
    self.shouldAnimate = YES;
    self.hasSelected = NO;
	[self.view endEditing:YES];
}

@end
