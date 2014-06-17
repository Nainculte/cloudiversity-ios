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

    self.menuItems = [NSMutableArray arrayWithObjects:@"cloudiversity", @"agenda", @"disconnect", nil];
    self.view.backgroundColor = [UIColor cloudDarkGrey];
    self.tableView.backgroundColor = [UIColor cloudDarkGrey];
    self.tableView.separatorColor = [UIColor cloudLightBlack];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath* path = [self.tableView indexPathForSelectedRow];
    UINavigationController *dest = (UINavigationController *)segue.destinationViewController;
    dest.title = [[self.menuItems objectAtIndex:path.row] capitalizedString];

    if ([segue.identifier isEqualToString:@"Agenda"]) {

    } else if ([segue.identifier isEqualToString:@"HomeScreen"]) {
        
    } else if ([segue.identifier isEqualToString:@"disconnect"]) {
        //virer les credentials
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor cloudDarkGrey];
    return cell;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
