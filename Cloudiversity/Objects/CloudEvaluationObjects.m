//
//  CloudEvaluationObjects.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 10/10/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "CloudEvaluationObjects.h"

@implementation CloudiversityAssessment

+ (instancetype)fromJSON:(id)json {
	if (json == nil || [json isKindOfClass:[NSNull class]])
		return nil;
	
	NSDictionary *jsonObject = json;
	CloudiversityAssessment *newAssessment = [[CloudiversityAssessment alloc] init];
	
	newAssessment.assessmentID = [jsonObject objectForKey:@"id"];
	newAssessment.assessment = [jsonObject objectForKey:@"assessment"];
	newAssessment.creationDate = [jsonObject objectForKey:@"created_at"];
	newAssessment.lastUpdateDate = [jsonObject objectForKey:@"updated_at"];
	newAssessment.isForAllClass = [jsonObject objectForKey:@"school_class_assessment"];
	newAssessment.period = [CloudiversityPeriod fromJSON:[jsonObject objectForKey:@"period"]];
	newAssessment.discipline = [CloudiversityDiscipline fromJSON:[jsonObject objectForKey:@"discipline"]];
	newAssessment.student = [CloudiversityStudent fromJSON:[jsonObject objectForKey:@"student"]];
	newAssessment.teacher = [CloudiversityTeacher fromJSON:[jsonObject objectForKey:@"teacher"]];
	newAssessment.schoolClass = [CloudiversityClass fromJSON:[jsonObject objectForKey:@"school_class"]];
	
	return newAssessment;
}

@end

@implementation CloudiversityGrade

+ (instancetype)fromJSON:(id)json {
	if (json == nil || [json isKindOfClass:[NSNull class]])
		return nil;
	
	NSDictionary *jsonObject = json;
	CloudiversityGrade *newGrade = [[CloudiversityGrade alloc] init];
	
	newGrade.gradeID = [jsonObject objectForKey:@"id"];
	newGrade.assessment = [jsonObject objectForKey:@"assessment"];
	newGrade.creationDate = [jsonObject objectForKey:@"created_at"];
	newGrade.lastUpdateDate = [jsonObject objectForKey:@"updated_at"];
	newGrade.note = [jsonObject objectForKey:@"note"];
	newGrade.coefficent = [jsonObject objectForKey:@"coefficient"];
	newGrade.period = [CloudiversityPeriod fromJSON:[jsonObject objectForKey:@"period"]];
	newGrade.discipline = [CloudiversityDiscipline fromJSON:[jsonObject objectForKey:@"discipline"]];
	newGrade.student = [CloudiversityStudent fromJSON:[jsonObject objectForKey:@"student"]];
	newGrade.teacher = [CloudiversityTeacher fromJSON:[jsonObject objectForKey:@"teacher"]];
	newGrade.schoolClass = [CloudiversityClass fromJSON:[jsonObject objectForKey:@"school_class"]];
	
	return newGrade;
}

@end