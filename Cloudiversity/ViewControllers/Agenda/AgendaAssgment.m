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
		self.description = description;
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
	
	return self;
}

@end
