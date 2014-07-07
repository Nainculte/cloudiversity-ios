//
//  AgendaAssgment.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 10/06/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AgendaAssgment.h"

@implementation AgendaAssgment

// Creation of an Assigment with general informations
// For student
- (id)initWithTitle:(NSString*)title
			 withId:(int)assigmentId
			dueDate:(NSDate*)dueDate
		   progress:(int)progress
	  forDissipline:(NSDictionary*)dissipline {
	self = [super init];
	
	if (self) {
		self.title = title;
		self.assigmentId = assigmentId;
		self.dueDate = dueDate;
		self.progress = progress;
		self.dissiplineInformation = dissipline;
	}
	
	return self;
}

// For teacher
- (id)initWithTitle:(NSString*)title
			 withId:(int)assigmentId
			dueDate:(NSDate*)dueDate
	  forDissipline:(NSDictionary*)dissipline
			inClass:(NSDictionary*)classInfo {
	self = [super init];
	
	if (self) {
		self.title = title;
		self.assigmentId = assigmentId;
		self.dueDate = dueDate;
		self.dissiplineInformation = dissipline;
		self.classInformation = classInfo;
	}
	
	return self;
}

// Creation of an Assigment with detailed informations
// For teacher
- (id)initWithTitle:(NSString*)title
			 withId:(int)assigmentId
			dueTime:(NSDate*)dueTime
		description:(NSString*)description
   withCreationDate:(NSDate*)creationDate
	  andLastUpdate:(NSDate*)lastUpdate
	  forDissipline:(NSDictionary*)dissipline
			inClass:(NSDictionary*)classInfo {
	self = [super init];
	
	if (self) {
		self.title = title;
		self.assigmentId = assigmentId;
		self.dueDate = dueTime;
		self.assigmentDescription = description;
		self.creationDate = creationDate;
		self.lastUpdate = lastUpdate;
		self.dissiplineInformation = dissipline;
		self.classInformation = classInfo;
	}
	
	return self;
}

// For student
- (id)initWithTitle:(NSString*)title
			 withId:(int)assigmentId
			dueTime:(NSDate*)dueTime
		description:(NSString*)description
		andProgress:(int)progress {
	self = [super init];
	
	if (self) {
		self.title = title;
		self.assigmentId = assigmentId;
		self.dueDate = dueTime;
		self.assigmentDescription = description;
		self.progress = progress;
	}
	
	return self;
}

#pragma mark - Old initializers for testing

- (id)initWithTitle:(NSString*)title
		description:(NSString*)description
			DueDate:(NSDate*)dueDate
			inField:(NSString*)field
		andIsMarked:(BOOL)isMarked
		   orAnExam:(BOOL)isExam
		   forClass:(NSString*)className {
	
	self = [super init];

	if (self) {
		self.title = title;
		self.assigmentDescription = description;
		self.dueDate = dueDate;
		self.progress = 0;
		self.dissiplineInformation = @{@"name": field};
		self.classInformation = @{@"name": className};
	}
	
	return self;
}

- (id)initWithTitle:(NSString *)title
		description:(NSString *)description
	DueDateByString:(NSString *)dueDateString
			inField:(NSString*)field
withPercentageOfCompletion:(float)percentageCompletion
		andIsMarked:(BOOL)isMarked
		   orAnExam:(BOOL)isExam
		   forClass:(NSString*)className {
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd"];

	self = [self initWithTitle:title
				   description:description
					   DueDate:[dateFormat dateFromString:dueDateString]
					   inField:field
				   andIsMarked:isMarked
					  orAnExam:isExam
					  forClass:className];
	if (self) {
		self.progress = percentageCompletion;
	}
	
	return self;
}

#pragma mark - NSCoding protocol implementation

-(id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if(self) {
        //decode properties, other class vars
		self.title = [aDecoder decodeObjectForKey:@"title"];
		self.assigmentDescription = [aDecoder decodeObjectForKey:@"assigmentDescription"];
		self.dissiplineInformation = [aDecoder decodeObjectForKey:@"field"];
		self.classInformation = [aDecoder decodeObjectForKey:@"className"];
		self.dueDate = [aDecoder decodeObjectForKey:@"dueDate"];
		self.creationDate = [aDecoder decodeObjectForKey:@"creationDate"];
		self.lastUpdate = [aDecoder decodeObjectForKey:@"lastUpdate"];
		self.progress = [aDecoder decodeIntForKey:@"percentageCompletion"];
		self.assigmentId = [aDecoder decodeIntForKey:@"assigmentId"];

		self.isMarked = [aDecoder decodeBoolForKey:@"isMarked"];
		self.isExam = [aDecoder decodeBoolForKey:@"isExam"];
	}
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.title forKey:@"title"];
	[aCoder encodeObject:self.assigmentDescription forKey:@"assigmentDescription"];
	[aCoder encodeObject:self.dissiplineInformation forKey:@"field"];
	[aCoder encodeObject:self.classInformation forKey:@"className"];
	[aCoder encodeObject:self.dueDate forKey:@"dueDate"];
	[aCoder encodeObject:self.lastUpdate forKey:@"lastUpdate"];
	[aCoder encodeObject:self.creationDate forKey:@"creationDate"];
	[aCoder encodeInt:self.progress forKey:@"percentageCompletion"];
	[aCoder encodeInt:self.assigmentId forKey:@"assigmentId"];

	[aCoder encodeBool:self.isMarked forKey:@"isMarked"];
	[aCoder encodeBool:self.isExam forKey:@"isExam"];
}

@end
