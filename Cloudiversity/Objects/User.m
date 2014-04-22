//
//  User.m
//  Cloudiversity
//
//  Created by Rémy Marty on 05/02/2014.
//  Copyright (c) 2014 Rémy Marty. All rights reserved.
//

#import "User.h"

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

@end
