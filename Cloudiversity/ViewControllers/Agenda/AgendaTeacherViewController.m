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
    [DejalBezelActivityView activityViewForView:self.view withLabel:LOCALIZEDSTRING(@"LOADING")].showNetworkActivityIndicator = YES;
    [IOSRequest getAssignmentsForUserOnSuccess:self.success onFailure:self.failure];
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
        [[EGOCache globalCache] setData:[NSKeyedArchiver archivedDataWithRootObject:disciplines] forKey:@"disciplinesTeacher"];
        [[EGOCache globalCache] setData:[NSKeyedArchiver archivedDataWithRootObject:response] forKey:@"disciplinesArray"];
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
    return 18;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    CloudLabel *label = [[CloudLabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    NSString *headerTitle = (self.sortedSections)[section][@"name"];
    label.text = headerTitle;
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
        cell.assignmentsLabel.text = [NSString stringWithFormat:@"%d %@", nbr, LOCALIZEDSTRING(@"ASSIGNMENT")];
    } else {
        cell.assignmentsLabel.text = [NSString stringWithFormat:@"%d %@", nbr, LOCALIZEDSTRING(@"ASSIGNMENTS")];
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
    return [(self.sortedSections)[section][@"school_classes"] count];
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
