//
//  IOSRequest.m
//  Cloudiversity
//
//  Created by Rémy Marty on 04/02/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "IOSRequest.h"
#import "User.h"

@implementation IOSRequest

#pragma mark - Basic HTTP requests

+(void) requestToPath:(NSString *)path
           withParams:(NSDictionary *)params
            onSuccess:(HTTPSuccessHandler)success
            onFailure:(HTTPFailureHandler)failure {

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"accept"];
    AFHTTPRequestOperation *operation = [manager POST:path parameters:params success:success failure:failure];
    [operation start];
}

+(void) requestGetToPath:(NSString *)path
			  withParams:(NSDictionary *)params
			   onSuccess:(HTTPSuccessHandler)success
			   onFailure:(HTTPFailureHandler)failure {
	
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"accept"];
    AFHTTPRequestOperation *operation = [manager GET:path parameters:params success:success failure:failure];
    [operation start];
}

#pragma mark - HTTP request for loging in

+(void) loginWithId:(NSString *)userName
        andPassword:(NSString *)password
          onSuccess:(HTTPSuccessHandler)success
          onFailure:(HTTPFailureHandler)failure {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *path = [defaults objectForKey:@"server"];
    path = [NSString stringWithFormat:@"%@/users/sign_in", path];
    NSDictionary * params = @{@"user[login]": userName, @"user[password]": password};
    [IOSRequest requestToPath:path withParams:params onSuccess:success onFailure:failure];
}

#pragma mark - HTTP requests for Agenda

+(void)getAssigmentsForUserAsRole:(NSString *)role
						onSuccess:(HTTPSuccessHandler)success
						onFailure:(HTTPFailureHandler)failure {
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *path = [defaults objectForKey:@"server"];
	if (role && [role length] != 0) {
		role = [@"?as=" stringByAppendingString:role];
	} else {
		role = @"";
	}
	path = [NSString stringWithFormat:@"%@/agenda%@", path, role];
	[IOSRequest requestGetToPath:path withParams:nil onSuccess:success onFailure:failure];
}

@end
