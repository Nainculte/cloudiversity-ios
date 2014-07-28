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
@property (nonatomic, strong) NSArray *disciplinesToFilter;

@property (nonatomic, strong) NSMutableArray *allDisciplinesName;
@property (nonatomic) AgendaStudentViewControllerProgressFilterPosition progressFilter;

@property (nonatomic) BOOL recievedResponseFromServer;

@property (nonatomic, strong) HTTPSuccessHandler success;
@property (nonatomic, strong) HTTPFailureHandler failure;

@property (nonatomic) id <AgendaStudentDataSource>dataSource;

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
		for (NSDictionary *assignmentDico in response) {
			// First, we create the Assignment from the Dictionary entrie
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
			
			// Geting discipline's name, and adding it in allDisciplines if it doesn't exist
			NSString *disciplineName = [assignment.dissiplineInformation objectForKey:DICO_DISCIPLINE_NAME];
			
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

        [[EGOCache globalCache] setData:[NSKeyedArchiver archivedDataWithRootObject:assignmentsByDates] forKey:@"assignmentsStudentList"];
        [[EGOCache globalCache] setData:[NSKeyedArchiver archivedDataWithRootObject:sortedDates] forKey:@"sortedStudentDates"];
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

	[self.revealViewController setDelegate:self];

    self.sections = [NSMutableDictionary dictionary];
	self.sortedSections = [NSMutableArray array];
	self.progressFilter = AgendaStudentViewControllerProgressFilterPositionToDo;

    [self setupHandlers];

    if ([[EGOCache globalCache] hasCacheForKey:@"assignmentsStudentList"]) {
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
	AgendaAssignment *assignment = [self assignmentForIndexPath:indexPath];

	[cell.pieChartView setInternalColor:[UIColor cloudLightBlue]];
	[cell.pieChartView setExternalColor:[UIColor cloudDarkBlue]];
	[cell.pieChartView setPercentage:assignment.progress];
	cell.workTitle.text = assignment.title;
	cell.workTitle.font = [UIFont fontWithName:CLOUD_FONT_BOLD size:cell.workTitle.font.pointSize];
	cell.fieldLabel.text = [assignment.dissiplineInformation objectForKey:DICO_DISCIPLINE_NAME];

	NSString *dueTimeString = [[CloudDateConverter sharedMager] stringFromTime:assignment.dueDate];
	if ([dueTimeString isEqualToString:@"00:00"]) {
		cell.dueTimeLabel.text = @"";
	} else {
		cell.dueTimeLabel.text = dueTimeString;
	}
}

- (void)tableViewWillReloadData:(UITableView *)tableView
{
    if ([[EGOCache globalCache] hasCacheForKey:@"assignmentsStudentList"]) {
        NSMutableDictionary *assignments = [NSKeyedUnarchiver unarchiveObjectWithData:[[EGOCache globalCache] dataForKey:@"assignmentsStudentList"]];
        NSArray *dates = [NSKeyedUnarchiver unarchiveObjectWithData:[[EGOCache globalCache] dataForKey:@"sortedStudentDates"]];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	NSArray *assignments;
	if (self.dateToFilter) {
		assignments = [self.sections objectForKey:self.dateToFilter];
	} else if (self.disciplinesToFilter) {
		assignments = [self getArrayOfAssignmentsForDisciplines:self.disciplinesToFilter atPosition:section];
	} else {
		assignments = [self getArrayOfAssignmentsForPosition:section];
	}
	
	int assignmentsCounter = 0;
	if (self.disciplinesToFilter && self.disciplinesToFilter.count > 0) {
		for (NSString *disciplineToFilter in self.disciplinesToFilter) {
			assignmentsCounter += [self countNumberOfAssignmentsForDisciplineName:disciplineToFilter
															 inArrayOfAssignments:assignments];
		}
	} else {
		assignmentsCounter = [self numberOfAssignmentsThatMatchTheProgressFilterInArrayOfAssignments:assignments];
	}
	
	return assignmentsCounter;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (self.dateToFilter) {
		return 1;
	} else if (self.disciplinesToFilter) {
		return [self countNumberOfSectionsToReturnForDisciplinesNames:self.disciplinesToFilter];
	}
	
	return [self numberOfSectionsForSelectedProgressFilter];
}

#pragma mark - AgendaStudentTaskDataSource protocol

- (AgendaAssignment *)getSelectedAssignment {
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	
	return [self assignmentForIndexPath:indexPath];
}

- (void)assignmentProgressUpdated:(AgendaAssignment *)assignment {
	NSArray *assignments = [self.sections objectForKey:assignment.dueDate];
	
	for (AgendaAssignment *assignmentObj in assignments) {
		if (assignmentObj.assignmentId == assignment.assignmentId) {
			assignmentObj.progress = assignment.progress;
			[self initAssignmentsByHTTPRequest]; //  C'est temporaire !
			[self reloadTableView];
			break;
		}
	}
}

#pragma mark - SWRevealViewControllerDelegate protocol

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position {
	id <AgendaStudentDataSource>filterViewController = (id <AgendaStudentDataSource>)self.revealViewController.rightViewController;

	if (position == FrontViewPositionLeftSide) { // When the filterView is shown
		[filterViewController setAvailableDisciplinesToFilter:self.allDisciplinesName];
	} else if (position == FrontViewPositionLeft) { // When the filterView is hidden
		NSDictionary *filters = [filterViewController getFilters];
		
		self.dateToFilter = [filters objectForKey:DATE_FILTER_KEY];
		self.disciplinesToFilter = [filters objectForKey:DISCIPLINE_FILTER_KEY];
		self.progressFilter = [[filters objectForKey:PROGRESS_FILTER_KEY] intValue];
		
		[self reloadTableView];
	}
}

#pragma mark - Some methodes to make it easy !

#pragma mark boolean methodes

// Return YES if the given Assignment's progress match the progressFilter value
- (BOOL)doesAssignmentMatchTheProgressFilterValue:(AgendaAssignment*)assignment {
	if ((assignment.progress == 100 && self.progressFilter == AgendaStudentViewControllerProgressFilterPositionDone) ||
		(assignment.progress != 100 && self.progressFilter == AgendaStudentViewControllerProgressFilterPositionToDo) ||
		self.progressFilter == AgendaStudentViewControllerProgressFilterPositionAll)
		return YES;
	
	return NO;
}

// Return YES if an Array of assignments contains at least one assignment in the filtered disciplines
- (BOOL)areDisciplines:(NSArray*)disciplinesNames inArrayOfAssignments:(NSArray*)assignments {
	for (AgendaAssignment *assignment in assignments) {
		for (NSString *disciplineName in disciplinesNames) {
			if ([[assignment.dissiplineInformation objectForKey:DICO_DISCIPLINE_NAME] isEqualToString:disciplineName] &&
				[self doesAssignmentMatchTheProgressFilterValue:assignment]) {
				return YES;
			}
		}
	}
	
	return NO;
}

#pragma mark NSInterger methodes (for number of sections and rows requests)

// Return the number of sections to display if only disciplines are filtered
- (NSInteger)countNumberOfSectionsToReturnForDisciplinesNames:(NSArray*)disciplinesNames {
	int numberOfSections = 0;
	
	for (NSDate *dateKey in self.sortedSections) {
		NSArray *assignments = [self.sections objectForKey:dateKey];
		
		if ([self areDisciplines:self.disciplinesToFilter inArrayOfAssignments:assignments])
			++numberOfSections;
	}
	
	return numberOfSections;
}

// Return the number of sections to display depending on the progressFilter
- (NSInteger)numberOfSectionsForSelectedProgressFilter {
	if (self.progressFilter == AgendaStudentViewControllerProgressFilterPositionAll) {
		return self.sections.count;
	}
	
	int numberOfSections = 0;
	for (NSString *dateKey in self.sortedSections) {
		NSArray *assignments = [self.sections objectForKey:dateKey];
		
		for (AgendaAssignment *assignment in assignments) {
			if ((assignment.progress == 100 && self.progressFilter == AgendaStudentViewControllerProgressFilterPositionDone) ||
				(assignment.progress != 100 && self.progressFilter == AgendaStudentViewControllerProgressFilterPositionToDo)) {
				++numberOfSections;
				break;
			}
		}
	}
	
	return numberOfSections;
}

// Return the number of assignments that are in the filtered disciplines for the given assignments Array
- (NSInteger)countNumberOfAssignmentsForDisciplineName:(NSString*)disciplineName
								  inArrayOfAssignments:(NSArray*)arrayOfAssignments {
	int assignmentCounter = 0;
	for (AgendaAssignment *assignment in arrayOfAssignments) {
		if ([[assignment.dissiplineInformation objectForKey:DICO_DISCIPLINE_NAME] isEqualToString:disciplineName] &&
			[self doesAssignmentMatchTheProgressFilterValue:assignment])
			++assignmentCounter;
	}
	
	return assignmentCounter;
}

// Return the number of assignments to display depending on the progressFilter
- (NSInteger)numberOfAssignmentsThatMatchTheProgressFilterInArrayOfAssignments:(NSArray*)assignments {
	if (self.progressFilter == AgendaStudentViewControllerProgressFilterPositionAll) {
		return assignments.count;
	}
	
	int numberOfAssignments = 0;
	for (AgendaAssignment *assignment in assignments) {
		if ([self doesAssignmentMatchTheProgressFilterValue:assignment])
			++numberOfAssignments;
	}
	
	return numberOfAssignments;
}

#pragma mark Array methodes (for array of assignments request)

// Return the correct Array of assignments for the asked position to display in the tableView, when only disciplines are filtered
- (NSArray*)getArrayOfAssignmentsForDisciplines:(NSArray*)disciplinesNames
									 atPosition:(NSInteger)position {
	int counter = -1;
	
	for (NSString *dateKey in self.sortedSections) {
		NSArray *assignments = [self.sections objectForKey:dateKey];
		
		if ([self areDisciplines:self.disciplinesToFilter inArrayOfAssignments:assignments]) {
			++counter;
			if (counter == position)
				return assignments;
		}
	}
	
	return nil;
}

// Return the correct Array of assignments for the asked position to display when no filters are set
- (NSArray*)getArrayOfAssignmentsForPosition:(NSInteger)position {
	int counter = -1;
	
	for (NSString *dateKey in self.sortedSections) {
		NSArray *assignments = [self.sections objectForKey:dateKey];
		
		for (AgendaAssignment *assignment in assignments) {
			if ([self doesAssignmentMatchTheProgressFilterValue:assignment]) {
				++counter;
				if (counter == position)
					return assignments;
			}
		}
	}
	
	return nil;
}

#pragma mark NSDictionary methodes (for single assignment requests)

// Return the asked assignment for the given NSIndexPath (Just for code factoring)
- (AgendaAssignment*)assignmentForIndexPath:(NSIndexPath*)indexPath {
	int *indexes = malloc(sizeof(int) * [indexPath length]);
	[indexPath getIndexes:(NSUInteger*)indexes];
	
	NSArray *assignments;
	if (self.dateToFilter) {
		assignments = [self.sections objectForKey:self.dateToFilter];
	} else if (self.disciplinesToFilter) {
		assignments = [self getArrayOfAssignmentsForDisciplines:self.disciplinesToFilter atPosition:indexes[0]];
	} else {
		assignments = [self getArrayOfAssignmentsForPosition:indexes[0]];
	}
	
	AgendaAssignment *assignment;
	if (self.disciplinesToFilter && self.disciplinesToFilter.count > 0) {
		assignment = [self assignmentForDisciplines:self.disciplinesToFilter atPosition:indexes[1] inArrayOfAssignments:assignments];
	} else {
		assignment = [self assignmentInArrayOfAssignements:assignments atPosition:indexes[1]];
	}
	
	return assignment;
}

// Return the nth assignment in the given assignments Array that match the filtered disciplines at the given position
- (AgendaAssignment*)assignmentForDisciplines:(NSArray*)disciplineNames
							   atPosition:(NSInteger)position
					 inArrayOfAssignments:(NSArray*)arrayOfAssignments {
	int cnt = -1;
	for (AgendaAssignment *assignment in arrayOfAssignments) {
		BOOL disciplineHasToBeDisplayed = NO;
		for (NSString *disciplineName in disciplineNames) {
			if ([[assignment.dissiplineInformation objectForKey:DICO_DISCIPLINE_NAME] isEqualToString:disciplineName] &&
				[self doesAssignmentMatchTheProgressFilterValue:assignment]) {
				disciplineHasToBeDisplayed = YES;
				break;
			}
		}
		if (disciplineHasToBeDisplayed) {
			++cnt;
			if (cnt == position)
				return assignment;
		}
	}
	
	return nil;
}

// Return the nth assignment in the given Array of assignments that match the progressFilter's property
- (AgendaAssignment*)assignmentInArrayOfAssignements:(NSArray*)assignments
									  atPosition:(NSInteger)position
{
	int cnt = -1;
	
	for (AgendaAssignment *assignment in assignments) {
		if ([self doesAssignmentMatchTheProgressFilterValue:assignment]) {
			++cnt;
			if (cnt == position)
				return assignment;
		}
	}
	
	return nil;
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
