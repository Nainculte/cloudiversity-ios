//
//  EvaluationAssessmentDetailsViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 19/12/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "EvaluationAssessmentDetailsViewController.h"
#import "CloudDateConverter.h"

#define LOCALIZEDSTRING(s) [[NSBundle mainBundle] localizedStringForKey:s value:@"Localization error" table:@"EvaluationVC"]

@interface EvaluationAssessmentDetailsViewController ()

@end

@implementation EvaluationAssessmentDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	self.givenByLabel.text = LOCALIZEDSTRING(@"EVAL_GIVEN_BY");
	self.givenOnLabel.text = LOCALIZEDSTRING(@"EVAL_GIVEN_ON");
	self.forDisciplineLabel.text = LOCALIZEDSTRING(@"EVAL_FOR_DISCIPLINE");
	
	self.assessmentLabel.text = self.assessment.assessment;
	self.teacherNameLabel.text = self.assessment.teacher.name;
	self.dateLabel.text = [[CloudDateConverter sharedMager] stringFromFullDate:self.assessment.creationDate];
	self.disciplineNameLabel.text = self.discipline.name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
