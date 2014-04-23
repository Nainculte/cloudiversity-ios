//
//  IOSRequest.m
//  Cloudiversity
//
//  Created by Rémy Marty on 04/02/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "IOSRequest.h"
#import "NSString+WebService.h"
#import "User.h"

@implementation IOSRequest

+(void) requestToPath:(NSString *)path withParams:(NSString *)params onCompletion:(RequestCompletionHandler)complete
{
    NSOperationQueue *backgroundQueue = [[NSOperationQueue alloc] init];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:path]
                                                                cachePolicy:NSURLCacheStorageAllowedInMemoryOnly
                                                            timeoutInterval:10];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:[NSString stringWithFormat:@"%d", [params length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:backgroundQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (complete) {
                                   complete(data, error);
                               }
                           }];
}

+(void) loginWithId:(NSString *)userName
        andPassword:(NSString *)password
       onCompletion:(RequestUserCompletionHandler)complete {
    userName = [userName URLEncode];
    password = [password URLEncode];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *path = [defaults objectForKey:@"server"];
    path = [NSString stringWithFormat:@"%@/users/sign_in", path];
    NSString *params = [NSString stringWithFormat:@"user[login]=%@&user[password]=%@", userName, password];
    [IOSRequest requestToPath:path withParams:params onCompletion:^(NSData *result, NSError *error) {
        if (!result) {
            complete(@"No internet Connection");
            return ;
        }
        NSError *err;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:result
                                                               options:NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers
                                                                 error:&err];
        if ([json valueForKey:@"error"]) {
            complete([json valueForKey:@"error"]);
        } else if (error) {
            complete(error);
        } else {
            User *user = [User withEmail:[json objectForKey:@"email"] andToken:[json objectForKey:@"token"]];
            complete(user);
        }
    }];
}

@end
