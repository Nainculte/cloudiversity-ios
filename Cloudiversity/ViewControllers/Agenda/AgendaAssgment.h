//
//  AgendaAssgment.h
//  Cloudiversity
//
//  Created by Anthony MERLE on 10/06/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AgendaAssgment : NSObject <NSCoding>

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSDate *dueDate; // and time
@property (strong, nonatomic) NSDictionary *dissiplineInformation;
@property (strong, nonatomic) NSDictionary *classInformation;
@property (strong, nonatomic) NSString *assigmentDescription;
@property (strong, nonatomic) NSDate *creationDate;
@property (strong, nonatomic) NSDate *lastUpdate;
@property (nonatomic) int assigmentId;
@property (nonatomic) int progress;

// In prevention for filtering assigments
@property (nonatomic) BOOL	isMarked;
@property (nonatomic) BOOL	isExam;

// Creation of an Assigment with general informations
// For student
- (id)initWithTitle:(NSString*)title
			 withId:(int)assigmentId
			dueDate:(NSDate*)dueDate
		   progress:(int)progress
	  forDissipline:(NSDictionary*)dissipline;

// For teacher
- (id)initWithTitle:(NSString*)title
			 withId:(int)assigmentId
			dueDate:(NSDate*)dueDate
	  forDissipline:(NSDictionary*)dissipline
			inClass:(NSDictionary*)classInfo;

// Creation of an Assigment with detailed informations
// For teacher
- (id)initWithTitle:(NSString*)title
			 withId:(int)assigmentId
			dueTime:(NSDate*)dueTime
		description:(NSString*)description
   withCreationDate:(NSDate*)creationDate
	  andLastUpdate:(NSDate*)lastUpdate
	  forDissipline:(NSDictionary*)dissipline
			inClass:(NSDictionary*)classInfo;

// For student
- (id)initWithTitle:(NSString*)title
			 withId:(int)assigmentId
			dueTime:(NSDate*)dueTime
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
