//
//  EvaluationGradeModificationViewController.h
//  Cloudiversity
//
//  Created by Anthony MERLE on 10/01/2015.
//  Copyright (c) 2015 Cloudiversity. All rights reserved.
//

#import <XLForm.h>
#import "CloudEvaluationObjects.h"
#import "EvaluationAllGradesViewController.h"

@interface EvaluationGradeModificationViewController : XLFormViewController

// If modifying grade
@property (strong, nonatomic) CloudiversityGrade *grade;

// If creating grade
//	Periods
//		-> Disciplines
//			-> Classes
@property (strong, nonatomic) NSDictionary *allowedTeachings;
@property (weak, nonatomic) EvaluationAllGradesViewController *gradeVC;

@property BOOL isCreatingGrade;

@end
