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

#define LOCALIZEDHTTPERROR(error) [[NSBundle mainBundle] localizedStringForKey:error value:@"Localization error" table:@"HTTPErrors"]

typedef void (^HTTPSuccessHandler)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^HTTPFailureHandler)(AFHTTPRequestOperation *operation, NSError *error);

@interface IOSRequest : NSObject

@property (nonatomic, strong) NSDictionary *user;

#pragma mark - HTTP request for loging in

+ (void)loginWithId:(NSString *)userName
        andPassword:(NSString *)password
          onSuccess:(HTTPSuccessHandler)success
          onFailure:(HTTPFailureHandler)failure;

+ (void)isCloudiversityServer:(NSString *)server
                    onSuccess:(HTTPSuccessHandler)success
                    onFailure:(HTTPFailureHandler)failure;

+ (void)getCurrentUserOnSuccess:(HTTPSuccessHandler)success
                      onFailure:(HTTPFailureHandler)failure;

#pragma mark - HTTP requests for Agenda

#pragma GET Requests

+(void) requestGetToPath:(NSString *)path
			  withParams:(NSDictionary *)params
			   onSuccess:(HTTPSuccessHandler)success
			   onFailure:(HTTPFailureHandler)failure;

+(void)getAssignmentsForUserOnSuccess:(HTTPSuccessHandler)success
                           onFailure:(HTTPFailureHandler)failure;

+(void)getAssignmentInformation:(int)assignmentId
					 onSuccess:(HTTPSuccessHandler)success
					 onFailure:(HTTPFailureHandler)failure;

#pragma Updating Progress Requests

+(void)requestPatchToPath:(NSString*)path
			   withParams:(NSDictionary *)params
				onSuccess:(HTTPSuccessHandler)success
				onFailure:(HTTPFailureHandler)failure;

+(void)updateAssignmentWithId:(int)assignmentId
			  withProgression:(int)progress
					onSuccess:(HTTPSuccessHandler)success
					onFailure:(HTTPFailureHandler)failure;

@end
