//
//  IOSRequest.m
//  Cloudiversity
//
//  Created by Rémy Marty on 04/02/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "NetworkManager.h"
#import "User.h"

@interface NetworkManager()

@property (nonatomic, strong)AFHTTPRequestOperationManager *AFManager;

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

- (id)init {
    manager = [super init];
    if (manager) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *path = [defaults objectForKey:@"server"];
        manager.AFManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:path]];
        manager.AFManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.AFManager.responseSerializer = [AFJSONResponseSerializer serializer];
        [manager.AFManager.requestSerializer setValue:@"application/json"
                              forHTTPHeaderField:@"accept"];
        manager.loggedIn = NO;
    }
    return manager;
}

#pragma mark - HTTP requests method

- (void)requestPatchToPath:(NSString*)path
                withParams:(NSDictionary *)params
                 onSuccess:(HTTPSuccessHandler)success
                 onFailure:(HTTPFailureHandler)failure {
    if (manager.loggedIn) {
        [manager userInfo];
    }
	AFHTTPRequestOperation *operation = [manager.AFManager PATCH:path parameters:params success:success failure:failure];
	[operation start];
}

- (void) requestGetToPath:(NSString *)path
			  withParams:(NSDictionary *)params
			   onSuccess:(HTTPSuccessHandler)success
			   onFailure:(HTTPFailureHandler)failure {

    if (manager.loggedIn) {
        [manager userInfo];
    }
    AFHTTPRequestOperation *operation = [manager.AFManager GET:path parameters:params success:success failure:failure];
    [operation start];
}

- (void) requestPostToPath:(NSString *)path
                withParams:(NSDictionary *)params
                 onSuccess:(HTTPSuccessHandler)success
                 onFailure:(HTTPFailureHandler)failure {

    if (manager.loggedIn) {
        [manager userInfo];
    }
    AFHTTPRequestOperation *operation = [manager.AFManager POST:path parameters:params success:success failure:failure];
    [operation start];
}

#pragma mark - HTTP request for logging in, getting current user info, authentcating server

- (void) loginWithId:(NSString *)userName
         andPassword:(NSString *)password
           onSuccess:(HTTPSuccessHandler)success
           onFailure:(HTTPFailureHandler)failure {

    NSDictionary * params = @{@"user[login]":userName,
                              @"user[password]":password};
    [manager requestPostToPath:@"/users/sign_in" withParams:params onSuccess:success onFailure:failure];
}

- (void) isCloudiversityServerOnSuccess:(HTTPSuccessHandler)success
                              onFailure:(HTTPFailureHandler)failure {

    [manager requestGetToPath:@"/version" withParams:nil onSuccess:success onFailure:failure];
}

- (void)getCurrentUserOnSuccess:(HTTPSuccessHandler)success
                      onFailure:(HTTPFailureHandler)failure {

    [manager requestGetToPath:@"/users/current" withParams:nil onSuccess:success onFailure:failure];
}

#pragma mark - HTTP requests for Agenda

- (void)getAssignmentsForUserOnSuccess:(HTTPSuccessHandler)success
                             onFailure:(HTTPFailureHandler)failure {

    NSString *role = [NetworkManager role];
	NSString *path = [NSString stringWithFormat:@"/agenda%@", role];
	[manager requestGetToPath:path withParams:nil onSuccess:success onFailure:failure];
}

- (void)getAssignmentsForClass:(NSInteger)classID
                 andDiscipline:(NSInteger)disciplineID
                     onSuccess:(HTTPSuccessHandler)success
                     onFailure:(HTTPFailureHandler)failure {

    NSString *role = [NetworkManager role];
	NSString *path = [NSString stringWithFormat:@"/agenda/assignments/%@/%@%@", @(disciplineID), @(classID), role];
	[manager requestGetToPath:path withParams:nil onSuccess:success onFailure:failure];
}

- (void)getAssignmentInformation:(NSInteger)assignmentId
                       onSuccess:(HTTPSuccessHandler)success
                       onFailure:(HTTPFailureHandler)failure {

    NSString *role = [NetworkManager role];
	NSString *path = [NSString stringWithFormat:@"/agenda/assignments/%@%@", @(assignmentId), role];
	[manager requestGetToPath:path withParams:nil onSuccess:success onFailure:failure];
}

- (void)updateAssignmentWithId:(NSInteger)assignmentId
               withProgression:(NSInteger)progress
                     onSuccess:(HTTPSuccessHandler)success
                     onFailure:(HTTPFailureHandler)failure {

    NSString *role = [NetworkManager role];
	NSString *path = [NSString stringWithFormat:@"/agenda/assignments/%@%@", @(assignmentId), role];
	NSDictionary *params = @{@"assignment": @{@"progress": @(progress)}};
	[manager requestPatchToPath:path withParams:params onSuccess:success onFailure:failure];
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
    [manager requestPostToPath:path withParams:@{@"assignment" : params} onSuccess:success onFailure:failure];
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
    [manager requestPatchToPath:path withParams:@{@"assignment" : params} onSuccess:success onFailure:failure];
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
    [manager.AFManager.requestSerializer setValue:user.email forHTTPHeaderField:@"X-User-Email"];
    [manager.AFManager.requestSerializer setValue:user.token forHTTPHeaderField:@"X-User-Token"];
}
@end
