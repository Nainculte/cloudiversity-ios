//
//  AgendaViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 21/04/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AgendaStudentViewController.h"
#import "AgendaStudentTableViewCell.h"
#import "AgendaAssignment.h"
#import "CloudDateConverter.h"

// id for cells in the tableView
#define REUSE_IDENTIFIER	@"agendaCell"

#define DICO_ID					@"id"
#define DICO_TITLE 				@"title"
#define DICO_DEADLINE 			@"deadline"
#define DICO_DUETIME 			@"duetime"
#define DICO_PROGRESS 			@"progress"
#define DICO_DISCIPLINE 		@"discipline"
#define DICO_DISCIPLINE_ID			@"id"
#define DICO_DISCIPLINE_NAME		@"name"

@interface AgendaStudentViewController ()

// Properties for filtering
@property BOOL isFilteringExams;
@property BOOL isFilteringExercices;
@property BOOL isFilteringNotedTasks;
@property (nonatomic, strong) NSDate *dateToFilter;
@property (nonatomic, strong) NSMutableArray *materialsToFilter;

@property (nonatomic, strong) NSMutableDictionary *assignmentsByDate;
@property (nonatomic, strong) NSArray *sortedDates;
@property (nonatomic, strong) NSMutableArray *allDisciplinesName;

@property (nonatomic) BOOL recievedResponseFromServer;

@property (nonatomic, strong) HTTPSuccessHandler success;
@property (nonatomic, strong) HTTPFailureHandler failure;

@end

@implementation AgendaStudentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setupHandlers
{
    BSELF(self)
    self.success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        
        NSMutableDictionary *assignmentsByDates = [NSMutableDictionary dictionary];
        NSArray *sortedDates;
		NSMutableArray *allDisciplinesName = [NSMutableArray array];
        
		// Adding assignments in Arrays grouped by date
		for (NSDictionary *assignment in response) {
			NSString *dateString = [assignment objectForKey:DICO_DEADLINE];
            
			NSDate* date = [[CloudDateConverter sharedMager] dateFromString:dateString];
            
			NSMutableArray *assignmentsByDatesArray = [assignmentsByDates objectForKey:date];
            
			if (assignmentsByDatesArray == nil) {
				assignmentsByDatesArray = [NSMutableArray array];
				[assignmentsByDates setObject:assignmentsByDatesArray forKey:date];
			}

			[assignmentsByDatesArray addObject:assignment];
			
			// Geting discipline's name, and adding it in allDisciplines if it doesn't exist
			NSString *disciplineName = [[assignment objectForKey:DICO_DISCIPLINE] objectForKey:DICO_DISCIPLINE_NAME];
			
			if (![allDisciplinesName containsObject:disciplineName])
				[allDisciplinesName addObject:disciplineName];
		}

		// Sorting keys from  earliest to latest
		sortedDates = [assignmentsByDates allKeys];
		sortedDates = [sortedDates sortedArrayUsingSelector:@selector(compare:)];

		// Sorting assignments of each array by dueTime

		for (NSDate *date in sortedDates) {
			NSArray *assignments = [assignmentsByDates objectForKey:date];

			assignments = [assignments sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
				NSDictionary *dico1 = (NSDictionary *)obj1;
				NSDictionary *dico2 = (NSDictionary *)obj2;

				NSString *dateString1 = [dico1 objectForKey:DICO_DUETIME];
				if (dateString1 == nil || [[dico1 objectForKey:DICO_DUETIME] isKindOfClass:[NSNull class]]) dateString1 = [CloudDateConverter nullTime];
				NSString *dateString2 = [dico2 objectForKey:DICO_DUETIME];
				if (dateString2 == nil || [[dico2 objectForKey:DICO_DUETIME] isKindOfClass:[NSNull class]]) dateString2 = [CloudDateConverter nullTime];

				NSDate *date1 = [[CloudDateConverter sharedMager] timeFromString:dateString1];
				NSDate *date2 = [[CloudDateConverter sharedMager] timeFromString:dateString2];

				return [date1 compare:date2];
			}];

			// remove the unsorted array...
			[assignmentsByDates removeObjectForKey:date];
			// ...then replace it by the sorted one
			[assignmentsByDates setObject:assignments forKey:date];
		}

        [[EGOCache globalCache] setData:[NSKeyedArchiver archivedDataWithRootObject:assignmentsByDates] forKey:@"assignmentsList"];
        [[EGOCache globalCache] setData:[NSKeyedArchiver archivedDataWithRootObject:sortedDates] forKey:@"sortedDates"];
	[[EGOCache globalCache] setData:[NSKeyedArchiver archivedDataWithRootObject:allDisciplinesName] forKey:@"allDisciplinesName"];
        bself.sections = assignmentsByDates;
        bself.sortedSections = sortedDates;
		bself.allDisciplinesName = allDisciplinesName;
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setRightViewController:@"AgendaFilterViewController" withButton:self.filters];

	[((AgendaFilterViewController*)self.revealViewController.rightViewController) setDelegate:self];
	[self.revealViewController setDelegate:(id <SWRevealViewControllerDelegate>)self.revealViewController.rightViewController];

    self.sections = [NSMutableDictionary dictionary];
	self.sortedSections = [NSMutableArray array];

    [self setupHandlers];

    if ([[EGOCache globalCache] hasCacheForKey:@"assignmentsList"]) {
        [self.tableView reloadData];
    } else {
        [self initAssignmentsByHTTPRequest];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)reuseIdentifier
{
    return @"agendaStudentCell";
}

+ (Class)cellClass
{
    return [AgendaStudentTableViewCell class];
}

- (void)reloadTableView
{
    [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:YES];
    [IOSRequest getAssignmentsForUserOnSuccess:self.success onFailure:self.failure];
}

- (void)initAssignmentsByHTTPRequest
{
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading..."].showNetworkActivityIndicator = YES;
    [IOSRequest getAssignmentsForUserOnSuccess:self.success onFailure:self.failure];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"segueForAssignmentDetails"]) {
		AgendaStudentTaskViewController *assignmentDetailsVC = [segue destinationViewController];
		
		[assignmentDetailsVC setDataSource:self];
	}
}

#pragma mark - UITableView management

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 18;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    CloudLabel *label = [[CloudLabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
	NSString *headerTitle = [[CloudDateConverter sharedMager] stringFromDate:[self.sortedSections objectAtIndex:section]];

    [label setText:headerTitle];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor cloudGrey]];
    return view;
}

- (void)setupCell:(UITableViewCell *)c withIndexPath:(NSIndexPath *)indexPath
{
    AgendaStudentTableViewCell *cell = (AgendaStudentTableViewCell *)c;
    //NSLog(@">>>>> Asking for cellForRowAtIndexPath : %@", indexPath);

	NSUInteger *indexes = calloc(sizeof(NSUInteger), indexPath.length);
	[indexPath getIndexes:(NSUInteger*)indexes];

	NSArray *assignments = [self.sections objectForKey:[self.sortedSections objectAtIndex:indexes[0]]];
	//NSLog(@">>>>>>>> assignments : %@\n", assignments);

	NSDictionary *assignment = [assignments objectAtIndex:indexes[1]];

	[cell.pieChartView setInternalColor:[UIColor cloudLightBlue]];
	[cell.pieChartView setExternalColor:[UIColor cloudDarkBlue]];
	[cell.pieChartView setPercentage:[[assignment objectForKey:DICO_PROGRESS] intValue]];
	cell.workTitle.text = [assignment objectForKey:DICO_TITLE];
	cell.workTitle.font = [UIFont fontWithName:CLOUD_FONT_BOLD size:cell.workTitle.font.pointSize];
	cell.fieldLabel.text = [[assignment objectForKey:DICO_DISCIPLINE] objectForKey:DICO_DISCIPLINE_NAME];
	if ([[assignment objectForKey:DICO_DUETIME] isKindOfClass:[NSNull class]]) {
		cell.dueTimeLabel.text = @"";
	} else {
		cell.dueTimeLabel.text = [assignment objectForKey:DICO_DUETIME];
	}
}

- (void)tableViewWillReloadData:(UITableView *)tableView
{
    if ([[EGOCache globalCache] hasCacheForKey:@"assignmentsList"]) {
        NSMutableDictionary *assignments = [NSKeyedUnarchiver unarchiveObjectWithData:[[EGOCache globalCache] dataForKey:@"assignmentsList"]];
        NSArray *dates = [NSKeyedUnarchiver unarchiveObjectWithData:[[EGOCache globalCache] dataForKey:@"sortedDates"]];
		NSMutableArray *allDisciplinesName = [NSKeyedUnarchiver unarchiveObjectWithData:[[EGOCache globalCache] dataForKey:@"allDisciplinesName"]];
        if (assignments && dates && allDisciplinesName) {
            self.sections = assignments;
            self.sortedSections = dates;
			self.allDisciplinesName = allDisciplinesName;
        }
    }
}

- (void)tableViewDidReloadData:(UITableView *)tableView
{
    [self.refreshControl endRefreshing];
}

/*- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}*/

#pragma mark - AgendaStudentTaskDataSource protocol

-(AgendaAssignment *)getSelectedAssignment {
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

	int *indexes = malloc(sizeof(int) * [indexPath length]);
	[indexPath getIndexes:(NSUInteger*)indexes];
	
	NSArray *assignments = [self.sections objectForKey:[self.sortedSections objectAtIndex:indexes[0]]];
	NSDictionary *assignmentDico = [assignments objectAtIndex:indexes[1]];
	
	NSString *dueTime = nil;
	if (!([[assignmentDico objectForKey:DICO_DUETIME] class] == [NSNull class]))
		dueTime = [assignmentDico objectForKey:DICO_DUETIME];
	if (dueTime == nil) dueTime = [CloudDateConverter nullTime];
	NSString *assignmentDateString = [[assignmentDico objectForKey:DICO_DEADLINE] stringByAppendingString:[NSString stringWithFormat:@" %@", dueTime]];
	NSDate *assignmentDate = [[CloudDateConverter sharedMager] dateAndTimeFromString:assignmentDateString];
	
	AgendaAssignment *assignment = [[AgendaAssignment alloc]
									initWithTitle:[assignmentDico objectForKey:DICO_TITLE]
									withId:[[assignmentDico objectForKey:DICO_ID] intValue]
									dueDate:assignmentDate
									progress:[[assignmentDico objectForKey:DICO_PROGRESS] intValue]
									forDissipline:[assignmentDico objectForKey:DICO_DISCIPLINE]];
	
	return assignment;
}

#pragma mark - AgendaFilterViewDelegate protocol

-(void)filtersUpdated:(NSDictionary *)newFilters {
	NSLog(@"%@", newFilters);
}

- (NSArray*)getDisciplineFilters {
	return self.allDisciplinesName;
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
