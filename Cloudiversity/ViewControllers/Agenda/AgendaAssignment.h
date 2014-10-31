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
@property (nonatomic, assign) NSInteger assignmentId;
@property (nonatomic, assign) NSInteger progress;
@property (nonatomic, assign) bool timePrecised;

// In prevention for filtering assignments
@property (nonatomic) BOOL	isMarked;
@property (nonatomic) BOOL	isExam;

// Creation of an Assignment with general informations
// For student
- (instancetype)initWithTitle:(NSString*)title
			 withId:(NSInteger)assignmentId
			dueDate:(NSDate*)dueDate
       timePrecised:(BOOL)timePrecised
		   progress:(NSInteger)progress
	  forDissipline:(NSDictionary*)dissipline;

// For teacher
- (instancetype)initWithTitle:(NSString*)title
			 withId:(NSInteger)assignmentId
            dueDate:(NSDate*)dueDate
       timePrecised:(BOOL)timePrecised
	  forDissipline:(NSDictionary*)dissipline
			inClass:(NSDictionary*)classInfo;

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
			inClass:(NSDictionary*)classInfo;

// For student
- (instancetype)initWithTitle:(NSString*)title
			 withId:(NSInteger)assignmentId
            dueTime:(NSDate*)dueTime
       timePrecised:(BOOL)timePrecised
		description:(NSString*)description
		andProgress:(NSInteger)progress;

#pragma mark - Old initializers for testing

- (instancetype)initWithTitle:(NSString*)title
		description:(NSString*)description
			DueDate:(NSDate*)dueDate
			inField:(NSString*)field
		andIsMarked:(BOOL)isMarked
		   orAnExam:(BOOL)isExam
		   forClass:(NSString*)className;

- (instancetype)initWithTitle:(NSString*)title
		description:(NSString*)description
	DueDateByString:(NSString*)dueDateString
			inField:(NSString*)field
withPercentageOfCompletion:(float)percentageCompletion
		andIsMarked:(BOOL)isMarked
		   orAnExam:(BOOL)isExam
		   forClass:(NSString*)className;

#pragma mark - NSCoding protocol implemantation

-(instancetype)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;

@end
