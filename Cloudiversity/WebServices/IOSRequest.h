//
//  IOSRequest.h
//  Cloudiversity
//
//  Created by Rémy Marty on 04/02/2014.
//  Copyright (c) 2014 Rémy Marty. All rights reserved.
//

#import "User.h"
#import <Foundation/Foundation.h>

typedef void(^RequestCompletionHandler)(NSData *, NSError *);
typedef void(^RequestUserCompletionHandler)(id);

@interface IOSRequest : NSObject

@property (nonatomic, strong) NSDictionary *user;

+(void)requestToPath:(NSString *)path withParams:(NSString *)params onCompletion:(RequestCompletionHandler)complete;

+(void)loginWithId:(NSString *)userName
       andPassword:(NSString *)password
      onCompletion:(RequestUserCompletionHandler)complete;
@end
