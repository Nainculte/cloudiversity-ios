//
//  EvaluationGradeDetailViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 18/12/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "EvaluationGradeDetailViewController.h"
#import "CloudDateConverter.h"

#define LOCALIZEDSTRING(s) [[NSBundle mainBundle] localizedStringForKey:s value:@"Localization error" table:@"EvaluationVC"]

@interface EvaluationGradeDetailViewController ()

@end

@implementation EvaluationGradeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.givenByLabel.text = LOCALIZEDSTRING(@"EVAL_GIVEN_BY");
	self.givenOnLabel.text = LOCALIZEDSTRING(@"EVAL_GIVEN_ON");
	self.forDisciplineLabel.text = LOCALIZEDSTRING(@"EVAL_FOR_DISCIPLINE");
	self.coeffLabel.text = [NSString stringWithFormat:LOCALIZEDSTRING(@"EVAL_COEFFICENT"), [self.grade.coefficent floatValue]];
	
	self.gradeLabel.text = [self.grade.note stringValue];
	self.assessmentLabel.text = self.grade.assessment;
	self.teacherNameLabel.text = self.grade.teacher.name;
	self.dateLabel.text = [[CloudDateConverter sharedMager] stringFromFullDate:self.grade.creationDate];
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
