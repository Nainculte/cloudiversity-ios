//
//  HomeScreenViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 18/04/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "HomeScreenViewController.h"
#import "AgendaViewController.h"
#import "AuthenticationViewController.h"

#define LOCALIZEDString(s) [[NSBundle mainBundle] localizedStringForKey:s value:@"Unknown error" table:@"HomeScreenVC"]

@interface HomeScreenViewController ()

@end

@implementation HomeScreenViewController

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
    // Do any additional setup after loading the view.
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

- (IBAction)logOut:(id)sender {
	NSLog(@"Log out...");
	
	// ereasing userDefaults
	NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	[userDefault setObject:nil forKey:DEFAULT_LOG_USER_KEY];
	[userDefault setObject:nil forKey:DEFAULT_PASS_USER_KEY];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)goToCahierDeTexte:(id)sender {
	UIStoryboard *agendaSBoard = [UIStoryboard storyboardWithName:@"AgendaStoryboard" bundle:nil];
	AgendaViewController *agendaVController = (AgendaViewController*)[agendaSBoard instantiateInitialViewController];
	[self presentViewController:agendaVController animated:YES completion:nil];
}

@end
