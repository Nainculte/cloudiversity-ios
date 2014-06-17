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

@interface NavigationViewController ()

@property (nonatomic, strong)NSMutableArray *menuItems;
@property (nonatomic, strong)NSMutableArray *menuSegues;

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

    self.menuItems = [NSMutableArray arrayWithObjects:@"cloudiversity", @"agenda", nil];
    self.menuSegues = [NSMutableArray arrayWithObjects:@"segueToHomeScreen", @"segueToAgenda", nil];
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

    return cell;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UIStoryboard *sb;
//    UIViewController *vc;
//    SWRevealViewControllerSegue *segue;
//    switch (indexPath.row) {
//        case 1:
//            sb = [UIStoryboard storyboardWithName:@"AgendaStoryboard" bundle:nil];
//            vc = [sb instantiateInitialViewController];
//            segue = [[SWRevealViewControllerSegue alloc] initWithIdentifier:@"Agenda"
//                                                                     source:self
//                                                                destination:vc];
//            break;
//
//        default:
//            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeScreenViewController"];
//            segue = [[SWRevealViewControllerSegue alloc] initWithIdentifier:@"Homescreen"
//                                                                     source:self
//                                                                destination:vc];
//            break;
//    }
//    [segue perform];
//    
//}
//
//- (void)segueToHomeScreen
//{
//    UIVideoEditorController *HomeScreenVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeScreenViewController"];
//    SWRevealViewControllerSegue *segue = [[SWRevealViewControllerSegue alloc] initWithIdentifier:@"Homescreen"
//                                                                                          source:self
//                                                                                     destination:HomeScreenVC];
//    [segue perform];
//}
//
//- (void)segueToAgenda
//{
//    UIStoryboard *agendaSBoard = [UIStoryboard storyboardWithName:@"AgendaStoryboard" bundle:nil];
//	UIViewController *agendaVC = (AgendaViewController*)[agendaSBoard instantiateInitialViewController];
//    SWRevealViewControllerSegue *segue = [[SWRevealViewControllerSegue alloc] initWithIdentifier:@"Agenda"
//                                                                                          source:self
//                                                                                     destination:agendaVC];
//    [segue perform];
//}

@end
