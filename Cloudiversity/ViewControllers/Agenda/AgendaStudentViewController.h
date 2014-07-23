//
//  AgendaViewController.h
//  Cloudiversity
//
//  Created by Anthony MERLE on 21/04/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AbstractTableViewController.h"
#import "AgendaStudentTaskViewController.h"

@protocol AgendaStudentDataSource <NSObject>

- (void)setAvailableDisciplinesToFilter:(NSArray*)disciplines;
- (NSDictionary*)getFilters;

@end

@interface AgendaStudentViewController : AbstractTableViewController <UITableViewDataSource, AgendaStudentTaskDataSource, CloudTableViewDelegate, SWRevealViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *filters;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@end
