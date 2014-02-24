//
//  IOSRequest.m
//  Cloudiversity
//
//  Created by Rémy Marty on 04/02/2014.
//  Copyright (c) 2014 Rémy Marty. All rights reserved.
//

#import "IOSRequest.h"
#import "NSString+WebService.h"
#import "User.h"

@implementation IOSRequest

+(void) requestToPath:(NSString *)path onCompletion:(RequestCompletionHandler)complete
{
    NSOperationQueue *backgroundQueue = [[NSOperationQueue alloc] init];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:path]
                                                  cachePolicy:NSURLCacheStorageAllowedInMemoryOnly
                                            timeoutInterval:10];
    
[NSURLConnection sendAsynchronousRequest:request
                                   queue:backgroundQueue
                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                           if (complete) {
                              complete(result, error);
                           }
}];
}

+(void) loginWithId:(NSString *)userName
        andPassword:(NSString *)password
       onCompletion:(RequestUserCompletionHandler)complete {
    userName = [userName URLEncode];
    password = [password URLEncode];
    NSLog(@"On va préparer la requete");
    //TODO
    NSString *basePath = @"http://joox/tutorial/index.php";
    NSString *fullpath = [basePath stringByAppendingFormat:@"user_name=%@&password=%@", userName, password];
    [IOSRequest requestToPath:fullpath onCompletion:^(NSString *result, NSError *error) {
        if (error || [result isEqualToString:@""]) {
            //login failed
            NSLog(@"Login failed");
            complete(nil);
        } else {
             User *user = (User *)[User fromJSON:result];
            if (complete) {
                complete(user);
            }
        }
    }];
}

@end
