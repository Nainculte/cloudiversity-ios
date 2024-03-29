//
//  AgendaTeacherViewController.m
//  Cloudiversity
//
//  Created by Nainculte on 14/07/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AgendaTeacherViewController.h"
#import "AgendaTeacherTableViewCell.h"
#import "AgendaTeacherClassViewController.h"

#define LOCALIZEDSTRING(s) [[NSBundle mainBundle] localizedStringForKey:s value:@"Localization error" table:@"AgendaTeacherVC"]

@interface AgendaTeacherViewController ()

@property (nonatomic, strong) HTTPSuccessHandler success;
@property (nonatomic, strong) HTTPFailureHandler failure;

@end

@implementation AgendaTeacherViewController

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupHandlers];
    self.sections = [NSMutableDictionary dictionary];

	[self initAssignmentsByHTTPRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.revealViewController.rightViewController = nil;
    if ([self.view.gestureRecognizers indexOfObject:self.revealViewController.panGestureRecognizer] == NSNotFound) {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

#pragma mark - HTTP handlers
- (void)initAssignmentsByHTTPRequest
{
    [DejalBezelActivityView activityViewForView:self.view withLabel:LOCALIZEDSTRING(@"LOADING")].showNetworkActivityIndicator = YES;
    [[NetworkManager manager] getAssignmentsForUserOnSuccess:self.success onFailure:self.failure];
}

- (void)setupHandlers
{
    BSELF(self)
    self.success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *response = (NSArray *)responseObject;
        NSMutableDictionary *disciplines = [NSMutableDictionary dictionary];

        for (NSDictionary *discipline in response) {
            disciplines[discipline[@"name"]] = discipline;
        }
        bself.sections = disciplines;
        bself.sortedSections = response;
		[bself.tableView reloadData];
        [DejalActivityView removeView];
        [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
    };
    self.failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:LOCALIZEDSTRING(@"AGENDA_TEACHER_ERROR")
                                    message:error.localizedDescription
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        [DejalActivityView removeView];
        [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
    };
}

#pragma mark - UITableView Delegate / DataSource
- (CGFloat)tableView:(UITableView *)tableView HeightForHeaderInSection:(NSInteger)section
{
    return 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    /* Create custom view to display section header... */
    CloudLabel *label = [[CloudLabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 25)];
    NSString *headerTitle = (self.sortedSections)[section][@"name"];
    label.text = headerTitle;
	label.font = [UIFont fontWithName:@"FiraSansOt-Bold" size:label.font.pointSize];
    [view addSubview:label];
    view.backgroundColor = [UIColor cloudGrey];
    return view;
}

- (void)setupCell:(UITableViewCell *)c withIndexPath:(NSIndexPath *)indexPath
{
    AgendaTeacherTableViewCell *cell = (AgendaTeacherTableViewCell *)c;

    cell.classLabel.text = (self.sortedSections)[indexPath.section][@"school_classes"][indexPath.row][@"name"];
    NSInteger nbr = [[(self.sortedSections)[indexPath.section][@"school_classes"][indexPath.row] valueForKey:@"assignment_count"] integerValue];
    if (nbr <= 1) {
        cell.assignmentsLabel.text = [NSString stringWithFormat:@"%@ %@", @(nbr), LOCALIZEDSTRING(@"ASSIGNMENT")];
    } else {
        cell.assignmentsLabel.text = [NSString stringWithFormat:@"%@ %@", @(nbr), LOCALIZEDSTRING(@"ASSIGNMENTS")];
    }
}

- (void)tableViewWillReloadData:(UITableView *)tableView
{
}

- (void)tableViewDidReloadData:(UITableView *)tableView
{
    [self.refreshControl endRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(self.sortedSections)[section][@"school_classes"] count];
}


- (void)reloadTableView
{
    [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:YES];
    [[NetworkManager manager] getAssignmentsForUserOnSuccess:self.success onFailure:self.failure];
}

- (NSString *)reuseIdentifier
{
    return @"AgendaTeacherCell";
}

+ (Class)cellClass
{
    return [AgendaTeacherTableViewCell class];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AssignmentsByClass"]) {
        AgendaTeacherClassViewController *dest = segue.destinationViewController;

        NSIndexPath *path  = [self.tableView indexPathForSelectedRow];
        NSDictionary *discipline = (self.sortedSections)[path.section];
        dest.disciplineTitle = discipline[@"name"];
        dest.disciplineID = [discipline[@"id"] integerValue];
        NSDictionary *class = discipline[@"school_classes"][path.row];
        dest.classTitle = class[@"name"];
        dest.classID = [class[@"id"] integerValue];
    }
}

@end
