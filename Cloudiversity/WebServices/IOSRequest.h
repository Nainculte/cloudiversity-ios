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

typedef void (^HTTPSuccessHandler)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^HTTPFailureHandler)(AFHTTPRequestOperation *operation, NSError *error);

@interface IOSRequest : NSObject

@property (nonatomic, strong) NSDictionary *user;

+(void)requestToPath:(NSString *)path
          withParams:(NSDictionary *)params
           onSuccess:(HTTPSuccessHandler)success
           onFailure:(HTTPFailureHandler)failure;

+(void)loginWithId:(NSString *)userName
       andPassword:(NSString *)password
         onSuccess:(HTTPSuccessHandler)success
         onFailure:(HTTPFailureHandler)failure;
@end
