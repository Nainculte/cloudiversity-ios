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

@interface AgendaTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet AMPieChartView *pieChartView;
@property (weak, nonatomic) IBOutlet CloudLabel *workTitle;

@end
