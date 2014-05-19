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

@end
