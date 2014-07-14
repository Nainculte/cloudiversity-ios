//
//  AgendaTableViewCell.h
//  Cloudiversity
//
//  Created by Anthony MERLE on 10/06/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudLabel.h"
#import "AMPieChartView.h"

@interface AgendaStudentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet AMPieChartView *pieChartView;
@property (weak, nonatomic) IBOutlet CloudLabel *workTitle;
@property (weak, nonatomic) IBOutlet CloudLabel *fieldLabel;
@property (weak, nonatomic) IBOutlet CloudLabel *dueTimeLabel;

@end
