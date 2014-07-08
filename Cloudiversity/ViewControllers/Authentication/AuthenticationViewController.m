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
#import "DejalActivityView.h"

#define LOCALIZEDSTRING(s) [[NSBundle mainBundle] localizedStringForKey:s value:@"Localization error" table:@"AuthenticationVC"]

@interface AuthenticationViewController ()

@property (nonatomic) BOOL shouldSegue;
@property (nonatomic, strong)User *user;

@end

@implementation AuthenticationViewController

@synthesize loginField;
@synthesize passwordField;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self localize];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.loginField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
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

- (void) startLogin {
    self.shouldAnimate = YES;
    self.hasSelected = NO;
    [self.view endEditing:YES];
    self.button.enabled = NO;
    [DejalActivityView activityViewForView:self.view withLabel:LOCALIZEDSTRING(@"CONNECTING")].showNetworkActivityIndicator = YES;
}

- (void) endLoginWithSuccess:(BOOL)success {
    if (success) {
        self.shouldSegue = YES;
        self.errorLabel.alpha = 0.0;
        [CloudKeychainManager saveToken:_user.token forEmail:_user.email];
        [self checkLogin];
    } else {
        [DejalActivityView removeView];
        self.shouldSegue = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.errorLabel.alpha = 1.0;
        }];
    }
    self.button.enabled = YES;
}

- (void)checkLogin {
    void (^success)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        self.user.firstName = [response objectForKey:@"first_name"];
        self.user.lastName = [response objectForKey:@"last_name"];
        self.user.roles = [response objectForKey:@"roles"];
        if (!self.user.currentRole && self.user.roles.count) {
            self.user.currentRole = self.user.roles[0];
        }
        [self.user saveUser];
        [DejalActivityView removeView];
        [self performSegueWithIdentifier:@"login_success" sender:self];
    };
    void (^failure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        self.errorLabel.text = LOCALIZEDSTRING(@"FAILCHECKLOGIN");
        [DejalActivityView removeView];
        self.shouldSegue = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.errorLabel.alpha = 1.0;
        }];
    };
    [IOSRequest getCurrentUserOnSuccess:success onFailure:failure];
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
        self.user = user;
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
