//
//  AgendaViewController.h
//  Cloudiversity
//
//  Created by Anthony MERLE on 21/04/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AbstractTableViewController.h"
#import "AgendaStudentTaskViewController.h"

#define DATE_FILTER_KEY			@"dateToFilter"
#define DISCIPLINE_FILTER_KEY	@"disciplinesToFilter"
#define PROGRESS_FILTER_KEY		@"progressFilter" // For To Do | All | Done filter

typedef enum : NSUInteger {
    AgendaStudentViewControllerProgressFilterPositionToDo = 0,
    AgendaStudentViewControllerProgressFilterPositionAll,
    AgendaStudentViewControllerProgressFilterPositionDone,
} AgendaStudentViewControllerProgressFilterPosition;

@protocol AgendaStudentDataSource <NSObject>

- (void)setAvailableDisciplinesToFilter:(NSArray*)disciplines;
- (NSDictionary*)getFilters;

@end

@interface AgendaStudentViewController : AbstractTableViewController <UITableViewDataSource, AgendaStudentTaskDataSource, CloudTableViewDelegate, SWRevealViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *filters;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@end
