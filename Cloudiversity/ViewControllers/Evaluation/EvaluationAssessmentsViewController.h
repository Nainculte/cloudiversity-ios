//
//  CloudAssessmentsViewController.h
//  Cloudiversity
//
//  Created by Anthony MERLE on 19/12/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AbstractTableViewController.h"

@interface EvaluationAssessmentsViewController : AbstractTableViewController

@property (strong, nonatomic) NSArray *assessments;
@property (strong, nonatomic) CloudiversityDiscipline *discipline;

@end
