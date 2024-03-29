//
//  IOSRequest.h
//  Cloudiversity
//
//  Created by Rémy Marty on 04/02/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "User.h"
#import "AgendaAssignment.h"

#define LOCALIZEDHTTPERROR(error) [[NSBundle mainBundle] localizedStringForKey:error value:@"Localization error" table:@"HTTPErrors"]

typedef void (^HTTPSuccessHandler)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^HTTPFailureHandler)(AFHTTPRequestOperation *operation, NSError *error);

@protocol NetworkManagerDelegate

- (void)internetReachable;
- (void)internetUnreachable;

@end

@interface NetworkManager : NSObject

- (void)baseURLDidChange;

@property (nonatomic, assign)BOOL loggedIn;
@property (nonatomic, assign, getter=isConnected)BOOL connected;

+ (instancetype)manager;

#pragma mark - NetworkManagerDelegate

- (void)addDelegate:(id<NetworkManagerDelegate>)delegate;
- (void)removeDelegate:(id<NetworkManagerDelegate>)delegate;

#pragma mark - Reachability Management
- (void)startMonitoringReachability;
- (void)stopMonitoringReachability;

#pragma mark - HTTP requests method

- (void)requestPatchToPath:(NSString*)path
                withParams:(NSDictionary *)params
                 onSuccess:(HTTPSuccessHandler)success
                 onFailure:(HTTPFailureHandler)failure;

- (void) requestGetToPath:(NSString *)path
               withParams:(NSDictionary *)params
                onSuccess:(HTTPSuccessHandler)success
                onFailure:(HTTPFailureHandler)failure;

- (void) requestPostToPath:(NSString *)path
				withParams:(NSDictionary *)params
				 onSuccess:(HTTPSuccessHandler)success
				 onFailure:(HTTPFailureHandler)failure;

#pragma mark - HTTP request for logging in, getting current user info, authentcating server

- (void)loginWithId:(NSString *)userName
        andPassword:(NSString *)password
          onSuccess:(HTTPSuccessHandler)success
          onFailure:(HTTPFailureHandler)failure;

- (void)isCloudiversityServerOnSuccess:(HTTPSuccessHandler)success
                             onFailure:(HTTPFailureHandler)failure;

- (void)getCurrentUserOnSuccess:(HTTPSuccessHandler)success
                      onFailure:(HTTPFailureHandler)failure;

#pragma mark - HTTP requests for Agenda

- (void)getAssignmentsForUserOnSuccess:(HTTPSuccessHandler)success
                             onFailure:(HTTPFailureHandler)failure;

- (void)getAssignmentsForClass:(NSInteger)classID
                 andDiscipline:(NSInteger)disciplineID
                     onSuccess:(HTTPSuccessHandler)success
                     onFailure:(HTTPFailureHandler)failure;

- (void)getAssignmentInformation:(NSInteger)assignmentId
                       onSuccess:(HTTPSuccessHandler)success
                       onFailure:(HTTPFailureHandler)failure;

- (void)updateAssignmentWithId:(NSInteger)assignmentId
               withProgression:(NSInteger)progress
                     onSuccess:(HTTPSuccessHandler)success
                     onFailure:(HTTPFailureHandler)failure;

- (void)postAssignmentWithAssignment:(AgendaAssignment *)assignment
                    withDisciplineID:(NSInteger)disciplineID
                         withClassID:(NSInteger)classID
                           onSuccess:(HTTPSuccessHandler)success
                           onFailure:(HTTPFailureHandler)failure;

- (void)patchAssignmentWithAssignment:(AgendaAssignment *)assignment
                     withDisciplineID:(NSInteger)disciplineID
                          withClassID:(NSInteger)classID
                            onSuccess:(HTTPSuccessHandler)success
                            onFailure:(HTTPFailureHandler)failure;

#pragma mark - HTTP requests for Evaluation

- (void)getAssessmentsForUserOnSuccess:(HTTPSuccessHandler)success
							 onFailure:(HTTPFailureHandler)failure;

- (void)getAssessmentInformation:(int)assessmentID
					   onSuccess:(HTTPSuccessHandler)success
					   onFailure:(HTTPFailureHandler)failure;

- (void)postAssessment:(NSString*)assessment
	  withDisciplineID:(int)disciplineID
		   withClassID:(int)classID
		  withPeriodID:(int)periodID
	  isClassAssesment:(BOOL)isClassAssessment
		 withStudentID:(int)studentID
			 onSuccess:(HTTPSuccessHandler)success
			 onFailure:(HTTPFailureHandler)failure;

- (void)updateAssessment:(int)assessmentID
		withInformations:(NSDictionary*)assessmentInfos
			   onSuccess:(HTTPSuccessHandler)success
			   onFailure:(HTTPFailureHandler)failure;

- (void)getGradesForUserOnSuccess:(HTTPSuccessHandler)success
						onFailure:(HTTPFailureHandler)failure;

- (void)getGradeInformation:(int)gradeID
				  onSuccess:(HTTPSuccessHandler)success
				  onFailure:(HTTPFailureHandler)failure;

- (void)postGradeWithAssessment:(NSString*)assessment
					   withMark:(int)mark
					   withCoef:(int)coef
			   withDisciplineID:(int)disciplineID
					withClassID:(int)classID
				   withPeriodID:(int)periodID
				  withStudentID:(int)studentID
					  onSuccess:(HTTPSuccessHandler)success
					  onFailure:(HTTPFailureHandler)failure;

- (void)updateGrade:(int)gradeID
   withInformations:(NSDictionary*)gradeInfos
		  onSuccess:(HTTPSuccessHandler)success
		  onFailure:(HTTPFailureHandler)failure;


@end
