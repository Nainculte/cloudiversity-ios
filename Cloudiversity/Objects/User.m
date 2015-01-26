//
//  User.m
//  Cloudiversity
//
//  Created by Rémy Marty on 05/02/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "User.h"
#import "CloudKeyChainManager.h"

NSString *const UserRoleTeacher = @"Teacher";
NSString *const UserRoleStudent = @"Student";
NSString *const UserRoleAdmin = @"Admin";

@interface User()

@end

#define LOCALIZEDSTRING(s) [[NSBundle mainBundle] localizedStringForKey:s value:@"Localization error" table:@"NavigationVC"]

@implementation User

static User *user;

+ (User *)sharedUser {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        user = [User fromUserDefaults];
    });
    return user;
}

+ (User *)withEmail:(NSString *)email andToken:(NSString *)token {
    user = [[User alloc] init];
    user.email = email;
    user.token = token;
    return user;
}

+ (User *)fromUserDefaults {
    user = [[User alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    user.firstName = [userDefaults objectForKey:@"firstname"];
    user.lastName = [userDefaults objectForKey:@"lastname"];
    user.email = [userDefaults objectForKey:@"email"];
    user.roles = [userDefaults objectForKey:@"roles"];
    user.currentRole = [userDefaults objectForKey:@"currentRole"];
	user.userId = [userDefaults objectForKey:@"id"];
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
    [userDefaults setObject:self.currentRole forKey:@"currentRole"];
	[userDefaults setObject:self.userId forKey:@"id"];
    [userDefaults synchronize];
}

- (void)deleteUser {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"firstname"];
    [userDefaults removeObjectForKey:@"lastname"];
    [userDefaults removeObjectForKey:@"email"];
    [userDefaults removeObjectForKey:@"roles"];
    [userDefaults removeObjectForKey:@"currentRole"];
	[userDefaults removeObjectForKey:@"id"];
    [userDefaults synchronize];
}

- (NSArray *)localizedRoles {
    if (!_localizedRoles) {
        NSMutableArray *a = [NSMutableArray array];
        for (NSString *role in self.roles) {
            NSString *s = [NSString stringWithFormat:@"ROLE_%@", role.uppercaseString];
            [a addObject:LOCALIZEDSTRING(s)];
        }
        _localizedRoles = [NSArray arrayWithArray:a];
    }
    return _localizedRoles;
}

@end
