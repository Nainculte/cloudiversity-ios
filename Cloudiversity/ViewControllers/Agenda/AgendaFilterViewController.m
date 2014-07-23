//
//  AgendaFilterViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 08/06/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AgendaFilterViewController.h"

#define REUSE_IDENTIFIER	@"fieldCell"

@interface AgendaFilterViewController ()

@property (weak, nonatomic) IBOutlet DSLCalendarView *calendarView;

@property (strong, nonatomic) NSDateComponents *selectedDay;
@property (strong, nonatomic) NSMutableArray *selectedDisciplines;
@property (strong, nonatomic) NSArray *availableDisciplines;
@property (weak, nonatomic) IBOutlet UITableView *disciplinesTableView;

@property BOOL dayIsSelected;

@end

@implementation AgendaFilterViewController

- (NSMutableArray *)selectedDisciplines {
	if (_selectedDisciplines == nil) {
		_selectedDisciplines = [NSMutableArray array];
	}
	
	return _selectedDisciplines;
}

-(void)setAvailableDisciplines:(NSArray *)availableDisciplines {
	_availableDisciplines = availableDisciplines;
	[self.disciplinesTableView reloadData];
}

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
    // Do any additional setup after loading the view.
	[self.controlSwitchFilter setOn:NO];
	[self.exercicesSwitchFilter setOn:NO];
	[self.markesTasksSwitchFilter setOn:NO];
    self.view.backgroundColor = [UIColor whiteColor];
	[self.calendarView setDelegate:self];

	[self setDayIsSelected:NO];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	CGRect newFrame = CGRectMake(self.calendarView.calendarMonthSelector.frame.origin.x, self.calendarView.calendarMonthSelector.frame.origin.y, self.calendarView.frame.size.width, self.calendarView.calendarMonthSelector.frame.size.height);
	[self.calendarView.calendarMonthSelector setFrame:newFrame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)updateSwitches:(id)sender {
	if ([sender isEqual:self.controlSwitchFilter]) {
		if ([self.controlSwitchFilter isOn]) {
			[self.exercicesSwitchFilter setOn:NO animated:YES];
			[self.markesTasksSwitchFilter setOn:NO animated:YES];
		}
	} else if ([sender isEqual:self.exercicesSwitchFilter]) {
		if ([self.exercicesSwitchFilter isOn]) {
			[self.controlSwitchFilter setOn:NO animated:YES];
			[self.markesTasksSwitchFilter setOn:NO animated:YES];
		}
	} else {
		if ([self.markesTasksSwitchFilter isOn]) {
			[self.controlSwitchFilter setOn:NO animated:YES];
			[self.exercicesSwitchFilter setOn:NO animated:YES];
		}
	}
}

- (IBAction)returnButton:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - UITableViewDelegate and dataSource protocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@">>>>>>>>\n%@\n<<<<<<<<<<", self.availableDisciplines);
	
	return self.availableDisciplines.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:REUSE_IDENTIFIER];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:REUSE_IDENTIFIER];
	}

	cell.textLabel.text = [self.availableDisciplines objectAtIndex:[indexPath indexAtPosition:1]];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *disciplineName = [self.availableDisciplines objectAtIndex:[indexPath indexAtPosition:1]];
	
	if (self.selectedDisciplines == nil)
		self.selectedDisciplines = [NSMutableArray array];
	if (![self.selectedDisciplines containsObject:disciplineName]) {
		[self.selectedDisciplines addObject:disciplineName];
	}
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *disciplineName = [self.availableDisciplines objectAtIndex:[indexPath indexAtPosition:1]];
	
	if (self.selectedDisciplines == nil)
		self.selectedDisciplines = [NSMutableArray array];
	if ([self.selectedDisciplines containsObject:disciplineName]) {
		[self.selectedDisciplines removeObject:disciplineName];
	}
}

#pragma mark - DSLCalendarViewDelegate methods

- (void)calendarView:(DSLCalendarView *)calendarView didSelectRange:(DSLCalendarRange *)range {
    if (range != nil) {
        NSLog( @"Selected %d/%d - %d/%d", range.startDay.day, range.startDay.month, range.endDay.day, range.endDay.month);
		if ([self.selectedDay.date compare:range.startDay.date] == NSOrderedSame &&
			self.selectedDay != nil) {
			[self.calendarView deselectSelectedDay:self.calendarView.selectedRange.startDay];
			self.selectedDay = nil;
		} else {
			self.selectedDay = range.startDay;
		}
    }
    else {
        NSLog( @"No selection" );
    }
}

- (DSLCalendarRange*)calendarView:(DSLCalendarView *)calendarView didDragToDay:(NSDateComponents *)day selectingRange:(DSLCalendarRange *)range {
    // Only select a single day
	return [[DSLCalendarRange alloc] initWithStartDay:day endDay:day];

	// Don't allow selections before today
	/*NSDateComponents *today = [[NSDate date] dslCalendarView_dayWithCalendar:calendarView.visibleMonth.calendar];
	
	NSDateComponents *startDate = range.startDay;
	NSDateComponents *endDate = range.endDay;
	
	if ([self day:startDate isBeforeDay:today] && [self day:endDate isBeforeDay:today]) {
		return nil;
	}
	else {
		if ([self day:startDate isBeforeDay:today]) {
			startDate = [today copy];
		}
		if ([self day:endDate isBeforeDay:today]) {
			endDate = [today copy];
		}
		
		return [[DSLCalendarRange alloc] initWithStartDay:startDate endDay:endDate];
	}
	return range;
	*/
}

- (BOOL)day:(NSDateComponents*)day1 isBeforeDay:(NSDateComponents*)day2 {
    return ([day1.date compare:day2.date] == NSOrderedAscending);
}

#pragma mark - AgendaStudentDataSource protocol

- (void)setAvailableDisciplinesToFilter:(NSArray *)disciplines {
	[self setAvailableDisciplines:disciplines];
}

- (NSDictionary*)getFilters {
	NSMutableDictionary *filters = [NSMutableDictionary dictionary];
	if (self.selectedDay) {
		[filters setObject:self.selectedDay.date forKey:DATE_FILTER_KEY];
	} else {
		[filters removeObjectForKey:DATE_FILTER_KEY];
	}
	if (self.selectedDisciplines && self.selectedDisciplines.count > 0) {
		[filters setObject:self.selectedDisciplines forKey:DISCIPLINE_FILTER_KEY];
	} else {
		[filters removeObjectForKey:DISCIPLINE_FILTER_KEY];
	}
	
	return filters;
}

@end
