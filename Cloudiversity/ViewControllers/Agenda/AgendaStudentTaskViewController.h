//
//  AgendaStudentTaskViewController.h
//  Cloudiversity
//
//  Created by Anthony MERLE on 10/06/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgendaAssignment.h"

@protocol AgendaStudentTaskDataSource <NSObject>

- (AgendaAssignment*)getSelectedAssignment;
- (void)assignmentProgressUpdated:(AgendaAssignment*)assignment;

@end

@interface AgendaStudentTaskViewController : UIViewController

@property (weak, nonatomic) IBOutlet UINavigationItem *backButton;
@property (nonatomic) id <AgendaStudentTaskDataSource>dataSource;

@end
