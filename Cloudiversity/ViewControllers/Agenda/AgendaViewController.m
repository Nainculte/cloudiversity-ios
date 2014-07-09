//
//  AgendaViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 21/04/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AgendaViewController.h"
#import "AgendaTableViewCell.h"
#import "AgendaAssignment.h"
#import "AgendaFilterViewController.h"
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

@interface AgendaViewController ()

@property BOOL isFilteringExams;
@property BOOL isFilteringExercices;
@property BOOL isFilteringNotedTasks;
@property (nonatomic, strong) NSMutableArray *materialsToFilter;

@property (nonatomic, strong) NSMutableDictionary *assignmentsByDate;
@property (nonatomic, strong) NSArray *sortedDates;

@property (nonatomic) BOOL recievedResponseFromServer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AgendaViewController

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
	
	[self.toolbar setBackgroundColor:[UIColor cloudLightBlue]];
    [self.toolbar setBarTintColor:[UIColor cloudLightBlue]];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    self.revealViewController.rightViewController = [sb instantiateViewControllerWithIdentifier:@"AgendaFilterViewController"];
    self.filters.target = self.revealViewController;
    self.filters.action = @selector(rightRevealToggle:);
	self.assignmentsByDate = [[NSMutableDictionary alloc] init];
	
	//[self initAssignmentsByDates];
	[self initAssignmentsByHTTPRequest];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initAssignmentsByHTTPRequest {
    void (^success)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;

		// Adding assignments in Arrays grouped by date
		for (NSDictionary *assignment in response) {
			NSString *dateString = [assignment objectForKey:DICO_DEADLINE];
			
			NSDate* date = [[CloudDateConverter sharedMager] dateFromString:dateString];
			
			NSMutableArray *assignmentsByDatesArray = [self.assignmentsByDate objectForKey:date];
			
			if (assignmentsByDatesArray == nil) {
				assignmentsByDatesArray = [NSMutableArray array];
				[self.assignmentsByDate setObject:assignmentsByDatesArray forKey:date];
			}
			
			[assignmentsByDatesArray addObject:assignment];
		}
		
		// Sorting keys from  earliest to latest
		self.sortedDates = [self.assignmentsByDate allKeys];
		self.sortedDates = [self.sortedDates sortedArrayUsingSelector:@selector(compare:)];
		
		// Sorting assignments of each array by dueTime
		for (NSDate *date in self.sortedDates) {
			NSArray *assignments = [self.assignmentsByDate objectForKey:date];
			
			assignments = [assignments sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
				NSDictionary *dico1 = (NSDictionary *)obj1;
				NSDictionary *dico2 = (NSDictionary *)obj2;
				
				NSString *dateString1 = [dico1 objectForKey:DICO_DUETIME];
				if (dateString1 == nil) dateString1 = [CloudDateConverter nullTime];
				NSString *dateString2 = [dico2 objectForKey:DICO_DUETIME];
				if (dateString2 == nil) dateString2 = [CloudDateConverter nullTime];
				
				NSDate *date1 = [[CloudDateConverter sharedMager] timeFromString:dateString1];
				NSDate *date2 = [[CloudDateConverter sharedMager] timeFromString:dateString2];
				
				return [date1 compare:date2];
			}];
			
			// remove the unsorted array...
			[self.assignmentsByDate removeObjectForKey:date];
			// ...then replace it by the sorted one
			[self.assignmentsByDate setObject:assignments forKey:date];
		}
		[self.tableView reloadData];
        [DejalActivityView removeView];
    };
    void (^failure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        switch (operation.response.statusCode) {
            default:
                break;
        }
        [DejalActivityView removeView];
    };
	//[self.activityIndicator setHidden:NO];
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading..."].showNetworkActivityIndicator = YES;
    [IOSRequest getAssignmentsForUserOnSuccess:success onFailure:failure];
}

#pragma mark - UITableView management

/*
 Maybe a number like 10, to have assignements for the 10 next days
 (have to talk about it)
 */
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.assignmentsByDate count];
}

/*
 For getting the number of rows in a section, we check the number of assignement per day
*/
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *keyForSection = [self.sortedDates objectAtIndex:section];
	
	//NSLog(@">>> Asking for numberOfRowsInSection : %d", section);

	return [[self.assignmentsByDate objectForKey:keyForSection] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 18;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    CloudLabel *label = [[CloudLabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
	NSString *headerTitle = [[CloudDateConverter sharedMager] stringFromDate:[self.sortedDates objectAtIndex:section]];

    [label setText:headerTitle];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor cloudGrey]];
    return view;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	AgendaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:REUSE_IDENTIFIER];
	if (!cell) {
		cell = [[AgendaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:REUSE_IDENTIFIER];
	}
	
	//NSLog(@">>>>> Asking for cellForRowAtIndexPath : %@", indexPath);

	NSUInteger *indexes = calloc(sizeof(NSUInteger), indexPath.length);
	[indexPath getIndexes:(NSUInteger*)indexes];
	
	NSArray *assignments = [self.assignmentsByDate objectForKey:[self.sortedDates objectAtIndex:indexes[0]]];
	//NSLog(@">>>>>>>> assignments : %@\n", assignments);
	
	NSDictionary *assignment = [assignments objectAtIndex:indexes[1]];
	
	[cell.pieChartView setInternalColor:[UIColor cloudLightBlue]];
	[cell.pieChartView setExternalColor:[UIColor cloudDarkBlue]];
	[cell.pieChartView setPercentage:[[assignment objectForKey:DICO_PROGRESS] intValue]];
	cell.workTitle.text = [assignment objectForKey:DICO_TITLE];
	cell.workTitle.font = [UIFont fontWithName:CLOUD_FONT_BOLD size:cell.workTitle.font.pointSize];
	cell.fieldLabel.text = [[assignment objectForKey:DICO_DISCIPLINE] objectForKey:DICO_DISCIPLINE_NAME];
	cell.dueTimeLabel.text = [[CloudDateConverter sharedMager] stringFromTime:[assignment objectForKey:DICO_DUETIME]];
	
	return cell;
}

/*- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}*/

#define SAVING_PLACE_ASSIGNMENT	@"agendaTmpPlaceForAssignment"

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int *indexes = malloc(sizeof(int) * [indexPath length]);
	[indexPath getIndexes:(NSUInteger*)indexes];
	
	NSArray *assignments = [self.assignmentsByDate objectForKey:[self.sortedDates objectAtIndex:indexes[0]]];
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
	
	NSUserDefaults *uDefault = [NSUserDefaults standardUserDefaults];
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:assignment];
	[uDefault setObject:data forKey:SAVING_PLACE_ASSIGNMENT];
	[uDefault synchronize];
}

#pragma mark - testDatas

- (NSArray*)datasForTest {
	return @[
			 @{@"title": @"Etude étymologique et philosophique approfondie de la pensée de soi du mot \"anticonstitutionellement\"",
			   @"description": @"Write something about Napoleon",
			   @"field": @"History",
			   @"progression": @"80",
			   @"date": @"2014-07-16",
			   @"dueTime": @"23:42"},
			 @{@"title": @"Try to fly",
			   @"description": @"Jump from a window, and try to fly...",
			   @"field": @"Sports",
			   @"progression": @"100",
			   @"date": @"2014-07-16"},
			 @{@"title": @"Pythagore's test",
			   @"description": @"Exam about Pythagore theorem",
			   @"field": @"Mathematics",
			   @"progression": @"35",
			   @"date": @"2014-08-04",
			   @"dueTime": @"12:00"},
			 @{@"title": @"\"Le Scaphandrier et le Papillon\"",
			   @"description": @"Read \"Le Scaphandrier et le Papillon\"",
			   @"field": @"Litterature",
			   @"progression": @"99",
			   @"date": @"2014-07-31"},
			 @{@"title": @"Happy Bloody Christmas !",
			   @"description": @"Kill Santa Claus",
			   @"field": @"Cereal Killer for dummies",
			   @"progression": @"10",
			   @"date": @"2014-12-25"}
			 ];
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
