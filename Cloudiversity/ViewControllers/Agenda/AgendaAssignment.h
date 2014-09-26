//
//  AgendaAssignment.h
//  Cloudiversity
//
//  Created by Anthony MERLE on 10/06/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AgendaAssignment : NSObject <NSCoding>

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSDate *dueDate; // and time
@property (strong, nonatomic) NSDictionary *dissiplineInformation;
@property (strong, nonatomic) NSDictionary *classInformation;
@property (strong, nonatomic) NSString *assignmentDescription;
@property (strong, nonatomic) NSDate *creationDate;
@property (strong, nonatomic) NSDate *lastUpdate;
@property (nonatomic) int assignmentId;
@property (nonatomic) int progress;
@property (nonatomic) bool timePrecised;

// In prevention for filtering assignments
@property (nonatomic) BOOL	isMarked;
@property (nonatomic) BOOL	isExam;

// Creation of an Assignment with general informations
// For student
- (id)initWithTitle:(NSString*)title
			 withId:(int)assignmentId
			dueDate:(NSDate*)dueDate
       timePrecised:(BOOL)timePrecised
		   progress:(int)progress
	  forDissipline:(NSDictionary*)dissipline;

// For teacher
- (id)initWithTitle:(NSString*)title
			 withId:(int)assignmentId
            dueDate:(NSDate*)dueDate
       timePrecised:(BOOL)timePrecised
	  forDissipline:(NSDictionary*)dissipline
			inClass:(NSDictionary*)classInfo;

// Creation of an Assignment with detailed informations
// For teacher
- (id)initWithTitle:(NSString*)title
			 withId:(int)assignmentId
            dueTime:(NSDate*)dueTime
       timePrecised:(BOOL)timePrecised
		description:(NSString*)description
   withCreationDate:(NSDate*)creationDate
	  andLastUpdate:(NSDate*)lastUpdate
	  forDissipline:(NSDictionary*)dissipline
			inClass:(NSDictionary*)classInfo;

// For student
- (id)initWithTitle:(NSString*)title
			 withId:(int)assignmentId
            dueTime:(NSDate*)dueTime
       timePrecised:(BOOL)timePrecised
		description:(NSString*)description
		andProgress:(int)progress;

#pragma mark - Old initializers for testing

- (id)initWithTitle:(NSString*)title
		description:(NSString*)description
			DueDate:(NSDate*)dueDate
			inField:(NSString*)field
		andIsMarked:(BOOL)isMarked
		   orAnExam:(BOOL)isExam
		   forClass:(NSString*)className;

- (id)initWithTitle:(NSString*)title
		description:(NSString*)description
	DueDateByString:(NSString*)dueDateString
			inField:(NSString*)field
withPercentageOfCompletion:(float)percentageCompletion
		andIsMarked:(BOOL)isMarked
		   orAnExam:(BOOL)isExam
		   forClass:(NSString*)className;

#pragma mark - NSCoding protocol implemantation

-(id)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;

@end
