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
    [self setupTitle];
    [self setupHandlers];

    if ([[EGOCache globalCache] hasCacheForKey:[NSString stringWithFormat:@"%@/%@", self.disciplineTitle, self.classTitle]]) {
        [self.tableView reloadData];
    } else {
        [self initAssignmentsByHTTPRequest];
    }

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
        NSArray *response = (NSArray *)responseObject;

        NSMutableDictionary *assignmentsByDates = [NSMutableDictionary dictionary];
        NSArray *sortedDates;

        for (NSDictionary *assignmentDico in response) {
            NSString *dueTimeString = ([[assignmentDico objectForKey:DICO_DUETIME] class] == [NSNull class] ? [CloudDateConverter nullTime] : [assignmentDico objectForKey:DICO_DUETIME]);
            NSString *fullDateAndTime = [NSString stringWithFormat:@"%@ %@", [assignmentDico objectForKey:DICO_DEADLINE], dueTimeString];
            AgendaAssignment *assignment = [[AgendaAssignment alloc] initWithTitle:[assignmentDico objectForKey:DICO_TITLE] withId:[[assignmentDico objectForKey:DICO_ID] intValue] dueDate:[[CloudDateConverter sharedMager] dateAndTimeFromString:fullDateAndTime] progress:[[assignmentDico objectForKey:DICO_PROGRESS] intValue] forDissipline:[assignmentDico objectForKey:DICO_DISCIPLINE]];

            NSDate* date = [[CloudDateConverter sharedMager] convertDate:assignment.dueDate toFormat:CloudDateConverterFormatDate];

			NSMutableArray *assignmentsByDatesArray = [assignmentsByDates objectForKey:date];

			if (assignmentsByDatesArray == nil) {
				assignmentsByDatesArray = [NSMutableArray array];
				[assignmentsByDates setObject:assignmentsByDatesArray forKey:date];
			}

			[assignmentsByDatesArray addObject:assignment];
        }

        // Sorting keys from  earliest to latest
		sortedDates = [assignmentsByDates allKeys];
		sortedDates = [sortedDates sortedArrayUsingSelector:@selector(compare:)];

		// Sorting assignments of each array by dueTime

		for (NSDate *date in sortedDates) {
			NSArray *assignments = [assignmentsByDates objectForKey:date];

			assignments = [assignments sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                AgendaAssignment *assignment1 = (AgendaAssignment *)obj1;
				AgendaAssignment *assignment2 = (AgendaAssignment *)obj2;

                NSDate *date1 = [[CloudDateConverter sharedMager] convertDate:assignment1.dueDate toFormat:CloudDateConverterFormatTime];
                NSDate *date2 = [[CloudDateConverter sharedMager] convertDate:assignment2.dueDate toFormat:CloudDateConverterFormatTime];

				return [date1 compare:date2];
			}];

			// remove the unsorted array...
			[assignmentsByDates removeObjectForKey:date];
			// ...then replace it by the sorted one
			[assignmentsByDates setObject:assignments forKey:date];
		}

        [[EGOCache globalCache] setData:[NSKeyedArchiver archivedDataWithRootObject:assignmentsByDates] forKey:@"assignmentsTeacherList"];
        [[EGOCache globalCache] setData:[NSKeyedArchiver archivedDataWithRootObject:sortedDates] forKey:@"sortedTeacherDates"];

        bself.sections = assignmentsByDates;
        bself.sortedSections = sortedDates;
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
    NSString *headerTitle = [[CloudDateConverter sharedMager] stringFromDate:[self.sortedSections objectAtIndex:section]];
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
    if ([[EGOCache globalCache] hasCacheForKey:@"assignmentsTeacherList"]) {
        NSMutableDictionary *assignments = [NSKeyedUnarchiver unarchiveObjectWithData:[[EGOCache globalCache] dataForKey:@"assignmentsTeacherList"]];
        NSArray *dates = [NSKeyedUnarchiver unarchiveObjectWithData:[[EGOCache globalCache] dataForKey:@"sortedTeacherDates"]];
        if (assignments && dates) {
            self.sections = assignments;
            self.sortedSections = dates;
        }
    }
}

- (void)tableViewDidReloadData:(UITableView *)tableView
{
    [self.refreshControl endRefreshing];
}

- (NSArray*)getArrayOfAssignmentsForPosition:(NSInteger)position {
    int counter = -1;

    for (NSString *dateKey in self.sortedSections) {
        NSArray *assignments = [self.sections objectForKey:dateKey];

        for (AgendaAssignment *__unused assignment in assignments) {
            ++counter;
            if (counter == position)
                return assignments;
        }
    }
    
    return nil;
}

- (AgendaAssignment*)assignmentInArrayOfAssignements:(NSArray*)assignments
                                          atPosition:(NSInteger)position
{
    int cnt = -1;

    for (AgendaAssignment *assignment in assignments) {
        ++cnt;
        if (cnt == position)
            return assignment;
    }
    return nil;
}

- (AgendaAssignment*)assignmentForIndexPath:(NSIndexPath*)indexPath {
    int *indexes = malloc(sizeof(int) * [indexPath length]);
    [indexPath getIndexes:(NSUInteger*)indexes];

    NSArray *assignments = [self getArrayOfAssignmentsForPosition:indexes[0]];

    AgendaAssignment *assignment;
    assignment = [self assignmentInArrayOfAssignements:assignments atPosition:indexes[1]];
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
    AgendaTeacherEditAssignmentViewController *vc = [[AgendaTeacherEditAssignmentViewController alloc] initWithDisciplineID:self.disciplineID withClassID:self.classID andAssignment:nil];
    [self presentViewController:vc animated:YES completion:^{}];
}

@end
