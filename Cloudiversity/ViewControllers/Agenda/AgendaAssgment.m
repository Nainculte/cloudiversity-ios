//
//  AgendaAssgment.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 10/06/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AgendaAssgment.h"

@implementation AgendaAssgment

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
		self.percentageCompletion = 0.f;
		self.field = field;
		self.isMarked = isMarked;
		self.isExam = isExam;
		self.className = className;
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
		self.percentageCompletion = percentageCompletion;
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
		self.field = [aDecoder decodeObjectForKey:@"field"];
		self.className = [aDecoder decodeObjectForKey:@"className"];
		self.dueDate = [aDecoder decodeObjectForKey:@"dueDate"];
		self.isMarked = [aDecoder decodeBoolForKey:@"isMarked"];
		self.isExam = [aDecoder decodeBoolForKey:@"isExam"];
		self.percentageCompletion = [aDecoder decodeFloatForKey:@"percentageCompletion"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.title forKey:@"title"];
	[aCoder encodeObject:self.assigmentDescription forKey:@"assigmentDescription"];
	[aCoder encodeObject:self.field forKey:@"field"];
	[aCoder encodeObject:self.className forKey:@"className"];
	[aCoder encodeObject:self.dueDate forKey:@"dueDate"];
	[aCoder encodeBool:self.isMarked forKey:@"isMarked"];
	[aCoder encodeBool:self.isExam forKey:@"isExam"];
	[aCoder encodeFloat:self.percentageCompletion forKey:@"percentageCompletion"];
}

@end
