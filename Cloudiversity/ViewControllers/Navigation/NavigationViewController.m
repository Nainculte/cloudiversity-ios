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
    agendaTeacher,
    evaluation
} ;

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cloudDarkGrey];

    [self initRoleSwitcher];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initRoleSwitcher];
}

#pragma Role management
- (void)initRoleSwitcher {
	User *user = [User sharedUser];
	if (user.roles.count > 1) {
		[self.roleSwitcher addTarget:self action:@selector(changeRole) forControlEvents:UIControlEventValueChanged];
		[self.roleSwitcher removeAllSegments];
		NSUInteger idx = 0;
		self.roleSwitcher.selectedSegmentIndex = 0;
		for (NSString *title in user.localizedRoles) {
			[self.roleSwitcher insertSegmentWithTitle:title atIndex:idx animated:NO];
			if ([user.currentRole isEqualToString:user.roles[idx]]) {
				user.currentRole = user.roles[idx];
				self.roleSwitcher.selectedSegmentIndex = idx;
			}
			idx++;
		}
		self.roleSwitcher.hidden = NO;
	} else {
		self.roleSwitcher.hidden = YES;
	}
	self.agendaButton.hidden = !user.roles.count || [user.currentRole isEqualToString:@"Admin"] || [user.currentRole isEqualToString:@"Parent"];
}

- (void)changeRole {
	User *user = [User sharedUser];
	user.currentRole = user.roles[self.roleSwitcher.selectedSegmentIndex];
	if (!user.roles.count || [user.currentRole isEqualToString:@"Admin"] || [user.currentRole isEqualToString:@"Parent"]) {
		self.agendaButton.hidden = YES;
	} else {
		self.agendaButton.hidden = NO;
	}
	
	switch (self.current) {
		case agendaStudent:
			if ([user.currentRole isEqualToString:@"Teacher"]) {
				[self performSegueWithIdentifier:@"AgendaTeacher" sender:self];
			} else {
				[self performSegueWithIdentifier:@"HomeScreen" sender:self];
			}
			break;
		case agendaTeacher:
			if ([user.currentRole isEqualToString:@"Student"]) {
				[self performSegueWithIdentifier:@"AgendaStudent" sender:self];
			} else {
				[self performSegueWithIdentifier:@"HomeScreen" sender:self];
			}
			break;
	}
	//do stuff to change the front view controller depending on the role
}

#pragma mark - Navigation
- (IBAction)agendaClicked:(id)sender {
    if ([[User sharedUser].currentRole isEqualToString:@"Student"]) {
        [self performSegueWithIdentifier:@"AgendaStudent" sender:sender];
    } else {
        [self performSegueWithIdentifier:@"AgendaTeacher" sender:sender];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *dest = (UINavigationController *)segue.destinationViewController;

    if ([segue.identifier isEqualToString:@"AgendaStudent"]) {
        dest.title = LOCALIZEDSTRING(@"AGENDA_TITLE");
        self.current = agendaStudent;
    } else if ([segue.identifier isEqualToString:@"Evaluation"]) {
        dest.title = @"Evaluation";
        self.current = evaluation;
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
			[navController setViewControllers:@[dest] animated: NO ];
            if (sender != self)
                [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated: YES];
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

#pragma mark - Styling
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
