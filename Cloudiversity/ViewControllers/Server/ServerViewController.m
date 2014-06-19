//
//  ServerViewController.m
//  Cloudiversity
//
//  Created by Nainculte on 6/19/14.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "ServerViewController.h"
#import "IOSRequest.h"

#define LOCALIZEDSTRING(s) [[NSBundle mainBundle] localizedStringForKey:s value:@"Unknown error" table:@"ServerVC"]

@interface ServerViewController ()
@property (nonatomic) BOOL shouldSegue;
@property (nonatomic, strong) NSString *server;
@end

@implementation ServerViewController

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

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *server = [defaults objectForKey:@"server"] ;
    if (![server isEqualToString:@""]) {
        self.serverField.text = server;
    }

    [self localize];
    // Do any additional setup after loading the view.
}

- (void)localize {
    self.serverField.placeholder = LOCALIZEDSTRING(@"ADDRESS");
    NSString *title = LOCALIZEDSTRING(@"SERVER");
    [self.button setTitle:title forState:UIControlStateNormal];
    [self.button setTitle:title forState:UIControlStateApplication];
    [self.button setTitle:title forState:UIControlStateDisabled];
    [self.button setTitle:title forState:UIControlStateHighlighted];
    [self.button setTitle:title forState:UIControlStateReserved];
    [self.button setTitle:title forState:UIControlStateSelected];
}

- (void)saveServer {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.server forKey:@"server"];
    [defaults synchronize];
}

- (void)validURL {
    self.shouldSegue = YES;
    self.errorLabel.alpha = 0.0;
    self.button.enabled = YES;
    [self saveServer];
    [self performSegueWithIdentifier:@"login" sender:nil];
}

- (void)invalidURL {
    self.shouldSegue = NO;
    self.errorLabel.text = LOCALIZEDSTRING(@"INVALIDSERVER");
    [UIView animateWithDuration:0.3 animations:^{
        self.errorLabel.alpha = 1.0;
    }];
    self.button.enabled = YES;
}

- (IBAction)chooseServer {
    self.server = self.serverField.text;
    const char *s = [self.server cStringUsingEncoding:NSUTF8StringEncoding];
    if (s[self.server.length - 1] == '/') {
        self.server = [self.server substringToIndex:self.server.length - 1];
    }
    self.shouldAnimate = YES;
    self.hasSelected = NO;
    [self.view endEditing:YES];
    self.button.enabled = NO;
    if ([self.serverField.text isEqualToString:@""]) {
        self.shouldSegue = NO;
        self.errorLabel.text = LOCALIZEDSTRING(@"FILLITALL");
        [UIView animateWithDuration:0.3 animations:^{
            self.errorLabel.alpha = 1.0;
        }];
        self.button.enabled = YES;
    }
    void (^success)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        if ([response objectForKey:@"version"]) {
            [self validURL];
            return ;
        }
        [self invalidURL];
    };
    void (^failure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [self invalidURL];
    };
    [IOSRequest isCloudiversityServer:self.server onSuccess:success onFailure:failure];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (self.shouldSegue) {
        return YES;
    }
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.serverField isFirstResponder]) {
        self.shouldAnimate = YES;
        self.hasSelected = NO;
        [self chooseServer];
        [self.serverField resignFirstResponder];
    }
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
