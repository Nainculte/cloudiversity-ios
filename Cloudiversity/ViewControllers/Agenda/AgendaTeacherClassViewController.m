//
//  AgendaTeacherClassViewController.m
//  Cloudiversity
//
//  Created by Nainculte on 20/07/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AgendaTeacherClassViewController.h"
#import "AgendaTeacherClassTableViewCell.h"
#import "AgendaTeacherEditAssignmentViewController.h"
#import "CloudDateConverter.h"

#define LOCALIZEDSTRING(s) [[NSBundle mainBundle] localizedStringForKey:s value:@"Localization error" table:@"AgendaTeacherVC"]

#define DICO_ID					@"id"
#define DICO_TITLE 				@"title"
#define DICO_DEADLINE 			@"deadline"
#define DICO_DUETIME 			@"duetime"
#define DICO_PROGRESS 			@"progress"
#define DICO_DISCIPLINE 		@"discipline"
#define DICO_DISCIPLINE_ID			@"id"
#define DICO_DISCIPLINE_NAME		@"name"

@interface AgendaTeacherClassViewController ()

@property (nonatomic, strong) HTTPSuccessHandler success;
@property (nonatomic, strong) HTTPFailureHandler failure;

@end

@implementation AgendaTeacherClassViewController

#pragma mark View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view removeGestureRecognizer:self.revealViewController.panGestureRecognizer];

    self.assignments = [NSMutableArray array];

    [self setupTitle];
    [self setupHandlers];

    NSString *key = [NSString stringWithFormat:@"%@/%@", self.disciplineTitle, self.classTitle];
    if ([[EGOCache globalCache] hasCacheForKey:key]) {
        self.assignments = [NSKeyedUnarchiver unarchiveObjectWithData:[[EGOCache globalCache] dataForKey:key]];

        [self.tableView reloadData];
    } else {
        [self initAssignmentsByHTTPRequest];
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[EGOCache globalCache] setData:[NSKeyedArchiver archivedDataWithRootObject:self.assignments] forKey:[NSString stringWithFormat:@"%@/%@", self.disciplineTitle, self.classTitle]];
}

#pragma mark - Styling
- (void)setupTitle
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 136, 44)];
    view.backgroundColor = [UIColor clearColor];

    UILabel *discipline = [[UILabel alloc] initWithFrame:CGRectMake(0, (view.frame.size.height * 2/3) - 8, view.frame.size.width, (view.frame.size.height / 3) + 4)];
    discipline.backgroundColor = [UIColor clearColor];
    discipline.text = self.disciplineTitle;
    discipline.textColor = [UIColor whiteColor];
    discipline.textAlignment = NSTextAlignmentCenter;
    [view addSubview:discipline];

    UILabel *class = [[UILabel alloc] initWithFrame:CGRectMake(0, -4, view.frame.size.width, view.frame.size.height * 2/3)];
    class.backgroundColor = [UIColor clearColor];
    class.text = self.classTitle;
    class.textColor = [UIColor whiteColor];
    class.textAlignment = NSTextAlignmentCenter;
    class.font = [UIFont boldSystemFontOfSize: 17.0];
    [view addSubview:class];

    self.navigationItem.titleView = view;
}

#pragma mark - HTTP handlers
- (void)setupHandlers
{
    BSELF(self)

    self.success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *response = responseObject;

        [bself.assignments removeAllObjects];
        for (NSDictionary *assignmentDico in response) {
            NSString *dueTimeString = ([assignmentDico[DICO_DUETIME] class] == [NSNull class] ? [CloudDateConverter nullTime] : assignmentDico[DICO_DUETIME]);
            NSString *fullDateAndTime = [NSString stringWithFormat:@"%@ %@", assignmentDico[DICO_DEADLINE], dueTimeString];
            AgendaAssignment *assignment = [[AgendaAssignment alloc] initWithTitle:assignmentDico[DICO_TITLE]
                                                                            withId:[assignmentDico[DICO_ID] integerValue] dueDate:[[CloudDateConverter sharedMager] dateAndTimeFromString:fullDateAndTime]
                                                                      timePrecised:[assignmentDico[DICO_DUETIME] class] == [NSNull class] ? NO : YES
                                                                          progress:[assignmentDico[DICO_PROGRESS] integerValue]
                                                                     forDissipline:assignmentDico[DICO_DISCIPLINE]];
            [bself.assignments addObject:assignment];
        }

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

- (void)initAssignmentsByHTTPRequest
{
    [DejalBezelActivityView activityViewForView:self.view withLabel:LOCALIZEDSTRING(@"LOADING")].showNetworkActivityIndicator = YES;
    [[NetworkManager manager] getAssignmentsForClass:self.classID andDiscipline:self.disciplineID onSuccess:self.success onFailure:self.failure];
}

#pragma mark - Generate sections / Sort assignments
- (void)sortAssignments
{
    self.sections = [NSMutableDictionary dictionary];
    self.sortedSections = @[];

    for (AgendaAssignment *assignment in self.assignments) {
        NSDate* date = [[CloudDateConverter sharedMager] convertDate:assignment.dueDate toFormat:CloudDateConverterFormatDate];

        NSMutableArray *assignmentsByDatesArray = (self.sections)[date];

        if (assignmentsByDatesArray == nil) {
            assignmentsByDatesArray = [NSMutableArray array];
            (self.sections)[date] = assignmentsByDatesArray;
        }

        [assignmentsByDatesArray addObject:assignment];
    }
    // Sorting keys from  earliest to latest
    self.sortedSections = [self.sections allKeys];
    self.sortedSections = [self.sortedSections sortedArrayUsingSelector:@selector(compare:)];

    // Sorting assignments of each array by dueTime

    for (NSDate *date in self.sortedSections) {
        NSArray *assignments = (self.sections)[date];

        assignments = [assignments sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            AgendaAssignment *assignment1 = (AgendaAssignment *)obj1;
            AgendaAssignment *assignment2 = (AgendaAssignment *)obj2;

            NSDate *date1 = [[CloudDateConverter sharedMager] convertDate:assignment1.dueDate toFormat:CloudDateConverterFormatTime];
            NSDate *date2 = [[CloudDateConverter sharedMager] convertDate:assignment2.dueDate toFormat:CloudDateConverterFormatTime];

            return [date1 compare:date2];
        }];

        // remove the unsorted array...
        [self.sections removeObjectForKey:date];
        // ...then replace it by the sorted one
        (self.sections)[date] = assignments;
    }
}

#pragma mark - UITableView Delegate / DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 18;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    CloudLabel *label = [[CloudLabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    NSString *headerTitle = [[CloudDateConverter sharedMager] stringFromDate:(self.sortedSections)[section]];
    label.text = headerTitle;
    [view addSubview:label];
    view.backgroundColor = [UIColor cloudGrey];
    return view;
}

- (void)setupCell:(UITableViewCell *)c withIndexPath:(NSIndexPath *)indexPath
{
    AgendaTeacherClassTableViewCell *cell = (AgendaTeacherClassTableViewCell *)c;
    AgendaAssignment *assignment = [self assignmentForIndexPath:indexPath];

    cell.workTitle.text = assignment.title;
    cell.dueLabel.text = [[CloudDateConverter sharedMager] stringFromDate:assignment.dueDate];
}

- (void)tableViewWillReloadData:(UITableView *)tableView
{
    [self sortAssignments];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.editedAssignment = [self assignmentForIndexPath:indexPath];
    [self.assignments removeObject:self.editedAssignment];
    HTTPSuccessHandler success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        self.editedAssignment.assignmentDescription = ((NSDictionary *)(responseObject))[@"wording"];
        AgendaTeacherEditAssignmentViewController *vc = [[AgendaTeacherEditAssignmentViewController alloc] initWithDisciplineID:self.disciplineID withClassID:self.classID andAssignment:self.editedAssignment presenter:self];
        [self presentViewController:vc animated:YES completion:^{
            //self.editedAssignment = vc.assignment;
        }];
        [DejalActivityView removeView];
        [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
    };

    HTTPFailureHandler failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalActivityView removeView];
        [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
    };
    [DejalBezelActivityView activityViewForView:self.view withLabel:LOCALIZEDSTRING(@"LOADING")].showNetworkActivityIndicator = YES;
    [[NetworkManager manager] getAssignmentInformation:self.editedAssignment.assignmentId onSuccess:success onFailure:failure];
}

- (void)tableViewDidReloadData:(UITableView *)tableView
{
    [self.refreshControl endRefreshing];
}

- (void)reloadTableView {
    [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:YES];
    [[NetworkManager manager] getAssignmentsForClass:self.classID andDiscipline:self.disciplineID onSuccess:self.success onFailure:self.failure];
}

- (NSString *)reuseIdentifier
{
    return @"AgendaTeacherAssignments";
}

+ (Class)cellClass
{
    return [AgendaTeacherClassTableViewCell class];
}

#pragma mark - Convenience methods
- (NSArray*)getArrayOfAssignmentsForPosition:(NSInteger)position {
    return (self.sections)[(self.sortedSections)[position]];
}

- (AgendaAssignment*)assignmentInArrayOfAssignements:(NSArray*)assignments
                                          atPosition:(NSInteger)position
{
    return assignments[position];
}

- (AgendaAssignment*)assignmentForIndexPath:(NSIndexPath*)indexPath {
    NSArray *assignments = [self getArrayOfAssignmentsForPosition:indexPath.section];

    AgendaAssignment *assignment;
    assignment = [self assignmentInArrayOfAssignements:assignments atPosition:indexPath.row];
    return assignment;
}


#pragma mark - Navigation

- (IBAction)newAssignment:(UIBarButtonItem *)sender {
    AgendaTeacherEditAssignmentViewController *vc = [[AgendaTeacherEditAssignmentViewController alloc] initWithDisciplineID:self.disciplineID withClassID:self.classID andAssignment:nil presenter:self];
    [self presentViewController:vc animated:YES completion:^{}];
}

@end
