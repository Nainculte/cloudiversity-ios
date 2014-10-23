//
//  AgendaViewController.h
//  Cloudiversity
//
//  Created by Anthony MERLE on 21/04/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AbstractTableViewController.h"
#import "AgendaStudentTaskViewController.h"
#import "AgendaFilterDelegate.h"

#define DATE_FILTER_KEY			@"dateToFilter"
#define DISCIPLINE_FILTER_KEY	@"disciplinesToFilter"
#define PROGRESS_FILTER_KEY		@"progressFilter" // For To Do | All | Done filter

typedef enum : NSUInteger {
    AgendaStudentViewControllerProgressFilterPositionToDo = 0,
    AgendaStudentViewControllerProgressFilterPositionAll,
    AgendaStudentViewControllerProgressFilterPositionDone,
} AgendaStudentViewControllerProgressFilterPosition;

@protocol AgendaStudentDataSource <NSObject>

- (NSArray *)getAvailableDisciplinesToFilter;
- (NSDictionary*)getFilters;

@end

@interface AgendaStudentViewController : AbstractTableViewController <AgendaStudentTaskDataSource, SWRevealViewControllerDelegate, AgendaFilterDelegate, AgendaStudentDataSource>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *filters;

@end
