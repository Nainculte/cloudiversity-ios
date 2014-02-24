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
    loginField.delegate = self;
    passwordField.delegate = self;
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loginWithID:(NSString *)userName andPassword:(NSString *)password
{
    if ([userName isEqual:NULL] || [userName isEqualToString:@""] || [password isEqual:NULL] || [password isEqualToString:@""]) {
        //ERROR PASSWORD || USERNAME == NULL
        NSLog(@"UserName or password is NULL");
        [self endLogin];
         } else {
             [IOSRequest loginWithId:userName andPassword:password onCompletion:^(User *user){
                 dispatch_async(dispatch_get_main_queue(), ^{
                      NSLog(@"GOGO request over");
                     [self setUser:user];
                     [self endLogin];
                 });
             }];
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
@end
