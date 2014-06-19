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
#import "SWRevealViewController.h"
#import "UIColor+Cloud.h"

#define LOCALIZEDSTRING(s) [[NSBundle mainBundle] localizedStringForKey:s value:@"Localization error" table:@"HomeScreenVC"]

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
    NSString *path = [[NSBundle mainBundle] pathForResource:@"HomeScreenVC" ofType:@"strings"];
    NSDictionary *d =  [NSDictionary dictionaryWithContentsOfFile:path];
    NSLog(@"%@ -> %@", path, d);
    self.title = LOCALIZEDSTRING(@"TITLE");


    self.leftButton.target = self.revealViewController;
    self.leftButton.action = @selector(revealToggle:);

    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    self.view.backgroundColor = [UIColor cloudGrey];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor cloudLightBlue]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor cloudLightBlue]];
    self.leftButton.tintColor = [UIColor whiteColor];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
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
