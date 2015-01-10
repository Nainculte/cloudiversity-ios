//
//  EvaluationAssessmentsModificationViewController.h
//  Cloudiversity
//
//  Created by Anthony MERLE on 10/01/2015.
//  Copyright (c) 2015 Cloudiversity. All rights reserved.
//

#import <XLForm.h>
#import "CloudEvaluationObjects.h"

@interface EvaluationAssessmentsModificationViewController : XLFormViewController

@property (nonatomic, strong) CloudiversityAssessment *assessment;
@property BOOL isCreatingAssessment;

@end
