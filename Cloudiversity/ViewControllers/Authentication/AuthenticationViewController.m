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

#define LOCALIZEDSTRING(s) [[NSBundle mainBundle] localizedStringForKey:s value:@"Localization error" table:@"AuthenticationVC"]

@interface AuthenticationViewController ()
@property (nonatomic) BOOL shouldSegue;
@end

@implementation AuthenticationViewController

@synthesize loginField;
@synthesize passwordField;
@synthesize _user;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self localize];
}

- (void)localize {
    self.loginField.placeholder = LOCALIZEDSTRING(@"USERNAME");
    self.passwordField.placeholder = LOCALIZEDSTRING(@"PASSWORD");
    NSString *title = LOCALIZEDSTRING(@"CONNECT");
    [self.button setTitle:title forState:UIControlStateNormal];
    [self.button setTitle:title forState:UIControlStateApplication];
    [self.button setTitle:title forState:UIControlStateDisabled];
    [self.button setTitle:title forState:UIControlStateHighlighted];
    [self.button setTitle:title forState:UIControlStateReserved];
    [self.button setTitle:title forState:UIControlStateSelected];
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
    self.button.enabled = NO;
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
    self.button.enabled = YES;
}

- (IBAction)loginBtn:(id)sender {
    if ([self.loginField.text isEqualToString:@""] || [self.passwordField.text isEqualToString:@""]) {
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
        self.errorLabel.text = [((NSDictionary *)operation.responseObject) objectForKey:@"error"];
        [self endLoginWithSuccess:false];
    };
    [IOSRequest loginWithId:loginField.text andPassword:self.passwordField.text onSuccess:success onFailure:failure];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([self.loginField.text isEqualToString:@""] || [self.passwordField.text isEqualToString:@""]) {
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
        self.shouldAnimate = YES;
        self.hasSelected = NO;
        [self loginBtn:nil];
        [self.passwordField resignFirstResponder];
    }
    return NO;
}

@end
