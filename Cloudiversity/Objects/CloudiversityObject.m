//
//  Object.m
//  Cloudiversity
//
//  Created by Rémy Marty on 05/02/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "CloudiversityObject.h"

@implementation CloudiversityObject

+ (instancetype)fromJSON:(id)json {
    [NSException raise:@"Forbidden call to abstract method" format:@"fromJSON must be invoked from a subclass of DomainObject."];
    return nil;
}

+ (NSArray *)fromJSONArray:(id)json {
    NSMutableArray *array = [NSMutableArray array];
    for (id jsonObject in json) {
        CloudiversityObject *object = [self fromJSON:jsonObject];
        if (object != nil) {
            [array addObject:object];
        }
    }
    return array;
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

@end

@implementation CloudiversityClass

+ (instancetype)fromJSON:(id)json {
	NSDictionary *jsonObject = (NSDictionary*)json;
	CloudiversityClass *newClass = [[CloudiversityClass alloc] init];
	
	newClass.classID = [jsonObject objectForKey:@"id"];
	newClass.name = [jsonObject objectForKey:@"name"];
	
	return newClass;
}

@end

@implementation CloudiversityDiscipline

+ (instancetype)fromJSON:(id)json {
	NSDictionary *jsonObject = (NSDictionary*)json;
	CloudiversityDiscipline *newDiscipline = [[CloudiversityDiscipline alloc] init];
	
	newDiscipline.disciplineID = [jsonObject objectForKey:@"id"];
	newDiscipline.name = [jsonObject objectForKey:@"name"];
	
	return newDiscipline;
}

//- (id)copyWithZone:(NSZone *)zone {
//	CloudiversityDiscipline *discipline = [[CloudiversityDiscipline alloc] init];
//	
//	discipline.disciplineID = self.disciplineID;
//	discipline.name = self.name;
//	
//	return discipline;
//}

@end

@implementation CloudiversityStudent

+ (instancetype)fromJSON:(id)json {
	NSDictionary *jsonObject = (NSDictionary*)json;
	CloudiversityStudent *newStudent = [[CloudiversityStudent alloc] init];
	
	newStudent.studentID = [jsonObject objectForKey:@"id"];
	newStudent.userID = [jsonObject objectForKey:@"user_id"];
	newStudent.login = [jsonObject objectForKey:@"login"];
	newStudent.name = [jsonObject objectForKey:@"name"];
	
	return newStudent;
}

@end

@implementation CloudiversityTeacher

+ (instancetype)fromJSON:(id)json {
	NSDictionary *jsonObject = (NSDictionary*)json;
	CloudiversityTeacher *newTeacher = [[CloudiversityTeacher alloc] init];
	
	newTeacher.teacherID = [jsonObject objectForKey:@"id"];
	newTeacher.userID = [jsonObject objectForKey:@"user_id"];
	newTeacher.login = [jsonObject objectForKey:@"login"];
	newTeacher.name = [jsonObject objectForKey:@"name"];
	
	return newTeacher;
}

@end