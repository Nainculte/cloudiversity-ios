//
//  CloudEvaluationObjects.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 10/10/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "CloudEvaluationObjects.h"

@implementation CloudiversityPeriod

+ (instancetype)fromJSON:(id)json {
	NSDictionary *jsonObject = json;
	CloudiversityPeriod *newPeriod = [[CloudiversityPeriod alloc] init];
	
	newPeriod.name = [jsonObject objectForKey:@"name"];
	newPeriod.periodID = [jsonObject objectForKey:@"id"];
	newPeriod.startDate = [jsonObject objectForKey:@"start_date"];
	newPeriod.endDate = [jsonObject objectForKey:@"end_date"];
	
	return newPeriod;
}

@end

@implementation CloudiversityAssessment

+ (CloudiversityObject *)fromJSON:(id)json {
	NSDictionary *jsonObject = json;
	CloudiversityAssessment *newAssessment = [[CloudiversityAssessment alloc] init];
	
	newAssessment.assessmentID = [jsonObject objectForKey:@"id"];
	newAssessment.assessment = [jsonObject objectForKey:@"assessment"];
	newAssessment.creationDate = [jsonObject objectForKey:@"created_at"];
	newAssessment.lastUpdateDate = [jsonObject objectForKey:@"updated_at"];
	newAssessment.isForAllClass = [jsonObject objectForKey:@"school_class_assessment"];
	newAssessment.period = [CloudiversityPeriod fromJSON:[jsonObject objectForKey:@"period"]];
	newAssessment.student = [jsonObject objectForKey:@""];
	newAssessment.teacher = [jsonObject objectForKey:@""];
	newAssessment.schoolClass = [jsonObject objectForKey:@""];
	
	return newAssessment;
}

@end