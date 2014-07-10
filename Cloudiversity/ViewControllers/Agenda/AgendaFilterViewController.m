//
//  AgendaFilterViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 08/06/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AgendaFilterViewController.h"

@interface AgendaFilterViewController ()

@property (weak, nonatomic) IBOutlet DSLCalendarView *calendarView;

@end

@implementation AgendaFilterViewController

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

#pragma mark - DSLCalendarViewDelegate methods

- (void)calendarView:(DSLCalendarView *)calendarView didSelectRange:(DSLCalendarRange *)range {
    if (range != nil) {
        NSLog( @"Selected %d/%d - %d/%d", range.startDay.day, range.startDay.month, range.endDay.day, range.endDay.month);
    }
    else {
        NSLog( @"No selection" );
    }
}

- (DSLCalendarRange*)calendarView:(DSLCalendarView *)calendarView didDragToDay:(NSDateComponents *)day selectingRange:(DSLCalendarRange *)range {
    if (YES) { // Only select a single day
        return [[DSLCalendarRange alloc] initWithStartDay:day endDay:day];
    }
    else if (NO) { // Don't allow selections before today
        NSDateComponents *today = [[NSDate date] dslCalendarView_dayWithCalendar:calendarView.visibleMonth.calendar];
        
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
    }
    
    return range;
}

- (void)calendarView:(DSLCalendarView *)calendarView willChangeToVisibleMonth:(NSDateComponents *)month duration:(NSTimeInterval)duration {
    NSLog(@"Will show %@ in %.3f seconds", month, duration);
}

- (void)calendarView:(DSLCalendarView *)calendarView didChangeToVisibleMonth:(NSDateComponents *)month {
    NSLog(@"Now showing %@", month);
}

- (BOOL)day:(NSDateComponents*)day1 isBeforeDay:(NSDateComponents*)day2 {
    return ([day1.date compare:day2.date] == NSOrderedAscending);
}

@end
