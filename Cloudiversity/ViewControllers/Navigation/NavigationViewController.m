//
//  NavigationViewController.m
//  Cloudiversity
//
//  Created by Nainculte on 6/17/14.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "NavigationViewController.h"
#import "SWRevealViewController.h"
#import "AgendaStudentViewController.h"
#import "UIColor+Cloud.h"
#import "UICloud.h"
#import "User.h"
#import "CloudKeychainManager.h"
#import "ServerViewController.h"

#define LOCALIZEDSTRING(s) [[NSBundle mainBundle] localizedStringForKey:s value:@"Localization error" table:@"NavigationVC"]

@interface NavigationViewController ()

@property (nonatomic, assign) NSInteger current;

- (IBAction)agendaClicked:(id)sender;

@end

@implementation NavigationViewController

typedef NS_ENUM(NSInteger, state) {
    homeScreen = 0,
    agendaStudent,
    agendaTeacher
} ;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    self.view.backgroundColor = [UIColor cloudDarkGrey];

    [self initRoleSwitcher];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initRoleSwitcher];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initRoleSwitcher {
    User *user = [User sharedUser];
    if (user.roles.count > 1) {
        [self.roleSwitcher addTarget:self action:@selector(changeRole) forControlEvents:UIControlEventValueChanged];
        [self.roleSwitcher removeAllSegments];
        for (NSInteger i = 0; i < user.localizedRoles.count; i++) {
            NSString *title = user.localizedRoles[i];
            [self.roleSwitcher insertSegmentWithTitle:title atIndex:i animated:NO];
            if ([user.currentRole isEqualToString:user.roles[i]]) {
                self.roleSwitcher.selectedSegmentIndex = i;
            }
        }
        self.roleSwitcher.hidden = NO;
    } else {
        self.roleSwitcher.hidden = YES;
    }
    user.currentRole = user.localizedRoles[self.roleSwitcher.selectedSegmentIndex];
    if (!user.roles.count || [user.currentRole isEqualToString:LOCALIZEDSTRING(@"ROLE_ADMIN")] || [user.currentRole isEqualToString:LOCALIZEDSTRING(@"ROLE_PARENT")]) {
        self.agendaButton.hidden = YES;
    } else {
        self.agendaButton.hidden = NO;
    }
}

- (void)changeRole {
    User *user = [User sharedUser];
    user.currentRole = user.roles[self.roleSwitcher.selectedSegmentIndex];
    if (!user.roles.count || [user.currentRole isEqualToString:LOCALIZEDSTRING(@"ROLE_ADMIN")] || [user.currentRole isEqualToString:LOCALIZEDSTRING(@"ROLE_PARENT")]) {
        self.agendaButton.hidden = YES;
    } else {
        self.agendaButton.hidden = NO;
    }

    switch (self.current) {
        case agendaStudent:
            if ([user.currentRole isEqualToString:LOCALIZEDSTRING(@"ROLE_TEACHER")]) {
                [self performSegueWithIdentifier:@"AgendaTeacher" sender:self];
            } else {
                [self performSegueWithIdentifier:@"HomeScreen" sender:self];
            }
            break;
        case agendaTeacher:
            if ([user.currentRole isEqualToString:LOCALIZEDSTRING(@"ROLE_STUDENT")]) {
                [self performSegueWithIdentifier:@"AgendaStudent" sender:self];
            } else {
                [self performSegueWithIdentifier:@"HomeScreen" sender:self];
            }
            break;
    }

    //do stuff to change the front view controller depending on the role
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *dest = (UINavigationController *)segue.destinationViewController;

    if ([segue.identifier isEqualToString:@"AgendaStudent"]) {
        dest.title = LOCALIZEDSTRING(@"AGENDA_TITLE");
        self.current = agendaStudent;
    } else if ([segue.identifier isEqualToString:@"AgendaTeacher"]) {
        dest.title = LOCALIZEDSTRING(@"AGENDA_TITLE");
        self.current = agendaTeacher;
    } else if ([segue.identifier isEqualToString:@"HomeScreen"]) {
        self.current = homeScreen;
    }

    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;

        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* source, UIViewController* dest) {

            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dest] animated: NO ];
            if (sender != self)
                [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };

    }
}
- (IBAction)disconnect {
    self.current = homeScreen;
    User *u = [User sharedUser];
    [CloudKeychainManager deleteTokenWithEmail:u.email];
    [u deleteUser];
    ServerRootViewController *vc = [[ServerRootViewController alloc] init];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)agendaClicked:(id)sender {
    if ([[User sharedUser].currentRole isEqualToString:LOCALIZEDSTRING(@"ROLE_STUDENT")]) {
        [self performSegueWithIdentifier:@"AgendaStudent" sender:sender];
    } else {
        [self performSegueWithIdentifier:@"AgendaTeacher" sender:sender];
    }
}
@end
