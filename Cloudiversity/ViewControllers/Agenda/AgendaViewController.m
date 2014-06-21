//
//  AgendaViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 21/04/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AgendaViewController.h"
#import "AgendaTableViewCell.h"
#import "AgendaAssgment.h"
#import "SWRevealViewController.h"
#import "UIColor+Cloud.h"
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

@property (nonatomic, strong) NSMutableDictionary *assigmentsByDate;
@property (nonatomic, strong) NSArray *sortedDates;

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
	
	/*[self.navigationController.toolbar setBackgroundColor:[UIColor cloudLightBlue]];
    [self.navigationController.toolbar setBarTintColor:[UIColor cloudLightBlue]];*/
	
	[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

    self.leftButton.target = self.revealViewController;
    self.leftButton.action = @selector(revealToggle:);
	self.assigmentsByDate = [[NSMutableDictionary alloc] init];
	
	[self initAssigmentsByDates];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)returnButton:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initAssigmentsByDates {
	NSArray *assigments = [self datasForTest];
	
	// Adding assigments in Arrays grouped by date
	for (NSDictionary *assigment in assigments) {
		NSString *dateString = [assigment objectForKey:@"date"];
				
		NSDate* date = [[CloudDateConverter sharedMager] dateFromString:dateString];

		NSMutableArray *assigmentsByDatesArray = [self.assigmentsByDate objectForKey:date];
		
		if (assigmentsByDatesArray == nil) {
			assigmentsByDatesArray = [NSMutableArray array];
			[self.assigmentsByDate setObject:assigmentsByDatesArray forKey:date];
		}
		
		[assigmentsByDatesArray addObject:assigment];
	}
	
	// Sorting keys from  earliest to latest
	self.sortedDates = [self.assigmentsByDate allKeys];
	self.sortedDates = [self.sortedDates sortedArrayUsingSelector:@selector(compare:)];
	
	// Sorting assigments of each array by dueTime
	for (NSDate *date in self.sortedDates) {
		NSArray *assigments = [self.assigmentsByDate objectForKey:date];
		
		assigments = [assigments sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			NSDictionary *dico1 = (NSDictionary *)obj1;
			NSDictionary *dico2 = (NSDictionary *)obj2;
			
			NSString *dateString1 = [dico1 objectForKey:@"dueTime"];
			if (dateString1 == nil) dateString1 = @"00:00";
			NSString *dateString2 = [dico2 objectForKey:@"dueTime"];
			if (dateString2 == nil) dateString2 = @"00:00";
			
			NSDate *date1 = [[CloudDateConverter sharedMager] timeFromString:dateString1];
			NSDate *date2 = [[CloudDateConverter sharedMager] timeFromString:dateString2];
			
			return [date1 compare:date2];
		}];
		
		// remove the unsorted array...
		[self.assigmentsByDate removeObjectForKey:date];
		// ...then replace it by the sorted one
		[self.assigmentsByDate setObject:assigments forKey:date];
	}
	
	return;
}

#pragma mark - UITableView management

/*
 Maybe a number like 10, to have assignements for the 10 next days
 (have to talk about it)
 */
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.assigmentsByDate count];
}

/*
 For getting the number of rows in a section, we check the number of assignement per day
*/
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *keyForSection = [self.sortedDates objectAtIndex:section];
	
	NSLog(@">>> Asking for numberOfRowsInSection : %d", section);

	return [[self.assigmentsByDate objectForKey:keyForSection] count];
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
	
	NSLog(@">>>>> Asking for cellForRowAtIndexPath : %@", indexPath);

	int *indexes = malloc(sizeof(int) * [indexPath length]);
	[indexPath getIndexes:(NSUInteger*)indexes];
	
	NSArray *assigments = [self.assigmentsByDate objectForKey:[self.sortedDates objectAtIndex:indexes[0]]];
	NSLog(@">>>>>>>> assigments : %@\n", assigments);
	
	NSDictionary *assigment = [assigments objectAtIndex:indexes[1]];
	
	[cell.pieChartView setInternalColor:[UIColor cloudLightBlue]];
	[cell.pieChartView setExternalColor:[UIColor cloudDarkBlue]];
	[cell.pieChartView setPercentage:[[assigment objectForKey:@"progression"] intValue]];
	cell.workTitle.text = [assigment objectForKey:@"title"];
	cell.workTitle.font = [UIFont fontWithName:CLOUD_FONT_BOLD size:cell.workTitle.font.pointSize];
	cell.fieldLabel.text = [assigment objectForKey:@"field"];
	cell.dueTimeLabel.text = [assigment objectForKey:@"dueTime"];
	
	return cell;
}

/*- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}*/

#pragma mark - testDatas

#define SAVING_PLACE_ASSIGMENT	@"agendaTmpPlaceForAssigment"

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int *indexes = malloc(sizeof(int) * [indexPath length]);
	[indexPath getIndexes:(NSUInteger*)indexes];
	
	NSArray *assigments = [self.assigmentsByDate objectForKey:[self.sortedDates objectAtIndex:indexes[0]]];
	NSDictionary *assigmentDico = [assigments objectAtIndex:indexes[1]];
	
	AgendaAssgment *assigment = [[AgendaAssgment alloc]
								 initWithTitle:[assigmentDico objectForKey:@"title"]
								 description:[assigmentDico objectForKey:@"description"]
								 DueDateByString:[assigmentDico objectForKey:@"date"]
								 inField:[assigmentDico objectForKey:@"field"]
								 withPercentageOfCompletion:[[assigmentDico objectForKey:@"progression"] intValue]
								 andIsMarked:NO
								 orAnExam:NO
								 forClass:@"3C"];
	
	NSUserDefaults *uDefault = [NSUserDefaults standardUserDefaults];
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:assigment];
	[uDefault setObject:data forKey:SAVING_PLACE_ASSIGMENT];
}

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
