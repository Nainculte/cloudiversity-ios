//
//  IOSRequest.m
//  Cloudiversity
//
//  Created by Rémy Marty on 04/02/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "IOSRequest.h"
#import "User.h"

#import "UIActivityIndicatorView+AFNetworking.h"

@implementation IOSRequest

#pragma mark - HTTP requests method

+(void)requestPatchToPath:(NSString*)path
			   withParams:(NSDictionary *)params
				onSuccess:(HTTPSuccessHandler)success
				onFailure:(HTTPFailureHandler)failure {
	User *user = [User sharedUser];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"accept"];
    [manager.requestSerializer setValue:user.email forHTTPHeaderField:@"X-User-Email"];
    [manager.requestSerializer setValue:user.token forHTTPHeaderField:@"X-User-Token"];
	AFHTTPRequestOperation *operation = [manager PATCH:path parameters:params success:success failure:failure];
	[operation start];
}

+(void) requestGetToPath:(NSString *)path
			  withParams:(NSDictionary *)params
			   onSuccess:(HTTPSuccessHandler)success
			   onFailure:(HTTPFailureHandler)failure {

    User *user = [User sharedUser];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"accept"];
    [manager.requestSerializer setValue:user.email forHTTPHeaderField:@"X-User-Email"];
    [manager.requestSerializer setValue:user.token forHTTPHeaderField:@"X-User-Token"];
    AFHTTPRequestOperation *operation = [manager GET:path parameters:params success:success failure:failure];
    [operation start];
}

#pragma mark - HTTP request for logging in, getting current user info, authentcating server

+(void) loginWithId:(NSString *)userName
        andPassword:(NSString *)password
          onSuccess:(HTTPSuccessHandler)success
          onFailure:(HTTPFailureHandler)failure {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *path = [defaults objectForKey:@"server"];
    path = [NSString stringWithFormat:@"%@/users/sign_in", path];
    NSDictionary * params = @{@"user[login]":userName,
                              @"user[password]":password};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json"
                     forHTTPHeaderField:@"accept"];
    AFHTTPRequestOperation *operation = [manager POST:path
                                           parameters:params
                                              success:success
                                              failure:failure];
    [operation start];
}

+ (void) isCloudiversityServer:(NSString *)server
                     onSuccess:(HTTPSuccessHandler)success
                     onFailure:(HTTPFailureHandler)failure {

    NSString *path = [NSString stringWithFormat:@"%@/version", server];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json"
                     forHTTPHeaderField:@"accept"];
    AFHTTPRequestOperation *operation = [manager GET:path
                                          parameters:nil
                                             success:success
                                             failure:failure];
    [operation start];
}

+ (void)getCurrentUserOnSuccess:(HTTPSuccessHandler)success
                      onFailure:(HTTPFailureHandler)failure {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *path = [NSString stringWithFormat:@"%@/users/current",
                      [defaults objectForKey:@"server"]];
    [IOSRequest requestGetToPath:path withParams:nil onSuccess:success onFailure:failure];
}

#pragma mark - HTTP requests for Agenda

+(void)getAssignmentsForUserOnSuccess:(HTTPSuccessHandler)success
                           onFailure:(HTTPFailureHandler)failure {
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *path = [defaults objectForKey:@"server"];
    NSString *role = @"";
    User *user = [User sharedUser];
	if (user.roles.count > 1) {
		role = [@"?as=" stringByAppendingString:[user.currentRole lowercaseString]];
	}
	path = [NSString stringWithFormat:@"%@/agenda%@", path, role];
	[IOSRequest requestGetToPath:path withParams:nil onSuccess:success onFailure:failure];
}

+ (void)getAssignmentsForClass:(int)classID
                 andDiscipline:(int)disciplineID
                     onSuccess:(HTTPSuccessHandler)success
                     onFailure:(HTTPFailureHandler)failure {

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *path = [defaults objectForKey:@"server"];
    NSString *role = @"";
    User *user = [User sharedUser];
	if (user.roles.count > 1) {
		role = [@"?as=" stringByAppendingString:[user.currentRole lowercaseString]];
	}
	path = [NSString stringWithFormat:@"%@/agenda/assignments/%d/%d%@", path, disciplineID, classID, role];
	[IOSRequest requestGetToPath:path withParams:nil onSuccess:success onFailure:failure];
}

+(void)getAssignmentInformation:(int)assignmentId
					 onSuccess:(HTTPSuccessHandler)success
					 onFailure:(HTTPFailureHandler)failure {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *path = [defaults objectForKey:@"server"];
    NSString *role = @"";
    User *user = [User sharedUser];
	if (user.roles.count > 1) {
		role = [@"?as=" stringByAppendingString:[user.currentRole lowercaseString]];
	}
	path = [NSString stringWithFormat:@"%@/agenda/assignments/%d%@", path, assignmentId, role];
	[IOSRequest requestGetToPath:path withParams:nil onSuccess:success onFailure:failure];
}

+(void)updateAssignmentWithId:(int)assignmentId
			  withProgression:(int)progress
					onSuccess:(HTTPSuccessHandler)success
					onFailure:(HTTPFailureHandler)failure {
	NSUserDefaults *uDefaults = [NSUserDefaults standardUserDefaults];
	NSString *path = [uDefaults objectForKey:@"server"];
    NSString *role = @"";
    User *user = [User sharedUser];
	if (user.roles.count > 1) {
		role = [@"?as=" stringByAppendingString:[user.currentRole lowercaseString]];
	}
	path = [NSString stringWithFormat:@"%@/agenda/assignments/%d%@", path, assignmentId, role];
	
	NSDictionary *params = @{@"assignment": @{@"progress": [NSNumber numberWithInt:progress]}};
	
	[IOSRequest requestPatchToPath:path withParams:params onSuccess:success onFailure:failure];
}

@end
