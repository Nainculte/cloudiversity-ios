//
//  EvaluationGradesViewController.h
//  Cloudiversity
//
//  Created by Anthony MERLE on 18/12/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AbstractTableViewController.h"
#import "CloudEvaluationObjects.h"

@interface EvaluationGradesViewController : AbstractTableViewController

@property (strong, nonatomic) NSArray *grades;
@property (strong, nonatomic) CloudiversityDiscipline *discipline;

@end
