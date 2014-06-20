//
//  NavigationViewController.m
//  Cloudiversity
//
//  Created by Nainculte on 6/17/14.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "NavigationViewController.h"
#import "SWRevealViewController.h"
#import "AgendaViewController.h"
#import "UIColor+Cloud.h"
#import "User.h"
#import "CloudKeychainManager.h"

@interface NavigationViewController ()

@property (nonatomic, strong)NSMutableArray *menuItems;

@end

@implementation NavigationViewController

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
    self.view.backgroundColor = [UIColor cloudDarkGrey];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *dest = (UINavigationController *)segue.destinationViewController;

    if ([segue.identifier isEqualToString:@"Agenda"]) {
        dest.title = @"Agenda";
    } else if ([segue.identifier isEqualToString:@"HomeScreen"]) {
        dest.title = @"Home";
    } else if ([segue.identifier isEqualToString:@"Disconnect"]) {
        User *u = [User sharedUser];
        [CloudKeychainManager deleteTokenWithEmail:u.email];
        [u deleteUser];
    }

    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;

        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* source, UIViewController* dest) {

            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dest] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };

    }
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
