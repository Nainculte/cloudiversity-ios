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

@interface AgendaTeacherViewController ()

@property (nonatomic, strong) HTTPSuccessHandler success;
@property (nonatomic, strong) HTTPFailureHandler failure;

@end

@implementation AgendaTeacherViewController

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

    [self setupHandlers];
    self.sections = [NSMutableDictionary dictionary];

    if ([[EGOCache globalCache] hasCacheForKey:@"disciplinesTeacher"]) {
        [self.tableView reloadData];
    } else {
        [self initAssignmentsByHTTPRequest];
    }
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.revealViewController.rightViewController = nil;
    if ([self.view.gestureRecognizers indexOfObject:self.revealViewController.panGestureRecognizer] == NSNotFound) {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (void)initAssignmentsByHTTPRequest
{
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading..."].showNetworkActivityIndicator = YES;
    [IOSRequest getAssignmentsForUserOnSuccess:self.success onFailure:self.failure];
}

- (void)setupHandlers
{
    BSELF(self)
    self.success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *response = (NSArray *)responseObject;
        NSLog(@"%@", response);
        NSMutableDictionary *disciplines = [NSMutableDictionary dictionary];

        for (NSDictionary *discipline in response) {
            [disciplines setObject:discipline forKey:[discipline objectForKey:@"name"]];
        }
        [[EGOCache globalCache] setData:[NSKeyedArchiver archivedDataWithRootObject:disciplines] forKey:@"disciplinesTeacher"];
        [[EGOCache globalCache] setData:[NSKeyedArchiver archivedDataWithRootObject:response] forKey:@"disciplinesArray"];
        bself.sections = disciplines;
        bself.sortedSections = response;
		[bself.tableView reloadData];
        [DejalActivityView removeView];
        [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
    };
    self.failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        switch (operation.response.statusCode) {
            default:
                break;
        }
        [DejalActivityView removeView];
        [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadTableView
{
    [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:YES];
    [IOSRequest getAssignmentsForUserOnSuccess:self.success onFailure:self.failure];
}

- (NSString *)reuseIdentifier
{
    return @"AgendaTeacherCell";
}

+ (Class)cellClass
{
    return [AgendaTeacherTableViewCell class];
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
    NSString *headerTitle = [[self.sortedSections objectAtIndex:section] objectForKey:@"name"];
    label.text = headerTitle;
	label.font = [UIFont fontWithName:@"FiraSansOt-Bold" size:label.font.pointSize];
    [view addSubview:label];
    view.backgroundColor = [UIColor cloudGrey];
    return view;
}

- (void)setupCell:(UITableViewCell *)c withIndexPath:(NSIndexPath *)indexPath
{
    AgendaTeacherTableViewCell *cell = (AgendaTeacherTableViewCell *)c;

    cell.classLabel.text = [[[[self.sortedSections objectAtIndex:indexPath.section] objectForKey:@"school_classes"] objectAtIndex:indexPath.row] objectForKey:@"name"];
    int nbr = [[[[[self.sortedSections objectAtIndex:indexPath.section] objectForKey:@"school_classes"] objectAtIndex:indexPath.row] valueForKey:@"assignment_count"] intValue];
    if (nbr <= 1) {
        cell.assignmentsLabel.text = [NSString stringWithFormat:@"%d assignment", nbr];
    } else {
        cell.assignmentsLabel.text = [NSString stringWithFormat:@"%d assignments", nbr];
    }
}

- (void)tableViewWillReloadData:(UITableView *)tableView
{
    if ([[EGOCache globalCache] hasCacheForKey:@"disciplinesTeacher"]) {
        NSMutableDictionary *disciplines = [NSKeyedUnarchiver unarchiveObjectWithData:[[EGOCache globalCache] dataForKey:@"disciplinesTeacher"]];
        NSArray *disciplinesArray = [NSKeyedUnarchiver unarchiveObjectWithData:[[EGOCache globalCache] dataForKey:@"disciplinesArray"]];
        if (disciplines && disciplinesArray) {
            self.sections = disciplines;
            self.sortedSections = disciplinesArray;
        }
    }
}

- (void)tableViewDidReloadData:(UITableView *)tableView
{
    [self.refreshControl endRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.sortedSections objectAtIndex:section] objectForKey:@"school_classes"] count];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AssignmentsByClass"]) {
        AgendaTeacherClassViewController *dest = segue.destinationViewController;

        NSIndexPath *path  = [self.tableView indexPathForSelectedRow];
        NSDictionary *discipline = [self.sortedSections objectAtIndex:path.section];
        dest.disciplineTitle = [discipline objectForKey:@"name"];
        dest.disciplineID = [[discipline objectForKey:@"id"] intValue];
        NSDictionary *class = [[discipline objectForKey:@"school_classes"] objectAtIndex:path.row];
        dest.classTitle = [class objectForKey:@"name"];
        dest.classID = [[class objectForKey:@"id"] intValue];
    }
}

@end
