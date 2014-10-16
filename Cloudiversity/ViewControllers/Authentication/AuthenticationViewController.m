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
#import "UIColor+Cloud.h"
#import "CloudLogoCell.h"
#import "CloudSeparatorCell.h"
#import "CloudTextFieldCell.h"

#define LOCALIZEDSTRING(s) [[NSBundle mainBundle] localizedStringForKey:s value:@"Localization error" table:@"AuthenticationVC"]

#pragma mark - AuthenticationRootViewController
@interface AuthenticationRootViewController ()

@end

@implementation AuthenticationRootViewController

- (id) init {
    AuthenticationViewController *vc = [[AuthenticationViewController alloc] init];
    self = [super initWithRootViewController:vc];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBarHidden = YES;
    self.navigationBar.translucent = NO;
    [self.navigationBar setBackgroundColor:[UIColor cloudLightBlue]];
    [self.navigationBar setBarTintColor:[UIColor cloudLightBlue]];
    self.navigationBar.tintColor = [UIColor whiteColor];
}

@end


#pragma mark - AuthenticationViewController
@interface AuthenticationViewController () <CloudTextFieldCellDelegate>

@property (nonatomic, strong)NSString *username;
@property (nonatomic, strong)NSString *password;

@property (nonatomic, strong)User *user;

@end

@implementation AuthenticationViewController

NSString *const logoCellTag = @"Logo";
NSString *const userTag = @"User";
NSString *const passwordTag = @"Password";
NSString *const buttonCellTag = @"Connect";
NSString *const cancelTag = @"Cancel";
NSString *const sepaTag = @"Sep";

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self configureForm];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

- (void)configureForm {
    XLFormDescriptor *form;
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;

    form = [XLFormDescriptor formDescriptor];

    //Logo
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:logoCellTag rowType:@"CloudLogoCell"];
    row.cellClass = [CloudLogoCell class];
    [section addFormRow:row];

    //Username and Password
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:sepaTag rowType:@"CloudSeparatorCell"];
    row.cellClass = [CloudSeparatorCell class];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:userTag rowType:@"CloudTextFieldCell"];
    row.cellClass = [CloudTextFieldCell class];
    [row.cellConfigAtConfigure setObject:LOCALIZEDSTRING(@"USERNAME") forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@0 forKey:@"isPassword"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:sepaTag rowType:@"CloudSeparatorCell"];
    row.cellClass = [CloudSeparatorCell class];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:passwordTag rowType:@"CloudTextFieldCell"];
    row.cellClass = [CloudTextFieldCell class];
    [row.cellConfigAtConfigure setObject:LOCALIZEDSTRING(@"PASSWORD") forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@1 forKey:@"isPassword"];
    [row.cellConfigAtConfigure setObject:self forKey:@"delegate"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:sepaTag rowType:@"CloudSeparatorCell"];
    row.cellClass = [CloudSeparatorCell class];
    [section addFormRow:row];;

    //Connect button
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:sepaTag rowType:@"CloudSeparatorCell"];
    row.cellClass = [CloudSeparatorCell class];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:buttonCellTag rowType:XLFormRowDescriptorTypeButton title:LOCALIZEDSTRING(@"CONNECT")];
    [row.cellConfigAtConfigure setObject:[UIColor cloudLightBlue] forKey:@"textLabel.textColor"];
//    row.disabled = YES;
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:sepaTag rowType:@"CloudSeparatorCell"];
    row.cellClass = [CloudSeparatorCell class];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:cancelTag rowType:XLFormRowDescriptorTypeButton title:LOCALIZEDSTRING(@"CANCEL")];
    [row.cellConfigAtConfigure setObject:[UIColor cloudRed] forKey:@"textLabel.textColor"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:sepaTag rowType:@"CloudSeparatorCell"];
    row.cellClass = [CloudSeparatorCell class];
    [section addFormRow:row];

    self.form = form;
}

#pragma mark - CloudTextFieldCellDelegate

- (void)textFieldReturned {
    [self connect];
}

#pragma mark - Actions
- (void)didSelectFormRow:(XLFormRowDescriptor *)formRow {
    [super didSelectFormRow:formRow];

    if ([formRow.tag isEqual:buttonCellTag]){
        [self connect];
        [self deselectFormRow:formRow];
    } else if ([formRow.tag isEqual:cancelTag]) {
        [self cancel];
        [self deselectFormRow:formRow];
    }
}

- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue {

    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];

    if ([formRow.tag isEqual:userTag]) {
        self.username = formRow.value;
    } else if ([formRow.tag isEqual:passwordTag]) {
        self.password = formRow.value;
    }
}

- (void)connect {
    if (!self.username || !self.password) {
        [[[UIAlertView alloc] initWithTitle:LOCALIZEDSTRING(@"ERROR")
                                    message:LOCALIZEDSTRING(@"FILLITALL")
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        return;
    }
    void (^success)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        User *user = [User withEmail:[response objectForKey:@"email"] andToken:[response objectForKey:@"token"]];
        self.user = user;
        [self endLoginWithSuccess:true];
    };
    void (^failure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:LOCALIZEDSTRING(@"ERROR")
                                    message:error.localizedDescription
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        [self endLoginWithSuccess:false];
    };
    [DejalActivityView activityViewForView:self.view withLabel:LOCALIZEDSTRING(@"CONNECTING")].showNetworkActivityIndicator = YES;
    [IOSRequest loginWithId:self.username andPassword:self.password onSuccess:success onFailure:failure];
}

- (void) endLoginWithSuccess:(BOOL)success {
    if (success) {
        [CloudKeychainManager saveToken:_user.token forEmail:_user.email];
        [self checkLogin];
    } else {
        [DejalActivityView removeView];
    }

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
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        [self presentViewController:[sb instantiateViewControllerWithIdentifier:@"RevealViewController"] animated:YES completion:nil];
    };
    void (^failure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:LOCALIZEDSTRING(@"ERROR")
                                    message:error.localizedDescription
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        [DejalActivityView removeView];
    };
    [IOSRequest getCurrentUserOnSuccess:success onFailure:failure];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
