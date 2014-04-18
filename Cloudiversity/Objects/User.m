//
//  User.m
//  Cloudiversity
//
//  Created by Rémy Marty on 05/02/2014.
//  Copyright (c) 2014 Rémy Marty. All rights reserved.
//

#import "User.h"

@implementation User

+ (User *)fromJSON:(id)json {
    if (json == (id)[NSNull null]) {
        return nil;
    }
    User *user = [[User alloc] init];
    user.uid = [json valueForKey:@"id"];
    user.firstName = [json valueForKey:@"firstName"];
    user.lastName = [json valueForKey:@"lastName"];
    user.email = [json valueForKey:@"email"];
    return user;
}

+ (User *)withName:(NSString *)name lastName:(NSString *)lastName andEmail:(NSString *)email {
    User *user = [[User alloc] init];
    user.firstName = name;
    user.lastName = lastName;
    user.email = email;
    return user;
}

@end
