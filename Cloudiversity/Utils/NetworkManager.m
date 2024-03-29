//
//  IOSRequest.m
//  Cloudiversity
//
//  Created by Rémy Marty on 04/02/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "NetworkManager.h"

@interface NetworkManager()

@property (nonatomic, strong)AFHTTPRequestOperationManager *AFManager;
@property (nonatomic, strong)NSMutableArray *delegates;

@end

@implementation NetworkManager

static NetworkManager *manager;

+ (instancetype)manager {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        manager = [[NetworkManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *path = [defaults objectForKey:@"server"];
        self.AFManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:path]];
        self.AFManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.AFManager.responseSerializer = [AFJSONResponseSerializer serializer];
        [self.AFManager.requestSerializer setValue:@"application/json"
                              forHTTPHeaderField:@"accept"];
        self.loggedIn = NO;
        self.AFManager.reachabilityManager = [AFNetworkReachabilityManager managerForDomain:[NSURL URLWithString:path].host];
        BSELF(self)
        [self.AFManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
            switch (status) {
                case AFNetworkReachabilityStatusNotReachable:
                case AFNetworkReachabilityStatusUnknown:
                    bself.connected = NO;
                    [bself.AFManager.operationQueue setSuspended:YES];
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    bself.connected = YES;
                    [bself.AFManager.operationQueue setSuspended:NO];
                    break;
            }
        }];
        [self.AFManager.reachabilityManager startMonitoring];
        self.delegates = [NSMutableArray array];
    }
    return self;
}

- (void)baseURLDidChange {
	manager = [[NetworkManager alloc] init];
}

#pragma mark - Reachability Management

- (void)startMonitoringReachability {
    [self.AFManager.reachabilityManager startMonitoring];
}

- (void)stopMonitoringReachability {
    [self.AFManager.reachabilityManager stopMonitoring];
}

#pragma mark - NetworkManagerDelegate

- (void)addDelegate:(id<NetworkManagerDelegate>)delegate {
    [self.delegates addObject:delegate];
}

- (void)removeDelegate:(id<NetworkManagerDelegate>)delegate {
    [self.delegates removeObject:delegate];
}

#pragma mark - HTTP requests method

- (void)requestPatchToPath:(NSString*)path
                withParams:(NSDictionary *)params
                 onSuccess:(HTTPSuccessHandler)success
                 onFailure:(HTTPFailureHandler)failure {
    if (self.loggedIn) {
        [self userInfo];
    }
	AFHTTPRequestOperation *operation = [self.AFManager PATCH:path parameters:params success:success failure:failure];
	[operation start];
}

- (void) requestGetToPath:(NSString *)path
			  withParams:(NSDictionary *)params
			   onSuccess:(HTTPSuccessHandler)success
			   onFailure:(HTTPFailureHandler)failure {

    if (self.loggedIn) {
        [self userInfo];
    }
    AFHTTPRequestOperation *operation = [self.AFManager GET:path parameters:params success:success failure:failure];
    [operation start];
}

- (void) requestPostToPath:(NSString *)path
                withParams:(NSDictionary *)params
                 onSuccess:(HTTPSuccessHandler)success
                 onFailure:(HTTPFailureHandler)failure {

    if (self.loggedIn) {
        [self userInfo];
    }
    AFHTTPRequestOperation *operation = [self.AFManager POST:path parameters:params success:success failure:failure];
    [operation start];
}

#pragma mark - HTTP request for logging in, getting current user info, authentcating server

- (void) loginWithId:(NSString *)userName
         andPassword:(NSString *)password
           onSuccess:(HTTPSuccessHandler)success
           onFailure:(HTTPFailureHandler)failure {

    NSDictionary * params = @{@"user[login]":userName,
                              @"user[password]":password};
    [self requestPostToPath:@"/users/sign_in" withParams:params onSuccess:success onFailure:failure];
}

- (void) isCloudiversityServerOnSuccess:(HTTPSuccessHandler)success
                              onFailure:(HTTPFailureHandler)failure {

    [self requestGetToPath:@"/version" withParams:nil onSuccess:success onFailure:failure];
}

- (void)getCurrentUserOnSuccess:(HTTPSuccessHandler)success
                      onFailure:(HTTPFailureHandler)failure {

    [self requestGetToPath:@"/users/current" withParams:nil onSuccess:success onFailure:failure];
}

#pragma mark - HTTP requests for Agenda

- (void)getAssignmentsForUserOnSuccess:(HTTPSuccessHandler)success
                             onFailure:(HTTPFailureHandler)failure {

    NSString *role = [NetworkManager role];
	NSString *path = [NSString stringWithFormat:@"/agenda%@", role];
	[self requestGetToPath:path withParams:nil onSuccess:success onFailure:failure];
}

- (void)getAssignmentsForClass:(NSInteger)classID
                 andDiscipline:(NSInteger)disciplineID
                     onSuccess:(HTTPSuccessHandler)success
                     onFailure:(HTTPFailureHandler)failure {

    NSString *role = [NetworkManager role];
	NSString *path = [NSString stringWithFormat:@"/agenda/assignments/teaching/%@/%@%@", @(disciplineID), @(classID), role];
	[self requestGetToPath:path withParams:nil onSuccess:success onFailure:failure];
}

- (void)getAssignmentInformation:(NSInteger)assignmentId
                       onSuccess:(HTTPSuccessHandler)success
                       onFailure:(HTTPFailureHandler)failure {

    NSString *role = [NetworkManager role];
	NSString *path = [NSString stringWithFormat:@"/agenda/assignments/%@%@", @(assignmentId), role];
	[self requestGetToPath:path withParams:nil onSuccess:success onFailure:failure];
}

- (void)updateAssignmentWithId:(NSInteger)assignmentId
               withProgression:(NSInteger)progress
                     onSuccess:(HTTPSuccessHandler)success
                     onFailure:(HTTPFailureHandler)failure {

    NSString *role = [NetworkManager role];
	NSString *path = [NSString stringWithFormat:@"/agenda/assignments/%@%@", @(assignmentId), role];
	NSDictionary *params = @{@"assignment": @{@"progress": @(progress)}};
	[self requestPatchToPath:path withParams:params onSuccess:success onFailure:failure];
}

- (void)postAssignmentWithAssignment:(AgendaAssignment *)assignment
                    withDisciplineID:(NSInteger)disciplineID
                         withClassID:(NSInteger)classID
                           onSuccess:(HTTPSuccessHandler)success
                           onFailure:(HTTPFailureHandler)failure {

    NSString *role = [NetworkManager role];
    NSString *path = [NSString stringWithFormat:@"/agenda/assignments/%@", role];
    NSMutableDictionary *params = [assignment parametersForHTTP];
    params[@"discipline_id"] = @(disciplineID);
    params[@"school_class_id"] = @(classID);
    [self requestPostToPath:path withParams:@{@"assignment" : params} onSuccess:success onFailure:failure];
}

- (void)patchAssignmentWithAssignment:(AgendaAssignment *)assignment
                     withDisciplineID:(NSInteger)disciplineID
                          withClassID:(NSInteger)classID
                            onSuccess:(HTTPSuccessHandler)success
                            onFailure:(HTTPFailureHandler)failure {

    NSString *role = [NetworkManager role];
    NSString *path = [NSString stringWithFormat:@"/agenda/assignments/%@%@", @(assignment.assignmentId), role];
    NSMutableDictionary *params = [assignment parametersForHTTP];
    params[@"discipline_id"] = @(disciplineID);
    params[@"school_class_id"] = @(classID);
    [self requestPatchToPath:path withParams:@{@"assignment" : params} onSuccess:success onFailure:failure];
}

#pragma mark - HTTP requests for Evealuation

- (void)getAssessmentsForUserOnSuccess:(HTTPSuccessHandler)success
							 onFailure:(HTTPFailureHandler)failure {

	NSString *role = [NetworkManager role];
	NSString *path = [NSString stringWithFormat:@"/evaluations/assessments%@", role];
	[self requestGetToPath:path withParams:nil onSuccess:success onFailure:failure];
}

- (void)getAssessmentInformation:(int)assessmentID
					   onSuccess:(HTTPSuccessHandler)success
					   onFailure:(HTTPFailureHandler)failure {

	NSString *role = [NetworkManager role];
	NSString *path = [NSString stringWithFormat:@"/evaluations/assessments/%d%@", assessmentID, role];
	[self requestGetToPath:path withParams:nil onSuccess:success onFailure:failure];
}

- (void)postAssessment:(NSString*)assessment
	  withDisciplineID:(int)disciplineID
		   withClassID:(int)classID
		  withPeriodID:(int)periodID
	  isClassAssesment:(BOOL)isClassAssessment
		 withStudentID:(int)studentID
			 onSuccess:(HTTPSuccessHandler)success
			 onFailure:(HTTPFailureHandler)failure {

	NSString *path = @"/evaluations/assessments";
	
    NSDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{@"grade_assessment" : @{@"assessment" : assessment,
                                                                                                     @"discipline_id" : @(disciplineID),
                                                                                                     @"school_class_id" : @(classID),
                                                                                                     @"period_id" : @(periodID),
                                                                                                     @"school_class_assessment" : @(isClassAssessment),
                                                                                                     @"student_id" : @(studentID)
                                                                                                     }
                                                                             }];
    [self requestPostToPath:path withParams:params onSuccess:success onFailure:failure];
}

- (void)updateAssessment:(int)assessmentID
		withInformations:(NSDictionary*)assessmentInfos
			   onSuccess:(HTTPSuccessHandler)success
			   onFailure:(HTTPFailureHandler)failure {

	NSString *path = [NSString stringWithFormat:@"/evaluations/assessments/%d", assessmentID];
	
	NSDictionary *params = @{@"grade_assessment": assessmentInfos};
	
	[self requestPatchToPath:path withParams:params onSuccess:success onFailure:failure];
}

- (void)getGradesForUserOnSuccess:(HTTPSuccessHandler)success
						onFailure:(HTTPFailureHandler)failure {

	NSString *role = [NetworkManager role];
	NSString *path = [NSString stringWithFormat:@"/evaluations/grades%@", role];
	[self requestGetToPath:path withParams:nil onSuccess:success onFailure:failure];
}

- (void)getGradeInformation:(int)gradeID
				  onSuccess:(HTTPSuccessHandler)success
				  onFailure:(HTTPFailureHandler)failure {

	NSString *role = [NetworkManager role];
	NSString *path = [NSString stringWithFormat:@"/evaluations/grades/%d%@", gradeID, role];
    [self requestGetToPath:path withParams:nil onSuccess:success onFailure:failure];
}

- (void)postGradeWithAssessment:(NSString*)assessment
					   withMark:(int)mark
					   withCoef:(int)coef
			   withDisciplineID:(int)disciplineID
					withClassID:(int)classID
				   withPeriodID:(int)periodID
				  withStudentID:(int)studentID
					  onSuccess:(HTTPSuccessHandler)success
					  onFailure:(HTTPFailureHandler)failure {

    NSString *path = @"/evaluations/grades";
	
    NSDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{@"grade_grade" : @{
                                                                                     @"assessment": assessment,
                                                                                     @"note": @(mark),
                                                                                     @"coefficient": @(coef),
                                                                                     @"discipline_id": @(disciplineID),
                                                                                     @"school_class_id": @(classID),
                                                                                     @"period_id": @(periodID),
                                                                                     @"student_id": @(studentID)
                                                                                     }
                                                                             }];
	[self requestPostToPath:path withParams:params onSuccess:success onFailure:failure];
}

- (void)updateGrade:(int)gradeID
   withInformations:(NSDictionary*)gradeInfos
		  onSuccess:(HTTPSuccessHandler)success
		  onFailure:(HTTPFailureHandler)failure {

    NSString *path = [NSString stringWithFormat:@"/evaluations/grades/%d", gradeID];
	
	NSDictionary *params = @{@"grade_grade": gradeInfos};
	
	[self requestPatchToPath:path withParams:params onSuccess:success onFailure:failure];
}


#pragma mark - Convenience Methods
+ (NSString *)role {
    NSString *role = @"";
    User *user = [User sharedUser];
    if (user.roles.count > 1) {
        role = [@"?as=" stringByAppendingString:[user.currentRole lowercaseString]];
    }
    return role;
}

- (void)userInfo {
    User *user = [User sharedUser];
    [self.AFManager.requestSerializer setValue:user.email forHTTPHeaderField:@"X-User-Email"];
    [self.AFManager.requestSerializer setValue:user.token forHTTPHeaderField:@"X-User-Token"];
}
@end
