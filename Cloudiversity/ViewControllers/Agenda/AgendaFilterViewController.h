//
//  AgendaFilterViewController.h
//  Cloudiversity
//
//  Created by Anthony MERLE on 08/06/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSLCalendarView.h"
#import "SWRevealViewController.h"
#import "AgendaStudentViewController.h"

@interface AgendaFilterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DSLCalendarViewDelegate, AgendaStudentDataSource>

@property (weak, nonatomic) IBOutlet UISwitch *controlSwitchFilter;
@property (weak, nonatomic) IBOutlet UISwitch *exercicesSwitchFilter;
@property (weak, nonatomic) IBOutlet UISwitch *markesTasksSwitchFilter;

@end
