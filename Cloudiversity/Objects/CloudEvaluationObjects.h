//
//  CloudEvaluationObjects.h
//  Cloudiversity
//
//  Created by Anthony MERLE on 10/10/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "CloudiversityObject.h"

@interface CloudiversityPeriod : CloudiversityObject

@property (strong, nonatomic) NSNumber *periodID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

+ (NSArray *)sortPeriods:(NSArray *)periods;

@end

@interface CloudiversityAssessment : CloudiversityObject

@property (strong, nonatomic) NSNumber *assessmentID;
@property (strong, nonatomic) NSString *assessment;
@property (strong, nonatomic) NSDate *creationDate;
@property (strong, nonatomic) NSDate *lastUpdateDate;
@property (strong, nonatomic) NSValue *isForAllClass;
@property (strong, nonatomic) CloudiversityPeriod *period;
@property (strong, nonatomic) CloudiversityDiscipline *discipline;
@property (strong, nonatomic) CloudiversityStudent *student; // is nil if isForAllClass == YES
@property (strong, nonatomic) CloudiversityTeacher *teacher;
@property (strong, nonatomic) CloudiversityClass *schoolClass;

@end

@interface CloudiversityGrade : CloudiversityObject

@property (strong, nonatomic) NSNumber *gradeID;
@property (strong, nonatomic) NSString *assessment;
@property (strong, nonatomic) NSNumber *note;
@property (strong, nonatomic) NSNumber *coefficent;
@property (strong, nonatomic) NSDate *creationDate;
@property (strong, nonatomic) NSDate *lastUpdateDate;
@property (strong, nonatomic) CloudiversityPeriod *period;
@property (strong, nonatomic) CloudiversityDiscipline *discipline;
@property (strong, nonatomic) CloudiversityStudent *student; // is nil if isForAllClass == YES
@property (strong, nonatomic) CloudiversityTeacher *teacher;
@property (strong, nonatomic) CloudiversityClass *schoolClass;

@end