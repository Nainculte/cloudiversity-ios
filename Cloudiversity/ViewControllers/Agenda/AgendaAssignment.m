//
//  AgendaAssignment.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 10/06/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AgendaAssignment.h"
#import "CloudDateConverter.h"

@implementation AgendaAssignment

// Creation of an Assignment with general informations
// For student
- (instancetype)initWithTitle:(NSString*)title
			 withId:(NSInteger)assignmentId
            dueDate:(NSDate*)dueDate
       timePrecised:(BOOL)timePrecised
		   progress:(NSInteger)progress
	  forDissipline:(NSDictionary*)dissipline {
	self = [super init];
	
	if (self) {
		self.title = title;
		self.assignmentId = assignmentId;
        self.dueDate = dueDate;
        self.timePrecised = timePrecised;
		self.progress = progress;
		self.dissiplineInformation = dissipline;
	}
	
	return self;
}

// For teacher
- (instancetype)initWithTitle:(NSString*)title
			 withId:(NSInteger)assignmentId
            dueDate:(NSDate*)dueDate
       timePrecised:(BOOL)timePrecised
	  forDissipline:(NSDictionary*)dissipline
			inClass:(NSDictionary*)classInfo {
	self = [super init];
	
	if (self) {
		self.title = title;
		self.assignmentId = assignmentId;
        self.dueDate = dueDate;
        self.timePrecised = timePrecised;
		self.dissiplineInformation = dissipline;
		self.classInformation = classInfo;
	}
	
	return self;
}

// Creation of an Assignment with detailed informations
// For teacher
- (instancetype)initWithTitle:(NSString*)title
			 withId:(NSInteger)assignmentId
            dueTime:(NSDate*)dueTime
       timePrecised:(BOOL)timePrecised
		description:(NSString*)description
   withCreationDate:(NSDate*)creationDate
	  andLastUpdate:(NSDate*)lastUpdate
	  forDissipline:(NSDictionary*)dissipline
			inClass:(NSDictionary*)classInfo {
	self = [super init];
	
	if (self) {
		self.title = title;
		self.assignmentId = assignmentId;
        self.dueDate = dueTime;
        self.timePrecised = timePrecised;
		self.assignmentDescription = description;
		self.creationDate = creationDate;
		self.lastUpdate = lastUpdate;
		self.dissiplineInformation = dissipline;
		self.classInformation = classInfo;
	}
	
	return self;
}

// For student
- (instancetype)initWithTitle:(NSString*)title
			 withId:(NSInteger)assignmentId
            dueTime:(NSDate*)dueTime
       timePrecised:(BOOL)timePrecised
		description:(NSString*)description
		andProgress:(NSInteger)progress {
	self = [super init];
	
	if (self) {
		self.title = title;
		self.assignmentId = assignmentId;
		self.dueDate = dueTime;
        self.timePrecised = timePrecised;
		self.assignmentDescription = description;
		self.progress = progress;
	}
	
	return self;
}

- (NSMutableDictionary *)parametersForHTTP {
    NSMutableDictionary *params;
    NSString *date = [[CloudDateConverter sharedMager] stringFromDate:self.dueDate];
    if (self.timePrecised) {
        NSString *time = [[CloudDateConverter sharedMager] stringFromTime:self.dueDate];
        params = [[NSMutableDictionary alloc] initWithDictionary:@{@"title" : self.title,
                                                                   @"deadline" : date,
                                                                   @"duetime" : time,
                                                                   @"wording" : self.assignmentDescription
                                                                   }];
    } else {
        params = [[NSMutableDictionary alloc] initWithDictionary:@{@"title" : self.title,
                                                                   @"deadline" : date,
                                                                   @"wording" : self.assignmentDescription
                                                                   }];
    }
    return params;
}

- (instancetype)initWithOther:(AgendaAssignment *)other {
    self = [super init];
    if (self) {
        self.title = other.title;
        self.assignmentDescription = other.assignmentDescription;
        self.dissiplineInformation = other.dissiplineInformation;
        self.classInformation = other.classInformation;
        self.dueDate = other.dueDate;
        self.timePrecised = other.timePrecised;
        self.creationDate = other.creationDate;
        self.lastUpdate = other.lastUpdate;
        self.progress = other.progress;
        self.assignmentId = other.assignmentId;
    }
    return self;
}

#pragma mark - NSCoding protocol implementation

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if(self) {
        //decode properties, other class vars
		self.title = [aDecoder decodeObjectForKey:@"title"];
		self.assignmentDescription = [aDecoder decodeObjectForKey:@"assignmentDescription"];
		self.dissiplineInformation = [aDecoder decodeObjectForKey:@"field"];
		self.classInformation = [aDecoder decodeObjectForKey:@"className"];
		self.dueDate = [aDecoder decodeObjectForKey:@"dueDate"];
        self.timePrecised = [[aDecoder decodeObjectForKey:@"timePrecised"] boolValue];
		self.creationDate = [aDecoder decodeObjectForKey:@"creationDate"];
		self.lastUpdate = [aDecoder decodeObjectForKey:@"lastUpdate"];
		self.progress = [aDecoder decodeIntForKey:@"percentageCompletion"];
		self.assignmentId = [aDecoder decodeIntForKey:@"assignmentId"];

		self.isMarked = [aDecoder decodeBoolForKey:@"isMarked"];
		self.isExam = [aDecoder decodeBoolForKey:@"isExam"];
	}
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.title forKey:@"title"];
	[aCoder encodeObject:self.assignmentDescription forKey:@"assignmentDescription"];
	[aCoder encodeObject:self.dissiplineInformation forKey:@"field"];
	[aCoder encodeObject:self.classInformation forKey:@"className"];
	[aCoder encodeObject:self.dueDate forKey:@"dueDate"];
    [aCoder encodeObject:@(self.timePrecised) forKey:@"timePrecised"];
	[aCoder encodeObject:self.lastUpdate forKey:@"lastUpdate"];
	[aCoder encodeObject:self.creationDate forKey:@"creationDate"];
	[aCoder encodeInteger:self.progress forKey:@"percentageCompletion"];
	[aCoder encodeInteger:self.assignmentId forKey:@"assignmentId"];

	[aCoder encodeBool:self.isMarked forKey:@"isMarked"];
	[aCoder encodeBool:self.isExam forKey:@"isExam"];
}

- (NSString*)debugDescription {
    return [NSString stringWithFormat:@"%@ <%p> : \n\ttitle => %@; id => %@, discipline's name => %@, discipline's id => %@, dueDate => %@; progress => %@", self.class, &self, self.title, @(self.assignmentId), (self.dissiplineInformation)[@"name"], @([(self.dissiplineInformation)[@"id"] integerValue]), self.dueDate, @(self.progress)];
}

@end
