//
//  AgendaAssgment.h
//  Cloudiversity
//
//  Created by Anthony MERLE on 10/06/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AgendaAssgment : NSObject <NSCoding>

@property (strong, nonatomic) NSString	*title;
@property (strong, nonatomic) NSString	*assigmentDescription;
@property (strong, nonatomic) NSDate	*dueDate;
@property (strong, nonatomic) NSString	*field;
@property (strong, nonatomic) NSString	*className;
@property (nonatomic) BOOL	isMarked;
@property (nonatomic) BOOL	isExam;
@property (nonatomic) float	percentageCompletion;

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
