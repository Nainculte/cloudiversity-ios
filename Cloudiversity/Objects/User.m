//
//  User.m
//  Cloudiversity
//
//  Created by Rémy Marty on 05/02/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "User.h"
#import "CloudKeyChainManager.h"

@interface User()

@end

@implementation User

+ (User *)sharedUser {
    static User *user = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        user = [User fromUserDefaults];
    });
    return user;
}

+ (User *)withEmail:(NSString *)email andToken:(NSString *)token {
    User *user = [[User alloc] init];
    user.email = email;
    user.token = token;
    return user;
}

+ (User *)fromUserDefaults {
    User *user = [[User alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    user.firstName = [userDefaults objectForKey:@"firstname"];
    user.lastName = [userDefaults objectForKey:@"lastname"];
    user.email = [userDefaults objectForKey:@"email"];
    user.roles = [userDefaults objectForKey:@"roles"];
    if (!user.email) {
        return nil;
    }
    user.token = [CloudKeychainManager retrieveTokenWithEmail:user.email];
    return user;
}

- (void)saveUser {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.firstName forKey:@"firstname"];
    [userDefaults setObject:self.lastName forKey:@"lastname"];
    [userDefaults setObject:self.email forKey:@"email"];
    [userDefaults setObject:self.roles forKey:@"roles"];
    [userDefaults synchronize];
}

- (void)deleteUser {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"firstname"];
    [userDefaults removeObjectForKey:@"lastname"];
    [userDefaults removeObjectForKey:@"email"];
    [userDefaults removeObjectForKey:@"roles"];
    [userDefaults synchronize];
}

@end
