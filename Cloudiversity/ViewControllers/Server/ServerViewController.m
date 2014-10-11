//
//  ServerViewController.m
//  Cloudiversity
//
//  Created by Nainculte on 6/19/14.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "ServerViewController.h"
#import "IOSRequest.h"
#import "CloudLogoCell.h"
#import "CloudURLCellPicker.h"
#import "UIColor+Cloud.h"
#import "DejalActivityView.h"
#import "CloudiversityAppDelegate.h"
#import "AuthenticationViewController.h"
#import "CloudSeparatorCell.h"

#define LOCALIZEDSTRING(s) [[NSBundle mainBundle] localizedStringForKey:s value:@"Localization error" table:@"ServerVC"]

#pragma mark - ServerRootViewController
@interface ServerRootViewController ()

@end

@implementation ServerRootViewController

- (id)init {
    ServerViewController *vc = [[ServerViewController alloc] init];
    self = [super initWithRootViewController:vc];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationBar.translucent = NO;
    self.navigationBar.hidden = YES;
    [self.navigationBar setBackgroundColor:[UIColor cloudLightBlue]];
    [self.navigationBar setBarTintColor:[UIColor cloudLightBlue]];
    self.navigationBar.tintColor = [UIColor whiteColor];
}

@end

#pragma mark - ServerViewController
@interface ServerViewController () <CloudURLCellPickerDelegate>

@property (nonatomic, strong)NSString *server;

@end

@implementation ServerViewController

NSString *const logoTag = @"Logo";
NSString *const URLTag = @"URL";
NSString *const buttonTag = @"Button";
NSString *const sepTag = @"Sep";

#pragma mark - Initialization

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
    row = [XLFormRowDescriptor formRowDescriptorWithTag:logoTag rowType:@"CloudLogoCell"];
    row.cellClass = [CloudLogoCell class];
    [section addFormRow:row];

    //URL picker
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:sepTag rowType:@"CloudSeparatorCell"];
    row.cellClass = [CloudSeparatorCell class];
    [section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:URLTag rowType:@"CloudURLCellPicker"];
    row.cellClass = [CloudURLCellPicker class];
    [row.cellConfigAtConfigure setObject:LOCALIZEDSTRING(@"ADDRESS") forKey:@"rightTextField.placeholder"];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *server = [defaults objectForKey:@"server"];
    NSRange range;
    if (!server || [server isEqualToString:@""]) {
        [row.cellConfigAtConfigure setObject:@0 forKey:@"selectedIndex"];
    } else {
        if ((range = [server rangeOfString:@"http://"]).location == NSNotFound) {
            [row.cellConfigAtConfigure setObject:@0 forKey:@"selectedIndex"];
            [row.cellConfigAtConfigure setObject:[server substringFromIndex:8] forKey:@"text"];
        } else {
            [row.cellConfigAtConfigure setObject:@1 forKey:@"selectedIndex"];
            [row.cellConfigAtConfigure setObject:[server substringFromIndex:7] forKey:@"text"];
        }
    }
    [row.cellConfigAtConfigure setObject:self forKey:@"delegate"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:sepTag rowType:@"CloudSeparatorCell"];
    row.cellClass = [CloudSeparatorCell class];
    [section addFormRow:row];

    //Connect button
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:sepTag rowType:@"CloudSeparatorCell"];
    row.cellClass = [CloudSeparatorCell class];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:buttonTag rowType:XLFormRowDescriptorTypeButton title:LOCALIZEDSTRING(@"SERVER")];
    [row.cellConfigAtConfigure setObject:[UIColor cloudLightBlue] forKey:@"textLabel.textColor"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:sepTag rowType:@"CloudSeparatorCell"];
    row.cellClass = [CloudSeparatorCell class];
    [section addFormRow:row];

    self.form = form;
}

#pragma mark - CloudURLCellPickerDelegate

- (void)returnCell:(CloudURLCellPicker *)cell {
    [self chooseServer:cell.rowDescriptor.value];
}

#pragma mark - Actions
-(void)didSelectFormRow:(XLFormRowDescriptor *)formRow
{
    [super didSelectFormRow:formRow];

    if ([formRow.tag isEqual:buttonTag]){
        XLFormRowDescriptor *row = [self.form formRowWithTag:URLTag];
        [self chooseServer:row.value];
        [self deselectFormRow:formRow];
    }
}

- (void)chooseServer:(NSString *)adress {
    if (!adress) {
        [[[UIAlertView alloc] initWithTitle:LOCALIZEDSTRING(@"ERROR")
                                    message:LOCALIZEDSTRING(@"FILLITALL")
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        return;
    }
    self.server = adress;
    void (^success)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;

        [DejalActivityView removeView];
        [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
        if ([response objectForKey:@"version"]) {
            [self validURL];
            return ;
        }
        [self invalidURL];
    };
    void (^failure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalActivityView removeView];
        [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
        [self invalidURL];
    };
    [DejalActivityView activityViewForView:self.view withLabel:LOCALIZEDSTRING(@"CONNECTING")].showNetworkActivityIndicator = YES;
    [IOSRequest isCloudiversityServer:self.server onSuccess:success onFailure:failure];
}

- (void)saveServer {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.server forKey:@"server"];
    [defaults synchronize];
}

- (void)validURL {
    [self saveServer];
    AuthenticationRootViewController *vc = [[AuthenticationRootViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)invalidURL {
    [[[UIAlertView alloc] initWithTitle:LOCALIZEDSTRING(@"ERROR")
                                message:LOCALIZEDSTRING(@"INVALIDSERVER")
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

@end
