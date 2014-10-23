//
//  AgendaFilterViewController.h
//  Cloudiversity
//
//  Created by Anthony MERLE on 08/06/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLForm.h"

//#import "DSLCalendarView.h"
#import "SWRevealViewController.h"
#import "AgendaStudentViewController.h"
#import "AgendaFilterDelegate.h"

//@interface AgendaFilterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DSLCalendarViewDelegate, AgendaStudentDataSource>
//
//@end

@class AgendaFilterViewController;

@interface AgendaFilterRootViewController : UINavigationController

@property (nonatomic, retain) AgendaFilterViewController *filterVC;

@end

@interface AgendaFilterViewController : XLFormViewController

@property (nonatomic, weak) id<AgendaFilterDelegate> delegate;
@property (nonatomic, weak) id<AgendaStudentDataSource> dataSource;

@end