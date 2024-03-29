//
//  Object.h
//  Cloudiversity
//
//  Created by Rémy Marty on 05/02/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudiversityObject : NSObject <NSCopying>

+ (instancetype)fromJSON:(id)json;
+ (NSArray *)fromJSONArray:(id)json;

@end

@interface CloudiversityPeriod : CloudiversityObject

@property (strong, nonatomic) NSNumber *periodID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

+ (NSArray *)sortPeriods:(NSArray *)periods;

@end

@interface CloudiversityClass : CloudiversityObject

@property (strong, nonatomic)	NSNumber *classID;
@property (strong, nonatomic)	NSString *name;

@property (strong, nonatomic)	NSNumber *schoolClassId;
@property (strong, nonatomic)	NSString *schoolClassName;
@property (strong, nonatomic)	CloudiversityPeriod *period;

@end

@interface CloudiversityDiscipline : CloudiversityObject

@property (strong, nonatomic)	NSNumber *disciplineID;
@property (strong, nonatomic)	NSString *name;

@end

@interface CloudiversityStudent : CloudiversityObject

@property (strong, nonatomic)	NSNumber *studentID;
@property (strong, nonatomic)	NSNumber *userID;
@property (strong, nonatomic)	NSString *login;
@property (strong, nonatomic)	NSString *name;

@end

@interface CloudiversityTeacher : CloudiversityObject

@property (strong, nonatomic)	NSNumber *teacherID;
@property (strong, nonatomic)	NSNumber *userID;
@property (strong, nonatomic)	NSString *login;
@property (strong, nonatomic)	NSString *name;

@end
