//
//  User.m
//  Cloudiversity
//
//  Created by Rémy Marty on 05/02/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "User.h"

@interface User()

@property (nonatomic, strong)User *singleton;

@end

@implementation User

+ (User *)withName:(NSString *)name lastName:(NSString *)lastName andEmail:(NSString *)email {
    User *user = [[User alloc] init];
    user.firstName = name;
    user.lastName = lastName;
    user.email = email;
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
    if (!user.email) {
        return nil;
    }
    return user;
}

- (void)saveUser {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.firstName forKey:@"firstname"];
    [userDefaults setObject:self.lastName forKey:@"lastname"];
    [userDefaults setObject:self.email forKey:@"email"];
    [userDefaults synchronize];
}

- (void)deleteUser {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"firstname"];
    [userDefaults removeObjectForKey:@"lastname"];
    [userDefaults removeObjectForKey:@"email"];
    [userDefaults synchronize];
}

@end
