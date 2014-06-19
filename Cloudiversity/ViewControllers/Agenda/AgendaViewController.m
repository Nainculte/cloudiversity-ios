//
//  AgendaViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 21/04/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AgendaViewController.h"
#import "AgendaTableViewCell.h"
#import "SWRevealViewController.h"
#import "UIColor+Cloud.h"

// id for cells in the tableView
#define REUSE_IDENTIFIER	@"agendaCell"

@interface AgendaViewController ()

@property BOOL isFilteringExams;
@property BOOL isFilteringExercices;
@property BOOL isFilteringNotedTasks;
@property (nonatomic, strong) NSMutableArray *materialsToFilter;

@property (nonatomic, strong) NSMutableDictionary *assigmentsByDate;

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
	
	for (NSDictionary *assigment in assigments) {
		NSString *date = [assigment objectForKey:@"date"];
		NSMutableArray *assigmentsByDatesArray = [self.assigmentsByDate objectForKey:date];
		
		if (assigmentsByDatesArray == nil) {
			assigmentsByDatesArray = [NSMutableArray array];
			[self.assigmentsByDate setObject:assigmentsByDatesArray forKey:date];
		}
		
		[assigmentsByDatesArray addObject:assigment];
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
	NSEnumerator *enumerator = [self.assigmentsByDate objectEnumerator];
	NSArray *assigments;

	for (int cnt = 0; cnt <= section; cnt++) {
		assigments = [enumerator nextObject];
	}

	return [assigments count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 18;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    CloudLabel *label = [[CloudLabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
	NSString *headerTitle = @"";

	NSEnumerator *enumerator = [self.assigmentsByDate keyEnumerator];
	for (int cnt = 0; cnt <= section; cnt++) {
		headerTitle = [enumerator nextObject];
	}

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
	
	NSArray *assigments;
	int *indexes = malloc(sizeof(int) * [indexPath length]);
	[indexPath getIndexes:(NSUInteger*)indexes];
	
	NSEnumerator *enumerator = [self.assigmentsByDate objectEnumerator];
	for (int cnt = 0; cnt <= indexes[0]; cnt++) {
		assigments = [enumerator nextObject];
	}
	
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

- (NSArray*)datasForTest {
	return @[
			 @{@"title": @"Etude étymologique et philosophique approfondie de la pensée de sois du mot \"anticonstitutionellement\"",
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
