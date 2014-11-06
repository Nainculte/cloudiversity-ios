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

- (IBAction)newAssignment:(UIBarButtonItem *)sender;
@end

@implementation AgendaTeacherClassViewController

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

- (void)setupHandlers
{
    BSELF(self)

    self.success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *response = responseObject;

        [bself.assignments removeAllObjects];
        for (NSDictionary *assignmentDico in response) {
            NSString *dueTimeString = ([[assignmentDico objectForKey:DICO_DUETIME] class] == [NSNull class] ? [CloudDateConverter nullTime] : [assignmentDico objectForKey:DICO_DUETIME]);
            NSString *fullDateAndTime = [NSString stringWithFormat:@"%@ %@", [assignmentDico objectForKey:DICO_DEADLINE], dueTimeString];
            AgendaAssignment *assignment = [[AgendaAssignment alloc] initWithTitle:[assignmentDico objectForKey:DICO_TITLE]
                                                                            withId:[[assignmentDico objectForKey:DICO_ID] intValue] dueDate:[[CloudDateConverter sharedMager] dateAndTimeFromString:fullDateAndTime]
                                                                      timePrecised:[[assignmentDico objectForKey:DICO_DUETIME] class] == [NSNull class] ? NO : YES
                                                                          progress:[[assignmentDico objectForKey:DICO_PROGRESS] intValue]
                                                                     forDissipline:[assignmentDico objectForKey:DICO_DISCIPLINE]];
            [bself.assignments addObject:assignment];
        }

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

- (void)initAssignmentsByHTTPRequest
{
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading..."].showNetworkActivityIndicator = YES;
    [IOSRequest getAssignmentsForClass:self.classID andDiscipline:self.disciplineID onSuccess:self.success onFailure:self.failure];
}

- (void)reloadTableView {
    [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:YES];
    [IOSRequest getAssignmentsForClass:self.classID andDiscipline:self.disciplineID onSuccess:self.success onFailure:self.failure];
}

- (NSString *)reuseIdentifier
{
    return @"AgendaTeacherAssignments";
}

+ (Class)cellClass
{
    return [AgendaTeacherClassTableViewCell class];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Generate sections / Sort assignments

- (void)sortAssignments
{
    self.sections = [NSMutableDictionary dictionary];
    self.sortedSections = [NSArray array];

    for (AgendaAssignment *assignment in self.assignments) {
        NSDate* date = [[CloudDateConverter sharedMager] convertDate:assignment.dueDate toFormat:CloudDateConverterFormatDate];

        NSMutableArray *assignmentsByDatesArray = [self.sections objectForKey:date];

        if (assignmentsByDatesArray == nil) {
            assignmentsByDatesArray = [NSMutableArray array];
            [self.sections setObject:assignmentsByDatesArray forKey:date];
        }

        [assignmentsByDatesArray addObject:assignment];
    }
    // Sorting keys from  earliest to latest
    self.sortedSections = [self.sections allKeys];
    self.sortedSections = [self.sortedSections sortedArrayUsingSelector:@selector(compare:)];

    // Sorting assignments of each array by dueTime

    for (NSDate *date in self.sortedSections) {
        NSArray *assignments = [self.sections objectForKey:date];

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
        [self.sections setObject:assignments forKey:date];
    }
}

#pragma mark - UITableView Delegate / DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    /* Create custom view to display section header... */
    CloudLabel *label = [[CloudLabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 25)];
    NSString *headerTitle = [[CloudDateConverter sharedMager] stringFromDate:[self.sortedSections objectAtIndex:section]];
    label.text = headerTitle;
	label.font = [UIFont fontWithName:@"FiraSansOt-Bold" size:label.font.pointSize];
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
        self.editedAssignment.assignmentDescription = [((NSDictionary *)(responseObject)) objectForKey:@"wording"];
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
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading..."].showNetworkActivityIndicator = YES;
    [IOSRequest getAssignmentInformation:self.editedAssignment.assignmentId onSuccess:success onFailure:failure];
}

- (void)tableViewDidReloadData:(UITableView *)tableView
{
    [self.refreshControl endRefreshing];
}

- (NSArray*)getArrayOfAssignmentsForPosition:(NSInteger)position {
    return [self.sections objectForKey:[self.sortedSections objectAtIndex:position]];
}

- (AgendaAssignment*)assignmentInArrayOfAssignements:(NSArray*)assignments
                                          atPosition:(NSInteger)position
{
    return [assignments objectAtIndex:position];
}

- (AgendaAssignment*)assignmentForIndexPath:(NSIndexPath*)indexPath {
    NSArray *assignments = [self getArrayOfAssignmentsForPosition:indexPath.section];

    AgendaAssignment *assignment;
    assignment = [self assignmentInArrayOfAssignements:assignments atPosition:indexPath.row];
    return assignment;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (IBAction)newAssignment:(UIBarButtonItem *)sender {
    AgendaTeacherEditAssignmentViewController *vc = [[AgendaTeacherEditAssignmentViewController alloc] initWithDisciplineID:self.disciplineID withClassID:self.classID andAssignment:nil presenter:self];
    [self presentViewController:vc animated:YES completion:^{}];
}

@end
