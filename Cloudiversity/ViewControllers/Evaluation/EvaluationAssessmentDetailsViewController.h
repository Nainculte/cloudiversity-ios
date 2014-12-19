//
//  EvaluationAssessmentDetailsViewController.h
//  Cloudiversity
//
//  Created by Anthony MERLE on 19/12/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudEvaluationObjects.h"

@interface EvaluationAssessmentDetailsViewController : UIViewController

@property (strong, nonatomic) CloudiversityAssessment *assessment;
@property (strong, nonatomic) CloudiversityDiscipline *discipline;

@property (weak, nonatomic) IBOutlet UILabel *assessmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *givenByLabel;
@property (weak, nonatomic) IBOutlet UILabel *teacherNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *forDisciplineLabel;
@property (weak, nonatomic) IBOutlet UILabel *disciplineNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *givenOnLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
